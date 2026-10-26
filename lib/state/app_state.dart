import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/translations.dart';
import '../models/country.dart';
import '../models/forecast.dart';
import '../models/weather.dart';
import '../services/api_service.dart';

/// Single source of truth shared by every tab: settings, the selected
/// location, saved locations and their cached weather.
class AppState extends ChangeNotifier {
  final ApiService api = ApiService();
  SharedPreferences? _prefs;

  // ── Settings ──────────────────────────────────────────────────────────
  bool useFahrenheit = false;
  bool useMph = false;
  bool pushNotifications = true;
  bool rainAlerts = true;

  /// When false the sky brightens during local daytime; when true the UI
  /// always stays in deep-night mode.
  bool darkMode = false;
  String lang = 'en';

  // ── Data ──────────────────────────────────────────────────────────────
  List<Country> countries = [];
  List<Map<String, String>> languages = List.from(kLanguages);

  String currentCode = 'US';

  /// True once the user has chosen a country; stops location auto-detection.
  bool manualCountry = false;
  Weather? current;
  Forecast? forecast;
  bool loading = false;
  String? error;

  List<String> savedCodes = ['GB', 'JP', 'FR', 'BR', 'ET'];
  List<Weather> savedWeather = [];
  bool savedLoading = false;

  Country? countryOf(String code) {
    for (final c in countries) {
      if (c.code.toUpperCase() == code.toUpperCase()) return c;
    }
    return null;
  }

  bool isSaved(String code) =>
      savedCodes.any((c) => c.toUpperCase() == code.toUpperCase());

  // ── Lifecycle ─────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    useFahrenheit = p.getBool('useFahrenheit') ?? false;
    useMph = p.getBool('useMph') ?? false;
    pushNotifications = p.getBool('pushNotifications') ?? true;
    rainAlerts = p.getBool('rainAlerts') ?? true;
    darkMode = p.getBool('darkMode') ?? false;
    lang = p.getString('lang') ?? 'en';
    currentCode = p.getString('currentCode') ?? 'US';
    manualCountry = p.getBool('manualCountry') ?? false;
    savedCodes = p.getStringList('savedCodes') ?? savedCodes;
    notifyListeners();

