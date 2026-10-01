import 'dart:math' as math;

import '../model/amplitude_direction.dart';
import '../model/mass.dart';
import '../model/nm_vec.dart';
import '../normal_modes_constants.dart';
import 'normal_mode_math.dart';

/// Exact / Verlet / modal decomposition from `OneDimensionModel.js`.
class OneDimensionSolver {
  OneDimensionSolver._();

  static void setExactPositions({
    required List<Mass> masses,
    required int n,
    required List<double> amplitudes,
    required List<double> phases,
    required List<double> frequencies,
    required double time,
    required AmplitudeDirection direction,
  }) {
    for (var i = 1; i <= n; i++) {
      var displacement = 0.0;
      var velocity = 0.0;
      var acceleration = 0.0;
      for (var r = 1; r <= n; r++) {
        final j = r - 1;
        final modeAmplitude = amplitudes[j];
        final modeFrequency = frequencies[j];
        final modePhase = phases[j];
        final displacementSin = math.sin(i * r * math.pi / (n + 1));
        final displacementCos =
            math.cos(modeFrequency * time - modePhase);
        final velocitySin = math.sin(modeFrequency * time - modePhase);
        final modeDisplacement =
            modeAmplitude * displacementSin * displacementCos;
        displacement += modeDisplacement;
        velocity +=
            -modeFrequency * modeAmplitude * displacementSin * velocitySin;
        acceleration += -(modeFrequency * modeFrequency) * modeDisplacement;
      }
      if (direction == AmplitudeDirection.horizontal) {
        masses[i].displacement = NmVec(displacement, 0);
        masses[i].velocity = NmVec(velocity, 0);
        masses[i].acceleration = NmVec(acceleration, 0);
      } else {
        masses[i].displacement = NmVec(0, displacement);
        masses[i].velocity = NmVec(0, velocity);
        masses[i].acceleration = NmVec(0, acceleration);
      }
    }
  }

  static void setVerletPositions({
    required List<Mass> masses,
    required int n,
    required int draggingMassIndex,
    required double dt,
  }) {
    for (var i = 1; i <= n; i++) {
      if (i == draggingMassIndex) continue;
      final x = masses[i].displacement;
      final v = masses[i].velocity;
      final a = masses[i].acceleration;
      masses[i].displacement =
          x + v.times(dt) + a.times(dt * dt / 2);
      masses[i].previousAcceleration = a;
    }
    recalculateVelocityAndAcceleration(
      masses: masses,
      n: n,
      draggingMassIndex: draggingMassIndex,
      dt: dt,
    );
  }

  static void recalculateVelocityAndAcceleration({
    required List<Mass> masses,
    required int n,
    required int draggingMassIndex,
    required double dt,
  }) {
    const k = NormalModesConstants.springConstant;
    const m = NormalModesConstants.massValue;
    for (var i = 1; i <= n; i++) {
      if (i == draggingMassIndex) {
        masses[i].acceleration = NmVec.zero;
        masses[i].velocity = NmVec.zero;
        continue;
      }
      final xLeft = masses[i - 1].displacement;
      final x = masses[i].displacement;
      final xRight = masses[i + 1].displacement;
      masses[i].acceleration =
          (xLeft + xRight - x.times(2)).times(k / m);
      final v = masses[i].velocity;
      final a = masses[i].acceleration;
      final aLast = masses[i].previousAcceleration;
      masses[i].velocity = v + (a + aLast).times(dt / 2);
    }
  }

  static void computeModeAmplitudesAndPhases({
    required List<Mass> masses,
    required int n,
    required AmplitudeDirection direction,
    required List<double> amplitudes,
    required List<double> phases,
    required List<double> frequencies,
  }) {
    for (var i = 1; i <= n; i++) {
      var amplitudeTimesCosPhase = 0.0;
      var amplitudeTimesSinPhase = 0.0;
      for (var j = 1; j <= n; j++) {
        final massDisplacement = direction == AmplitudeDirection.horizontal
            ? masses[j].displacement.x
            : masses[j].displacement.y;
        final massVelocity = direction == AmplitudeDirection.horizontal
            ? masses[j].velocity.x
            : masses[j].velocity.y;
        final amplitudeSin = math.sin(i * j * math.pi / (n + 1));
        final modeFrequency = frequencies[i - 1];
        amplitudeTimesCosPhase +=
            (2 / (n + 1)) * massDisplacement * amplitudeSin;
        if (modeFrequency != 0) {
          amplitudeTimesSinPhase +=
              (2 / (modeFrequency * (n + 1))) * massVelocity * amplitudeSin;
        }
      }
      amplitudes[i - 1] = math.sqrt(
        amplitudeTimesCosPhase * amplitudeTimesCosPhase +
            amplitudeTimesSinPhase * amplitudeTimesSinPhase,
      );
      phases[i - 1] =
          math.atan2(amplitudeTimesSinPhase, amplitudeTimesCosPhase);
    }
    for (var i = n; i < NormalModesConstants.maxMassesPerRow; i++) {
      amplitudes[i] = NormalModesConstants.initialAmplitude;
      phases[i] = NormalModesConstants.initialPhase;
    }
  }

  static List<double> frequenciesFor(int n) {
    return List<double>.generate(
      NormalModesConstants.maxMassesPerRow,
      (i) => NormalModeMath.frequency1D(i, n),
    );
  }
}
