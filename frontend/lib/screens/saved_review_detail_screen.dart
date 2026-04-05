import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_review.dart';
import '../providers/navigation_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/figma_bottom_nav.dart';

class SavedReviewDetailScreen extends StatelessWidget {
  final SavedReview review;

  const SavedReviewDetailScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final total = review.result.positiveCount +
        review.result.negativeCount +
        review.result.neutralCount;

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Saved Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: 'Edit',
                onPressed: () => _showEditDialog(context, review),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.white),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, review),
              ),
            ],
            subtitle: Text(
              review.title,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (review.note != null && review.note!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        review.note!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _countCard(
                          'Positive',
                          review.result.positiveCount,
                          const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _countCard(
                          'Negative',
                          review.result.negativeCount,
                          const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _countCard('Neutral', review.result.neutralCount,
                      const Color(0xFFF59E0B)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights_rounded,
                            color: Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        Text(
                          '$total reviews analyzed',
                          style: const TextStyle(
                              color: Color(0xFF4338CA),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Detailed Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...review.result.results.map((item) {
                    final color = item.sentiment == 'POSITIVE'
                        ? Colors.green
                        : item.sentiment == 'NEGATIVE'
                            ? Colors.red
                            : Colors.orange;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item.sentiment == 'POSITIVE'
                                    ? Icons.sentiment_satisfied_rounded
                                    : item.sentiment == 'NEGATIVE'
                                        ? Icons
                                            .sentiment_dissatisfied_rounded
                                        : Icons.sentiment_neutral_rounded,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.sentiment,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(item.confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(color: color),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item.text),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FigmaBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          context.read<NavigationProvider>().setIndex(index);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        items: const [
          FigmaBottomNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          FigmaBottomNavItem(icon: Icons.analytics_rounded, label: 'Analyze'),
          FigmaBottomNavItem(icon: Icons.history_rounded, label: 'History'),
          FigmaBottomNavItem(icon: Icons.bookmark_rounded, label: 'Saved'),
          FigmaBottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _countCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SavedReview review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete saved review?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      if (!context.mounted) return;
      try {
        await context.read<ReviewProvider>().delete(review.id);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved review deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, SavedReview review) async {
    final titleController = TextEditingController(text: review.title);
    final noteController = TextEditingController(text: review.note ?? '');
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit saved review'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated == true) {
      final updatedReview = SavedReview(
        id: review.id,
        userId: review.userId,
        title: titleController.text.trim(),
        note: noteController.text.trim(),
        result: review.result,
        createdAt: review.createdAt,
        updatedAt: DateTime.now(),
      );
      if (!context.mounted) return;
      try {
        await context.read<ReviewProvider>().update(updatedReview);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved review updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
}

