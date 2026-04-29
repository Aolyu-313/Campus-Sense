import 'environment_models.dart';
import 'report_models.dart';

class HistoryRecord {
  const HistoryRecord({required this.report, this.environment});

  final CampusReport report;
  final EnvironmentCurrent? environment;

  factory HistoryRecord.fromJson(Map<String, Object?> json) {
    final environmentJson = json['environmentSnapshot'];
    return HistoryRecord(
      report: CampusReport.fromJson(json),
      environment: environmentJson is Map
          ? EnvironmentCurrent.fromJson(environmentJson.cast<String, Object?>())
          : null,
    );
  }
}

class HistoryTrend {
  const HistoryTrend({required this.deviceId, required this.points});

  final String deviceId;
  final List<HistoryTrendPoint> points;

  factory HistoryTrend.fromJson(Map<String, Object?> json) {
    final pointsJson = json['points'];
    return HistoryTrend(
      deviceId: json['deviceId']?.toString() ?? '',
      points: pointsJson is List
          ? pointsJson
                .whereType<Map>()
                .map(
                  (item) =>
                      HistoryTrendPoint.fromJson(item.cast<String, Object?>()),
                )
                .toList()
          : const [],
    );
  }
}

class HistoryTrendPoint {
  const HistoryTrendPoint({
    required this.createdAt,
    required this.comfortScore,
    required this.aqi,
    required this.temperature,
  });

  final DateTime? createdAt;
  final int comfortScore;
  final int aqi;
  final double temperature;

  factory HistoryTrendPoint.fromJson(Map<String, Object?> json) {
    return HistoryTrendPoint(
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      comfortScore: _int(json['comfortScore']),
      aqi: _int(json['aqi']),
      temperature: _double(json['temperature']),
    );
  }
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
