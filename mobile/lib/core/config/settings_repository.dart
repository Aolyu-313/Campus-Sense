import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class SettingsRepository {
  static const _baseUrlKey = 'campussense.baseUrl';
  static const _deviceIdKey = 'campussense.deviceId';
  static const _languageKey = 'campussense.preferredLanguage';
  static const _latitudeKey = 'campussense.latitude';
  static const _longitudeKey = 'campussense.longitude';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final defaults = AppSettings.defaults();

    final deviceId = preferences.getString(_deviceIdKey) ?? defaults.deviceId;
    final settings = AppSettings(
      baseUrl: preferences.getString(_baseUrlKey) ?? defaults.baseUrl,
      deviceId: deviceId,
      preferredLanguage:
          preferences.getString(_languageKey) ?? defaults.preferredLanguage,
      latitude: preferences.getDouble(_latitudeKey) ?? defaults.latitude,
      longitude: preferences.getDouble(_longitudeKey) ?? defaults.longitude,
    );

    if (!preferences.containsKey(_deviceIdKey)) {
      await save(settings);
    }

    return settings;
  }

  Future<void> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_baseUrlKey, settings.baseUrl.trim());
    await preferences.setString(_deviceIdKey, settings.deviceId.trim());
    await preferences.setString(
      _languageKey,
      settings.preferredLanguage.trim().toLowerCase(),
    );
    await preferences.setDouble(_latitudeKey, settings.latitude);
    await preferences.setDouble(_longitudeKey, settings.longitude);
  }

  Future<AppSettings> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_baseUrlKey);
    await preferences.remove(_deviceIdKey);
    await preferences.remove(_languageKey);
    await preferences.remove(_latitudeKey);
    await preferences.remove(_longitudeKey);
    final settings = AppSettings.defaults();
    await save(settings);
    return settings;
  }
}
