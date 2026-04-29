import 'package:campussense_mobile/core/config/app_settings.dart';
import 'package:campussense_mobile/core/config/settings_repository.dart';
import 'package:campussense_mobile/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('settings screen uses Chinese copy when language is zh', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    const settings = AppSettings(
      baseUrl: 'http://39.104.76.34:8081',
      deviceId: 'device-1',
      preferredLanguage: 'zh',
      latitude: 31.2304,
      longitude: 121.4737,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsScreen(
            settings: settings,
            settingsRepository: SettingsRepository(),
            onSettingsSaved: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('后端服务'), findsOneWidget);
    expect(find.text('健康检查'), findsOneWidget);
    expect(find.text('匿名设备 ID'), findsOneWidget);
    expect(find.text('数据来源'), findsOneWidget);
    expect(find.textContaining('高德'), findsOneWidget);
    expect(find.textContaining('和风天气'), findsOneWidget);
  });
}
