import 'package:flutter/material.dart';

class ModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double borderRadius;
  final double elevation;
  final bool enableHoverEffect;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradientColors,
    this.borderRadius = 24,
    this.elevation = 0,
    this.enableHoverEffect = true,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (widget.enableHoverEffect) {
      _controller.forward();
    }
  }

  void _onHoverExit() {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _shadowAnimation,
              builder: (context, child) {
                return Container(
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: widget.elevation + _shadowAnimation.value,
                        offset: Offset(0, _shadowAnimation.value / 2),
                      ),
                      if (widget.enableHoverEffect)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: widget.elevation + _shadowAnimation.value,
                        ),
                    ],
                  ),
                  child: widget.child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Shimmer loading card
class ShimmerCard extends StatefulWidget {
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.borderRadius = 24,
    this.margin,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2D3748) : const Color(0xFFF3F4F6);
    final highlightColor =
        isDark ? const Color(0xFF4A5568) : const Color(0xFFE5E7EB);

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: baseColor,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: [
                  _controller.value - 0.3,
                  _controller.value,
                  _controller.value + 0.3,
                ].map((e) => e.clamp(0, 1).toDouble()).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

