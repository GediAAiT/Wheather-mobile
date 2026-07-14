import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass panel with a subtle glowing gradient border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color glow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 24,
    this.glow = const Color(0xFF7DD3FC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            glow.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.08),
            const Color(0xFFF2B441).withValues(alpha: 0.25),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.10),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius - 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  const Color(0xFF141A3C).withValues(alpha: 0.45),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
