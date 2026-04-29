import 'package:campussense_mobile/core/i18n/campus_copy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns English labels by default', () {
    final copy = CampusCopy.forLanguage('en');

    expect(copy.dashboard, 'Dashboard');
    expect(copy.nearby, 'Nearby');
    expect(copy.startSensing, 'Start sensing');
  });

  test('returns Chinese labels for zh language preference', () {
    final copy = CampusCopy.forLanguage('zh');

    expect(copy.dashboard, '仪表盘');
    expect(copy.nearby, '附近');
    expect(copy.startSensing, '开始感知');
  });
}
