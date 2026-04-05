import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/sentiment_result.dart';
import '../services/supabase_service.dart';

class AnalysisHistoryItem {
  final int id;
  final String userId;
  final SentimentResult result;
  final DateTime createdAt;

  AnalysisHistoryItem({
    required this.id,
    required this.userId,
    required this.result,
    required this.createdAt,
  });

  factory AnalysisHistoryItem.fromMap(Map<String, dynamic> map) {
    final raw = map['result_json'];
    final parsed = raw is String
        ? jsonDecode(raw) as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return AnalysisHistoryItem(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      result: SentimentResult.fromJson(parsed),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class HistoryProvider extends ChangeNotifier {
  String? _userId;
  bool _loading = false;
  List<AnalysisHistoryItem> _items = [];

  List<SentimentResult> get history =>
      _items.map((item) => item.result).toList(growable: false);
  List<AnalysisHistoryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;

  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _items = [];
    if (userId == null) {
      notifyListeners();
      return;
    }
    load();
  }

  Future<void> load() async {
    final userId = _userId;
    if (userId == null) return;
    _loading = true;
    notifyListeners();
    final rows = await SupabaseService.client
        .from('analysis_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    _items = rows
        .map<AnalysisHistoryItem>((row) => AnalysisHistoryItem.fromMap(row))
        .toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> addToHistory(SentimentResult result) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now().toIso8601String();
    await SupabaseService.client.from('analysis_history').insert({
      'user_id': userId,
      'result_json': result.toJson(),
      'created_at': now,
      'updated_at': now,
    });
    await load();
  }

  Future<void> deleteById(int id) async {
    await SupabaseService.client.from('analysis_history').delete().eq('id', id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> deleteAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    await deleteById(_items[index].id);
  }
}
