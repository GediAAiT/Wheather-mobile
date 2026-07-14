import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hand-painted, continuously animated weather glyph: rotating sun rays,
/// breathing clouds, falling rain/snow, flashing bolts, twinkling moon.
class AnimatedWeatherIcon extends StatefulWidget {
  final String conditionKey;
  final bool isDay;
  final double size;

  const AnimatedWeatherIcon({
    super.key,
    required this.conditionKey,
    required this.isDay,
    this.size = 120,
  });

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  _Glyph get _glyph {
    final k = widget.conditionKey;
    if (k.startsWith('thunderstorm')) return _Glyph.storm;
    if (k.startsWith('snow') || k.contains('freezing')) return _Glyph.snow;
    if (k.startsWith('rain') || k.startsWith('drizzle')) return _Glyph.rain;
    if (k == 'fog' || k == 'rime_fog') return _Glyph.fog;
    if (k == 'clear' || k == 'mainly_clear') {
      return widget.isDay ? _Glyph.sun : _Glyph.moon;
    }
    if (k == 'partly_cloudy') {
      return widget.isDay ? _Glyph.sunCloud : _Glyph.moonCloud;
    }
    return _Glyph.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final hover = math.sin(t * 2 * math.pi) * widget.size * 0.03;
        return Transform.translate(
          offset: Offset(0, hover),
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _GlyphPainter(t: t, glyph: _glyph),
          ),
        );
      },
    );
  }
}

enum _Glyph { sun, moon, cloud, sunCloud, moonCloud, rain, snow, storm, fog }

class _GlyphPainter extends CustomPainter {
  final double t;
  final _Glyph glyph;

  _GlyphPainter({required this.t, required this.glyph});

