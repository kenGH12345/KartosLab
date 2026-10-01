import 'dart:math' as math;

/// Mutable 2D vector for model space.
class MtVec2 {
  MtVec2(this.x, this.y);

  double x;
  double y;

  MtVec2 copy() => MtVec2(x, y);

  void set(MtVec2 other) {
    x = other.x;
    y = other.y;
  }

  void setXY(double nx, double ny) {
    x = nx;
    y = ny;
  }

  MtVec2 operator +(MtVec2 o) => MtVec2(x + o.x, y + o.y);

  MtVec2 scaled(double s) => MtVec2(x * s, y * s);

  double get length => math.sqrt(x * x + y * y);

  MtVec2 normalized() {
    final len = length;
    if (len < 1e-12) return MtVec2(1, 0);
    return MtVec2(x / len, y / len);
  }

  double distanceTo(MtVec2 o) {
    final dx = x - o.x;
    final dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  String toString() => 'MtVec2($x, $y)';
}

class MtSize {
  const MtSize(this.width, this.height);
  final double width;
  final double height;
}

class MtBounds {
  const MtBounds(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;

  bool intersects(MtBounds o) =>
      minX < o.maxX && maxX > o.minX && minY < o.maxY && maxY > o.minY;

  MtBounds dilated(double amount) =>
      MtBounds(minX - amount, minY - amount, maxX + amount, maxY + amount);
}
