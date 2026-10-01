import 'dart:math' as math;

/// Model-space 2D vector.
///
/// PhET MP coordinate frame: (0,0) upper-left, +x right, +y **DOWN**.
/// Positive rotation is **CLOCKWISE** (matches `atan2(y,x)` with +y down).
class MpVector2 {
  const MpVector2(this.x, this.y);

  final double x;
  final double y;

  static const MpVector2 zero = MpVector2(0, 0);

  factory MpVector2.polar(double magnitude, double angle) => MpVector2(
        magnitude * math.cos(angle),
        magnitude * math.sin(angle),
      );

  double get angle => math.atan2(y, x);

  double get magnitude => math.sqrt(x * x + y * y);

  MpVector2 operator +(MpVector2 other) => MpVector2(x + other.x, y + other.y);

  MpVector2 operator -(MpVector2 other) => MpVector2(x - other.x, y - other.y);

  MpVector2 operator *(double s) => MpVector2(x * s, y * s);

  MpVector2 rotated(double theta) {
    final c = math.cos(theta);
    final s = math.sin(theta);
    return MpVector2(x * c - y * s, x * s + y * c);
  }

  MpVector2 average(MpVector2 other) =>
      MpVector2((x + other.x) / 2, (y + other.y) / 2);

  double distance(MpVector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      other is MpVector2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'MpVector2($x, $y)';
}