  static const _sunColor = Color(0xFFFFD56B);
  static const _moonColor = Color(0xFFE7ECFF);
  static const _cloudColor = Color(0xFFFFFFFF);
  static const _rainColor = Color(0xFF9BDCFF);
  static const _boltColor = Color(0xFFFFE066);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide;
    switch (glyph) {
      case _Glyph.sun:
        _sun(canvas, c, r * 0.30);
        break;
      case _Glyph.moon:
        _moon(canvas, c, r * 0.32);
        break;
      case _Glyph.cloud:
        _cloud(canvas, c, r * 0.34, alpha: 1);
        break;
      case _Glyph.sunCloud:
        _sun(canvas, c.translate(r * 0.16, -r * 0.16), r * 0.20);
        _cloud(canvas, c.translate(-r * 0.04, r * 0.10), r * 0.30, alpha: 1);
        break;
      case _Glyph.moonCloud:
        _moon(canvas, c.translate(r * 0.18, -r * 0.18), r * 0.18);
        _cloud(canvas, c.translate(-r * 0.04, r * 0.10), r * 0.30, alpha: 1);
        break;
      case _Glyph.rain:
        _cloud(canvas, c.translate(0, -r * 0.08), r * 0.32, alpha: 1);
        _rain(canvas, c, r);
        break;
      case _Glyph.snow:
        _cloud(canvas, c.translate(0, -r * 0.08), r * 0.32, alpha: 1);
        _snow(canvas, c, r);
        break;
      case _Glyph.storm:
        _cloud(canvas, c.translate(0, -r * 0.08), r * 0.32, alpha: 1);
        _bolt(canvas, c, r);
        break;
      case _Glyph.fog:
        _cloud(canvas, c.translate(0, -r * 0.12), r * 0.28, alpha: 0.9);
        _fogLines(canvas, c, r);
        break;
    }
  }

  void _sun(Canvas canvas, Offset c, double radius) {
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 2);
    // halo
    canvas.drawCircle(
      c,
      radius * (1.45 + pulse * 0.12),
      Paint()
        ..color = _sunColor.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5),
    );
    // rotating rays
    final rayPaint = Paint()
      ..color = _sunColor
      ..strokeWidth = radius * 0.14
      ..strokeCap = StrokeCap.round;
    final spin = t * 2 * math.pi * 0.5;
    for (var i = 0; i < 8; i++) {
      final a = spin + i * math.pi / 4;
      final inner = radius * 1.30;
      final outer = radius * (1.55 + 0.08 * math.sin(t * 2 * math.pi * 3 + i));
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * inner,
        c + Offset(math.cos(a), math.sin(a)) * outer,
        rayPaint,
      );
    }
    // core
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFF2C7), _sunColor],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
  }

  void _moon(Canvas canvas, Offset c, double radius) {
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 2);
    canvas.drawCircle(
      c,
      radius * (1.4 + pulse * 0.1),
      Paint()
        ..color = _moonColor.withValues(alpha: 0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5),
    );
    final moon = Path()..addOval(Rect.fromCircle(center: c, radius: radius));
    final bite = Path()
      ..addOval(Rect.fromCircle(
          center: c.translate(radius * 0.55, -radius * 0.35),
          radius: radius * 0.85));
    canvas.drawPath(
      Path.combine(PathOperation.difference, moon, bite),
      Paint()..color = _moonColor,
    );
    // twinkling companion stars
    final starPaint = Paint()
      ..color =
          Colors.white.withValues(alpha: 0.4 + 0.6 * math.sin(t * 2 * math.pi * 3).abs());
    canvas.drawCircle(c.translate(radius * 1.5, -radius * 0.9), radius * 0.10, starPaint);
    canvas.drawCircle(c.translate(radius * 1.1, radius * 1.1), radius * 0.07, starPaint);
  }

  void _cloud(Canvas canvas, Offset c, double s, {required double alpha}) {
    final breathe = 1 + 0.03 * math.sin(t * 2 * math.pi * 2);
    final paint = Paint()
      ..color = _cloudColor.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    // soft shadow glow
    canvas.drawCircle(
      c,
      s * 1.3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.6),
    );
    final w = s * breathe;
    canvas.drawCircle(c.translate(-w * 0.75, w * 0.25), w * 0.55, paint);
    canvas.drawCircle(c.translate(-w * 0.15, -w * 0.18), w * 0.70, paint);
    canvas.drawCircle(c.translate(w * 0.62, w * 0.18), w * 0.58, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: c.translate(0, w * 0.42), width: w * 2.3, height: w * 0.8),
        Radius.circular(w * 0.4),
      ),
      paint,
    );
  }

  void _rain(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = _rainColor
      ..strokeWidth = r * 0.035
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final phase = (t * 2 + i * 0.25) % 1.0;
      final x = c.dx + (i - 1.5) * r * 0.17;
      final y = c.dy + r * 0.20 + phase * r * 0.30;
      final fade = (1 - phase) * 0.9;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - r * 0.03, y + r * 0.09),
        paint..color = _rainColor.withValues(alpha: fade),
      );
    }
  }

  void _snow(Canvas canvas, Offset c, double r) {
    final paint = Paint();
    for (var i = 0; i < 4; i++) {
      final phase = (t * 1.2 + i * 0.25) % 1.0;
      final sway = math.sin(phase * math.pi * 4 + i) * r * 0.04;
      final x = c.dx + (i - 1.5) * r * 0.17 + sway;
      final y = c.dy + r * 0.20 + phase * r * 0.30;
      paint.color = Colors.white.withValues(alpha: (1 - phase) * 0.95);
      canvas.drawCircle(Offset(x, y), r * 0.035, paint);
    }
  }

  void _bolt(Canvas canvas, Offset c, double r) {
    final flash =
        math.pow(math.sin(t * 2 * math.pi * 2).clamp(0.0, 1.0), 6).toDouble();
    final s = r * 0.32;
    final path = Path()
      ..moveTo(c.dx + s * 0.10, c.dy + r * 0.05)
      ..lineTo(c.dx - s * 0.35, c.dy + r * 0.05 + s * 0.75)
      ..lineTo(c.dx - s * 0.02, c.dy + r * 0.05 + s * 0.75)
      ..lineTo(c.dx - s * 0.30, c.dy + r * 0.05 + s * 1.5)
      ..lineTo(c.dx + s * 0.45, c.dy + r * 0.05 + s * 0.55)
      ..lineTo(c.dx + s * 0.05, c.dy + r * 0.05 + s * 0.55)
      ..lineTo(c.dx + s * 0.45, c.dy + r * 0.05)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = _boltColor.withValues(alpha: 0.35 + flash * 0.65)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, flash * 3),
    );
  }

  void _fogLines(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = r * 0.045
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final drift = math.sin(t * 2 * math.pi + i * 1.3) * r * 0.05;
      final y = c.dy + r * 0.16 + i * r * 0.12;
      final half = r * (0.30 - i * 0.05);
      canvas.drawLine(
        Offset(c.dx - half + drift, y),
        Offset(c.dx + half + drift, y),
        paint..color = Colors.white.withValues(alpha: 0.75 - i * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.t != t || old.glyph != glyph;
}
