import 'dart:math' as math;

import 'appendage.dart';
import 'john_travoltage_constants.dart';

/// Leg appendage — PhET `Leg.js` (+ `LegNode.limitRotation` for View).
class Leg extends Appendage {
  Leg()
      : super(
          position: JohnTravoltageConstants.legPivot,
          initialAngle: JohnTravoltageConstants.legInitialAngle,
          angleMin: JohnTravoltageConstants.legAngleMin,
          angleMax: JohnTravoltageConstants.legAngleMax,
        );

  /// radians/s — updated by [JohnTravoltageModel.step].
  double angularVelocity = 0;

  /// True when foot angle is strictly inside carpet window (Leg.js).
  bool get shoeOnCarpet =>
      angle > JohnTravoltageConstants.footOnCarpetMinAngle &&
      angle < JohnTravoltageConstants.footOnCarpetMaxAngle;

  /// `angle - initialAngle` (Leg.js `deltaAngle`).
  double deltaAngle() => angle - initialAngle;

  /// View drag clamp from `LegNode.js` — restricts to bottom semicircle.
  static double limitRotation(double angle) {
    if (angle < -math.pi / 2) {
      return math.pi;
    }
    if (angle > -math.pi / 2 && angle < 0) {
      return 0;
    }
    return angle;
  }

  @override
  void reset() {
    angularVelocity = 0;
    super.reset();
  }
}
