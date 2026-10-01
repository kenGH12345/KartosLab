import 'dart:math' as math;

/// Fresnel s-polarized power fractions from `BendingLightModel.ts`.
///
/// Note: callers pass cos of the **transmitted** angle as [cosTheta2]
/// (Intro & Prisms), matching PhET source despite a misleading param comment.
class Fresnel {
  Fresnel._();

  /// R = ((n1·cosθ1 − n2·cosθ2) / (n1·cosθ1 + n2·cosθ2))²
  static double getReflectedPower(
    double n1,
    double n2,
    double cosTheta1,
    double cosTheta2,
  ) {
    final num_ = n1 * cosTheta1 - n2 * cosTheta2;
    final den = n1 * cosTheta1 + n2 * cosTheta2;
    return math.pow(num_ / den, 2).toDouble();
  }

  /// T = 4·n1·n2·cosθ1·cosθ2 / (n1·cosθ1 + n2·cosθ2)²
  static double getTransmittedPower(
    double n1,
    double n2,
    double cosTheta1,
    double cosTheta2,
  ) {
    final den = n1 * cosTheta1 + n2 * cosTheta2;
    return 4 * n1 * n2 * cosTheta1 * cosTheta2 / (den * den);
  }

  static double clamp01(double v) {
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }
}
