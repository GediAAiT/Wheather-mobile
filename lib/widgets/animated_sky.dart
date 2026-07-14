import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/weather.dart';

/// Full-screen living background. Reacts to the current weather (rain, snow,
/// stars, lightning, drifting clouds) and brightens into a daytime sky when
/// the location is in daylight and dark mode is off.
class AnimatedSky extends StatefulWidget {
  final Weather? weather;
  final bool darkMode;

  const AnimatedSky({super.key, this.weather, this.darkMode = false});

  @override
  State<AnimatedSky> createState() => _AnimatedSkyState();
}

class _AnimatedSkyState extends State<AnimatedSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Particle> _particles =
      List.generate(80, (i) => _Particle(math.Random(i * 7 + 3)));

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 28))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  SkyMode get _mode {
    final w = widget.weather;
    final day = w != null && w.isDay && !widget.darkMode;
    if (w == null) return SkyMode.nightIdle;
    final k = w.conditionKey;
    if (k.startsWith('thunderstorm')) {
      return day ? SkyMode.dayStorm : SkyMode.nightStorm;
    }
    if (k.startsWith('snow') || k.contains('freezing')) {
      return day ? SkyMode.daySnow : SkyMode.nightSnow;
    }
    if (k.startsWith('rain') || k.startsWith('drizzle')) {
      return day ? SkyMode.dayRain : SkyMode.nightRain;
    }
    if (k == 'fog' || k == 'rime_fog') {
      return day ? SkyMode.dayFog : SkyMode.nightFog;
    }
    if (k == 'clear' || k == 'mainly_clear') {
      return day ? SkyMode.dayClear : SkyMode.nightClear;
    }
    return day ? SkyMode.dayCloud : SkyMode.nightCloud;
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: mode.gradient,
            ),
          ),
          child: CustomPaint(
            painter: _SkyPainter(
              t: _ctrl.value,
              mode: mode,
              particles: _particles,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

enum SkyMode {
  nightIdle,
  nightClear,
  nightCloud,
  nightRain,
  nightSnow,
  nightStorm,
  nightFog,
  dayClear,
  dayCloud,
  dayRain,
  daySnow,
  dayStorm,
  dayFog;

  bool get isDay => name.startsWith('day');

  List<Color> get gradient {
    switch (this) {
      case SkyMode.dayClear:
        return const [Color(0xFF1E6FD4), Color(0xFF3F95EC), Color(0xFF7CC2F8)];
      case SkyMode.dayCloud:
        return const [Color(0xFF2A77D3), Color(0xFF4D9AE8), Color(0xFF8AC3F2)];
      case SkyMode.dayRain:
        return const [Color(0xFF3A5C84), Color(0xFF55779E), Color(0xFF7995B5)];
      case SkyMode.daySnow:
        return const [Color(0xFF5E7FA8), Color(0xFF87A4C8), Color(0xFFB4CBE4)];
      case SkyMode.dayStorm:
        return const [Color(0xFF2B3350), Color(0xFF3E466B), Color(0xFF555E84)];
      case SkyMode.dayFog:
        return const [Color(0xFF5E6E85), Color(0xFF7B8BA1), Color(0xFF9AA8BB)];
      case SkyMode.nightClear:
        return const [Color(0xFF070B1F), Color(0xFF131038), Color(0xFF0B1026)];
      case SkyMode.nightRain:
        return const [Color(0xFF0A1530), Color(0xFF0F2140), Color(0xFF0B1026)];
      case SkyMode.nightSnow:
        return const [Color(0xFF101A3E), Color(0xFF18234E), Color(0xFF0B1026)];
      case SkyMode.nightStorm:
        return const [Color(0xFF120B2E), Color(0xFF1C1140), Color(0xFF0B0820)];
      case SkyMode.nightFog:
        return const [Color(0xFF11162E), Color(0xFF181D38), Color(0xFF0B1026)];
      case SkyMode.nightCloud:
        return const [Color(0xFF0C1230), Color(0xFF151B40), Color(0xFF0B1026)];
      case SkyMode.nightIdle:
        return const [Color(0xFF0B1026), Color(0xFF161B39), Color(0xFF0B1026)];
    }
  }

  List<Color> get aurora {
    switch (this) {
      case SkyMode.dayClear:
      case SkyMode.dayCloud:
        return const [Color(0xFFFFE9A8), Color(0xFFBDE3FF), Color(0xFF8EC8FF)];
      case SkyMode.dayRain:
      case SkyMode.daySnow:
      case SkyMode.dayFog:
        return const [Color(0xFFCBD9EA), Color(0xFFA9C2DD), Color(0xFF8FB1D4)];
      case SkyMode.dayStorm:
        return const [Color(0xFF8B5CF6), Color(0xFFF2B441), Color(0xFF64748B)];
      case SkyMode.nightClear:
        return const [Color(0xFF8B5CF6), Color(0xFF7DD3FC), Color(0xFF312E81)];
      case SkyMode.nightRain:
        return const [Color(0xFF38BDF8), Color(0xFF6366F1), Color(0xFF0EA5E9)];
      case SkyMode.nightSnow:
        return const [Color(0xFF7DD3FC), Color(0xFFA5B4FC), Color(0xFFE0F2FE)];
      case SkyMode.nightStorm:
        return const [Color(0xFF8B5CF6), Color(0xFFF2B441), Color(0xFF4C1D95)];
      case SkyMode.nightFog:
        return const [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFF475569)];
      case SkyMode.nightCloud:
        return const [Color(0xFF6366F1), Color(0xFF7DD3FC), Color(0xFF475569)];
      case SkyMode.nightIdle:
        return const [Color(0xFFF2B441), Color(0xFF7DD3FC), Color(0xFF6366F1)];
    }
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double drift;

  _Particle(math.Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        size = 0.5 + r.nextDouble() * 2.5,
        speed = 0.4 + r.nextDouble() * 0.9,
        phase = r.nextDouble() * math.pi * 2,
        drift = (r.nextDouble() - 0.5) * 0.3;
}

class _SkyPainter extends CustomPainter {
  final double t;
  final SkyMode mode;
  final List<_Particle> particles;

  _SkyPainter({required this.t, required this.mode, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    _paintAurora(canvas, size);
    if (mode.isDay) _paintDayClouds(canvas, size);
    switch (mode) {
      case SkyMode.nightRain:
      case SkyMode.dayRain:
        _paintRain(canvas, size);
        break;
      case SkyMode.nightSnow:
      case SkyMode.daySnow:
        _paintSnow(canvas, size);
        break;
      case SkyMode.nightStorm:
      case SkyMode.dayStorm:
        _paintRain(canvas, size);
        _paintLightning(canvas, size);
        break;
      case SkyMode.nightClear:
        _paintStars(canvas, size);
        break;
      case SkyMode.nightFog:
      case SkyMode.dayFog:
        _paintFog(canvas, size);
        break;
      case SkyMode.dayClear:
        _paintSunGlow(canvas, size);
        break;
      default:
        _paintOrbs(canvas, size);
    }
  }

  void _paintAurora(Canvas canvas, Size size) {
    final colors = mode.aurora;
    final blur = MaskFilter.blur(BlurStyle.normal, size.shortestSide * 0.18);
    final angle = t * 2 * math.pi;
    final baseAlpha = mode.isDay ? 0.20 : 0.16;

    void blob(Color c, double cx, double cy, double radius, double opacity) {
      final paint = Paint()
        ..color = c.withValues(alpha: opacity)
        ..maskFilter = blur;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    blob(
      colors[0],
      size.width * (0.78 + 0.10 * math.sin(angle)),
      size.height * (0.10 + 0.05 * math.cos(angle * 1.3)),
      size.width * 0.34,
      baseAlpha,
    );
    blob(
      colors[1],
      size.width * (0.12 + 0.08 * math.cos(angle * 0.8)),
      size.height * (0.42 + 0.06 * math.sin(angle * 1.1)),
      size.width * 0.30,
      baseAlpha * 0.75,
    );
    blob(
      colors[2],
      size.width * (0.55 + 0.12 * math.sin(angle * 0.6 + 2)),
      size.height * (0.85 + 0.04 * math.cos(angle)),
      size.width * 0.38,
      baseAlpha * 0.6,
    );
  }

  void _paintSunGlow(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 4);
    final center = Offset(size.width * 0.85, size.height * 0.07);
    canvas.drawCircle(
      center,
      size.width * (0.22 + pulse * 0.02),
      Paint()
        ..color = const Color(0xFFFFF3C4).withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.10),
    );
    canvas.drawCircle(
      center,
      size.width * 0.07,
      Paint()
        ..color = const Color(0xFFFFFDF5).withValues(alpha: 0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02),
    );
  }

  /// Soft cumulus shapes drifting across a daytime sky.
  void _paintDayClouds(Canvas canvas, Size size) {
    final blur = MaskFilter.blur(BlurStyle.normal, size.width * 0.035);
    for (var i = 0; i < 5; i++) {
      final speed = 0.4 + i * 0.13;
      final x = ((t * speed + i * 0.23) % 1.3 - 0.15) * size.width;
      final y = size.height * (0.08 + i * 0.14);
      final s = size.width * (0.10 + (i % 3) * 0.04);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.30 - i * 0.03)
        ..maskFilter = blur;
      canvas.drawCircle(Offset(x, y), s, paint);
      canvas.drawCircle(Offset(x + s * 0.9, y + s * 0.2), s * 0.75, paint);
      canvas.drawCircle(Offset(x - s * 0.8, y + s * 0.25), s * 0.6, paint);
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final base = mode.isDay ? Colors.white : const Color(0xFF7DD3FC);
    final paint = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final p in particles) {
      final fall = (p.y + t * p.speed * 6) % 1.0;
      final dx = p.x * size.width + p.drift * 40;
      final dy = fall * size.height;
      canvas.drawLine(
        Offset(dx, dy),
        Offset(dx - 4, dy + 14 + p.size * 4),
        paint..color = base.withValues(alpha: 0.12 + p.size * 0.09),
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final fall = (p.y + t * p.speed * 2) % 1.0;
      final sway = math.sin(t * 2 * math.pi * 2 + p.phase) * 14;
      paint.color = Colors.white.withValues(alpha: 0.10 + p.size * 0.14);
      canvas.drawCircle(
        Offset(p.x * size.width + sway, fall * size.height),
        p.size,
        paint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final twinkle =
          0.5 + 0.5 * math.sin(t * 2 * math.pi * (1 + p.speed * 3) + p.phase);
      paint.color = Colors.white.withValues(alpha: 0.10 + twinkle * 0.5);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height * 0.85),
        p.size * 0.7,
        paint,
      );
    }
  }

  void _paintOrbs(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final base = mode.isDay ? Colors.white : const Color(0xFF7DD3FC);
    for (final p in particles.take(28)) {
      final rise = (p.y - t * p.speed * 0.6) % 1.0;
      final sway = math.sin(t * 2 * math.pi + p.phase) * 18;
      paint.color = base.withValues(alpha: 0.05 + p.size * 0.05);
      canvas.drawCircle(
        Offset(p.x * size.width + sway, rise * size.height),
        p.size,
        paint,
      );
    }
  }

  void _paintFog(Canvas canvas, Size size) {
    final blur = MaskFilter.blur(BlurStyle.normal, size.width * 0.08);
    for (var i = 0; i < 4; i++) {
      final drift =
          math.sin(t * 2 * math.pi * 0.5 + i * 1.7) * size.width * 0.15;
      final paint = Paint()
        ..color = const Color(0xFF94A3B8)
            .withValues(alpha: mode.isDay ? 0.14 : 0.06)
        ..maskFilter = blur;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * (0.2 + i * 0.22) + drift,
            size.height * (0.25 + i * 0.18),
          ),
          width: size.width * 0.8,
          height: size.height * 0.16,
        ),
        paint,
      );
    }
  }

  void _paintLightning(Canvas canvas, Size size) {
    // Brief flash roughly twice per loop.
    final pulse = math.sin(t * 2 * math.pi * 9);
    final flash = math.pow(pulse.clamp(0.0, 1.0), 24).toDouble();
    if (flash < 0.05) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE0E7FF).withValues(alpha: flash * 0.14),
    );
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.t != t || old.mode != mode;
}
