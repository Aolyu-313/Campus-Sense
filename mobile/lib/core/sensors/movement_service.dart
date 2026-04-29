import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

enum MovementState {
  stationary('STATIONARY', 'Stationary'),
  lowMotion('LOW_MOTION', 'Low motion'),
  walking('WALKING', 'Walking'),
  moving('MOVING', 'Moving'),
  unknown('UNKNOWN', 'Unknown');

  const MovementState(this.code, this.label);

  final String code;
  final String label;
}

class MotionSample {
  const MotionSample({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;

  double get magnitude => sqrt(x * x + y * y + z * z);
}

class MovementClassifier {
  static MovementState classify(List<MotionSample> samples) {
    if (samples.length < 2) {
      return MovementState.unknown;
    }

    final magnitudes = samples.map((sample) => sample.magnitude).toList();
    final mean = magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    final meanDeviation =
        magnitudes
            .map((value) => (value - mean).abs())
            .reduce((a, b) => a + b) /
        magnitudes.length;

    if (meanDeviation < 0.20) {
      return MovementState.stationary;
    }
    if (meanDeviation < 0.55) {
      return MovementState.lowMotion;
    }
    if (meanDeviation < 1.65) {
      return MovementState.walking;
    }
    return MovementState.moving;
  }
}

class MovementService {
  const MovementService();

  Future<MovementState> sampleMovementState({
    Duration timeout = const Duration(milliseconds: 900),
    int sampleCount = 12,
  }) async {
    try {
      final samples =
          await userAccelerometerEventStream(
                samplingPeriod: SensorInterval.uiInterval,
              )
              .map((event) => MotionSample(x: event.x, y: event.y, z: event.z))
              .take(sampleCount)
              .toList()
              .timeout(timeout);
      return MovementClassifier.classify(samples);
    } on TimeoutException {
      return MovementState.unknown;
    } catch (_) {
      return MovementState.unknown;
    }
  }
}
