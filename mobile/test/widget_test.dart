import 'package:campussense_mobile/app/campus_sense_app.dart';
import 'package:campussense_mobile/core/config/app_settings.dart';
import 'package:campussense_mobile/core/config/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CampusSense app starts at the intro entry point', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      CampusSenseApp(
        settingsRepository: SettingsRepository(),
        initialSettings: AppSettings.defaults(),
      ),
    );

    expect(find.text('CampusSense'), findsWidgets);
    expect(find.text('Start sensing'), findsOneWidget);
  });
}
