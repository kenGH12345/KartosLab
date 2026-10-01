import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/wave_scene.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('point source sine at known t', () {
    const t = 0.25;
    const f = 1.0;
    const phase = 0.0;
    const amp = 8.0;
    final expected = -math.sin(t * 2 * math.pi * f + phase) *
        amp *
        WavesIntroConstants.amplitudeCalibrationScale;
    final actual = WaveScene.computePointSourceValue(
      time: t,
      frequency: f,
      phase: phase,
      amplitude: amp,
    );
    expect(actual, closeTo(expected, 1e-12));
  });

  test('point source at t=0 phase=0 is 0', () {
    expect(
      WaveScene.computePointSourceValue(
        time: 0,
        frequency: 0.5,
        phase: 0,
        amplitude: 8,
      ),
      closeTo(0, 1e-12),
    );
  });

  test('forceZero returns 0', () {
    expect(
      WaveScene.computePointSourceValue(
        time: 0.1,
        frequency: 1,
        phase: 0,
        amplitude: 8,
        forceZero: true,
      ),
      0,
    );
  });
}
