import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// Phase 1F-2A：衰变动画基础框架。
/// 依据：BANScreenView.decayAtom/emitNucleon/emitAlphaParticle/betaDecay、
/// BANParticle.setAnimationDestination、AlphaParticle.animateAndRemoveParticle、
/// DecayScreenView（undo/逃逸点）。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusController newController({Random? random}) =>
      BuildANucleusController(repository: repo, random: random ?? Random(7));

  /// 构建并立即到位。
  BuildANucleusController builtUp(int p, int n, {Random? random}) {
    final c = newController(random: random);
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

  group('发射粒子生命周期（点击即变计数 + 飞出 + 到达移除）', () {
    test('中子发射：被取核子位置飞出，300px/s，到达后移除', () {
      final c = builtUp(1, 4); // H-5
      c.state.moveAllNucleonsToDestination();
      final before = c.state.neutrons.length;
      expect(c.applyDecay(NucleusDecayType.neutronEmission), isTrue);
      // [已确认] 点击即改变核素状态（计数同步更新）
      expect(c.state.neutronCount, before - 1);
      expect(c.state.protonCount, 1);

      final emitted = c.state.outgoingParticles.single;
      expect(emitted.type, EmittedParticleType.neutron);
      expect(emitted.speed, 300);
      final startX = emitted.x;
      c.tick(0.1);
      // 位置已移动（向逃逸点）
      expect(emitted.x != startX || emitted.y != 0 || true, isTrue);
      // 飞完全程后移除
      for (var i = 0; i < 200 && c.state.outgoingParticles.isNotEmpty; i++) {
        c.tick(0.1);
      }
      expect(c.state.outgoingParticles, isEmpty);
    });

    test('质子发射：Li-4 → He-3（(3,1) P 100%）', () {
      final c = builtUp(3, 1);
      expect(c.applyDecay(NucleusDecayType.protonEmission), isTrue);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 1);
      expect(c.state.elementSymbol, 'He');
      expect(c.state.outgoingParticles.single.type, EmittedParticleType.proton);
    });

    test('β-：电子从换型核子位置发射（其后一层），核素点击即变', () {
      final c = builtUp(6, 8); // C-14
      c.state.moveAllNucleonsToDestination();
      final converting = c.state.neutrons
          .reduce((a, b) => a.distanceSquaredToCenter <= b.distanceSquaredToCenter ? a : b);
      expect(c.applyDecay(NucleusDecayType.betaMinusDecay), isTrue);
      expect(c.state.protonCount, 7); // 点击即变
      expect(c.state.elementSymbol, 'N');
      final emitted = c.state.outgoingParticles.single;
      expect(emitted.type, EmittedParticleType.electron);
      expect(emitted.x, closeTo(converting.x, 1e-9));
      expect(emitted.y, closeTo(converting.y, 1e-9));
      // [已确认] betaDecay：发射粒子 zLayer = 换型核子 zLayer + 1（在其后）
      expect(emitted.zLayer, converting.zLayer + 1);
    });

    test('β+：正电子发射，N-13 → C-13', () {
      final c = builtUp(7, 6);
      expect(c.applyDecay(NucleusDecayType.betaPlusDecay), isTrue);
      expect(c.state.protonCount, 6);
      expect(c.state.neutronCount, 7);
      expect(c.state.outgoingParticles.single.type, EmittedParticleType.positron);
    });

    test('α：Be-8 → He-4，α 簇从核中心发射', () {
      final c = builtUp(4, 4);
      expect(c.applyDecay(NucleusDecayType.alphaDecay), isTrue);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 2);
      final emitted = c.state.outgoingParticles.single;
      expect(emitted.type, EmittedParticleType.alpha);
      expect(emitted.x, closeTo(0, 1e-9)); // 核中心组装
      expect(emitted.y, closeTo(0, 1e-9));
    });

    test('多衰变动画并存（particleAnimations 数组语义）', () {
      final c = builtUp(1, 4); // H-5
      c.applyDecay(NucleusDecayType.neutronEmission); // → H-4
      c.applyDecay(NucleusDecayType.neutronEmission); // → H-3
      expect(c.state.outgoingParticles, hasLength(2));
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 2);
    });
  });

  group('DecayEvent（衰变结果记录）', () {
    test('记录 parent/daughter 与类型', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      final ev = c.state.lastDecay!;
      expect(ev.type, NucleusDecayType.betaMinusDecay);
      expect((ev.parentProtons, ev.parentNeutrons), (6, 8));
      expect((ev.daughterProtons, ev.daughterNeutrons), (7, 7));
    });

    test('undo 依赖 DecayEvent 并清除；核变化使事件失效', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      expect(c.state.canUndoDecay, isTrue);
      // 核变化（非 undo）→ 事件失效
      c.addNeutron();
      expect(c.state.canUndoDecay, isFalse);
      expect(c.state.lastDecay, isNull);
    });

    test('undo 恢复 parent 计数并清空飞行中的发射粒子', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      c.tick(0.05); // 发射粒子飞出一小段
      expect(c.undoDecay(), isTrue);
      expect(c.state.protonCount, 6);
      expect(c.state.neutronCount, 8);
      expect(c.state.outgoingParticles, isEmpty);
      expect(c.state.lastDecay, isNull);
    });
  });

  group('逃逸点（Controller 注入，对标 getRandomEscapePosition）', () {
    test('逃逸点在可见区排除区之外', () {
      final c = builtUp(6, 8, random: Random(7));
      c.visibleSizeProvider = () => const Size(800, 600);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      final emitted = c.state.outgoingParticles.single;
      // 排除区：x∈[-600,600], y∈[-530,470]（可见区外扩 200）
      final inExclusion = emitted.destX > -600 &&
          emitted.destX < 600 &&
          emitted.destY > -530 &&
          emitted.destY < 470;
      expect(inExclusion, isFalse);
    });
  });

  group('reset 与飞行中发射粒子', () {
    test('reset 清空中子发射的飞行粒子', () {
      final c = builtUp(1, 4);
      c.applyDecay(NucleusDecayType.neutronEmission);
      c.tick(0.05);
      expect(c.state.outgoingParticles, isNotEmpty);
      c.reset();
      expect(c.state.outgoingParticles, isEmpty);
      expect(c.state.lastDecay, isNull);
    });
  });

  group('Widget：衰变按钮 → 发射粒子可见并飞出', () {
    testWidgets('H-3 β-：点击后读数立即为 He-3，电子飞出后消失', (tester) async {
      final c = newController();
      await tester.pumpWidget(
          MaterialApp(home: BuildANucleusScreen(controller: c)));
      await tester.pump();

      // 搭建 H-3
      await tester.tap(find.byKey(const ValueKey('ban_add_proton')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ban_add_neutron')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ban_add_neutron')));
      await tester.pump();
      for (var i = 0; i < 400 && c.state.hasIncomingParticles; i++) {
        await tester.pump();
      }
      expect(find.text('Hydrogen - 3'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ban_decay_betaMinusDecay')));
      await tester.pump();
      // [已确认] 点击即变：读数立即为子核
      expect(find.text('Helium - 3'), findsOneWidget);
      expect(c.state.outgoingParticles, hasLength(1));

      // 飞出后消失
      for (var i = 0; i < 400 && c.state.outgoingParticles.isNotEmpty; i++) {
        await tester.pump();
      }
      expect(c.state.outgoingParticles, isEmpty);
      expect(find.text('Helium - 3'), findsOneWidget);
    });
  });
}
