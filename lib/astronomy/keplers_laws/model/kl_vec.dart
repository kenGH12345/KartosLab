/// 2D vector helpers matching phetsims/dot Vector2 methods used by the engine.
library;

import 'dart:math' as math;

class KlVec {
  const KlVec(this.x, this.y);

  final double x;
  final double y;

  static const KlVec zero = KlVec(0, 0);

  double get magnitude => math.sqrt(x * x + y * y);

  double get angle => math.atan2(y, x);

  bool get isZero => x == 0 && y == 0;

  KlVec operator +(KlVec o) => KlVec(x + o.x, y + o.y);

  KlVec operator -(KlVec o) => KlVec(x - o.x, y - o.y);

  KlVec times(double s) => KlVec(x * s, y * s);

  /// [已确认] Vector2.perpendicular = (-y, x)
  KlVec get perpendicular => KlVec(-y, x);

  KlVec normalized() {
    final m = magnitude;
    if (m == 0) return KlVec.zero;
    return times(1 / m);
  }

  double distance(KlVec o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// [已确认] Vector2.crossScalar
  double cross(KlVec o) => x * o.y - y * o.x;

  double dot(KlVec o) => x * o.x + y * o.y;

  /// [已确认] Vector2.rotated — CCW
  KlVec rotated(double radians) {
    final c = math.cos(radians);
    final s = math.sin(radians);
    return KlVec(x * c - y * s, x * s + y * c);
  }

  /// Absolute angle between this and [o].
  double angleBetween(KlVec o) {
    final m = magnitude * o.magnitude;
    if (m == 0) return 0;
    final c = (dot(o) / m).clamp(-1.0, 1.0);
    return math.acos(c);
  }

  /// [已确认] Vector2.createPolar
  static KlVec polar(double magnitude, double angle) =>
      KlVec(magnitude * math.cos(angle), magnitude * math.sin(angle));

  bool equals(KlVec o) => x == o.x && y == o.y;

  @override
  String toString() => 'KlVec($x, $y)';
}

/// [已确认] dot Utils.moduloBetweenDown
double moduloBetweenDown(double value, double min, double max) {
  final period = max - min;
  if (period == 0) return min;
  var v = (value - min) % period;
  if (v < 0) v += period;
  return v + min;
}
