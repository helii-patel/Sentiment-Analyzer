from pathlib import Path

from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

_MODEL_DIR = (
    Path(__file__)
    .resolve()
    .parents[3]
    / "Sentiment-Analysis-Engine-for-Movie-Reviews-main"
    / "sentimentModel"
    / "distilbert_imdb_model"
)

_WEIGHT_FILES = (
    list(_MODEL_DIR.glob("*.bin"))
    + list(_MODEL_DIR.glob("*.safetensors"))
    + list(_MODEL_DIR.glob("*.pt"))
)

if not _MODEL_DIR.exists():
    raise RuntimeError(
        f"Local model directory not found: {_MODEL_DIR}. "
        "Expected the repo 'Sentiment-Analysis-Engine-for-Movie-Reviews-main' "
        "to be copied into the 'sentiment-analyzer' root."
    )

if not _WEIGHT_FILES:
    raise RuntimeError(
        f"No model weights found in {_MODEL_DIR}. "
        "Place the fine-tuned weights file (e.g., pytorch_model.bin or model.safetensors) "
        "in that directory."
    )

_tokenizer = AutoTokenizer.from_pretrained(_MODEL_DIR)
_model = AutoModelForSequenceClassification.from_pretrained(_MODEL_DIR)
_model.eval()

classifier = pipeline(
    "sentiment-analysis",
    model=_model,
    tokenizer=_tokenizer
)

def analyze_texts(texts: list[str]):
    results = []
    positive_count = 0
    negative_count = 0
    neutral_count = 0

    for text in texts:
        if not text.strip():
            continue  # Skip empty texts
        result = classifier(text)[0]
        label = result["label"]
        confidence = float(result["score"])

        # Map labels: DistilBERT IMDB model typically returns LABEL_0/1.
        if label in {"LABEL_0", "NEGATIVE"}:
            sentiment = "NEGATIVE"
            negative_count += 1
        elif label in {"LABEL_1", "POSITIVE"}:
            sentiment = "POSITIVE"
            positive_count += 1
        else:
            sentiment = "NEUTRAL"
            neutral_count += 1

        results.append({
            "text": text,
            "sentiment": sentiment,
            "confidence": confidence
        })

    return {
        "positive_count": positive_count,
        "negative_count": negative_count,
        "neutral_count": neutral_count,
        "results": results
    }
