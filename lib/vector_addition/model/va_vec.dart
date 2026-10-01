import 'dart:math' as math;

import '../vector_addition_constants.dart';

/// 2D vector in Vector Addition model space (+x right, +y up).
/// Mirrors PhET `dot/Vector2` usage for this sim only — not a cross-sim framework.
class VaVec {
  const VaVec(this.x, this.y);

  final double x;
  final double y;

  static const VaVec zero = VaVec(0, 0);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  /// Angle in radians via atan2(y, x). Null convention for zero is handled by callers.
  double get angle => math.atan2(y, x);

  VaVec operator +(VaVec o) => VaVec(x + o.x, y + o.y);
  VaVec operator -(VaVec o) => VaVec(x - o.x, y - o.y);
  VaVec operator -() => VaVec(-x, -y);
  VaVec operator *(double s) => VaVec(x * s, y * s);

  VaVec plus(VaVec o) => this + o;
  VaVec minus(VaVec o) => this - o;
  VaVec timesScalar(double s) => this * s;

  double distance(VaVec o) => (this - o).magnitude;

  bool equalsEpsilon(VaVec o, [double epsilon = 1e-7]) =>
      (x - o.x).abs() <= epsilon && (y - o.y).abs() <= epsilon;

  bool get isEffectivelyZero =>
      magnitude < VectorAdditionConstants.zeroThreshold;

  VaVec withX(double nx) => VaVec(nx, y);
  VaVec withY(double ny) => VaVec(x, ny);

  /// PhET `Vector2.setPolar` / `createPolar`.
  static VaVec createPolar(double magnitude, double angleRadians) =>
      VaVec(magnitude * math.cos(angleRadians), magnitude * math.sin(angleRadians));

  VaVec withMagnitude(double mag) {
    final m = magnitude;
    if (m == 0) return VaVec(mag, 0);
    return this * (mag / m);
  }

  /// PhET `roundedSymmetric` on each component (to integers).
  VaVec roundedSymmetric() =>
      VaVec(roundSymmetric(x), roundSymmetric(y));

  static double roundSymmetric(double v) {
    return v < 0
        ? -(v.abs() + 0.5).floorToDouble()
        : (v + 0.5).floorToDouble();
  }

  @override
  bool operator ==(Object other) =>
      other is VaVec && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'VaVec($x, $y)';
}

/// Axis-aligned bounds in model space.
class VaBounds {
  const VaBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
  VaVec get center => VaVec((minX + maxX) / 2, (minY + maxY) / 2);

  static final VaBounds defaultGraph = VaBounds(
    minX: VectorAdditionConstants.defaultGraphMinX,
    minY: VectorAdditionConstants.defaultGraphMinY,
    maxX: VectorAdditionConstants.defaultGraphMaxX,
    maxY: VectorAdditionConstants.defaultGraphMaxY,
  );

  /// Explore 1D centered origin.
  static VaBounds explore1dCentered() {
    final w = defaultGraph.width;
    final h = defaultGraph.height;
    return VaBounds(minX: -w / 2, minY: -h / 2, maxX: w / 2, maxY: h / 2);
  }

  bool containsPoint(VaVec p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;

  VaVec closestPointTo(VaVec p) => VaVec(
        p.x.clamp(minX, maxX).toDouble(),
        p.y.clamp(minY, maxY).toDouble(),
      );

  VaBounds eroded(double margin) => VaBounds(
        minX: minX + margin,
        minY: minY + margin,
        maxX: maxX - margin,
        maxY: maxY - margin,
      );

  VaBounds shiftedXY(double dx, double dy) => VaBounds(
        minX: minX + dx,
        minY: minY + dy,
        maxX: maxX + dx,
        maxY: maxY + dy,
      );

  @override
  bool operator ==(Object other) =>
      other is VaBounds &&
      other.minX == minX &&
      other.minY == minY &&
      other.maxX == maxX &&
      other.maxY == maxY;

  @override
  int get hashCode => Object.hash(minX, minY, maxX, maxY);
}
