import 'gravity_force_constants.dart';

/// Force calculation helpers — PhET `ISLCModel.calculateForce` / arrow range.
class ForceSolver {
  ForceSolver._();

  static double calculateForce(double m1, double m2, double distance) {
    assert(distance > 0, 'must have non zero distance between objects');
    return GravityForceConstants.gravitationalConstant * m1 * m2 /
        (distance * distance);
  }

  static double getMinForceMagnitude({
    double massMin = GravityForceConstants.massMin,
    double leftBoundary = -GravityForceConstants.pullPositionMax,
    double rightBoundary = GravityForceConstants.pullPositionMax,
  }) {
    final maxDistance = (rightBoundary - leftBoundary).abs();
    return calculateForce(massMin, massMin, maxDistance).abs();
  }

  /// Gravity always attractive → same as [getMinForceMagnitude].
  static double getMinForce({
    double massMin = GravityForceConstants.massMin,
    double leftBoundary = -GravityForceConstants.pullPositionMax,
    double rightBoundary = GravityForceConstants.pullPositionMax,
  }) =>
      getMinForceMagnitude(
        massMin: massMin,
        leftBoundary: leftBoundary,
        rightBoundary: rightBoundary,
      );

  /// Max force at max masses and min centers with constant radii.
  static double getMaxForce({
    double massMax = GravityForceConstants.massMax,
    double constantRadius = GravityForceConstants.constantRadius,
    double minSeparation = GravityForceConstants.minSeparationBetweenObjects,
    double snap = GravityForceConstants.positionSnap,
  }) {
    final minCenters = GravityForceConstants.snapToGrid(
      constantRadius * 2 + minSeparation,
      snap,
    );
    return calculateForce(massMax, massMax, minCenters).abs();
  }

  /// Piecewise linear arrow width (ISLCForceArrowNode + Full MassNode params).
  static double arrowMappedWidth(
    double forceAbs, {
    required double forceMin,
    required double forceMax,
    double minArrowWidth = GravityForceConstants.minArrowWidth,
    double thresholdArrowWidth = GravityForceConstants.thresholdArrowWidth,
    double maxArrowWidth = GravityForceConstants.maxArrowWidth,
    double forceThresholdPercent = GravityForceConstants.forceThresholdPercent,
  }) {
    final forceThreshold =
        forceMin + (forceMax - forceMin) * forceThresholdPercent;
    if (forceAbs < forceThreshold) {
      return _linear(
        forceAbs,
        forceMin,
        forceThreshold,
        minArrowWidth,
        thresholdArrowWidth,
      );
    }
    return _linear(
      forceAbs,
      forceThreshold,
      forceMax,
      thresholdArrowWidth,
      maxArrowWidth,
    );
  }

  static double arrowTipLength(double mappedWidth) =>
      mappedWidth * GravityForceConstants.arrowLengthFactor;

  static double _linear(
    double x,
    double x0,
    double x1,
    double y0,
    double y1,
  ) {
    if ((x1 - x0).abs() < 1e-30) return y0;
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
  }
}
