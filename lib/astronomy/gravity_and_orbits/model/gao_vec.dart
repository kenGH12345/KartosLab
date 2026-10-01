/// Lightweight 2D vector for Gravity and Orbits model (no Flutter dependency).
library;

import 'dart:math' as math;

class GaoVec {
  double x;
  double y;

  GaoVec(this.x, this.y);

  factory GaoVec.zero() => GaoVec(0, 0);

  GaoVec copy() => GaoVec(x, y);

  void setXY(double nx, double ny) {
    x = nx;
    y = ny;
  }

  void setFrom(GaoVec o) {
    x = o.x;
    y = o.y;
  }

  double get magnitude => math.sqrt(x * x + y * y);

  GaoVec operator +(GaoVec o) => GaoVec(x + o.x, y + o.y);
  GaoVec operator -(GaoVec o) => GaoVec(x - o.x, y - o.y);
  GaoVec operator *(double s) => GaoVec(x * s, y * s);

  void add(GaoVec o) {
    x += o.x;
    y += o.y;
  }

  void addScaled(GaoVec o, double s) {
    x += o.x * s;
    y += o.y * s;
  }

  GaoVec times(double s) => GaoVec(x * s, y * s);

  GaoVec normalized() {
    final m = magnitude;
    if (m == 0) return GaoVec.zero();
    return GaoVec(x / m, y / m);
  }

  bool equalsApprox(GaoVec o, [double eps = 1e-12]) =>
      (x - o.x).abs() < eps && (y - o.y).abs() < eps;

  @override
  String toString() => 'GaoVec($x, $y)';
}
