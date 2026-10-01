import 'dart:math' as math;

import '../model/mass.dart';
import '../model/nm_vec.dart';
import '../normal_modes_constants.dart';
import 'normal_mode_math.dart';

/// Exact / Verlet / modal decomposition from `TwoDimensionsModel.js`.
class TwoDimensionsSolver {
  TwoDimensionsSolver._();

  /// sineProduct[i][j][r][s] = sin(j*r*π/(N+1)) * sin(i*s*π/(N+1))
  static List<List<List<List<double>>>> calculateSineProducts(int n) {
    final product = List<List<List<List<double>>>>.generate(
      n + 1,
      (_) => List<List<List<double>>>.generate(
        n + 1,
        (_) => List<List<double>>.generate(
          n + 1,
          (_) => List<double>.filled(n + 1, 0),
        ),
      ),
    );
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= n; j++) {
        for (var r = 1; r <= n; r++) {
          final sin = math.sin(j * r * math.pi / (n + 1));
          for (var s = 1; s <= n; s++) {
            product[i][j][r][s] = sin * math.sin(i * s * math.pi / (n + 1));
          }
        }
      }
    }
    return product;
  }

  static void setExactPositions({
    required List<List<Mass>> masses,
    required int n,
    required List<List<double>> ampX,
    required List<List<double>> ampY,
    required List<List<double>> phaseX,
    required List<List<double>> phaseY,
    required List<List<double>> frequencies,
    required List<List<List<List<double>>>> sineProduct,
    required double time,
  }) {
    final amplitudeXTimesCos = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(n + 1, 0),
    );
    final amplitudeYTimesCos = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(n + 1, 0),
    );
    final frequencyTimesAmplitudeXTimesSin = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(n + 1, 0),
    );
    final frequencyTimesAmplitudeYTimesSin = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(n + 1, 0),
    );
    final frequencySquaredTimesAmplitudeXTimesCos = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(n + 1, 0),
    );
    final frequencySquaredTimesAmplitudeYTimesCos = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(n + 1, 0),
    );

    for (var r = 1; r <= n; r++) {
      for (var s = 1; s <= n; s++) {
        final modeAmplitudeX = ampX[r - 1][s - 1];
        final modeAmplitudeY = ampY[r - 1][s - 1];
        final modeFrequency = frequencies[r - 1][s - 1];
        final modePhaseX = phaseX[r - 1][s - 1];
        final modePhaseY = phaseY[r - 1][s - 1];
        final frequencyTimesTime = modeFrequency * time;
        final mx = frequencyTimesTime - modePhaseX;
        final my = frequencyTimesTime - modePhaseY;
        final cosX = math.cos(mx);
        final cosY = math.cos(my);
        amplitudeXTimesCos[r][s] = modeAmplitudeX * cosX;
        amplitudeYTimesCos[r][s] = modeAmplitudeY * cosY;
        frequencyTimesAmplitudeXTimesSin[r][s] =
            -modeFrequency * modeAmplitudeX * math.sin(mx);
        frequencyTimesAmplitudeYTimesSin[r][s] =
            -modeFrequency * modeAmplitudeY * math.sin(my);
        frequencySquaredTimesAmplitudeXTimesCos[r][s] =
            -(modeFrequency * modeFrequency) * modeAmplitudeX * cosX;
        frequencySquaredTimesAmplitudeYTimesCos[r][s] =
            -(modeFrequency * modeFrequency) * modeAmplitudeY * cosY;
      }
    }

    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= n; j++) {
        var dx = 0.0;
        var dy = 0.0;
        var vx = 0.0;
        var vy = 0.0;
        var ax = 0.0;
        var ay = 0.0;
        final sineProductMatrix = sineProduct[i][j];
        for (var r = 1; r <= n; r++) {
          final sineProductArray = sineProductMatrix[r];
          for (var s = 1; s <= n; s++) {
            final sine = sineProductArray[s];
            dx += sine * amplitudeXTimesCos[r][s];
            dy -= sine * amplitudeYTimesCos[r][s];
            vx += sine * frequencyTimesAmplitudeXTimesSin[r][s];
            vy -= sine * frequencyTimesAmplitudeYTimesSin[r][s];
            ax += sine * frequencySquaredTimesAmplitudeXTimesCos[r][s];
            ay -= sine * frequencySquaredTimesAmplitudeYTimesCos[r][s];
          }
        }
        masses[i][j].displacement = NmVec(dx, dy);
        masses[i][j].velocity = NmVec(vx, vy);
        masses[i][j].acceleration = NmVec(ax, ay);
      }
    }
  }

  static void setVerletPositions({
    required List<List<Mass>> masses,
    required int n,
    required int? dragI,
    required int? dragJ,
    required double dt,
  }) {
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= n; j++) {
        if (dragI == i && dragJ == j) continue;
        final x = masses[i][j].displacement;
        final v = masses[i][j].velocity;
        final a = masses[i][j].acceleration;
        masses[i][j].displacement =
            x + v.times(dt) + a.times(dt * dt / 2);
        masses[i][j].previousAcceleration = a;
      }
    }
    recalculateVelocityAndAcceleration(
      masses: masses,
      n: n,
      dragI: dragI,
      dragJ: dragJ,
      dt: dt,
    );
  }

  static void recalculateVelocityAndAcceleration({
    required List<List<Mass>> masses,
    required int n,
    required int? dragI,
    required int? dragJ,
    required double dt,
  }) {
    const k = NormalModesConstants.springConstant;
    const m = NormalModesConstants.massValue;
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= n; j++) {
        if (dragI == i && dragJ == j) {
          masses[i][j].acceleration = NmVec.zero;
          masses[i][j].velocity = NmVec.zero;
          continue;
        }
        final sLeft = masses[i][j - 1].displacement;
        final sAbove = masses[i - 1][j].displacement;
        final s = masses[i][j].displacement;
        final sRight = masses[i][j + 1].displacement;
        final sUnder = masses[i + 1][j].displacement;
        masses[i][j].acceleration =
            (sLeft + sRight + sAbove + sUnder - s.times(4)).times(k / m);
        final v = masses[i][j].velocity;
        final a = masses[i][j].acceleration;
        final aLast = masses[i][j].previousAcceleration;
        masses[i][j].velocity = v + (a + aLast).times(dt / 2);
      }
    }
  }

  static void computeModeAmplitudesAndPhases({
    required List<List<Mass>> masses,
    required int n,
    required List<List<double>> ampX,
    required List<List<double>> ampY,
    required List<List<double>> phaseX,
    required List<List<double>> phaseY,
    required List<List<double>> frequencies,
    required List<List<List<List<double>>>> sineProduct,
  }) {
    for (var r = 1; r <= n; r++) {
      for (var s = 1; s <= n; s++) {
        var amplitudeTimesCosPhaseX = 0.0;
        var amplitudeTimesSinPhaseX = 0.0;
        var amplitudeTimesCosPhaseY = 0.0;
        var amplitudeTimesSinPhaseY = 0.0;
        final modeFrequency = frequencies[r - 1][s - 1];
        for (var i = 1; i <= n; i++) {
          for (var j = 1; j <= n; j++) {
            final massDisplacement = masses[i][j].displacement;
            final massVelocity = masses[i][j].velocity;
            final constantTimesSineProduct =
                (4 / ((n + 1) * (n + 1))) * sineProduct[i][j][r][s];
            amplitudeTimesCosPhaseX +=
                constantTimesSineProduct * massDisplacement.x;
            amplitudeTimesCosPhaseY -=
                constantTimesSineProduct * massDisplacement.y;
            if (modeFrequency != 0) {
              amplitudeTimesSinPhaseX +=
                  (constantTimesSineProduct / modeFrequency) * massVelocity.x;
              amplitudeTimesSinPhaseY -=
                  (constantTimesSineProduct / modeFrequency) * massVelocity.y;
            }
          }
        }
        ampX[r - 1][s - 1] = math.sqrt(
          amplitudeTimesCosPhaseX * amplitudeTimesCosPhaseX +
              amplitudeTimesSinPhaseX * amplitudeTimesSinPhaseX,
        );
        ampY[r - 1][s - 1] = math.sqrt(
          amplitudeTimesCosPhaseY * amplitudeTimesCosPhaseY +
              amplitudeTimesSinPhaseY * amplitudeTimesSinPhaseY,
        );
        phaseX[r - 1][s - 1] =
            math.atan2(amplitudeTimesSinPhaseX, amplitudeTimesCosPhaseX);
        phaseY[r - 1][s - 1] =
            math.atan2(amplitudeTimesSinPhaseY, amplitudeTimesCosPhaseY);
      }
    }
  }

  static List<List<double>> frequenciesFor(int n) {
    return List<List<double>>.generate(
      NormalModesConstants.maxMassesPerRow,
      (i) => List<double>.generate(
        NormalModesConstants.maxMassesPerRow,
        (j) => NormalModeMath.frequency2D(i, j, n),
      ),
    );
  }
}
