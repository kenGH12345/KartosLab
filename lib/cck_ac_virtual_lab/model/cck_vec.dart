import 'dart:math' as math;

class CckVec {
  const CckVec(this.x, this.y);

  final double x;
  final double y;

  static const CckVec zero = CckVec(0, 0);

  double get length => math.sqrt(x * x + y * y);

  double distanceTo(CckVec other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  CckVec operator +(CckVec o) => CckVec(x + o.x, y + o.y);
  CckVec operator -(CckVec o) => CckVec(x - o.x, y - o.y);
  CckVec operator *(double s) => CckVec(x * s, y * s);

  CckVec normalized() {
    final len = length;
    if (len == 0) return this;
    return CckVec(x / len, y / len);
  }

  CckVec lerp(CckVec other, double t) =>
      CckVec(x + (other.x - x) * t, y + (other.y - y) * t);

  double dot(CckVec o) => x * o.x + y * o.y;
}