import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/painters/nucleus_painter.dart';

/// Phase 1F-2B-1：β 衰变 0.5s 换色动画。
/// 依据：ParticleAtom.changeNucleonType（0.5s 线性 base color 插值、
/// 动画期间 inputEnabled=false、完成后回调）+ BANScreenView.betaDecay
/// （发射粒子在 onChangeComplete 回调中才飞出）。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  const neutronColor = Color(BanConstants.neutronColorValue);
  const protonColor = Color(BanConstants.protonColorValue);

  BuildANucleusController builtUp(int p, int n) {
    final c = BuildANucleusController(repository: repo);
    while (c.state.protonCount < p || c.state.neutronCount < n) {
      if (c.state.protonCount < p && c.state.neutronCount < n) {
        c.addPair();
      } else if (c.state.protonCount < p) {
        c.addProton();
      } else {
        c.addNeutron();
      }
      c.state.settleAll();
    }
    return c;
  }

  /// β- 后换型核子（唯一那个 colorAnimating 或新类型的核子）。
  Nucleon convertingNucleon(BuildANucleusController c) {
    // β-：中子→质子，换型核子现在在 protons 里且带换色标记
    return c.state.protons.firstWhere((n) => n.isColorAnimating);
  }

  group('β- 换色动画（中子 → 质子）', () {
    test('点击即换型（状态立即更新），换色从 0 开始', () {
      final c = builtUp(6, 8); // C-14
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      final n = convertingNucleon(c);
      expect(n.type, NucleonType.proton); // 状态立即变
      expect(n.colorAnimatingFrom, NucleonType.neutron);
      expect(n.colorProgress, 0);
      expect(c.state.protonCount, 7);
      expect(c.state.neutronCount, 7);
    });

    test('0s / 中间 / 0.5s 完成的颜色插值（线性）', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      final n = convertingNucleon(c);

      // 0s：纯旧色（中子灰）
      expect(NucleusPainter.baseColorFor(n), neutronColor);

      c.tick(0.25); // 半程：线性插值中点
      expect(n.colorProgress, closeTo(0.5, 1e-9));
      expect(
        NucleusPainter.baseColorFor(n),
        Color.lerp(neutronColor, protonColor, 0.5),
      );

      c.tick(0.25); // 0.5s 完成
      expect(n.isColorAnimating, isFalse);
      expect(NucleusPainter.baseColorFor(n), protonColor);
    });

    test('zLayer 在换色期间不变', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      final n = convertingNucleon(c);
      final z = n.zLayer;
      c.tick(0.25);
      expect(n.zLayer, z);
    });

    test('换色期间该核子不可拖，完成后可拖', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      final n = convertingNucleon(c);
      // [已确认] issue#115：换色中 inputEnabled=false
      expect(c.state.beginNucleonDrag(n), isNull);
      expect(c.state.protonCount, 7); // 未被取出
      c.tick(0.6);
      expect(c.state.beginNucleonDrag(n), same(n));
    });

    test('电子滞留 0.5s 后才飞出（onChangeComplete 才启动发射动画）', () {
      final c = builtUp(6, 8);
      // 确定性逃逸点走 state 层（controller 层为随机注入）
      c.state.applyDecay(NucleusDecayType.betaMinusDecay, escapeX: 500, escapeY: 0);
      final e = c.state.outgoingParticles.single;
      expect(e.type, EmittedParticleType.electron);
      final x0 = e.x;

      c.tick(0.25);
      expect(e.x, x0); // 滞留中不动
      c.tick(0.25); // 滞留结束（0.5s）
      expect(e.x, x0);
      c.tick(0.1); // 开始飞出
      expect(e.x, greaterThan(x0));
    });
  });

  group('β+ 换色动画（质子 → 中子）', () {
    test('换型、颜色方向与发射正电子滞留', () {
      final c = builtUp(7, 6); // N-13
      c.state.applyDecay(NucleusDecayType.betaPlusDecay, escapeX: 500, escapeY: 0);
      expect(c.state.protonCount, 6);
      expect(c.state.neutronCount, 7);

      final n = c.state.neutrons.firstWhere((n) => n.isColorAnimating);
      expect(n.type, NucleonType.neutron);
      expect(n.colorAnimatingFrom, NucleonType.proton);
      expect(NucleusPainter.baseColorFor(n), protonColor); // 0s：质子色
      c.tick(0.5);
      expect(NucleusPainter.baseColorFor(n), neutronColor); // 完成：中子色

      final e = c.state.outgoingParticles.single;
      expect(e.type, EmittedParticleType.positron);
      expect(e.holdTime, 0); // 0.5s 滞留已结束
      c.tick(0.1);
      expect(e.x, greaterThan(0)); // 开始飞出
    });
  });

  group('边界', () {
    test('换色动画中 reset → 清空无残留', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      c.tick(0.25); // 换色进行中
      c.reset();
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.outgoingParticles, isEmpty);
      expect(c.state.lastDecay, isNull);
    });

    test('undo 在换色动画中：恢复计数 + 颜色冻结（对标 clearAnimations）', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      c.tick(0.25); // 换色进行中（progress=0.5）
      expect(c.undoDecay(), isTrue);
      expect(c.state.protonCount, 6);
      expect(c.state.neutronCount, 8);
      expect(c.state.outgoingParticles, isEmpty);
      // [已确认] 原版 undo 停止换色动画、颜色定格中间值（不恢复也不完成）。
      // 换型核子离中心最近，undo 移除的是最远质子 → 它留在核内并冻结。
      final frozen =
          c.state.protons.where((n) => n.colorAnimatingFrom != null).toList();
      expect(frozen, hasLength(1));
      expect(frozen.single.isColorAnimating, isFalse); // 已停止推进
      expect(
        NucleusPainter.baseColorFor(frozen.single),
        Color.lerp(neutronColor, protonColor, 0.5), // 冻结在半途混合色
      );
      c.tick(0.5);
      expect(frozen.single.colorProgress, closeTo(0.5, 1e-9)); // 不再推进
    });
  });
}
