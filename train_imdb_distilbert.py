import argparse
from pathlib import Path

import inspect
import numpy as np
import pandas as pd
import torch
from datasets import Dataset, load_dataset
from sklearn.metrics import accuracy_score, f1_score
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    Trainer,
    TrainingArguments,
)


def _load_from_csv(csv_path: Path, test_size: float, seed: int):
    df = pd.read_csv(csv_path)
    if "review" not in df.columns or "sentiment" not in df.columns:
        raise ValueError(
            "CSV must contain 'review' and 'sentiment' columns (sentiment values: positive/negative)."
        )
    label_map = {"negative": 0, "positive": 1}
    df["label"] = df["sentiment"].map(label_map)
    if df["label"].isna().any():
        bad = df[df["label"].isna()]["sentiment"].unique()
        raise ValueError(f"Unexpected sentiment values in CSV: {bad}")
    df = df.rename(columns={"review": "text"})
    ds = Dataset.from_pandas(df[["text", "label"]])
    split = ds.train_test_split(test_size=test_size, seed=seed, shuffle=True)
    return split["train"], split["test"]


def _load_from_hf(seed: int):
    raw = load_dataset("imdb")
    train_ds = raw["train"].shuffle(seed=seed)
    test_ds = raw["test"].shuffle(seed=seed)
    return train_ds, test_ds


def _maybe_subset(ds, max_samples: int | None):
    if max_samples is None:
        return ds
    max_samples = min(max_samples, len(ds))
    return ds.select(range(max_samples))


def _tokenize(tokenizer, max_length: int):
    def _fn(batch):
        return tokenizer(
            batch["text"],
            truncation=True,
            padding="max_length",
            max_length=max_length,
        )

    return _fn


def _compute_metrics(eval_pred):
    logits, labels = eval_pred
    preds = np.argmax(logits, axis=1)
    return {
        "accuracy": accuracy_score(labels, preds),
        "f1": f1_score(labels, preds),
    }


def main():
    parser = argparse.ArgumentParser(
        description="Train a DistilBERT IMDB sentiment model and save weights locally."
    )
    parser.add_argument(
        "--output-dir",
        default=(
            Path(__file__).resolve().parent
            / "Sentiment-Analysis-Engine-for-Movie-Reviews-main"
            / "sentimentModel"
            / "distilbert_imdb_model"
        ),
        type=Path,
    )
    parser.add_argument("--dataset-csv", type=Path, default=None)
    parser.add_argument("--test-size", type=float, default=0.2)
    parser.add_argument("--epochs", type=int, default=2)
    parser.add_argument("--train-batch", type=int, default=8)
    parser.add_argument("--eval-batch", type=int, default=16)
    parser.add_argument("--max-length", type=int, default=256)
    parser.add_argument("--train-samples", type=int, default=None)
    parser.add_argument("--eval-samples", type=int, default=None)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument(
        "--base-model",
        default="distilbert-base-uncased",
        help="Base model to fine-tune.",
    )
    args = parser.parse_args()

    if args.dataset_csv is not None and not args.dataset_csv.exists():
        raise FileNotFoundError(f"CSV not found: {args.dataset_csv}")

    torch.manual_seed(args.seed)

    if args.dataset_csv is not None:
        train_ds, test_ds = _load_from_csv(args.dataset_csv, args.test_size, args.seed)
    else:
        train_ds, test_ds = _load_from_hf(args.seed)

    train_ds = _maybe_subset(train_ds, args.train_samples)
    test_ds = _maybe_subset(test_ds, args.eval_samples)

    tokenizer = AutoTokenizer.from_pretrained(args.base_model)
    tokenized_train = train_ds.map(
        _tokenize(tokenizer, args.max_length),
        batched=True,
        remove_columns=[col for col in train_ds.column_names if col not in {"label"}],
    )
    tokenized_test = test_ds.map(
        _tokenize(tokenizer, args.max_length),
        batched=True,
        remove_columns=[col for col in test_ds.column_names if col not in {"label"}],
    )
    tokenized_train.set_format("torch")
    tokenized_test.set_format("torch")

    model = AutoModelForSequenceClassification.from_pretrained(
        args.base_model, num_labels=2
    )

    args.output_dir.mkdir(parents=True, exist_ok=True)
    ta_kwargs = {
        "output_dir": str(args.output_dir),
        "save_strategy": "epoch",
        "learning_rate": 2e-5,
        "per_device_train_batch_size": args.train_batch,
        "per_device_eval_batch_size": args.eval_batch,
        "num_train_epochs": args.epochs,
        "weight_decay": 0.01,
        "load_best_model_at_end": True,
        "metric_for_best_model": "f1",
        "report_to": "none",
        "logging_steps": 100,
        "save_total_limit": 1,
        "seed": args.seed,
    }
    ta_params = inspect.signature(TrainingArguments.__init__).parameters
    if "evaluation_strategy" in ta_params:
        ta_kwargs["evaluation_strategy"] = "epoch"
    else:
        ta_kwargs["eval_strategy"] = "epoch"

    training_args = TrainingArguments(**ta_kwargs)

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_train,
        eval_dataset=tokenized_test,
        tokenizer=tokenizer,
        compute_metrics=_compute_metrics,
    )

    trainer.train()
    trainer.save_model(str(args.output_dir))
    tokenizer.save_pretrained(str(args.output_dir))


if __name__ == "__main__":
    main()
