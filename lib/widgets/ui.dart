import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Staggered entrance: fades + floats a child in after [delay] ms.
class Entrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final double dy;

  const Entrance({super.key, required this.child, this.delay = 0, this.dy = 26});

  @override
  Widget build(BuildContext context) {
    final total = 550 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, dy * (1 - v)), child: child),
      ),
      child: child,
    );
  }
}

/// Animated pill switch with a glowing thumb, like the settings mockup.
class GlowSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const GlowSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF38BDF8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? activeColor.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.16),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.5),
                    blurRadius: 14,
                    spreadRadius: -2,
                  )
                ]
              : const [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Color(0x44000000), blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small uppercase section label ("HOURLY FORECAST", "SAVED LOCATIONS"…).
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
      ),
    );
  }
}

/// Clamps content width on tablets/desktop so layouts stay elegant.
class MaxWidth extends StatelessWidget {
  final Widget child;
  final double width;

  const MaxWidth({super.key, required this.child, this.width = 720});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}
