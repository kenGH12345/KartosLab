import 'dart:math' as math;

/// 2D vector matching PhET `dot/js/Vector2` methods used by this sim.
class NmVec {
  const NmVec(this.x, this.y);

  final double x;
  final double y;

  static const NmVec zero = NmVec(0, 0);

  NmVec operator +(NmVec o) => NmVec(x + o.x, y + o.y);
  NmVec operator -(NmVec o) => NmVec(x - o.x, y - o.y);
  NmVec operator -() => NmVec(-x, -y);

  NmVec times(double s) => NmVec(x * s, y * s);

  double get magnitude => math.sqrt(x * x + y * y);

  double get angle => math.atan2(y, x);

  double distance(NmVec o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      other is NmVec && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'NmVec($x, $y)';
}
