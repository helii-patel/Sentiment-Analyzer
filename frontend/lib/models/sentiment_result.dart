class SentimentResult {
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;
  final List<IndividualResult> results;

  SentimentResult({
    required this.positiveCount,
    required this.negativeCount,
    required this.neutralCount,
    required this.results,
  });

  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    return SentimentResult(
      positiveCount: json['positive_count'],
      negativeCount: json['negative_count'],
      neutralCount: json['neutral_count'],
      results: (json['results'] as List)
          .map((item) => IndividualResult.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'neutral_count': neutralCount,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}

class IndividualResult {
  final String text;
  final String sentiment;
  final double confidence;

  IndividualResult({
    required this.text,
    required this.sentiment,
    required this.confidence,
  });

  factory IndividualResult.fromJson(Map<String, dynamic> json) {
    return IndividualResult(
      text: json['text'],
      sentiment: json['sentiment'],
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sentiment': sentiment,
      'confidence': confidence,
    };
  }
}
