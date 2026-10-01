import 'dart:math' as math;

/// Minimal 2D vector for Balancing Act model space (meters).
class BaVector2 {
  const BaVector2(this.x, this.y);

  final double x;
  final double y;

  static const BaVector2 zero = BaVector2(0, 0);

  BaVector2 plus(BaVector2 other) => BaVector2(x + other.x, y + other.y);

  BaVector2 minus(BaVector2 other) => BaVector2(x - other.x, y - other.y);

  BaVector2 times(double s) => BaVector2(x * s, y * s);

  double get magnitude => math.sqrt(x * x + y * y);

  double distance(BaVector2 other) => minus(other).magnitude;

  BaVector2 rotated(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return BaVector2(x * c - y * s, x * s + y * c);
  }

  /// Source: `Vector2.createPolar(magnitude, angle)`.
  static BaVector2 createPolar(double magnitude, double angle) {
    return BaVector2(
      magnitude * math.cos(angle),
      magnitude * math.sin(angle),
    );
  }

  @override
  String toString() => 'BaVector2($x, $y)';

  @override
  bool operator ==(Object other) =>
      other is BaVector2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
