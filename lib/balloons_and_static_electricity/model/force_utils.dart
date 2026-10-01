import 'dart:math' as math;

import 'base_vec2.dart';

/// Coulomb-like force helper — PhET `BalloonModel.getForce`.
abstract final class ForceUtils {
  /// Force from [p2] toward/away based on [kqq] / r^[power], direction unit(p1−p2).
  ///
  /// Default [power] is 2. Wall polarization uses 2.35.
  static BaseVec2 getForce(
    BaseVec2 p1,
    BaseVec2 p2,
    double kqq, {
    double power = 2,
  }) {
    final difference = p1.minus(p2);
    final r = difference.magnitude;
    if (r == 0) {
      return BaseVec2.zero;
    }
    final unit = difference.normalize();
    final scale = kqq / math.pow(r, power);
    return unit.timesScalar(scale.toDouble());
  }

  /// Cap force magnitude to [maxMagnitude] (PhET max = 1E-2).
  static BaseVec2 capMagnitude(BaseVec2 force, double maxMagnitude) {
    final mag = force.magnitude;
    if (mag > maxMagnitude) {
      return force.normalize().timesScalar(maxMagnitude);
    }
    return force;
  }
}
