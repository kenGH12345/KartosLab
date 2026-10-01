import 'dart:math' as math;

/// World-space 2D vector (metres). Immutable; physics step copies then writes.
class DensityVec {
  const DensityVec(this.x, this.y);

  static const zero = DensityVec(0, 0);

  final double x;
  final double y;

  double get magnitude => math.sqrt(x * x + y * y);

  DensityVec operator +(DensityVec o) => DensityVec(x + o.x, y + o.y);
  DensityVec operator -(DensityVec o) => DensityVec(x - o.x, y - o.y);
  DensityVec operator *(double s) => DensityVec(x * s, y * s);

  DensityVec copyWith({double? x, double? y}) =>
      DensityVec(x ?? this.x, y ?? this.y);

  @override
  bool operator ==(Object other) =>
      other is DensityVec && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
