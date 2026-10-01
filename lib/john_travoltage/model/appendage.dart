import 'jt_vec2.dart';

/// Base appendage — PhET `Appendage.js`.
class Appendage {
  Appendage({
    required this.position,
    required this.initialAngle,
    required this.angleMin,
    required this.angleMax,
  }) : angle = initialAngle;

  /// Pivot point in ScreenView coordinates.
  final JtVec2 position;

  final double initialAngle;
  final double angleMin;
  final double angleMax;

  double angle;
  bool dragging = false;
  bool borderVisible = true;

  void setAngle(double value) {
    angle = value.clamp(angleMin, angleMax);
  }

  void reset() {
    angle = initialAngle;
    // PhET Appendage.reset only resets angleProperty; Flutter model also
    // clears interaction flags so reset is self-contained without View.
    dragging = false;
    borderVisible = true;
  }
}
