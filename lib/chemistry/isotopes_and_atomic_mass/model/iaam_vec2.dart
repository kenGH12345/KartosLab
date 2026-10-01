/// Pure-Dart 2D vector for IAAM model space (not Flutter Offset).
library;

import 'dart:math' as math;

class IaamVec2 {
  const IaamVec2(this.x, this.y);

  final double x;
  final double y;

  static const IaamVec2 zero = IaamVec2(0, 0);

  double distanceTo(IaamVec2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double get length => math.sqrt(x * x + y * y);

  IaamVec2 operator +(IaamVec2 o) => IaamVec2(x + o.x, y + o.y);

  IaamVec2 operator -(IaamVec2 o) => IaamVec2(x - o.x, y - o.y);

  IaamVec2 operator *(double s) => IaamVec2(x * s, y * s);

  @override
  bool operator ==(Object other) =>
      other is IaamVec2 && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'IaamVec2($x, $y)';
}
