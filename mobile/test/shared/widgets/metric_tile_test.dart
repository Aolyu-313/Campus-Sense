import 'package:campussense_mobile/shared/widgets/metric_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MetricTile renders label value and helper', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricTile(
            label: 'AQI',
            value: '42',
            helper: 'Good',
            icon: Icons.eco_outlined,
          ),
        ),
      ),
    );

    expect(find.text('AQI'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
  });
}
