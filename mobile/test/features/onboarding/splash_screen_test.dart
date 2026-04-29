import 'package:campussense_mobile/core/i18n/campus_copy.dart';
import 'package:campussense_mobile/features/onboarding/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash screen calls onContinue from the start button', (
    tester,
  ) async {
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          copy: CampusCopy.forLanguage('en'),
          onContinue: () => continued = true,
        ),
      ),
    );

    expect(find.text('CampusSense'), findsOneWidget);
    await tester.tap(find.text('Start sensing'));

    expect(continued, isTrue);
  });
}
