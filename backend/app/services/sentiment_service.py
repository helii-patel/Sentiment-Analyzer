from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

_analyzer = SentimentIntensityAnalyzer()


def _classify(compound_score: float) -> str:
    if compound_score >= 0.05:
        return "POSITIVE"
    if compound_score <= -0.05:
        return "NEGATIVE"
    return "NEUTRAL"


def analyze_texts(texts: list[str]):
    results = []
    positive_count = 0
    negative_count = 0
    neutral_count = 0

    for text in texts:
        cleaned = text.strip()
        if not cleaned:
            continue

        scores = _analyzer.polarity_scores(cleaned)
        compound = float(scores.get("compound", 0.0))
        sentiment = _classify(compound)
        confidence = abs(compound)

        if sentiment == "POSITIVE":
            positive_count += 1
        elif sentiment == "NEGATIVE":
            negative_count += 1
        else:
            neutral_count += 1

        results.append(
            {
                "text": cleaned,
                "sentiment": sentiment,
                "confidence": confidence,
            }
        )

    return {
        "positive_count": positive_count,
        "negative_count": negative_count,
        "neutral_count": neutral_count,
        "results": results,
    }
