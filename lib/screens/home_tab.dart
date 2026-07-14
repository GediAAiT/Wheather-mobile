import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/forecast.dart';
import '../models/weather.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui.dart';
import '../widgets/weather_icon.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeTab({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final w = app.current;

    return RefreshIndicator(
      color: const Color(0xFF7DD3FC),
      backgroundColor: const Color(0xFF141A3C),
      onRefresh: app.refreshCurrent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: MaxWidth(
          child: w == null
              ? _Placeholder(loading: app.loading, error: app.error)
              : _HomeContent(weather: w),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool loading;
  final String? error;

  const _Placeholder({required this.loading, this.error});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: Color(0xFF7DD3FC))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 56, color: Color(0xFFF98080)),
                  const SizedBox(height: 14),
                  Text(error ?? app.tr('state.empty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 16)),
                  const SizedBox(height: 18),
                  FilledButton.tonal(
                    onPressed: app.refreshCurrent,
                    child: Text(app.tr('action.retry')),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final Weather weather;

  const _HomeContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final w = weather;
    final today = app.forecast?.days.isNotEmpty == true
        ? app.forecast!.days.first
        : null;
    final localTime = DateTime.tryParse(w.time) ?? DateTime.now();
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Entrance(child: _LocationHeader(weather: w)),
        SizedBox(height: isWide ? 16 : 8),
        Entrance(
          delay: 80,
          child: AnimatedWeatherIcon(
            conditionKey: w.conditionKey,
            isDay: w.isDay,
            size: isWide ? 170 : 140,
          ),
        ),
        Entrance(delay: 140, child: _HeroTemp(weather: w)),
        const SizedBox(height: 8),
        Entrance(
          delay: 200,
          child: Text(
            app.tr('weather.${w.conditionKey}'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (today != null)
          Entrance(
            delay: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward_rounded,
                    size: 18, color: Colors.white),
                Text(' ${app.temp(today.temperatureMax)}   ',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                Icon(Icons.arrow_downward_rounded,
                    size: 18, color: Colors.white.withValues(alpha: 0.7)),
                Text(' ${app.temp(today.temperatureMin)}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Entrance(
          delay: 280,
          child: Text(
            '${app.tr('label.feelsLike')} ${app.temp(w.apparentTemperature)}'
            ' · ${DateFormat('E, MMM d').format(localTime)}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
        ),
        const SizedBox(height: 26),
        Entrance(
          delay: 340,
          child: _HourlyCard(weather: w, today: today,
              tomorrow: (app.forecast?.days.length ?? 0) > 1
                  ? app.forecast!.days[1]
                  : null),
        ),
        const SizedBox(height: 16),
        Entrance(delay: 420, child: _DetailGrid(weather: w, today: today)),
      ],
    );
  }
}

class _LocationHeader extends StatelessWidget {
  final Weather weather;

  const _LocationHeader({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  weather.capital,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                weather.countryCode,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Icon(Icons.more_vert_rounded,
            color: Colors.white.withValues(alpha: 0.8)),
      ],
    );
  }
}

class _HeroTemp extends StatelessWidget {
  final Weather weather;

  const _HeroTemp({required this.weather});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final target = app.tempValue(weather.temperature);
    final isWide = MediaQuery.of(context).size.width >= 600;
    return TweenAnimationBuilder<double>(
      key: ValueKey('${weather.countryCode}-${app.useFahrenheit}'),
      tween: Tween(begin: target - 14, end: target),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutExpo,
      builder: (context, v, _) => Text(
        '${v.round()}°',
        style: TextStyle(
          color: Colors.white,
          fontSize: isWide ? 132 : 104,
          height: 1.0,
          fontWeight: FontWeight.w200,
          letterSpacing: -4,
        ),
      ),
    );
  }
}

// ── Hourly forecast ──────────────────────────────────────────────────────
//
// The backend exposes current weather + daily ranges. The hourly strip is
// interpolated with a diurnal curve (coolest ~05:00, warmest ~15:00),
// anchored to the live temperature so "Now" is always the real reading.
class _HourPoint {
  final DateTime time;
  final double temp;
  final int precipChance;
  final bool isNow;

  _HourPoint(this.time, this.temp, this.precipChance, this.isNow);
}

List<_HourPoint> _buildHourly(
    Weather w, DailyForecast? today, DailyForecast? tomorrow) {
  final now = DateTime.tryParse(w.time) ?? DateTime.now();
  final tMin = today?.temperatureMin ?? w.temperature - 4;
  final tMax = today?.temperatureMax ?? w.temperature + 4;

  double diurnal(DateTime t, double lo, double hi) {
    final h = t.hour + t.minute / 60.0;
    final v = math.cos((h - 15) / 24 * 2 * math.pi); // peak at 15:00
    return lo + (hi - lo) * (v + 1) / 2;
  }

  final anchor = w.temperature - diurnal(now, tMin, tMax);
  final points = <_HourPoint>[];
  for (var i = 0; i < 12; i++) {
    final t = now.add(Duration(hours: i));
    final crossedMidnight = t.day != now.day;
    final lo = crossedMidnight ? (tomorrow?.temperatureMin ?? tMin) : tMin;
    final hi = crossedMidnight ? (tomorrow?.temperatureMax ?? tMax) : tMax;
    final source = crossedMidnight ? tomorrow : today;
    final temp = diurnal(t, lo, hi) + anchor * math.pow(0.8, i);
    points.add(_HourPoint(t, temp, source?.precipChance ?? 0, i == 0));
  }
  return points;
}

class _HourlyCard extends StatelessWidget {
  final Weather weather;
  final DailyForecast? today;
  final DailyForecast? tomorrow;

  const _HourlyCard({required this.weather, this.today, this.tomorrow});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final hours = _buildHourly(weather, today, tomorrow);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(app.tr('label.hourly')),
          const SizedBox(height: 14),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hours.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final h = hours[i];
                return Entrance(
                  delay: 60 * i,
                  dy: 14,
                  child: _HourPill(point: h, weather: weather),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HourPill extends StatelessWidget {
  final _HourPoint point;
  final Weather weather;

  const _HourPill({required this.point, required this.weather});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final isNow = point.isNow;
    final hourIsDay = point.time.hour >= 6 && point.time.hour < 19;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: isNow
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.transparent,
        border: isNow
            ? Border.all(color: Colors.white.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isNow ? app.tr('label.now') : DateFormat('h a').format(point.time),
            style: TextStyle(
              color: Colors.white.withValues(alpha: isNow ? 1 : 0.75),
              fontSize: 13,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          AnimatedWeatherIcon(
            conditionKey: weather.conditionKey,
            isDay: hourIsDay,
            size: 30,
          ),
          if (point.precipChance > 0)
            Text('${point.precipChance}%',
                style: TextStyle(
                    color: const Color(0xFF9BDCFF).withValues(alpha: 0.9),
                    fontSize: 10))
          else
            const SizedBox(height: 12),
          Text(
            app.temp(point.temp),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Detail tiles ─────────────────────────────────────────────────────────
class _DetailGrid extends StatelessWidget {
  final Weather weather;
  final DailyForecast? today;

  const _DetailGrid({required this.weather, this.today});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final w = weather;
    final localTime = DateTime.tryParse(w.time);
    final tiles = [
      _DetailTile(
        icon: Icons.water_drop_rounded,
        label: app.tr('label.humidity'),
        value: '${w.humidity}%',
        footer:
            '${app.tr('label.precipitation')}: ${w.precipitation.toStringAsFixed(1)} ${app.tr('unit.mm')}',
      ),
      _DetailTile(
        icon: Icons.air_rounded,
        label: app.tr('label.wind'),
        value: app.wind(w.windSpeed),
        footer: '${app.tr('label.direction')}: ${app.compass(w.windDirection)}',
        child: _WindCompass(degrees: w.windDirection),
      ),
      _DetailTile(
        icon: Icons.thermostat_rounded,
        label: app.tr('label.feelsLike'),
        value: app.temp(w.apparentTemperature),
        footer: today != null
            ? '${app.tr('label.high')} ${app.temp(today!.temperatureMax)} · ${app.tr('label.low')} ${app.temp(today!.temperatureMin)}'
            : '',
      ),
      _DetailTile(
        icon: w.isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
        label: app.tr('label.localTime'),
        value: localTime != null ? DateFormat('HH:mm').format(localTime) : '—',
        footer: w.isDay ? app.tr('label.daytime') : app.tr('label.nighttime'),
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    final cols = width >= 900 ? 4 : 2;
    return LayoutBuilder(builder: (context, constraints) {
      final gap = 14.0;
      final tileW = (constraints.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < tiles.length; i++)
            SizedBox(
              width: tileW,
              child: Entrance(delay: 80 * i, dy: 18, child: tiles[i]),
            ),
        ],
      );
    });
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String footer;
  final Widget? child;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.footer = '',
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 8),
              Expanded(child: SectionLabel(label)),
              if (child != null) child!,
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(footer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _WindCompass extends StatelessWidget {
  final int degrees;

  const _WindCompass({required this.degrees});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: degrees * math.pi / 180),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, a, _) => Transform.rotate(
        angle: a,
        child: Icon(Icons.navigation_rounded,
            size: 18, color: Colors.white.withValues(alpha: 0.8)),
      ),
    );
  }
}
