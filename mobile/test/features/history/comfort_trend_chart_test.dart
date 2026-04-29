import 'package:campussense_mobile/core/models/history_models.dart';
import 'package:campussense_mobile/features/history/widgets/comfort_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comfort trend chart renders a chart title and painter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComfortTrendChart(
            points: [
              HistoryTrendPoint(
                createdAt: DateTime(2026, 4, 28, 9),
                comfortScore: 62,
                aqi: 40,
                temperature: 18.5,
              ),
              HistoryTrendPoint(
                createdAt: DateTime(2026, 4, 28, 10),
                comfortScore: 78,
                aqi: 35,
                temperature: 20.0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Comfort trend'), findsOneWidget);
    expect(find.byKey(const Key('comfort-trend-painter')), findsOneWidget);
  });
}
