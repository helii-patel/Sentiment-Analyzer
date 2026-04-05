import 'package:flutter/material.dart';
import '../models/saved_review.dart';
import '../services/supabase_service.dart';

enum ReviewSort { newest, oldest, title }

class ReviewProvider extends ChangeNotifier {
  String? _userId;
  bool _loading = false;
  List<SavedReview> _items = [];
  String _query = '';
  ReviewSort _sort = ReviewSort.newest;

  ReviewProvider();

  bool get isLoading => _loading;
  List<SavedReview> get items => _filteredItems();
  ReviewSort get sort => _sort;
  String get query => _query;

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
        .from('saved_reviews')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    _items = rows.map<SavedReview>((row) => SavedReview.fromMap(row)).toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(SavedReview review) async {
    await SupabaseService.client.from('saved_reviews').insert(review.toInsertMap());
    await load();
  }

  Future<void> update(SavedReview review) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('Please login again.');
    }
    final rows = await SupabaseService.client
        .from('saved_reviews')
        .update(review.toUpdateMap())
        .eq('id', review.id)
        .eq('user_id', userId)
        .select('id');
    if (rows.isEmpty) {
      throw Exception('Update failed: review not found or permission denied.');
    }
    await load();
  }

  Future<void> delete(int id) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('Please login again.');
    }
    final rows = await SupabaseService.client
        .from('saved_reviews')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .select('id');
    if (rows.isEmpty) {
      throw Exception('Delete failed: review not found or permission denied.');
    }
    await load();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setSort(ReviewSort value) {
    _sort = value;
    notifyListeners();
  }

  List<SavedReview> _filteredItems() {
    var result = _items;
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      result = result
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              (r.note ?? '').toLowerCase().contains(q))
          .toList();
    }
    switch (_sort) {
      case ReviewSort.oldest:
        result.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case ReviewSort.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case ReviewSort.newest:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    return result;
  }
}
