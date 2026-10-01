import 'package:kratos/energy_skate_park/model/esp_vec.dart';

/// Axis-aligned bounds in model meters (PhET Bounds2 subset).
class EspBounds {
  const EspBounds(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  bool containsPoint(EspVec p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;

  EspVec getClosestPoint(double px, double py) {
    final cx = px.clamp(minX, maxX);
    final cy = py.clamp(minY, maxY);
    return EspVec(cx.toDouble(), cy.toDouble());
  }
}

/// Control point defining a Track spline (ControlPoint.ts).
class ControlPoint {
  ControlPoint(
    double x,
    double y, {
    this.interactive = true,
    this.visible = true,
    this.limitBounds,
  })  : sourceX = x,
        sourceY = y;

  double sourceX;
  double sourceY;
  bool interactive;
  bool visible;
  EspBounds? limitBounds;
  ControlPoint? snapTarget;
  bool dragging = false;

  /// Position shown / used by Track (snap target if set).
  double get x => snapTarget?.x ?? sourceX;
  double get y => snapTarget?.y ?? sourceY;

  set x(double v) => sourceX = v;
  set y(double v) => sourceY = v;

  EspVec get position => EspVec(x, y);

  void reset() {
    // Callers that need initial restore should keep their own copy;
    // Phase 4 keeps source as current mutable state.
    snapTarget = null;
    dragging = false;
  }
}