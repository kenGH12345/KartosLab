import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

/// Phase 1F-2B-2：Be-6 α Hollywood 特例。
///
/// 依据：DecayScreenView.emitAlphaParticle 在 super（普通 α）之后的附加分支；
/// doc/model.md Hollywood 段。触发条件是 α 后剩余 (2p, 0n)，表内唯 Be-6。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusController builtUp(int p, int n, {Random? random}) {
    final c = BuildANucleusController(
      repository: repo,
      random: random ?? Random(7),
    );
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

  /// 沿 +Y 飞出，便于用时间精确换算距离。
  const escapeY = 10000.0;
  const extraA = (10000.0, 0.0);
  const extraB = (-10000.0, 0.0);

  const triggerDistance =
      BanConstants.timeToShowDoesNotExist * BanConstants.particleAnimationSpeed;

  void applyBe6Alpha(BuildANucleusController c) {
    c.state.applyDecay(
      NucleusDecayType.alphaDecay,
      escapeX: 0,
      escapeY: escapeY,
      extraEscapes: const [extraA, extraB],
    );
  }

  group('Be-6 触发与点击即时状态', () {
    test('Be-6(4p,2n) 可 α，点击后立即变为 2p0n（不是 0p0n）', () {
      final c = builtUp(4, 2);
      expect(c.state.protonCount, 4);
      expect(c.state.neutronCount, 2);
      expect(c.state.elementSymbol, 'Be');
      expect(c.state.isDecayEnabled(NucleusDecayType.alphaDecay), isTrue);

      applyBe6Alpha(c);

      // [已确认] 与普通 α 相同：点击即 extract 2p2n，计数同步更新
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 0);
      expect(c.state.isShowingInvalidNuclide, isTrue); // He-2 不存在
      expect(c.state.isEmptyNucleus, isFalse);
      expect(c.state.correctingNonexistentNuclide, isFalse);
      expect(c.state.inSpecialAlphaWindow, isTrue);
      expect(c.state.hasEmittedSpecialProtons, isFalse);
    });

    test('α 从核中心创建，destination 为注入的逃逸点', () {
      final c = builtUp(4, 2);
      c.state.moveAllNucleonsToDestination();
      applyBe6Alpha(c);

      final alpha = c.state.outgoingParticles.single;
      expect(alpha.type, EmittedParticleType.alpha);
      expect(alpha.x, closeTo(0, 1e-9));
      expect(alpha.y, closeTo(0, 1e-9));
      expect(alpha.destX, 0);
      expect(alpha.destY, escapeY);
      expect(alpha.speed, BanConstants.particleAnimationSpeed);
    });

    test('剩余 2 质子留在核内且不可拖', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);
      expect(c.state.protons, hasLength(2));
      expect(c.state.neutrons, isEmpty);
      // [已确认] 特例窗口内 remaining protons inputEnabled=false
      expect(c.state.beginNucleonDrag(c.state.protons.first), isNull);
      expect(c.state.draggedNucleons, isEmpty);
      expect(c.state.protonCount, 2);
    });
  });

  group('特例时序：α 飞满 300px 才强制射出 2 质子', () {
    test('飞不满 300px 时仍是 2p0n，不触发 1s 自动回退', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);

      // 0.9s × 300px/s = 270px < 300px；同时也 < 1s 纠正窗口
      c.tick(0.9);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 0);
      expect(c.state.hasEmittedSpecialProtons, isFalse);
      expect(c.state.outgoingParticles, hasLength(1));
      expect(c.state.outgoingParticles.single.type, EmittedParticleType.alpha);
      expect(c.state.outgoingParticles.single.distanceTraveled, closeTo(270, 1e-6));
      // correcting=false → 无效核素计时不累计，不会回退到 Be-6
      expect(c.state.invalidNuclideElapsed, 0);
      expect(c.state.protonCount, isNot(4));
    });

    test('α 飞满 300px：2 质子从核内位置射出，核变 0p0n', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);
      c.state.moveAllNucleonsToDestination();
      final remaining = List<Nucleon>.from(c.state.protons);
      expect(remaining, hasLength(2));
      final startA = (remaining[0].x, remaining[0].y);
      final startB = (remaining[1].x, remaining[1].y);

      c.tick(1.0); // 恰好 TIME_TO_SHOW_DOES_NOT_EXIST × 300px/s
      expect(
        c.state.outgoingParticles
            .firstWhere((p) => p.type == EmittedParticleType.alpha)
            .distanceTraveled,
        closeTo(triggerDistance, 1e-6),
      );
      expect(c.state.hasEmittedSpecialProtons, isTrue);
      expect(c.state.protonCount, 0);
      expect(c.state.neutronCount, 0);
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.isShowingInvalidNuclide, isFalse); // 0p0n 合法空态
      expect(c.state.lastDecay, isNull); // 质量数 2→0 隐藏 undo

      final protons = c.state.outgoingParticles
          .where((p) => p.type == EmittedParticleType.proton)
          .toList();
      expect(protons, hasLength(2));
      // 起点 = 被取质子当时位置（emitNucleon），不是核中心
      final starts = protons.map((p) => (p.x, p.y)).toSet();
      expect(starts, containsAll([startA, startB]));
      expect(
        protons.map((p) => (p.destX, p.destY)).toSet(),
        {extraA, extraB},
      );
      expect(protons.every((p) => p.speed == 300), isTrue);

      // α 仍在飞（目的地远），特例窗口尚未关
      expect(c.state.inSpecialAlphaWindow, isTrue);
      expect(
        c.state.outgoingParticles.any((p) => p.type == EmittedParticleType.alpha),
        isTrue,
      );
    });

    test('α 到达后关闭特例窗口，恢复自动回退标志', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);
      for (var i = 0; i < 400 && c.state.inSpecialAlphaWindow; i++) {
        c.tick(0.1);
      }
      expect(c.state.inSpecialAlphaWindow, isFalse);
      expect(c.state.correctingNonexistentNuclide, isTrue);
      expect(c.state.isEmptyNucleus, isTrue);
      expect(
        c.state.outgoingParticles.any((p) => p.type == EmittedParticleType.alpha),
        isFalse,
      );
    });
  });

  group('Reset / Undo', () {
    test('undo 在强制射出前：恢复 Be-6，关闭窗口，清空 outgoing', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);
      c.tick(0.3);
      expect(c.state.canUndoDecay, isTrue);
      expect(c.undoDecay(), isTrue);
      expect(c.state.protonCount, 4);
      expect(c.state.neutronCount, 2);
      expect(c.state.elementSymbol, 'Be');
      expect(c.state.outgoingParticles, isEmpty);
      expect(c.state.inSpecialAlphaWindow, isFalse);
      expect(c.state.correctingNonexistentNuclide, isTrue);
      expect(c.state.lastDecay, isNull);
    });

    test('强制射出后不可 undo（质量数变化隐藏按钮）', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);
      c.tick(1.0);
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.canUndoDecay, isFalse);
      expect(c.undoDecay(), isFalse);
    });

    test('reset 在特例窗口中：清空一切并关闭窗口', () {
      final c = builtUp(4, 2);
      applyBe6Alpha(c);
      expect(c.state.inSpecialAlphaWindow, isTrue);
      c.reset();
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.outgoingParticles, isEmpty);
      expect(c.state.inSpecialAlphaWindow, isFalse);
      expect(c.state.hasEmittedSpecialProtons, isFalse);
      expect(c.state.correctingNonexistentNuclide, isTrue);
      expect(c.state.lastDecay, isNull);
    });
  });

  group('与普通 α 对照（Be-8 → He-4）', () {
    test('Be-8 α 后是 2p2n，不进特例，飞满 300px 也不再射质子', () {
      final c = builtUp(4, 4);
      final ok = c.state.applyDecay(
        NucleusDecayType.alphaDecay,
        escapeX: 0,
        escapeY: escapeY,
        extraEscapes: const [extraA, extraB],
      );
      expect(ok, isTrue);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 2);
      expect(c.state.elementSymbol, 'He');
      expect(c.state.nuclideExists, isTrue);
      expect(c.state.inSpecialAlphaWindow, isFalse);
      expect(c.state.correctingNonexistentNuclide, isTrue);
      expect(c.state.outgoingParticles, hasLength(1));
      expect(c.state.outgoingParticles.single.type, EmittedParticleType.alpha);

      c.tick(1.0); // 普通 α 飞满 300px
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 2);
      expect(c.state.hasEmittedSpecialProtons, isFalse);
      expect(
        c.state.outgoingParticles.where((p) => p.type == EmittedParticleType.proton),
        isEmpty,
      );
      expect(c.state.outgoingParticles, hasLength(1)); // 仍只有 α
    });
  });
}
