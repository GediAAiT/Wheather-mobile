import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/forecast.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui.dart';
import '../widgets/weather_icon.dart';

class ForecastTab extends StatefulWidget {
  const ForecastTab({super.key});

  @override
  State<ForecastTab> createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final f = app.forecast;

    return RefreshIndicator(
      color: const Color(0xFF7DD3FC),
      backgroundColor: const Color(0xFF141A3C),
      onRefresh: app.refreshCurrent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: MaxWidth(
          child: f == null || f.days.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: app.loading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF7DD3FC))
                        : Text(app.tr('state.empty'),
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7))),
                  ),
                )
              : _content(app, f),
        ),
      ),
    );
  }

  Widget _content(AppState app, Forecast f) {
    final sel = _selected.clamp(0, f.days.length - 1);
    final day = f.days[sel];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Entrance(
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(f.capital,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ),
              Text(f.countryCode,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Entrance(delay: 60, child: _dayChips(app, f, sel)),
        const SizedBox(height: 22),
        Entrance(
          delay: 120,
          child: _SelectedDayCard(day: day, isToday: sel == 0,
              key: ValueKey('day-$sel')),
        ),
        const SizedBox(height: 20),
        Entrance(delay: 200, child: _dailyList(app, f, sel)),
      ],
    );
  }

  Widget _dayChips(AppState app, Forecast f, int sel) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: f.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = f.days[i];
          final active = i == sel;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selected = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                color: Colors.white.withValues(alpha: active ? 0.26 : 0.08),
                border: Border.all(
                    color:
                        Colors.white.withValues(alpha: active ? 0.45 : 0.10)),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7DD3FC)
                              .withValues(alpha: 0.25),
                          blurRadius: 22,
                          spreadRadius: -4,
                        )
                      ]
                    : const [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM d').format(d.day),
                      style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: active ? 1 : 0.7),
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500)),
                  AnimatedWeatherIcon(
                      conditionKey: d.conditionKey, isDay: true, size: 30),
                  Text(app.temp(d.temperatureMax),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dailyList(AppState app, Forecast f, int sel) {
    return GlassCard(
      radius: 34,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < f.days.length; i++)
            _DailyRow(
              day: f.days[i],
              isToday: i == 0,
              active: i == sel,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selected = i);
              },
            ),
        ],
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final DailyForecast day;
  final bool isToday;

  const _SelectedDayCard({super.key, required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final title = isToday
        ? '${app.tr('label.today')} · ${DateFormat('MMM d').format(day.day)}'
        : DateFormat('EEEE · MMM d').format(day.day);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.scale(scale: 0.96 + v * 0.04, child: child),
      ),
      child: GlassCard(
        radius: 40,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            AnimatedWeatherIcon(
                conditionKey: day.conditionKey, isDay: true, size: 110),
            const SizedBox(height: 4),
            Text(app.temp(day.temperatureMax),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    height: 1,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -2)),
            const SizedBox(height: 6),
            Text(app.tr('weather.${day.conditionKey}'),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 19,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 22),
            Row(
              children: [
                _col(app.tr('label.low'), app.temp(day.temperatureMin)),
                _divider(),
                _col(app.tr('label.precip'), '${day.precipChance}%',
                    accent: const Color(0xFF9BDCFF)),
                _divider(),
                _col(app.tr('label.high'), app.temp(day.temperatureMax)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withValues(alpha: 0.15),
      );

  Widget _col(String label, String value, {Color? accent}) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: accent ?? Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyForecast day;
  final bool isToday;
  final bool active;
  final VoidCallback onTap;

  const _DailyRow({
    required this.day,
    required this.isToday,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final label =
        isToday ? app.tr('label.today') : DateFormat('EEE').format(day.day);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: active
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
            ),
            AnimatedWeatherIcon(
                conditionKey: day.conditionKey, isDay: true, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(app.tr('weather.${day.conditionKey}'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13)),
                  ),
                  if (day.precipChance > 0) ...[
                    const SizedBox(width: 6),
                    Text('${day.precipChance}%',
                        style: const TextStyle(
                            color: Color(0xFF9BDCFF), fontSize: 11)),
                  ],
                ],
              ),
            ),
            Text(app.temp(day.temperatureMin),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            _tempBar(),
            const SizedBox(width: 8),
            Text(app.temp(day.temperatureMax),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _tempBar() {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFFF2B441)],
        ),
      ),
    );
  }
}
