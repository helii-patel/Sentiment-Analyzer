import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_review.dart';
import '../providers/review_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_card.dart';
import 'saved_review_detail_screen.dart';

class SavedReviewsScreen extends StatelessWidget {
  const SavedReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: const Text(
              'Saved Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<ReviewSort>(
                icon: const Icon(Icons.sort_rounded,
                    color: Colors.white, size: 28),
                onSelected: (value) =>
                    context.read<ReviewProvider>().setSort(value),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: ReviewSort.newest,
                    child: Text('Newest'),
                  ),
                  PopupMenuItem(
                    value: ReviewSort.oldest,
                    child: Text('Oldest'),
                  ),
                  PopupMenuItem(
                    value: ReviewSort.title,
                    child: Text('Title'),
                  ),
                ],
              ),
            ],
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Search, edit, and manage your saved analysis results',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = provider.items;
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.bookmark_border_rounded,
                    title: 'No saved reviews yet',
                    subtitle: 'Save results from the analysis screen to see them here',
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: provider.setQuery,
                        decoration: InputDecoration(
                          hintText: 'Search saved reviews...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _SavedReviewTile(review: item);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedReviewTile extends StatelessWidget {
  final SavedReview review;

  const _SavedReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final total = review.result.positiveCount +
        review.result.negativeCount +
        review.result.neutralCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SavedReviewDetailScreen(review: review),
            ),
          );
        },
        child: Dismissible(
          key: ValueKey(review.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
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
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            if (!context.mounted) return;
            try {
              await context.read<ReviewProvider>().delete(review.id);
              if (context.mounted) {
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
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (review.note != null && review.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    review.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _badge('Pos ${review.result.positiveCount}',
                        const Color(0xFFD1FAE5), const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _badge('Neg ${review.result.negativeCount}',
                        const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    _badge('Neu ${review.result.neutralCount}',
                        const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
                    const Spacer(),
                    Text(
                      '$total reviews',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

