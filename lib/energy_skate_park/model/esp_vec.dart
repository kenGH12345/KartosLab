import 'dart:math' as math;

/// Simple immutable 2D vector (PhET Vector2 subset used by ESP).
class EspVec {
  const EspVec(this.x, this.y);

  final double x;
  final double y;

  static const EspVec zero = EspVec(0, 0);

  EspVec operator +(EspVec o) => EspVec(x + o.x, y + o.y);
  EspVec operator -(EspVec o) => EspVec(x - o.x, y - o.y);
  EspVec operator *(double s) => EspVec(x * s, y * s);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  double distance(EspVec o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
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

  EspVec normalize() {
    final m = magnitude;
    if (m == 0) return EspVec.zero;
    return EspVec(x / m, y / m);
  }

  /// atan2(y, x) — matches PhET Vector2.angle.
  double get angle => math.atan2(y, x);

  double dot(EspVec o) => x * o.x + y * o.y;

  /// Rotate 90° CCW: (-y, x) — PhET Vector2.perpendicular.
  EspVec get perpendicular => EspVec(-y, x);

  /// this*(1-alpha) + other*alpha — PhET Vector2.blend.
  EspVec blend(EspVec other, double alpha) =>
      this + (other - this) * alpha;

  EspVec times(double s) => this * s;

  EspVec plusXY(double dx, double dy) => EspVec(x + dx, y + dy);

  /// PhET Vector2.createPolar(magnitude, angle).
  static EspVec createPolar(double magnitude, double angle) =>
      EspVec(magnitude * math.cos(angle), magnitude * math.sin(angle));

  @override
  String toString() => 'EspVec($x, $y)';
}