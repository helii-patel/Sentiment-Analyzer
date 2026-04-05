import os
from pathlib import Path

from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

_DEFAULT_MODEL_DIR = (
    Path(__file__)
    .resolve()
    .parents[3]
    / "Sentiment-Analysis-Engine-for-Movie-Reviews-main"
    / "sentimentModel"
    / "distilbert_imdb_model"
)
_MODEL_DIR = Path(os.getenv("MODEL_DIR", str(_DEFAULT_MODEL_DIR))).expanduser()
_MODEL_ID = os.getenv(
    "MODEL_ID",
    "sshleifer/tiny-distilbert-base-uncased-finetuned-sst-2-english",
).strip()

_WEIGHT_FILES = (
    list(_MODEL_DIR.glob("*.bin"))
    + list(_MODEL_DIR.glob("*.safetensors"))
    + list(_MODEL_DIR.glob("*.pt"))
)

_classifier = None


def _get_classifier():
    global _classifier
    if _classifier is not None:
        return _classifier

    use_local_model = _MODEL_DIR.exists() and bool(_WEIGHT_FILES)
    if use_local_model:
        tokenizer = AutoTokenizer.from_pretrained(_MODEL_DIR)
        model = AutoModelForSequenceClassification.from_pretrained(_MODEL_DIR)
    else:
        # Low-memory fallback for free-tier deployments.
        tokenizer = AutoTokenizer.from_pretrained(_MODEL_ID)
        model = AutoModelForSequenceClassification.from_pretrained(_MODEL_ID)

    model.eval()
    _classifier = pipeline(
        "sentiment-analysis",
        model=model,
        tokenizer=tokenizer,
        device=-1,
    )
    return _classifier

def analyze_texts(texts: list[str]):
    classifier = _get_classifier()
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
