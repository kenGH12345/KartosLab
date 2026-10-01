import '../gflb_constants.dart';

/// Force calculation and arrow-width mapping (ISLC / GFLB).
class ForceSolver {
  ForceSolver._();

  static double calculateForce(double m1, double m2, double distance) {
    assert(distance > 0);
    return GflbConstants.g * m1 * m2 / (distance * distance);
  }

  /// Min force magnitude over value/position extremes (ISLCModel.getMinForceMagnitude).
  static double getMinForceMagnitude({
    double massMin = GflbConstants.massMin,
    double leftBoundary = -GflbConstants.pullPositionMax,
    double rightBoundary = GflbConstants.pullPositionMax,
  }) {
    final maxDistance = (rightBoundary - leftBoundary).abs();
    return calculateForce(massMin, massMin, maxDistance).abs();
  }

  /// Alias used by puller range (ISLCModel.getMinForce for gravity = abs).
  static double getMinForce({
    double massMin = GflbConstants.massMin,
    double leftBoundary = -GflbConstants.pullPositionMax,
    double rightBoundary = GflbConstants.pullPositionMax,
  }) =>
      getMinForceMagnitude(
        massMin: massMin,
        leftBoundary: leftBoundary,
        rightBoundary: rightBoundary,
      );

  /// Max force at max masses and min center separation with constant radii.
  static double getMaxForce({
    double massMax = GflbConstants.massMax,
    double constantRadius = 0,
    double minSeparation = GflbConstants.minDistanceBetweenMasses,
    double snap = GflbConstants.massPositionDelta,
  }) {
    final r = constantRadius > 0
        ? constantRadius
        : GflbConstants.constantRadius;
    final minCenters = snapToGrid(r * 2 + minSeparation, snap);
    return calculateForce(massMax, massMax, minCenters).abs();
  }

  /// Piecewise linear arrow width (ISLCForceArrowNode + GFLB params).
  static double arrowMappedWidth(
    double forceAbs, {
    required double forceMin,
    required double forceMax,
    double minArrowWidth = GflbConstants.minArrowWidth,
    double thresholdArrowWidth = GflbConstants.thresholdArrowWidth,
    double maxArrowWidth = GflbConstants.maxArrowWidth,
    double forceThresholdPercent = GflbConstants.forceThresholdPercent,
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

  /// Tip length in view px = mappedWidth * ARROW_LENGTH (8).
  static double arrowTipLength(double mappedWidth) =>
      mappedWidth * GflbConstants.arrowLengthFactor;

  static double snapToGrid(double position, [double? delta]) {
    final snap = delta ?? GflbConstants.massPositionDelta;
    if (snap <= 0) return position;
    var snapped = _roundSymmetric(position / snap) * snap;
    snapped = double.parse(snapped.toStringAsFixed(_decimalPlaces(snap)));
    snapped = snapped.clamp(
      -GflbConstants.pullPositionMax,
      GflbConstants.pullPositionMax,
    );
    return snapped;
  }

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

  static double _roundSymmetric(double value) =>
      value < 0 ? -value.abs().roundToDouble() : value.roundToDouble();

  static int _decimalPlaces(double value) {
    final s = value.toString();
    final i = s.indexOf('.');
    if (i < 0) return 0;
    return s.length - i - 1;
  }

  /// Puller frame index 0..30 from force (GFLB: pull images only).
  static int pullerFrameIndex(
    double forceAbs, {
    required double forceMin,
    required double forceMax,
    int frameCount = GflbConstants.pullerFrameCount,
  }) {
    final t = _linear(forceAbs, forceMin, forceMax, 0, frameCount - 1);
    final clamped = t.clamp(0, frameCount - 1).toDouble();
    return _roundSymmetric(clamped).toInt().clamp(0, frameCount - 1);
  }
}
