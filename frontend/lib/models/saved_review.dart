import 'dart:convert';

import 'sentiment_result.dart';

class SavedReview {
  final int id;
  final String userId;
  final String title;
  final String? note;
  final SentimentResult result;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedReview({
    required this.id,
    required this.userId,
    required this.title,
    required this.note,
    required this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedReview.fromMap(Map<String, dynamic> map) {
    return SavedReview(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      result: SentimentResult.fromJson(
        map['result_json'] is String
            ? jsonDecode(map['result_json'] as String) as Map<String, dynamic>
            : (map['result_json'] as Map<String, dynamic>),
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'title': title,
      'note': note,
      'result_json': result.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'note': note,
      'result_json': result.toJson(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
