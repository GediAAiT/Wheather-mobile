import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/country.dart';
import '../models/weather.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui.dart';
import '../widgets/weather_icon.dart';

class LocationsTab extends StatefulWidget {
  final VoidCallback onLocationSelected;

  const LocationsTab({super.key, required this.onLocationSelected});

  @override
  State<LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Country> _filtered(AppState app) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return app.countries
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.capital.toLowerCase().contains(q) ||
            c.code.toLowerCase() == q)
        .take(30)
        .toList();
  }

  void _select(AppState app, String code) {
    HapticFeedback.lightImpact();
    _search.clear();
    FocusScope.of(context).unfocus();
    app.selectCountry(code);
    widget.onLocationSelected();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final results = _filtered(app);
    final searching = _search.text.trim().isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFF7DD3FC),
      backgroundColor: const Color(0xFF141A3C),
      onRefresh: app.refreshSaved,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: MaxWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Entrance(
                child: Text(app.tr('tab.locations'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ),
              const SizedBox(height: 18),
              Entrance(delay: 60, child: _searchField(app)),
              const SizedBox(height: 20),
              if (searching)
                _SearchResults(results: results, onPick: (c) => _select(app, c.code))
              else ...[
                Entrance(delay: 120, child: _CurrentLocationCard(
                  onTap: () => widget.onLocationSelected(),
                )),
                const SizedBox(height: 24),
                Entrance(
                    delay: 180,
                    child: SectionLabel(app.tr('label.savedLocations'))),
                const SizedBox(height: 12),
                ..._savedList(app),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField(AppState app) {
    return GlassCard(
      radius: 26,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: _search,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: const Color(0xFF7DD3FC),
        decoration: InputDecoration(
          hintText: app.tr('search.placeholder'),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.6)),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.6)),
                  onPressed: () => setState(_search.clear),
                ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  List<Widget> _savedList(AppState app) {
    if (app.savedWeather.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: app.savedLoading
                ? const CircularProgressIndicator(color: Color(0xFF7DD3FC))
                : Text(app.tr('state.noSaved'),
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          ),
        )
      ];
    }
    return [
      for (var i = 0; i < app.savedWeather.length; i++)
        Entrance(
          delay: 220 + i * 70,
          dy: 20,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(app.savedWeather[i].countryCode),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                HapticFeedback.mediumImpact();
                app.toggleSaved(app.savedWeather[i].countryCode);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                ),
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              child: _SavedCard(
                weather: app.savedWeather[i],
                onTap: () => _select(app, app.savedWeather[i].countryCode),
              ),
            ),
          ),
        ),
    ];
  }
}

class _SearchResults extends StatelessWidget {
  final List<Country> results;
  final ValueChanged<Country> onPick;

  const _SearchResults({required this.results, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(app.tr('state.noResults'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < results.length; i++)
          Entrance(
            delay: i * 40,
            dy: 12,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                radius: 24,
                padding: EdgeInsets.zero,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  onTap: () => onPick(results[i]),
                  leading: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                    child: Text(results[i].code,
                        style: const TextStyle(
                            color: Color(0xFF7DD3FC),
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                  title: Text(results[i].name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${results[i].capital} · ${results[i].continent}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12)),
                  trailing: IconButton(
                    icon: Icon(
                      app.isSaved(results[i].code)
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_outlined,
                      color: app.isSaved(results[i].code)
                          ? const Color(0xFFF2B441)
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      app.toggleSaved(results[i].code);
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CurrentLocationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final w = app.current;
    final today = app.forecast?.days.isNotEmpty == true
        ? app.forecast!.days.first
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D4ED8), Color(0xFF0E2A66)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: w == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child:
                      CircularProgressIndicator(color: Color(0xFF7DD3FC)),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.my_location_rounded,
                                size: 14, color: Color(0xFF7DD3FC)),
                            const SizedBox(width: 6),
                            Text(app.tr('label.currentLocation'),
                                style: const TextStyle(
                                    color: Color(0xFF7DD3FC), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${w.capital}, ${w.countryCode}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(app.tr('weather.${w.conditionKey}'),
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(app.temp(w.temperature),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              height: 1,
                              fontWeight: FontWeight.w300)),
                      if (today != null)
                        Text(
                            '${app.temp(today.temperatureMin)}  ${app.temp(today.temperatureMax)}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Weather weather;
  final VoidCallback onTap;

  const _SavedCard({required this.weather, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final w = weather;
    return GlassCard(
      radius: 30,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.countryName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AnimatedWeatherIcon(
                          conditionKey: w.conditionKey,
                          isDay: w.isDay,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${w.countryCode} · ${app.tr('weather.${w.conditionKey}')}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(app.temp(w.temperature),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w300)),
                  Text(
                      '${app.tr('label.feelsLike')} ${app.temp(w.apparentTemperature)}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
