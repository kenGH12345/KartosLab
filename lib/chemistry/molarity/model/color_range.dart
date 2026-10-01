import 'package:flutter/material.dart';

/// Color range — interpolate between [min] (low non-zero) and [max] (saturated).
///
/// Source: PhET Scenery `Color.interpolateRGBA` used by `Solution.getColor()`.
/// Molarity-local; do not reuse Beer's Law Lab color tables.
@immutable
class ColorRange {
  const ColorRange({required this.min, required this.max});

  final Color min;
  final Color max;

  Color get maxColor => max;

  /// 按 t∈[0,1] 在 min→max 线性插值（越界自动 clamp）。
  Color interpolate(double t) =>
      Color.lerp(min, max, t.clamp(0.0, 1.0))!;
}
