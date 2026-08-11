import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'solute.dart';
import 'solvent.dart';

/// 溶液模型：Intrinsic（solute / soluteAmount / volume）+ Derived（concentration / precipitate 等）。
///
/// Derived 全部为 getter 即时计算（对齐蓝本 `Solution.java:31-56` · 严禁独立可写字段）：
/// - concentration = min(饱和浓度, soluteAmount / volume)（volume≤0 时为 0）
/// - precipitateAmount = max(0, volume × (n/V − 饱和浓度))（volume≤0 时为 soluteAmount）
/// - isSaturated = precipitateAmount > 0
/// - numberOfParticles = max(1, floor(particlesPerMole × precipitateAmount))
class Solution extends ChangeNotifier {
  Solution({
    required this.solvent,
    required this.solute,
    this.soluteAmount = 0.5,
    this.volume = 0.5,
  });

  final Solvent solvent;

  /// 当前溶质（Intrinsic P1）。
  Solute solute;

  /// 溶质量 mol（Intrinsic P2 · 0–1）。
  double soluteAmount;

  /// 溶液体积 L（Intrinsic P3 · 0.2–1）。
  double volume;

  /// 摩尔浓度（M）· Derived。
  double get concentration => volume > 0
      ? math.min(solute.saturatedConcentration, soluteAmount / volume)
      : 0;

  /// 沉淀量 mol · Derived。
  double get precipitateAmount => volume > 0
      ? math.max(0, volume * (soluteAmount / volume - solute.saturatedConcentration))
      : soluteAmount;

  /// 是否饱和 · Derived。
  bool get isSaturated => precipitateAmount > 0;

  /// 沉淀粒子数 · Derived（>0 时至少 1 个粒子）。
  int get numberOfParticles {
    final n = (solute.particlesPerMole * precipitateAmount).floor();
    return precipitateAmount > 0 && n < 1 ? 1 : n;
  }

  /// 溶液颜色 · Derived：浓度 0 → 溶剂色；否则 ColorRange 按 浓度/饱和浓度 插值。
  /// 饱和浓度 ≤0 的异常配置 → 直接取饱和色（防除零 Infinity）。
  Color get solutionColor {
    if (concentration <= 0) return solvent.color;
    final sat = solute.saturatedConcentration;
    if (sat <= 0) return solute.solutionColor.maxColor;
    final t = concentration / sat;
    return solute.solutionColor.interpolate(t);
  }

  void setSolute(Solute v) {
    solute = v;
    notifyListeners();
  }

  void setSoluteAmount(double v) {
    soluteAmount = v;
    notifyListeners();
  }

  void setVolume(double v) {
    volume = v;
    notifyListeners();
  }
}
