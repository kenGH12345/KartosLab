import 'dart:math' as math;

/// Immutable 2D vector in model space. +y is up.
class BVec2 {
  const BVec2(this.x, this.y);

  final double x;
  final double y;

  static const zero = BVec2(0, 0);

  double get magnitude => math.sqrt(x * x + y * y);

  bool get isFinite => x.isFinite && y.isFinite;

  BVec2 operator +(BVec2 o) => BVec2(x + o.x, y + o.y);
  BVec2 operator -(BVec2 o) => BVec2(x - o.x, y - o.y);
  BVec2 operator *(double s) => BVec2(x * s, y * s);
  BVec2 operator -() => BVec2(-x, -y);

  BVec2 plusXY(double dx, double dy) => BVec2(x + dx, y + dy);

  BVec2 withMagnitude(double m) {
    final mag = magnitude;
    if (mag == 0) {
      return zero;
    }
    return this * (m / mag);
  }

  BVec2 clampMagnitude(double maxMag) {
    final mag = magnitude;
    if (mag <= maxMag || mag == 0) {
      return this;
    }
    return this * (maxMag / mag);
  }

  @override
  bool operator ==(Object other) =>
      other is BVec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'BVec2($x, $y)';
}
