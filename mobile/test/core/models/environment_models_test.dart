import 'package:campussense_mobile/core/models/environment_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses environment summary from backend JSON', () {
    final environment = EnvironmentCurrent.fromJson({
      'location': {
        'latitude': 51.5246,
        'longitude': -0.134,
        'name': 'UCL Main Quad',
        'city': 'London',
      },
      'weather': {
        'temperature': 19.5,
        'feelsLike': 18.9,
        'humidity': 62,
        'windSpeed': 9.1,
        'precipitation': 0.0,
        'conditionCode': 'CLOUDY',
      },
      'airQuality': {'aqi': 38, 'pm25': 9.5, 'pm10': 18.0, 'levelCode': 'GOOD'},
      'comfort': {
        'score': 84,
        'levelCode': 'COMFORTABLE',
        'adviceCode': 'GOOD_FOR_OUTDOOR_STAY',
      },
    });

    expect(environment.location.name, 'UCL Main Quad');
    expect(environment.weather.temperature, 19.5);
    expect(environment.airQuality.aqi, 38);
    expect(environment.comfort.score, 84);
    expect(environment.comfort.adviceLabel, 'Good for outdoor stay');
  });
}
