import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/model/color_range.dart';
import 'package:kratos/chemistry/molarity/model/molarity_solute_catalog.dart';
import 'package:kratos/chemistry/molarity/model/solute.dart';
import 'package:kratos/chemistry/molarity/model/solution.dart';
import 'package:kratos/chemistry/molarity/model/solvent.dart';

void main() {
  // Source: MolarityModel.js / Solution.js (HTML5) — not Java.
  final drinkMix = MolaritySoluteCatalog.createCanonical().first;
  final k2cr2o7 = MolaritySoluteCatalog.createCanonical()[3];
  final kmno4 = MolaritySoluteCatalog.createCanonical()[8];

  Solution make(Solute s, double n, double v) =>
      Solution(solvent: const Solvent(), solute: s, soluteAmount: n, volume: v);

  group('concentration（AC-1.1 · Solution.js）', () {
    test('未饱和：n/V', () {
      expect(make(drinkMix, 0.5, 0.5).concentration, closeTo(1.0, 1e-9));
    });

    test('饱和封顶：min(sat, n/V)', () {
      expect(make(k2cr2o7, 1.0, 0.2).concentration, closeTo(0.50, 1e-9));
    });

    test('volume=0 → 浓度 0', () {
      expect(make(drinkMix, 0.5, 0).concentration, 0);
    });

    test('soluteAmount=0 → 浓度 0 · 无沉淀', () {
      final s = make(drinkMix, 0, 0.5);
      expect(s.concentration, 0);
      expect(s.precipitateAmount, 0);
      expect(s.isSaturated, isFalse);
    });
  });

  group('precipitateAmount（AC-1.2）', () {
    test('未饱和 → 0', () {
      expect(make(drinkMix, 0.5, 0.5).precipitateAmount, 0);
    });

    test('超饱和：n − V·C_sat', () {
      expect(make(k2cr2o7, 1.0, 0.5).precipitateAmount, closeTo(0.75, 1e-9));
    });

    test('volume=0 → precipitate = soluteAmount', () {
      expect(make(drinkMix, 0.8, 0).precipitateAmount, closeTo(0.8, 1e-9));
    });
  });

  group('isSaturated（AC-1.3）', () {
    test('沉淀 ≠ 0 → 饱和', () {
      expect(make(k2cr2o7, 1.0, 0.5).isSaturated, isTrue);
    });

    test('恰好饱和边界（n/V = sat）→ 不饱和', () {
      expect(make(k2cr2o7, 0.25, 0.5).isSaturated, isFalse);
    });
  });

  test('切换溶质：n/V 不变 · sat 改变 → 重算（AC-1.5）', () {
    final s = make(drinkMix, 0.5, 0.5);
    expect(s.concentration, closeTo(1.0, 1e-9));
    s.setSolute(k2cr2o7);
    expect(s.concentration, closeTo(0.50, 1e-9));
    expect(s.soluteAmount, 0.5);
    expect(s.volume, 0.5);
  });

  test('numberOfParticles：沉淀极小 >0 时至少 1 个粒子', () {
    final s = make(k2cr2o7, 0.251, 0.5);
    expect(s.precipitateAmount, greaterThan(0));
    expect(s.numberOfParticles, greaterThanOrEqualTo(1));
  });

  test('KMnO₄ particleColor = 黑', () {
    expect(kmno4.particleColor, const Color(0xFF000000));
  });

  test('solutionColor：浓度 0 → 溶剂色（AC-1.4）', () {
    expect(make(drinkMix, 0, 0.5).solutionColor, const Color(0xFFE0FFFF));
  });

  test('solutionColor：非 0 → ColorRange 插值（不越界）', () {
    final s = make(drinkMix, 0.5, 0.5);
    final c = s.solutionColor;
    expect(c, isNot(const Color(0xFFE0FFFF)));
    expect(c.r * 255, greaterThanOrEqualTo(225));
  });

  test('solutionColor：sat≤0 异常配置 → 不 Infinity', () {
    final bad = Solute(
      name: 'Bad',
      formula: 'X',
      saturatedConcentration: 0,
      solutionColor: const ColorRange(
        min: Color(0xFFFFFFFF),
        max: Color(0xFFFF0000),
      ),
      particleColor: const Color(0xFFFF0000),
    );
    final s = make(bad, 0.5, 0.5);
    expect(s.concentration, 0);
    expect(s.solutionColor, const Color(0xFFE0FFFF));
  });
}
