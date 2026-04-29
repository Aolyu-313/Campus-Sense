class EnvironmentCurrent {
  const EnvironmentCurrent({
    required this.location,
    required this.weather,
    required this.airQuality,
    required this.comfort,
  });

  final LocationInfo location;
  final WeatherInfo weather;
  final AirQualityInfo airQuality;
  final ComfortInfo comfort;

  factory EnvironmentCurrent.fromJson(Map<String, Object?> json) {
    return EnvironmentCurrent(
      location: LocationInfo.fromJson(_map(json['location'])),
      weather: WeatherInfo.fromJson(_map(json['weather'])),
      airQuality: AirQualityInfo.fromJson(_map(json['airQuality'])),
      comfort: ComfortInfo.fromJson(_map(json['comfort'])),
    );
  }
}

class LocationInfo {
  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.city,
  });

  final double latitude;
  final double longitude;
  final String name;
  final String city;

  factory LocationInfo.fromJson(Map<String, Object?> json) {
    return LocationInfo(
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      name: _text(json['name'], 'Campus Area'),
      city: _text(json['city'], 'Local Campus'),
    );
  }
}

class WeatherInfo {
  const WeatherInfo({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.conditionCode,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final String conditionCode;

  factory WeatherInfo.fromJson(Map<String, Object?> json) {
    return WeatherInfo(
      temperature: _double(json['temperature']),
      feelsLike: _double(json['feelsLike']),
      humidity: _int(json['humidity']),
      windSpeed: _double(json['windSpeed']),
      precipitation: _double(json['precipitation']),
      conditionCode: _text(json['conditionCode'], 'UNKNOWN'),
    );
  }
}

class AirQualityInfo {
  const AirQualityInfo({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.levelCode,
  });

  final int aqi;
  final double pm25;
  final double pm10;
  final String levelCode;

  factory AirQualityInfo.fromJson(Map<String, Object?> json) {
    return AirQualityInfo(
      aqi: _int(json['aqi']),
      pm25: _double(json['pm25']),
      pm10: _double(json['pm10']),
      levelCode: _text(json['levelCode'], 'UNKNOWN'),
    );
  }
}

class ComfortInfo {
  const ComfortInfo({
    required this.score,
    required this.levelCode,
    required this.adviceCode,
  });

  final int score;
  final String levelCode;
  final String adviceCode;

  String get levelLabel => labelForCode(levelCode);
  String get adviceLabel => labelForCode(adviceCode);

  factory ComfortInfo.fromJson(Map<String, Object?> json) {
    return ComfortInfo(
      score: _int(json['score']),
      levelCode: _text(json['levelCode'], 'UNKNOWN'),
      adviceCode: _text(json['adviceCode'], 'UNKNOWN'),
    );
  }
}

String labelForCode(String code) {
  const labels = {
    'COMFORTABLE': 'Comfortable',
    'MODERATE': 'Moderate',
    'LOW': 'Low comfort',
    'UNCOMFORTABLE': 'Uncomfortable',
    'GOOD_FOR_OUTDOOR_STAY': 'Good for outdoor stay',
    'OK_FOR_SHORT_STAY': 'OK for a short stay',
    'USE_WITH_CAUTION': 'Use with caution',
    'CHOOSE_INDOOR_SPACE': 'Choose an indoor space',
    'GOOD': 'Good',
    'UNHEALTHY_FOR_SENSITIVE': 'Sensitive groups caution',
    'UNHEALTHY': 'Unhealthy',
    'CLOUDY': 'Cloudy',
    'SUNNY': 'Sunny',
    'RAIN': 'Rain',
    'SNOW': 'Snow',
    'UNKNOWN': 'Unknown',
  };
  return labels[code.toUpperCase()] ?? code.replaceAll('_', ' ');
}

Map<String, Object?> _map(Object? value) {
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  return const {};
}

String _text(Object? value, String fallback) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

double _double(Object? value, [double fallback = 0]) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int _int(Object? value, [int fallback = 0]) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
