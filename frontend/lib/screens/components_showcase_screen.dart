import 'package:flutter/material.dart';
import '../widgets/flow_button.dart';
import '../widgets/action_button.dart';
import '../widgets/modern_card.dart';

/// Showcase screen demonstrating all animated components
/// Use this as reference for implementing components in your app
class ComponentsShowcaseScreen extends StatefulWidget {
  const ComponentsShowcaseScreen({super.key});

  @override
  State<ComponentsShowcaseScreen> createState() =>
      _ComponentsShowcaseScreenState();
}

class _ComponentsShowcaseScreenState extends State<ComponentsShowcaseScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Components Showcase'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FlowButton Section
            _buildSectionTitle('FlowButton - Circular Gradient Buttons'),
            const SizedBox(height: 16),
            _buildFlowButtonSection(),
            const SizedBox(height: 40),

            // 2. AnimatedFlowButton Section
            _buildSectionTitle('AnimatedFlowButton - Full-width Buttons'),
            const SizedBox(height: 16),
            _buildAnimatedFlowButtonSection(),
            const SizedBox(height: 40),

            // 3. ActionButton Section
            _buildSectionTitle('ActionButton - Compact Buttons'),
            const SizedBox(height: 16),
            _buildActionButtonSection(),
            const SizedBox(height: 40),

            // 4. ModernCard Section
            _buildSectionTitle('ModernCard - Elevated Cards'),
            const SizedBox(height: 16),
            _buildModernCardSection(),
            const SizedBox(height: 40),

            // 5. Color Palette
            _buildSectionTitle('Color Palette'),
            const SizedBox(height: 16),
            _buildColorPalette(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFlowButtonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Circular gradient buttons with smooth animations',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          // Blue - Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFlowButtonExample(
                label: 'Share',
                icon: Icons.share_rounded,
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.7),
                  const Color(0xFF1D4ED8),
                ],
              ),
              _buildFlowButtonExample(
                label: 'Delete',
                icon: Icons.delete_outline_rounded,
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.7),
                  const Color(0xFFDC2626),
                ],
              ),
              _buildFlowButtonExample(
                label: 'Save',
                icon: Icons.check_circle_outline_rounded,
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.7),
                  const Color(0xFF059669),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFlowButtonExample(
                label: 'Settings',
                icon: Icons.settings_rounded,
                colors: [
                  const Color(0xFF667EEA).withValues(alpha: 0.7),
                  const Color(0xFF764BA2),
                ],
              ),
              _buildFlowButtonExample(
                label: 'Edit',
                icon: Icons.edit_rounded,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                  const Color(0xFF6D28D9),
                ],
                isLoading: _isLoading,
              ),
              _buildFlowButtonExample(
                label: 'Download',
                icon: Icons.download_rounded,
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.7),
                  const Color(0xFFD97706),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = !_isLoading;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
              ),
              child: Text(
                _isLoading ? 'Loading...' : 'Toggle Loading State',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowButtonExample({
    required String label,
    required IconData icon,
    required List<Color> colors,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        FlowButton(
          icon: icon,
          size: 50,
          gradientColors: colors,
          isLoading: isLoading,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label pressed!')),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAnimatedFlowButtonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Large buttons with labels and gradients',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AnimatedFlowButton(
              icon: Icons.analytics_rounded,
              label: 'Analyze Sentiment',
              gradientColors: const [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analyzing sentiment...')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AnimatedFlowButton(
              icon: Icons.check_rounded,
              label: 'Confirm Action',
              gradientColors: const [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action confirmed!')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AnimatedFlowButton(
              icon: Icons.delete_rounded,
              label: 'Delete Analysis',
              gradientColors: const [
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compact inline action buttons',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onPressed: () {},
              ),
              ActionButton(
                icon: Icons.delete_rounded,
                label: 'Delete',
                onPressed: () {},
              ),
              ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onPressed: () {},
              ),
              ActionButton(
                icon: Icons.download_rounded,
                label: 'Export',
                onPressed: () {},
              ),
              ActionButton(
                icon: Icons.visibility_rounded,
                label: 'View',
                onPressed: () {},
              ),
              ActionButton(
                icon: Icons.bookmark_rounded,
                label: 'Save',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCardSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cards with hover effects (hover to see animation)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ModernCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card 1 tapped!')),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.show_chart_rounded,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '156 Reviews Analyzed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Analysis #1',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ModernCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card 2 tapped!')),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '89% Positive Sentiment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Based on latest analysis',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      ('Blue', [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]),
      ('Green', [const Color(0xFF10B981), const Color(0xFF059669)]),
      ('Red', [const Color(0xFFEF4444), const Color(0xFFDC2626)]),
      ('Purple', [const Color(0xFF667EEA), const Color(0xFF764BA2)]),
      ('Indigo', [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]),
      ('Amber', [const Color(0xFFF59E0B), const Color(0xFFD97706)]),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color scheme for gradients',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors
                .map(
                  (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: item.$2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