    // Fire everything in parallel; each part fails independently.
    final countriesLoaded = _loadCountries();
    await Future.wait([
      countriesLoaded,
      _loadLanguages(),
      refreshCurrent(),
      refreshSaved(),
      if (!manualCountry) _useDeviceLocation(countriesLoaded),
    ]);
  }

  /// Switches the current place to the country the device is in, unless the
  /// user picked a country by hand. Silently keeps the last place on failure
  /// (permission denied, location off, no fix).
  Future<void> _useDeviceLocation(Future<void> countriesLoaded) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 15),
            ),
          );

      await countriesLoaded;
      final code = await _countryCodeAt(pos.latitude, pos.longitude);
      if (code == null || code == currentCode) return;
      currentCode = code;
      _prefs?.setString('currentCode', code);
      current = null;
      forecast = null;
      await refreshCurrent();
    } catch (_) {/* keep the last known place */}
  }

  Future<String?> _countryCodeAt(double lat, double lon) async {
    try {
      final marks = await Geocoding().placemarkFromCoordinates(lat, lon);
      final iso = marks
          .map((m) => m.isoCountryCode)
          .firstWhere((c) => c != null && c.isNotEmpty, orElse: () => null);
      if (iso != null && (countries.isEmpty || countryOf(iso) != null)) {
        return iso.toUpperCase();
      }
    } catch (_) {/* geocoder unavailable: fall back to nearest capital */}
    return _nearestCountry(lat, lon)?.code.toUpperCase();
  }

  Country? _nearestCountry(double lat, double lon) {
    Country? best;
    var bestKm = double.infinity;
    for (final c in countries) {
      final dLat = (c.latitude - lat) * math.pi / 180;
      final dLon = (c.longitude - lon) * math.pi / 180;
      final a = math.pow(math.sin(dLat / 2), 2) +
          math.cos(lat * math.pi / 180) *
              math.cos(c.latitude * math.pi / 180) *
              math.pow(math.sin(dLon / 2), 2);
      final km = 12742 * math.asin(math.sqrt(a));
      if (km < bestKm) {
        bestKm = km;
        best = c;
      }
    }
    return best;
  }

  Future<void> _loadCountries() async {
    try {
      countries = await api.getCountries(lang);
      notifyListeners();
    } catch (_) {/* search will simply be empty until backend is up */}
  }

  Future<void> _loadLanguages() async {
    try {
      final langs = await api.getLanguages();
      if (langs.isNotEmpty) {
        languages = langs;
        notifyListeners();
      }
    } catch (_) {/* keep bundled list */}
  }

  Future<void> refreshCurrent() async {
    loading = true;
    error = null;
    notifyListeners();
    final code = currentCode;
    try {
      final results = await Future.wait([
        api.getWeather(code, lang),
        api.getForecast(code, lang, days: 7),
      ]);
      // The place may have changed (location detected) while this was loading.
      if (code != currentCode) return;
      current = results[0] as Weather;
      forecast = results[1] as Forecast;
    } catch (_) {
      if (code != currentCode) return;
      error = t(lang, 'state.error');
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refreshSaved() async {
    savedLoading = true;
    notifyListeners();
    try {
      savedWeather = await api.getBatch(savedCodes, lang);
    } catch (_) {/* keep stale data */}
    savedLoading = false;
    notifyListeners();
  }

  // ── Actions ───────────────────────────────────────────────────────────
  Future<void> selectCountry(String code) async {
    currentCode = code.toUpperCase();
    manualCountry = true;
    _prefs?.setString('currentCode', currentCode);
    _prefs?.setBool('manualCountry', true);
    current = null;
    forecast = null;
    await refreshCurrent();
  }

  void toggleSaved(String code) {
    final up = code.toUpperCase();
    if (isSaved(up)) {
      savedCodes.removeWhere((c) => c.toUpperCase() == up);
      savedWeather
          .removeWhere((w) => w.countryCode.toUpperCase() == up);
      notifyListeners();
    } else {
      savedCodes.add(up);
      notifyListeners();
      refreshSaved();
    }
    _prefs?.setStringList('savedCodes', savedCodes);
  }

  void setLang(String code) {
    if (code == lang) return;
    lang = code;
    _prefs?.setString('lang', code);
    notifyListeners();
    _loadCountries();
    refreshCurrent();
    refreshSaved();
  }

  void setFahrenheit(bool v) {
    useFahrenheit = v;
    _prefs?.setBool('useFahrenheit', v);
    notifyListeners();
  }

  void setMph(bool v) {
    useMph = v;
    _prefs?.setBool('useMph', v);
    notifyListeners();
  }

  void setPushNotifications(bool v) {
    pushNotifications = v;
    _prefs?.setBool('pushNotifications', v);
    notifyListeners();
  }

  void setRainAlerts(bool v) {
    rainAlerts = v;
    _prefs?.setBool('rainAlerts', v);
    notifyListeners();
  }

  void setDarkMode(bool v) {
    darkMode = v;
    _prefs?.setBool('darkMode', v);
    notifyListeners();
  }

  // ── Unit helpers ──────────────────────────────────────────────────────
  double tempValue(double celsius) =>
      useFahrenheit ? celsius * 9 / 5 + 32 : celsius;

  /// "72°"
  String temp(double celsius) => '${tempValue(celsius).round()}°';

  String get tempUnit => useFahrenheit ? '°F' : '°C';

  double windValue(double kmh) => useMph ? kmh * 0.621371 : kmh;

  String wind(double kmh) =>
      '${windValue(kmh).round()} ${useMph ? 'mph' : t(lang, 'unit.kmh')}';

  String get windUnit => useMph ? 'mph' : 'km/h';

  String compass(int degrees) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((degrees + 22.5) % 360 ~/ 45)];
  }

  String tr(String key) => t(lang, key);
}

/// Lightweight inherited access: `AppScope.of(context)` rebuilds on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
