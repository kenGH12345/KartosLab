import 'dart:math' as math;

/// 2D vector in model meters (+x right, +y up). Mirrors PhET `dot/Vector2` usage.
class ClVec {
  const ClVec(this.x, this.y);

  final double x;
  final double y;

  static const ClVec zero = ClVec(0, 0);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  ClVec operator +(ClVec o) => ClVec(x + o.x, y + o.y);
  ClVec operator -(ClVec o) => ClVec(x - o.x, y - o.y);
  ClVec operator -() => ClVec(-x, -y);
  ClVec operator *(double s) => ClVec(x * s, y * s);
  ClVec operator /(double s) => ClVec(x / s, y / s);

  double dot(ClVec o) => x * o.x + y * o.y;

  /// 2D cross product scalar: x1*y2 - y1*x2
  double crossScalar(ClVec o) => x * o.y - y * o.x;

  ClVec normalized() {
    final m = magnitude;
    if (m == 0) return ClVec.zero;
    return this / m;
  }

  ClVec rotated(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return ClVec(c * x - s * y, s * x + c * y);
  }

  ClVec withX(double nx) => ClVec(nx, y);
  ClVec withY(double ny) => ClVec(x, ny);

  /// Unit vector in +x (PhET `Vector2.X_UNIT`).
  static const ClVec xUnit = ClVec(1, 0);

  ClVec withMagnitude(double mag) {
    final m = magnitude;
    if (m == 0) return ClVec(mag, 0);
    return this * (mag / m);
  }

  ClVec roundSymmetricScaled(double multiple) {
    // Matches Vector2.dividedScalar(m).roundSymmetric().multiply(m)
    final sx = x / multiple;
    final sy = y / multiple;
    return ClVec(_roundSymmetric(sx) * multiple, _roundSymmetric(sy) * multiple);
  }

  static double _roundSymmetric(double v) {
    // PhET Utils.roundSymmetric
    return v < 0 ? -(v.abs() + 0.5).floorToDouble() : (v + 0.5).floorToDouble();
  }

  @override
  bool operator ==(Object other) =>
      other is ClVec && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'ClVec($x, $y)';
}

/// Axis-aligned bounds in model space.
class ClBounds {
  const ClBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
  double get left => minX;
  double get right => maxX;
  double get bottom => minY;
  double get top => maxY;
  ClVec get center => ClVec((minX + maxX) / 2, (minY + maxY) / 2);

  ClBounds eroded(double amount) => ClBounds(
        minX: minX + amount,
        minY: minY + amount,
        maxX: maxX - amount,
        maxY: maxY - amount,
      );

  ClVec closestPointTo(ClVec p) {
    // Guard inverted bounds (can occur if erosion + grid round-in collapses an axis).
    final loX = minX <= maxX ? minX : maxX;
    final hiX = minX <= maxX ? maxX : minX;
    final loY = minY <= maxY ? minY : maxY;
    final hiY = minY <= maxY ? maxY : minY;
    return ClVec(p.x.clamp(loX, hiX), p.y.clamp(loY, hiY));
  }

  bool containsPoint(ClVec p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;
}
