import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/sentiment_result.dart';
import '../providers/history_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_card.dart';
import '../widgets/flow_button.dart';
import '../widgets/theme_mode_switcher.dart';
import 'result_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0F172A), Color(0xFF111827), Color(0xFF0B1220)]
                : const [Color(0xFFF8FAFF), Color(0xFFF1F5FF), Color(0xFFFDF2F8)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, historyProvider, child) {
                  if (historyProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final history = historyProvider.history;
                  if (history.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No analysis history yet',
                      subtitle: 'Your analyzed reviews will appear here',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildTrendsChart(context, history),
                      const SizedBox(height: 28),
                      Text(
                        'Past Analyses (${history.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...history.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final total = item.positiveCount + item.negativeCount + item.neutralCount;

                        return AnimatedCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(result: item),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF111827) : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.show_chart_rounded, color: Color(0xFF10B981), size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$total Reviews Analyzed",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            "Analysis #${history.length - index}",
                                            style: TextStyle(
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FlowButton(
                                          icon: Icons.share_rounded,
                                          size: 40,
                                          tooltip: 'Share analysis',
                                          gradientColors: [
                                            const Color(0xFF3B82F6).withValues(alpha: 0.8),
                                            const Color(0xFF1D4ED8),
                                          ],
                                          onPressed: () {
                                            _shareAnalysis(context, item, total);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        FlowButton(
                                          icon: Icons.delete_outline_rounded,
                                          size: 40,
                                          tooltip: 'Delete analysis',
                                          gradientColors: [
                                            const Color(0xFFEF4444).withValues(alpha: 0.85),
                                            const Color(0xFFDC2626),
                                          ],
                                          onPressed: () => _confirmDelete(context, index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    _StatItem(label: 'Total', value: total.toString(), color: const Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    _StatItem(label: 'Positive', value: item.positiveCount.toString(), color: const Color(0xFF10B981)),
                                    const SizedBox(width: 8),
                                    _StatItem(label: 'Negative', value: item.negativeCount.toString(), color: const Color(0xFFEF4444)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sentiment Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFCBD5F5) : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildProgressBar(item.positiveCount / (total > 0 ? total : 1)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const GradientHeader(
      actions: [ThemeModeSwitcher()],
      title: Text(
        'Analysis History',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTrendsChart(BuildContext context, List history) {
    if (history.isEmpty) return const SizedBox();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sentiment Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: history.asMap().entries.map((e) {
                  final total = e.value.positiveCount + e.value.negativeCount + e.value.neutralCount;
                  final positive = total == 0 ? 0 : e.value.positiveCount.toDouble();
                  final negative = total == 0 ? 0 : e.value.negativeCount.toDouble();
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: positive,
                        color: const Color(0xFF10B981),
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: negative,
                        color: const Color(0xFFEF4444),
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Color(0xFF10B981), label: 'Positive'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFEF4444), label: 'Negative'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        widthFactor: percentage,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Future<void> _shareAnalysis(
    BuildContext context,
    SentimentResult item,
    int total,
  ) async {
    final lines = item.results
        .map<String>((result) => '${result.sentiment}: ${result.text}')
        .toList();
    final text = [
      'SentimentPro Analysis',
      'Total: $total',
      'Positive: ${item.positiveCount}',
      'Negative: ${item.negativeCount}',
      'Neutral: ${item.neutralCount}',
      '',
      ...lines,
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis copied to clipboard')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete analysis?'),
        content: const Text('This will delete the analysis from the database.'),
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

    if (shouldDelete != true || !context.mounted) return;

    try {
      await context.read<HistoryProvider>().deleteAt(index);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete from database')),
        );
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

