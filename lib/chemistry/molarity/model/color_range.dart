import 'package:flutter/material.dart';

/// 颜色渐变工具：在 [min]（低浓度）与 [max]（高浓度/饱和）之间线性插值。
///
/// L1 候选组件（第 1 用户为本 sim）· 待第 3 用户（如 beer-law-lab）后上抽 common。
/// 对齐蓝本 `edu.colorado.phet.common.phetcommon.util.ColorRange`。
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
