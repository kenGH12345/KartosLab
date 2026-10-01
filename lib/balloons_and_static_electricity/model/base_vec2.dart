import 'dart:math' as math;

/// Immutable 2D vector — PhET `dot/js/Vector2` subset for BASE.
class BaseVec2 {
  const BaseVec2(this.x, this.y);

  final double x;
  final double y;

  static const BaseVec2 zero = BaseVec2(0, 0);

  BaseVec2 operator +(BaseVec2 o) => BaseVec2(x + o.x, y + o.y);
  BaseVec2 operator -(BaseVec2 o) => BaseVec2(x - o.x, y - o.y);
  BaseVec2 operator *(double s) => BaseVec2(x * s, y * s);
  BaseVec2 operator -() => BaseVec2(-x, -y);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  double distance(BaseVec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  BaseVec2 plus(BaseVec2 o) => this + o;
  BaseVec2 minus(BaseVec2 o) => this - o;
  BaseVec2 timesScalar(double s) => this * s;

  BaseVec2 minusXY(double dx, double dy) => BaseVec2(x - dx, y - dy);

  BaseVec2 normalize() {
    final m = magnitude;
    if (m == 0) return BaseVec2.zero;
    return BaseVec2(x / m, y / m);
  }

  /// PhET `Vector2.setMagnitude(1)` then scale — unit then times.
  BaseVec2 withMagnitude(double mag) {
    final m = magnitude;
    if (m == 0) return BaseVec2.zero;
    return BaseVec2(x / m * mag, y / m * mag);
  }

  BaseVec2 copy() => BaseVec2(x, y);

  @override
  bool operator ==(Object other) =>
      other is BaseVec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'BaseVec2($x, $y)';
}
