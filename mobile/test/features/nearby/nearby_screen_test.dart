import 'package:campussense_mobile/core/models/report_models.dart';
import 'package:campussense_mobile/features/nearby/nearby_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('nearby screen lists reports with distance and comfort score', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NearbyScreen(
          reportsLoader: () async => [
            CampusReport(
              id: 1,
              deviceId: 'device-1',
              latitude: 51.5246,
              longitude: -0.1340,
              scene: 'STUDY',
              movementState: 'STATIONARY',
              tags: const ['QUIET'],
              note: 'Good courtyard seat',
              comfortScore: 82,
              createdAt: DateTime(2026, 4, 28, 9),
              distanceMeters: 126,
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nearby comfort map'), findsOneWidget);
    expect(find.text('Higher comfort'), findsOneWidget);
    expect(find.text('Lower comfort'), findsOneWidget);
    expect(find.text('Nearby reports'), findsOneWidget);
    expect(find.text('126 m away'), findsOneWidget);
    expect(find.text('Good courtyard seat'), findsOneWidget);
    expect(find.text('82'), findsWidgets);
  });
}
