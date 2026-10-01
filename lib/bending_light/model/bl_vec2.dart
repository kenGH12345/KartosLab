import 'dart:math' as math;

/// Model-space 2D vector (SI meters). No Flutter dependency.
class BlVec2 {
  const BlVec2(this.x, this.y);

  final double x;
  final double y;

  static const BlVec2 zero = BlVec2(0, 0);

  factory BlVec2.polar(double magnitude, double angle) =>
      BlVec2(magnitude * math.cos(angle), magnitude * math.sin(angle));

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;
  double get angle => math.atan2(y, x);

  double distance(BlVec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double distanceSquared(BlVec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return dx * dx + dy * dy;
  }

  BlVec2 operator +(BlVec2 o) => BlVec2(x + o.x, y + o.y);
  BlVec2 operator -(BlVec2 o) => BlVec2(x - o.x, y - o.y);
  BlVec2 operator *(double s) => BlVec2(x * s, y * s);
  BlVec2 operator -() => BlVec2(-x, -y);

  BlVec2 plusXY(double dx, double dy) => BlVec2(x + dx, y + dy);
  BlVec2 times(double s) => this * s;

  double dot(BlVec2 o) => x * o.x + y * o.y;
  double dotXY(double ox, double oy) => x * ox + y * oy;
  double cross(BlVec2 o) => x * o.y - y * o.x;

  BlVec2 normalize() {
    final m = magnitude;
    if (m == 0) return BlVec2.zero;
    return BlVec2(x / m, y / m);
  }

  /// Counterclockwise rotation (model +y up).
  BlVec2 rotate(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return BlVec2(x * c - y * s, x * s + y * c);
  }

  BlVec2 rotated(double angle) => rotate(angle);

  bool get isFiniteVec => x.isFinite && y.isFinite;

  @override
  bool operator ==(Object other) =>
      other is BlVec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'BlVec2($x, $y)';
}

/// Infinite ray: position + unit direction.
class BlRay2 {
  const BlRay2(this.position, this.direction);

  final BlVec2 position;
  final BlVec2 direction;
}
