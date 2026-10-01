/// Mutable 2D vector for the PEFRL engine.
///
/// Matches `dot/js/Vector2` mutation used by `NumericalEngine.ts`.
library;

import 'dart:math' as math;

class MssVec {
  MssVec(this.x, this.y);

  factory MssVec.zero() => MssVec(0, 0);

  double x;
  double y;

  double get magnitude => math.sqrt(x * x + y * y);

  double distance(MssVec o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  MssVec copy() => MssVec(x, y);

  MssVec setFrom(MssVec other) {
    x = other.x;
    y = other.y;
    return this;
  }

  MssVec setXY(double nx, double ny) {
    x = nx;
    y = ny;
    return this;
  }

  MssVec operator +(MssVec o) => MssVec(x + o.x, y + o.y);
  MssVec operator -(MssVec o) => MssVec(x - o.x, y - o.y);
  MssVec operator *(double s) => MssVec(x * s, y * s);

  MssVec add(MssVec o) {
    x += o.x;
    y += o.y;
    return this;
  }

  MssVec subtract(MssVec o) {
    x -= o.x;
    y -= o.y;
    return this;
  }

  MssVec multiplyScalar(double s) {
    x *= s;
    y *= s;
    return this;
  }

  bool equals(MssVec o) => x == o.x && y == o.y;
}
