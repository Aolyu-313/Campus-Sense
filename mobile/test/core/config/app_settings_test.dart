import 'package:campussense_mobile/core/config/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default settings include emulator backend and generated device id', () {
    final settings = AppSettings.defaults();

    expect(settings.baseUrl, AppSettings.defaultBaseUrl);
    expect(settings.deviceId, startsWith('anonymous-'));
    expect(settings.latitude, AppSettings.defaultLatitude);
    expect(settings.longitude, AppSettings.defaultLongitude);
  });

  test('copyWith changes only requested values', () {
    const settings = AppSettings(
      baseUrl: 'http://10.0.2.2:8080',
      deviceId: 'device-1',
      preferredLanguage: 'en',
      latitude: 51.5,
      longitude: -0.1,
    );

    final changed = settings.copyWith(preferredLanguage: 'zh');

    expect(changed.baseUrl, settings.baseUrl);
    expect(changed.deviceId, settings.deviceId);
    expect(changed.preferredLanguage, 'zh');
    expect(changed.latitude, settings.latitude);
  });
}
