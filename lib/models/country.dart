class Country {
  final String name;
  final String code;
  final String capital;
  final double latitude;
  final double longitude;
  final String continent;

  Country({
    required this.name,
    required this.code,
    required this.capital,
    required this.latitude,
    required this.longitude,
    required this.continent,
  });

  factory Country.fromJson(Map<String, dynamic> j) => Country(
        name: j['name'] as String,
        code: j['code'] as String,
        capital: j['capital'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        continent: j['continent'] as String,
      );
}
