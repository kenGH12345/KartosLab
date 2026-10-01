import 'dart:math' as math;

import '../constants/qwi_constants.dart';
import '../domain/slit_configuration.dart';

/// Options matching `DetectorPatternOptions` (meters).
class FraunhoferOptions {
  const FraunhoferOptions({
    required this.positionOnScreenM,
    required this.effectiveWavelengthM,
    required this.screenDistanceM,
    required this.slitWidthM,
    required this.slitSeparationM,
    required this.slitSetting,
  });

  final double positionOnScreenM;
  final double effectiveWavelengthM;
  final double screenDistanceM;
  final double slitWidthM;
  final double slitSeparationM;
  final SlitConfiguration slitSetting;
}

/// Port of `DetectorPattern.ts`.
///
/// Uses unnormalized `sinc(x) = sin(x)/x` with argument `π a sinθ / λ`.
class FraunhoferSolver {
  const FraunhoferSolver();

  /// `sinc²(x) = (sin(x)/x)²`, limit 1 at x=0.
  static double sincSquared(double x) {
    if (x == 0) {
      return 1;
    }
    final s = math.sin(x) / x;
    return s * s;
  }

  static double getSingleSlitEnvelopeIntensity({
    required double positionOnScreenM,
    required double effectiveWavelengthM,
    required double screenDistanceM,
    required double slitWidthM,
  }) {
    if (effectiveWavelengthM == 0) {
      return 0;
    }
    final sinTheta = positionOnScreenM /
        math.sqrt(positionOnScreenM * positionOnScreenM + screenDistanceM * screenDistanceM);
    final singleSlitArg = math.pi * slitWidthM * sinTheta / effectiveWavelengthM;
    return sincSquared(singleSlitArg);
  }

  static double getExactDetectorIntensity(FraunhoferOptions options) {
    final lambda = options.effectiveWavelengthM;
    if (lambda == 0) {
      return 0;
    }

    if (options.slitSetting == SlitConfiguration.noBarrier) {
      return 1;
    }

    final slitSetting = options.slitSetting;

    if (slitSetting == SlitConfiguration.leftCovered || slitSetting == SlitConfiguration.rightCovered) {
      final uncoveredSlitOffset =
          slitSetting == SlitConfiguration.leftCovered ? options.slitSeparationM / 2 : -options.slitSeparationM / 2;
      return QwiConstants.singleOpenSlitIntensityScale *
          getSingleSlitEnvelopeIntensity(
            positionOnScreenM: options.positionOnScreenM - uncoveredSlitOffset,
            effectiveWavelengthM: lambda,
            screenDistanceM: options.screenDistanceM,
            slitWidthM: options.slitWidthM,
          );
    }

    final envelope = getSingleSlitEnvelopeIntensity(
      positionOnScreenM: options.positionOnScreenM,
      effectiveWavelengthM: lambda,
      screenDistanceM: options.screenDistanceM,
      slitWidthM: options.slitWidthM,
    );

    if (slitSetting.hasAnyDetector) {
      return envelope;
    }

    final sinTheta = options.positionOnScreenM /
        math.sqrt(
          options.positionOnScreenM * options.positionOnScreenM + options.screenDistanceM * options.screenDistanceM,
        );
    final doubleSlitArg = math.pi * options.slitSeparationM * sinTheta / lambda;
    return math.pow(math.cos(doubleSlitArg), 2).toDouble() * envelope;
  }

  /// Sample intensity curve over physical positions (meters relative to screen center).
  static List<double> sampleIntensity({
    required int sampleCount,
    required double halfWidthM,
    required double effectiveWavelengthM,
    required double screenDistanceM,
    required double slitWidthM,
    required double slitSeparationM,
    required SlitConfiguration slitSetting,
  }) {
    final out = List<double>.filled(sampleCount, 0);
    for (var i = 0; i < sampleCount; i++) {
      final t = (i + 0.5) / sampleCount;
      final y = (t - 0.5) * 2 * halfWidthM;
      out[i] = getExactDetectorIntensity(
        FraunhoferOptions(
          positionOnScreenM: y,
          effectiveWavelengthM: effectiveWavelengthM,
          screenDistanceM: screenDistanceM,
          slitWidthM: slitWidthM,
          slitSeparationM: slitSeparationM,
          slitSetting: slitSetting,
        ),
      );
    }
    return out;
  }
}
