import 'dart:math' as math;

/// Simple 2D vector for Rutherford Scattering model (PhET Vector2 subset).
class RsVec2 {
  const RsVec2(this.x, this.y);

  final double x;
  final double y;

  static const RsVec2 zero = RsVec2(0, 0);

  RsVec2 operator +(RsVec2 o) => RsVec2(x + o.x, y + o.y);
  RsVec2 operator -(RsVec2 o) => RsVec2(x - o.x, y - o.y);
  RsVec2 operator *(double s) => RsVec2(x * s, y * s);

  double get length => math.sqrt(x * x + y * y);

  RsVec2 get normalized {
    final len = length;
    if (len == 0) return RsVec2.zero;
    return RsVec2(x / len, y / len);
  }

  /// Perpendicular rotated by −π/2 — matches PhET Vector2.perpendicular `(y, -x)`.
  RsVec2 get perpendicular => RsVec2(y, -x);

  double get angle => math.atan2(y, x);

  RsVec2 rotated(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return RsVec2(x * c - y * s, x * s + y * c);
  }

  RsVec2 minus(RsVec2 o) => this - o;
  RsVec2 plus(RsVec2 o) => this + o;

  @override
  String toString() => 'RsVec2($x, $y)';
}

/// Axis-aligned bounds (PhET Bounds2 subset).
class RsBounds2 {
  const RsBounds2(this.minX, this.minY, this.maxX, this.maxY);

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
  double get centerX => (minX + maxX) / 2;
  double get centerY => (minY + maxY) / 2;

  bool containsPoint(RsVec2 p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;
}

/// Axis-aligned rectangle used as atom boundingRect.
class RsRect {
  RsRect(this.center, this.width)
      : half = width / 2,
        bounds = RsBounds2(
          center.x - width / 2,
          center.y - width / 2,
          center.x + width / 2,
          center.y + width / 2,
        );

  final RsVec2 center;
  final double width;
  final double half;
  final RsBounds2 bounds;

  bool containsPoint(RsVec2 p) => bounds.containsPoint(p);
}

/// Circle containing the atom bounding square.
class RsCircle {
  RsCircle(this.center, this.radius);

  final RsVec2 center;
  final double radius;

  bool containsPoint(RsVec2 p) {
    final dx = p.x - center.x;
    final dy = p.y - center.y;
    return dx * dx + dy * dy <= radius * radius;
  }
}

/// Rotated rectangle: AABB rotated around [pivot] by [angle].
class RsRotatedRect {
  RsRotatedRect({
    required this.pivot,
    required this.halfWidth,
    required this.angle,
  });

  final RsVec2 pivot;
  final double halfWidth;
  final double angle;

  bool containsPoint(RsVec2 p) {
    final local = (p - pivot).rotated(-angle);
    return local.x.abs() <= halfWidth && local.y.abs() <= halfWidth;
  }
}
