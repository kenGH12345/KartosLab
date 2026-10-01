import 'dart:math' as math;

import 'fresnel.dart';

/// Scalar Snell's law for Intro / More Tools (`IntroModel.propagateRays`).
/// Separated from [VectorSnell] — do not merge.
class IntroSnellResult {
  const IntroSnellResult({
    required this.theta1,
    required this.theta2,
    required this.hasTransmittedRay,
    required this.reflectedPowerRatio,
    required this.transmittedPowerRatio,
    required this.hasReflectedRay,
    required this.thetaCritical,
  });

  /// Angle from upward vertical (rad).
  final double theta1;

  /// Angle from downward vertical (rad); may be NaN if TIR path.
  final double theta2;

  final bool hasTransmittedRay;
  final double reflectedPowerRatio;
  final double transmittedPowerRatio;
  final bool hasReflectedRay;
  final double thetaCritical;
}

class IntroSnell {
  IntroSnell._();

  /// [laserAngle] = `Laser.getAngle()` (rad).
  static IntroSnellResult compute({
    required double n1,
    required double n2,
    required double laserAngle,
  }) {
    final theta1 = laserAngle - math.pi / 2;
    final theta2 = math.asin(n1 / n2 * math.sin(theta1));

    final thetaOfTotalInternalReflection = math.asin(n2 / n1);
    var hasTransmittedRay = thetaOfTotalInternalReflection.isNaN ||
        theta1 < thetaOfTotalInternalReflection;

    late double reflectedPowerRatio;
    if (hasTransmittedRay) {
      reflectedPowerRatio = Fresnel.getReflectedPower(
        n1,
        n2,
        math.cos(theta1),
        math.cos(theta2),
      );
    } else {
      reflectedPowerRatio = 1.0;
    }

    // #296 — if nothing transmitted, do not create 0-power transmitted ray
    if (reflectedPowerRatio == 1.0) {
      hasTransmittedRay = false;
    }

    var hasReflectedRay = reflectedPowerRatio >= 0.005;
    var transmittedPowerRatio = 0.0;

    if (hasTransmittedRay && !theta2.isNaN && theta2.isFinite) {
      transmittedPowerRatio = Fresnel.getTransmittedPower(
        n1,
        n2,
        math.cos(theta1),
        math.cos(theta2),
      );
      if (!hasReflectedRay) {
        transmittedPowerRatio = 1.0;
        reflectedPowerRatio = 0.0;
      }
    } else if (!hasReflectedRay) {
      reflectedPowerRatio = 0.0;
    }

    return IntroSnellResult(
      theta1: theta1,
      theta2: theta2,
      hasTransmittedRay: hasTransmittedRay && !theta2.isNaN && theta2.isFinite,
      reflectedPowerRatio: hasReflectedRay ? reflectedPowerRatio : 0.0,
      transmittedPowerRatio: hasTransmittedRay && !theta2.isNaN && theta2.isFinite
          ? transmittedPowerRatio
          : 0.0,
      hasReflectedRay: hasReflectedRay,
      thetaCritical: thetaOfTotalInternalReflection,
    );
  }
}
