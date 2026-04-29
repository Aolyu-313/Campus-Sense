import 'package:campussense_mobile/core/models/history_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses trend points in response order', () {
    final trend = HistoryTrend.fromJson({
      'deviceId': 'anonymous-device',
      'points': [
        {
          'createdAt': '2026-04-28T08:00:00',
          'comfortScore': 72,
          'aqi': 44,
          'temperature': 20.1,
        },
        {
          'createdAt': '2026-04-28T09:00:00',
          'comfortScore': 81,
          'aqi': 39,
          'temperature': 21.0,
        },
      ],
    });

    expect(trend.deviceId, 'anonymous-device');
    expect(trend.points, hasLength(2));
    expect(trend.points.last.comfortScore, 81);
    expect(trend.points.last.temperature, 21.0);
  });
}
