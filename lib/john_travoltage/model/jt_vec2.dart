import 'dart:math' as math;

/// Immutable 2D vector — PhET `dot/js/Vector2` subset for John Travoltage.
class JtVec2 {
  const JtVec2(this.x, this.y);

  final double x;
  final double y;

  static const JtVec2 zero = JtVec2(0, 0);

  JtVec2 operator +(JtVec2 o) => JtVec2(x + o.x, y + o.y);
  JtVec2 operator -(JtVec2 o) => JtVec2(x - o.x, y - o.y);
  JtVec2 operator *(double s) => JtVec2(x * s, y * s);
  JtVec2 operator -() => JtVec2(-x, -y);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  /// atan2(y, x) — matches PhET `Vector2.angle`.
  double get angle => math.atan2(y, x);

  double distance(JtVec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double distanceSquared(JtVec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return dx * dx + dy * dy;
  }

  double distanceXY(double ox, double oy) {
    final dx = x - ox;
    final dy = y - oy;
    return math.sqrt(dx * dx + dy * dy);
  }

  double distanceSquaredXY(double ox, double oy) {
    final dx = x - ox;
    final dy = y - oy;
    return dx * dx + dy * dy;
  }

  JtVec2 plus(JtVec2 o) => this + o;
  JtVec2 minus(JtVec2 o) => this - o;
  JtVec2 timesScalar(double s) => this * s;
  JtVec2 times(double s) => this * s;

  JtVec2 normalize() {
    final m = magnitude;
    if (m == 0) return JtVec2.zero;
    return JtVec2(x / m, y / m);
  }

  double dot(JtVec2 o) => x * o.x + y * o.y;

  /// Rotate 90° CCW: (-y, x) — PhET `Vector2.perpendicular`.
  JtVec2 get perpendicular => JtVec2(-y, x);

  /// this*(1-alpha) + other*alpha — PhET `Vector2.blend`.
  JtVec2 blend(JtVec2 other, double alpha) => this + (other - this) * alpha;

  /// Rotate about origin by [angle] radians — PhET `Vector2.rotated`.
  JtVec2 rotated(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return JtVec2(x * c - y * s, x * s + y * c);
  }

  /// PhET `Vector2.createPolar(magnitude, angle)`.
  static JtVec2 createPolar(double magnitude, double angle) =>
      JtVec2(magnitude * math.cos(angle), magnitude * math.sin(angle));

  @override
  bool operator ==(Object other) =>
      other is JtVec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'JtVec2($x, $y)';
}

/// Mutable velocity vector (PhET Electron.velocity with `set` / `setXY`).
class JtMutableVec2 {
  JtMutableVec2(this.x, this.y);

  double x;
  double y;

  double get magnitude => math.sqrt(x * x + y * y);

  double dot(JtVec2 o) => x * o.x + y * o.y;

  void set(JtVec2 v) {
    x = v.x;
    y = v.y;
  }

  void setXY(double nx, double ny) {
    x = nx;
    y = ny;
  }

  JtVec2 toVec2() => JtVec2(x, y);

  JtVec2 minus(JtVec2 o) => JtVec2(x - o.x, y - o.y);

  JtVec2 timesScalar(double s) => JtVec2(x * s, y * s);
}
