class DailyForecast {
  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final double precipitation;
  final double windSpeedMax;
  final int weatherCode;
  final String conditionKey;
  final String condition;

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitation,
    required this.windSpeedMax,
    required this.weatherCode,
    required this.conditionKey,
    required this.condition,
  });

  DateTime get day => DateTime.parse(date);

  /// Rough rain-chance heuristic derived from precipitation volume (mm).
  int get precipChance =>
      precipitation <= 0 ? 0 : (15 + precipitation * 18).clamp(5, 95).round();

  factory DailyForecast.fromJson(Map<String, dynamic> j) => DailyForecast(
        date: j['date'] as String,
        temperatureMax: (j['temperatureMax'] as num).toDouble(),
        temperatureMin: (j['temperatureMin'] as num).toDouble(),
        precipitation: (j['precipitation'] as num? ?? 0).toDouble(),
        windSpeedMax: (j['windSpeedMax'] as num? ?? 0).toDouble(),
        weatherCode: (j['weatherCode'] as num).toInt(),
        conditionKey: j['conditionKey'] as String? ?? 'unknown',
        condition: j['condition'] as String? ?? '',
      );
}

class Forecast {
  final String countryName;
  final String countryCode;
  final String capital;
  final List<DailyForecast> days;

  Forecast({
    required this.countryName,
    required this.countryCode,
    required this.capital,
    required this.days,
  });

  factory Forecast.fromJson(Map<String, dynamic> j) => Forecast(
        countryName: j['countryName'] as String,
        countryCode: j['countryCode'] as String,
        capital: j['capital'] as String? ?? '',
        days: (j['days'] as List<dynamic>? ?? [])
            .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
