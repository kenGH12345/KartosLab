import 'package:flutter/material.dart';

import 'color_range.dart';

/// 溶质不可变数据（对齐蓝本 `Solute.java` · ROYGBIV 色序 9 种）。
@immutable
class Solute {
  const Solute({
    required this.name,
    required this.formula,
    required this.saturatedConcentration,
    required this.solutionColor,
    required this.particleColor,
    this.particleSize = 5,
    this.particlesPerMole = 200,
  });

  final String name;
  final String formula;

  /// 饱和浓度（M）· 浓度 Derived 的封顶值。
  final double saturatedConcentration;

  /// 溶液颜色渐变（低浓度→饱和）。
  final ColorRange solutionColor;

  /// 沉淀粒子颜色（KMnO₄ 为黑例外）。
  final Color particleColor;

  /// 粒子边长（正方形）。
  final double particleSize;

  /// 每摩尔沉淀显示粒子数。
  final int particlesPerMole;

  Color get solutionColorMax => solutionColor.maxColor;
}
