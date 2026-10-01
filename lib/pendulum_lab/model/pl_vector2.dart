import 'dart:math' as math;

/// Model-space 2D vector (y-up). PhET `dot/js/Vector2.js`.
class PlVector2 {
  const PlVector2(this.x, this.y);

  final double x;
  final double y;

  static const PlVector2 zero = PlVector2(0, 0);

  /// `Vector2.createPolar(magnitude, angle)` — angle 0 = +x, CCW in y-up.
  factory PlVector2.polar(double magnitude, double angle) => PlVector2(
        magnitude * math.cos(angle),
        magnitude * math.sin(angle),
      );

  double get angle => math.atan2(y, x);

  double get magnitude => math.sqrt(x * x + y * y);

  PlVector2 operator +(PlVector2 other) => PlVector2(x + other.x, y + other.y);

  PlVector2 operator -(PlVector2 other) => PlVector2(x - other.x, y - other.y);

  PlVector2 operator *(double s) => PlVector2(x * s, y * s);

  PlVector2 rotated(double theta) {
    final c = math.cos(theta);
    final s = math.sin(theta);
    return PlVector2(x * c - y * s, x * s + y * c);
  }

  @override
  String toString() => 'PlVector2($x, $y)';
}
