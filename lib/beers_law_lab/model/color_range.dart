import 'dart:ui';

/// PhET `ColorRange` — linear RGBA interpolation between [min] and [max].
class ColorRange {
  const ColorRange(this.min, this.max);

  final Color min;
  final Color max;

  /// [distance] in [0, 1].
  Color interpolateLinear(double distance) {
    assert(distance >= 0 && distance <= 1);
    return Color.lerp(min, max, distance)!;
  }
}
