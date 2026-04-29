import 'dart:math';

class AppSettings {
  const AppSettings({
    required this.baseUrl,
    required this.deviceId,
    required this.preferredLanguage,
    required this.latitude,
    required this.longitude,
  });

  static const defaultBaseUrl = 'http://39.104.76.34:8081';
  static const defaultLatitude = 31.2304;
  static const defaultLongitude = 121.4737;
  static const defaultLanguage = 'en';

  final String baseUrl;
  final String deviceId;
  final String preferredLanguage;
  final double latitude;
  final double longitude;

  String get cacheKey =>
      '$baseUrl|$deviceId|$preferredLanguage|$latitude|$longitude';

  static AppSettings defaults() {
    return AppSettings(
      baseUrl: defaultBaseUrl,
      deviceId: generateDeviceId(),
      preferredLanguage: defaultLanguage,
      latitude: defaultLatitude,
      longitude: defaultLongitude,
    );
  }

  static String generateDeviceId() {
    final random = Random.secure().nextInt(999999).toString().padLeft(6, '0');
    return 'anonymous-${DateTime.now().millisecondsSinceEpoch}-$random';
  }

  AppSettings copyWith({
    String? baseUrl,
    String? deviceId,
    String? preferredLanguage,
    double? latitude,
    double? longitude,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      deviceId: deviceId ?? this.deviceId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'baseUrl': baseUrl,
      'deviceId': deviceId,
      'preferredLanguage': preferredLanguage,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AppSettings.fromJson(Map<String, Object?> json) {
    final defaults = AppSettings.defaults();
    return AppSettings(
      baseUrl: _text(json['baseUrl'], defaults.baseUrl),
      deviceId: _text(json['deviceId'], defaults.deviceId),
      preferredLanguage: _text(
        json['preferredLanguage'],
        defaults.preferredLanguage,
      ),
      latitude: _double(json['latitude'], defaults.latitude),
      longitude: _double(json['longitude'], defaults.longitude),
    );
  }

  static String _text(Object? value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static double _double(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
