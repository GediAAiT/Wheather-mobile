class Weather {
  final String countryName;
  final String countryCode;
  final String capital;
  final double temperature;
  final double apparentTemperature;
  final double windSpeed;
  final int windDirection;
  final int humidity;
  final double precipitation;
  final bool isDay;
  final int weatherCode;
  final String conditionKey;
  final String condition;
  final String time;

  Weather({
    required this.countryName,
    required this.countryCode,
    required this.capital,
    required this.temperature,
    required this.apparentTemperature,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.precipitation,
    required this.isDay,
    required this.weatherCode,
    required this.conditionKey,
    required this.condition,
    required this.time,
  });

  factory Weather.fromJson(Map<String, dynamic> j) => Weather(
        countryName: j['countryName'] as String,
        countryCode: j['countryCode'] as String,
        capital: j['capital'] as String,
        temperature: (j['temperature'] as num).toDouble(),
        apparentTemperature: (j['apparentTemperature'] as num).toDouble(),
        windSpeed: (j['windSpeed'] as num).toDouble(),
        windDirection: (j['windDirection'] as num? ?? 0).toInt(),
        humidity: (j['humidity'] as num).toInt(),
        precipitation: (j['precipitation'] as num).toDouble(),
        isDay: j['day'] == true || j['isDay'] == true,
        weatherCode: (j['weatherCode'] as num).toInt(),
        conditionKey: j['conditionKey'] as String,
        condition: j['condition'] as String,
        time: j['time'] as String,
      );
}
