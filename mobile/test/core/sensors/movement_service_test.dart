import 'package:campussense_mobile/core/sensors/movement_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifier treats tiny acceleration changes as stationary', () {
    final state = MovementClassifier.classify(const [
      MotionSample(x: 0.0, y: 0.0, z: 9.80),
      MotionSample(x: 0.02, y: 0.01, z: 9.82),
      MotionSample(x: -0.01, y: 0.02, z: 9.79),
    ]);

    expect(state, MovementState.stationary);
  });

  test('classifier treats medium acceleration variance as walking', () {
    final state = MovementClassifier.classify(const [
      MotionSample(x: 0.2, y: 0.4, z: 10.2),
      MotionSample(x: 0.9, y: 1.1, z: 8.9),
      MotionSample(x: -0.5, y: 0.7, z: 10.7),
    ]);

    expect(state, MovementState.walking);
  });

  test('classifier treats large acceleration variance as moving', () {
    final state = MovementClassifier.classify(const [
      MotionSample(x: 2.8, y: 1.4, z: 12.2),
      MotionSample(x: -3.1, y: 2.2, z: 7.6),
      MotionSample(x: 2.5, y: -2.9, z: 13.4),
    ]);

    expect(state, MovementState.moving);
  });
}
