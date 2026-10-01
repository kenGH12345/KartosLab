import 'dart:math' as math;

/// Simple 2D vector for CAF model (no Flutter dependency).
class CafVec2 {
  const CafVec2(this.x, this.y);

  final double x;
  final double y;

  static const CafVec2 zero = CafVec2(0, 0);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  double distance(CafVec2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double distanceSquared(CafVec2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  CafVec2 operator +(CafVec2 o) => CafVec2(x + o.x, y + o.y);
  CafVec2 operator -(CafVec2 o) => CafVec2(x - o.x, y - o.y);
  CafVec2 operator *(double s) => CafVec2(x * s, y * s);
  CafVec2 operator -() => CafVec2(-x, -y);

  CafVec2 plus(CafVec2 o) => this + o;
  CafVec2 minus(CafVec2 o) => this - o;
  CafVec2 timesScalar(double s) => this * s;
  CafVec2 dividedScalar(double s) => CafVec2(x / s, y / s);

  CafVec2 normalize() {
    final m = magnitude;
    if (m == 0) return CafVec2.zero;
    return CafVec2(x / m, y / m);
  }

  /// Rotate by [angle] radians (counterclockwise in model coords).
  CafVec2 rotate(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return CafVec2(x * c - y * s, x * s + y * c);
  }

  double get angle => math.atan2(y, x);

  double angleBetween(CafVec2 other) {
    final a = normalize();
    final b = other.normalize();
    final dot = (a.x * b.x + a.y * b.y).clamp(-1.0, 1.0);
    return math.acos(dot);
  }

  /// 2D cross product magnitude (z-component).
  double crossScalar(CafVec2 other) => x * other.y - y * other.x;

  CafVec2 roundedSymmetric() => CafVec2(x.roundToDouble(), y.roundToDouble());

  bool equals(CafVec2 other, {double eps = 0}) {
    if (eps == 0) return x == other.x && y == other.y;
    return (x - other.x).abs() <= eps && (y - other.y).abs() <= eps;
  }

  @override
  bool operator ==(Object other) =>
      other is CafVec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'CafVec2($x, $y)';
}

class CafBounds2 {
  const CafBounds2(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
  CafVec2 get center => CafVec2((minX + maxX) / 2, (minY + maxY) / 2);

  bool containsPoint(CafVec2 p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;

  CafBounds2 intersect(CafBounds2 other) {
    return CafBounds2(
      math.max(minX, other.minX),
      math.max(minY, other.minY),
      math.min(maxX, other.maxX),
      math.min(maxY, other.maxY),
    );
  }
}
