import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// Phase 1G-1：Reset / Undo 按状态矩阵对齐原版。
///
/// Reset ≠ Undo。[已确认]
/// - Reset：BANModel.reset 销毁全部粒子数组 + BANScreenView.reset 计时/标志
///   + DecayScreenView.populateDefaultAtom(0,0)
/// - Undo：只 restore 核子计数 + 清 outgoing + 停飞出动画 + 冻结换色；
///   不清 incoming / userControlled / returning，不重置 invalid 计时。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

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

  void expectPristine(BuildANucleusController c) {
    final s = c.state;
    expect(s.isEmptyNucleus, isTrue);
    expect(s.outgoingParticles, isEmpty);
    expect(s.incomingNucleons, isEmpty);
    expect(s.draggedNucleons, isEmpty);
    expect(s.returningNucleons, isEmpty);
    expect(s.lastDecay, isNull);
    expect(s.inSpecialAlphaWindow, isFalse);
    expect(s.correctingNonexistentNuclide, isTrue);
    expect(s.invalidNuclideElapsed, 0);
    expect(s.hasIncomingParticles, isFalse);
  }

  group('Reset 全状态', () {
    test('空核 Reset 仍是空核', () {
      final c = BuildANucleusController(repository: repo);
      c.reset();
      expectPristine(c);
    });

    test('飞入中 Reset：粒子销毁，随后 tick 不会入核', () {
      final c = BuildANucleusController(repository: repo);
      c.state.addProton(fromX: 0, fromY: 300);
      expect(c.state.hasIncomingParticles, isTrue);
      c.reset();
      expectPristine(c);
      c.tick(1.0);
      expectPristine(c);
    });

    test('拖拽中 Reset 后 endDrop 不得把核子加回', () {
      final c = builtUp(1, 0);
      final n = c.startTrayDrag(NucleonType.neutron, 0, 0);
      expect(c.state.draggedNucleons, contains(n));
      c.reset();
      expect(c.state.draggedNucleons, isEmpty);
      // 松手落在核中心：修前会入核
      expect(c.endDrop(n, returnX: 0, returnY: 0), isFalse);
      expectPristine(c);
    });

    test('多指拖拽中 Reset：两枚核子都销毁，松手均无效', () {
      final c = BuildANucleusController(repository: repo);
      final a = c.startTrayDrag(NucleonType.proton, 10, 0);
      final b = c.startTrayDrag(NucleonType.neutron, -10, 0);
      expect(c.state.draggedNucleons, hasLength(2));
      c.reset();
      expect(c.endDrop(a), isFalse);
      expect(c.endDrop(b), isFalse);
      expectPristine(c);
    });

    test('归位中 Reset：returning 清空，tick 不复活', () {
      final c = BuildANucleusController(repository: repo);
      final n = c.startTrayDrag(NucleonType.proton, 250, 0);
      c.endDrop(n, returnX: 0, returnY: 0);
      expect(c.state.returningNucleons, hasLength(1));
      c.reset();
      expectPristine(c);
      c.tick(1.0);
      expectPristine(c);
    });

    test('outgoing（β 滞留）中 Reset：发射粒子与换色核子一并销毁', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      expect(c.state.outgoingParticles, isNotEmpty);
      c.tick(0.2); // 换色进行中、电子仍 hold
      c.reset();
      expectPristine(c);
      c.tick(1.0);
      expectPristine(c);
    });

    test('invalid 窗口中 Reset：计时清零，之后不会回退到旧核素', () {
      final c = BuildANucleusController(repository: repo);
      c.addNeutron();
      c.state.settleAll(); // (0,1)
      c.tick(0.016); // 写入 previousValid
      c.addNeutron();
      c.state.settleAll(); // (0,2) 不存在
      expect(c.state.isShowingInvalidNuclide, isTrue);
      c.tick(0.5);
      expect(c.state.invalidNuclideElapsed, closeTo(0.5, 1e-9));
      c.reset();
      expectPristine(c);
      c.tick(2.0); // 若 previousValid 泄漏会回到 (0,1)
      expect(c.state.neutronCount, 0);
      expect(c.state.isEmptyNucleus, isTrue);
    });

    test('Be-6 特例窗口中 Reset（射出前）', () {
      final c = builtUp(4, 2);
      c.state.applyDecay(NucleusDecayType.alphaDecay, escapeX: 0, escapeY: 10000);
      expect(c.state.inSpecialAlphaWindow, isTrue);
      c.reset();
      expectPristine(c);
    });

    test('Be-6 射出后、α 仍在飞时 Reset', () {
      final c = builtUp(4, 2);
      c.state.applyDecay(NucleusDecayType.alphaDecay, escapeX: 0, escapeY: 10000);
      c.tick(1.0); // 射出 2p，α 未到
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.inSpecialAlphaWindow, isTrue);
      c.reset();
      expectPristine(c);
      c.tick(2.0);
      expectPristine(c);
    });
  });

  group('Undo 全状态（与 Reset 不同）', () {
    test('无衰变不可 Undo', () {
      final c = builtUp(1, 0);
      expect(c.undoDecay(), isFalse);
      expect(c.state.protonCount, 1);
    });

    test('outgoing 飞行中 Undo：恢复 parent，发射粒子立即消失', () {
      final c = builtUp(1, 4); // H-5
      c.applyDecay(NucleusDecayType.neutronEmission);
      c.tick(0.2);
      expect(c.state.outgoingParticles, isNotEmpty);
      expect(c.undoDecay(), isTrue);
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 4);
      expect(c.state.outgoingParticles, isEmpty);
      expect(c.state.canUndoDecay, isFalse);
    });

    test('飞入开始后 Undo 按钮已失效（hideUndoButton / incoming.length）', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      expect(c.state.canUndoDecay, isTrue);
      c.state.addProton(fromX: 0, fromY: 300);
      expect(c.state.canUndoDecay, isFalse);
      expect(c.undoDecay(), isFalse);
      expect(c.state.hasIncomingParticles, isTrue); // Undo 并不清 incoming
      expect(c.state.protonCount, 7); // 仍是衰变后的 N-14
    });

    test('核内拖出开始后 Undo 失效（userControlled.length）', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay); // N-14 (7,7)
      final proton = c.state.protons.first;
      c.beginDrag(proton);
      expect(c.state.canUndoDecay, isFalse);
      expect(c.undoDecay(), isFalse);
      expect(c.state.draggedNucleons, contains(proton)); // Undo 并不清拖拽
    });

    test('衰变时已在拖生成器粒子：Undo 恢复核内计数，拖拽粒子保留', () {
      // [已确认] hideUndoButton 在 decay 的 handleDecayListener 里先 emit 再
      // visible=true（最后），故拖着生成器粒子仍可看到 Undo；undoDecay 不清
      // userControlled。
      final c = builtUp(4, 4); // Be-8 可 α
      final dragged = c.startTrayDrag(NucleonType.proton, 80, 0);
      expect(c.applyDecay(NucleusDecayType.alphaDecay), isTrue);
      expect(c.state.canUndoDecay, isTrue);
      expect(c.state.draggedNucleons, contains(dragged));
      expect(c.undoDecay(), isTrue);
      expect(c.state.protonCount, 4);
      expect(c.state.neutronCount, 4);
      expect(c.state.draggedNucleons, contains(dragged));
      expect(c.state.outgoingParticles, isEmpty);
    });

    test('衰变后再改核子数：Undo 失效（hideUndoButton / massNumber）', () {
      final c = builtUp(6, 8);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      expect(c.state.canUndoDecay, isTrue);
      c.addProton();
      c.state.settleAll();
      expect(c.state.canUndoDecay, isFalse);
      expect(c.undoDecay(), isFalse);
    });

    test('Be-6 射出前 Undo：恢复 Be-6，关闭特例窗口', () {
      final c = builtUp(4, 2);
      c.state.applyDecay(
        NucleusDecayType.alphaDecay,
        escapeX: 0,
        escapeY: 10000,
      );
      c.tick(0.3);
      expect(c.state.inSpecialAlphaWindow, isTrue);
      expect(c.undoDecay(), isTrue);
      expect(c.state.protonCount, 4);
      expect(c.state.neutronCount, 2);
      expect(c.state.inSpecialAlphaWindow, isFalse);
      expect(c.state.correctingNonexistentNuclide, isTrue);
      expect(c.state.outgoingParticles, isEmpty);
    });

    test('Be-6 射出后不可 Undo（massNumber 2→0 隐藏按钮）', () {
      final c = builtUp(4, 2);
      c.state.applyDecay(
        NucleusDecayType.alphaDecay,
        escapeX: 0,
        escapeY: 10000,
      );
      c.tick(1.0);
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.undoDecay(), isFalse);
    });
  });

  group('Widget：拖拽中点 Reset，松手不再入核', () {
    testWidgets('生成器拖入途中 Reset', (tester) async {
      final c = BuildANucleusController(repository: repo);
      await tester.pumpWidget(
          MaterialApp(home: BuildANucleusScreen(controller: c)));
      await tester.pump();
      final canvas = tester.getRect(find.byKey(const ValueKey('ban_canvas')));

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('质子')));
      await gesture.moveTo(canvas.center);
      await tester.pump();
      expect(c.state.draggedNucleons, hasLength(1));

      await tester.tap(find.byKey(const ValueKey('ban_reset')));
      await tester.pump();
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.draggedNucleons, isEmpty);

      await gesture.up();
      await tester.pump();
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.protonCount, 0);
      expect(c.state.returningNucleons, isEmpty);
    });
  });
}
