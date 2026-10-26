import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/country.dart';
import '../models/forecast.dart';
import '../models/weather.dart';

class ApiService {
  // Override for a deployed backend: flutter run --dart-define=API_BASE_URL=https://host/api
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static final String baseUrl = () {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8081/api';
    return 'http://localhost:8081/api';
  }();

  Future<List<Country>> getCountries(String lang) async {
    final res = await http.get(Uri.parse('$baseUrl/countries?lang=$lang'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load countries (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, String>>> getLanguages() async {
    final res = await http.get(Uri.parse('$baseUrl/meta/languages'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load languages');
    }
    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data
        .map((e) => (e as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v.toString())))
        .toList();
  }

  Future<Weather> getWeather(String code, String lang) async {
    final uri = Uri.parse('$baseUrl/weather?code=$code&lang=$lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather (${res.statusCode})');
    }
    return Weather.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<Forecast> getForecast(String code, String lang, {int days = 7}) async {
    final uri =
        Uri.parse('$baseUrl/weather/forecast?code=$code&days=$days&lang=$lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load forecast (${res.statusCode})');
    }
    return Forecast.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<List<Weather>> getBatch(List<String> codes, String lang) async {
    if (codes.isEmpty) return [];
    final uri = Uri.parse(
        '$baseUrl/weather/batch?codes=${codes.join(',')}&lang=$lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load batch weather (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data
        .map((e) => Weather.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getWeatherOverview(String code, String lang) async {
    final uri = Uri.parse('$baseUrl/weather/overview?code=$code&lang=$lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather overview (${res.statusCode})');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Weather> getWeatherByCoords(double lat, double lon, String lang) async {
    final uri = Uri.parse('$baseUrl/weather/coords?lat=$lat&lon=$lon&lang=$lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather by coords (${res.statusCode})');
    }
    return Weather.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<Weather> getWeatherByCity(String q, String lang) async {
    final uri = Uri.parse('$baseUrl/weather/city?q=$q&lang=$lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather by city (${res.statusCode})');
    }
    return Weather.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<String> getHealth() async {
    final res = await http.get(Uri.parse('$baseUrl/meta/health'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load health status');
    }
    return res.body;
  }

  Future<Map<String, dynamic>> getCountryHighlights(String code) async {
    final res = await http.get(Uri.parse('$baseUrl/countries/$code/highlights'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load country highlights (${res.statusCode})');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
