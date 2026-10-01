import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/build_a_nucleus_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

/// 状态层测试使用真实核素数据（与 1A 锚点测试同方式读取资产文件）。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusState newState() => BuildANucleusState(repository: repo);

  /// 依次添加 p/n 到目标计数；每步断言未被规则拦截。
  /// 1F-1 起添加为飞入动画（到达才计数），每步后用 settleAll 立即到位。
  void buildUp(BuildANucleusState s, int p, int n) {
    while (s.protonCount < p || s.neutronCount < n) {
      if (s.protonCount < p && s.neutronCount < n) {
        expect(s.addPair(), isTrue, reason: 'addPair at ${s.protonCount},${s.neutronCount}');
      } else if (s.protonCount < p) {
        expect(s.addProton(), isNotNull, reason: 'addProton at ${s.protonCount},${s.neutronCount}');
      } else {
        expect(s.addNeutron(), isNotNull, reason: 'addNeutron at ${s.protonCount},${s.neutronCount}');
      }
      s.settleAll();
    }
  }

  group('初始化', () {
    test('默认 0p0n 空核', () {
      final s = newState();
      expect(s.protonCount, 0);
      expect(s.neutronCount, 0);
      expect(s.massNumber, 0);
      expect(s.isEmptyNucleus, isTrue);
      expect(s.nuclideExists, isFalse); // 数据层：0p0n 不存在
      expect(s.isShowingInvalidNuclide, isFalse); // 视图层特例：空核不算 invalid
      expect(s.halfLifeNumber, BanConstants.nonexistentHalfLife);
      expect(s.canUndoDecay, isFalse);
      expect(s.outgoingParticles, isEmpty);
      expect(s.elementSymbol, '-');
      expect(s.elementName, '');
    });
  });

  group('核子增减与核素派生', () {
    test('添加质子 → H-1(稳定)', () {
      final s = newState();
      final nucleon = s.addProton();
      expect(nucleon, isNotNull);
      expect(s.protonCount, 0); // 飞行中未计数（1F-1 起到达才入核）
      s.settleAll();
      expect(s.protonCount, 1);
      expect(s.nuclideExists, isTrue);
      expect(s.isStable, isTrue);
      expect(s.elementSymbol, 'H');
      expect(s.elementName, 'Hydrogen');
      expect(s.halfLifeNumber, BanConstants.stableHalfLifeDisplay);
      expect(s.availableDecays, isEmpty);
    });

    test('H-1 → H-2 → H-3: 稳定性与衰变联动', () {
      final s = newState();
      buildUp(s, 1, 2); // H-3
      expect(s.isStable, isFalse);
      expect(s.halfLifeNumber, 388781328.0);
      expect(s.isDecayEnabled(NucleusDecayType.betaMinusDecay), isTrue);
      expect(s.isDecayEnabled(NucleusDecayType.alphaDecay), isFalse);
      expect(s.removeNeutron(), isTrue); // 回到 H-2
      expect(s.isStable, isTrue);
      expect(s.halfLifeNumber, BanConstants.stableHalfLifeDisplay);
    });

    test('空核不能移除', () {
      final s = newState();
      expect(s.removeProton(), isFalse);
      expect(s.removeNeutron(), isFalse);
      expect(s.removePair(), isFalse);
    });
  });

  group('箭头 enable 规则（对标 NucleonCreatorsNode)', () {
    test('0p0n: 可加不可减', () {
      final s = newState();
      expect(s.canAddProton, isTrue);
      expect(s.canAddNeutron, isTrue);
      expect(s.canRemoveProton, isFalse);
      expect(s.canRemoveNeutron, isFalse);
    });

    test('上箭头允许越界 1 个进入不存在态，之后全部禁用', () {
      final s = newState();
      s.addNeutron(); // (0,1) 自由中子，存在
      s.settleAll();
      expect(s.canAddNeutron, isTrue); // 允许越界到 (0,2)
      s.addNeutron(); // (0,2) 不存在
      s.settleAll();
      expect(s.isShowingInvalidNuclide, isTrue);
      expect(s.canAddProton, isFalse);
      expect(s.canAddNeutron, isFalse);
      expect(s.canRemoveNeutron, isFalse);
      expect(s.addNeutron(), isNull); // 被规则拦截
    });

    test('下箭头特例：(1,0) 可减质子、(1,1) 可减一对', () {
      final s = newState();
      s.addProton(); // (1,0)
      s.settleAll();
      expect(s.canRemoveProton, isTrue); // n==0 && p==1 特例
      s.addNeutron(); // (1,1)
      s.settleAll();
      expect(s.canRemovePair, isTrue); // n==1 && p==1 特例
    });
  });

  group('核子进出核（拖拽松手语义）', () {
    test('捕获半径内松手 → 留在核内', () {
      final s = newState();
      buildUp(s, 2, 2); // He-4
      final nucleon = s.neutrons.first;
      s.beginNucleonDrag(nucleon);
      expect(s.neutronCount, 1); // 拖出后不计数
      nucleon.x = 50; // 距中心 50 < 100
      expect(s.endNucleonDrop(nucleon), isTrue);
      expect(s.neutronCount, 2);
    });

    test('捕获半径外松手 → 返回生成器', () {
      final s = newState();
      buildUp(s, 2, 2);
      final nucleon = s.neutrons.first;
      s.beginNucleonDrag(nucleon);
      nucleon.x = 150; // 距中心 150 > 100
      expect(s.endNucleonDrop(nucleon), isFalse);
      expect(s.neutronCount, 1); // He-3
      expect(s.nuclideExists, isTrue);
    });

    test('移除会造成不存在核素时强制收回核内', () {
      final s = newState();
      buildUp(s, 1, 2); // H-3
      final proton = s.protons.first;
      s.beginNucleonDrag(proton); // 取出后 (0,2) 不存在且非空
      proton.x = 500; // 远在捕获区外
      expect(s.endNucleonDrop(proton), isTrue); // 强制收回
      expect(s.protonCount, 1);
      expect(s.neutronCount, 2);
    });

    test('捕获半径边界', () {
      final s = newState();
      buildUp(s, 1, 1);
      final probe = Nucleon(id: 999, type: NucleonType.proton);
      probe.x = 99;
      expect(s.isWithinCaptureArea(probe), isTrue);
      probe.x = 101;
      expect(s.isWithinCaptureArea(probe), isFalse);
    });
  });

  group('衰变', () {
    test('C-14 β- → N-14(稳定), 发射电子', () {
      final s = newState();
      buildUp(s, 6, 8); // C-14
      expect(s.isDecayEnabled(NucleusDecayType.betaMinusDecay), isTrue);
      expect(s.applyDecay(NucleusDecayType.betaMinusDecay), isTrue);
      expect(s.protonCount, 7);
      expect(s.neutronCount, 7);
      expect(s.elementSymbol, 'N');
      expect(s.isStable, isTrue);
      expect(s.outgoingParticles.single.type, EmittedParticleType.electron);
      expect(s.canUndoDecay, isTrue);
    });

    test('Be-8 α → He-4(稳定)', () {
      final s = newState();
      buildUp(s, 4, 4); // Be-8
      expect(s.applyDecay(NucleusDecayType.alphaDecay), isTrue);
      expect(s.protonCount, 2);
      expect(s.neutronCount, 2);
      expect(s.isStable, isTrue);
      expect(s.outgoingParticles.single.type, EmittedParticleType.alpha);
    });

    test('N-13 β+ → C-13(稳定), 发射正电子', () {
      final s = newState();
      buildUp(s, 7, 6); // N-13
      expect(s.applyDecay(NucleusDecayType.betaPlusDecay), isTrue);
      expect(s.protonCount, 6);
      expect(s.neutronCount, 7);
      expect(s.isStable, isTrue);
      expect(s.outgoingParticles.single.type, EmittedParticleType.positron);
    });

    test('H-5 中子发射 → H-4', () {
      final s = newState();
      buildUp(s, 1, 4); // H-5（2N → 映射为 neutronEmission）
      expect(s.isDecayEnabled(NucleusDecayType.neutronEmission), isTrue);
      expect(s.applyDecay(NucleusDecayType.neutronEmission), isTrue);
      expect(s.protonCount, 1);
      expect(s.neutronCount, 3);
      expect(s.outgoingParticles.single.type, EmittedParticleType.neutron);
    });

    test('不可用衰变不改变状态', () {
      final s = newState();
      buildUp(s, 1, 2); // H-3 只有 β-
      expect(s.applyDecay(NucleusDecayType.alphaDecay), isFalse);
      expect(s.protonCount, 1);
      expect(s.neutronCount, 2);
      expect(s.outgoingParticles, isEmpty);
      expect(s.canUndoDecay, isFalse);
    });
  });

  group('撤销衰变', () {
    test('undo 恢复衰变前计数并清空发射产物', () {
      final s = newState();
      buildUp(s, 6, 8);
      s.applyDecay(NucleusDecayType.betaMinusDecay);
      expect(s.undoDecay(), isTrue);
      expect(s.protonCount, 6);
      expect(s.neutronCount, 8);
      expect(s.outgoingParticles, isEmpty);
      expect(s.canUndoDecay, isFalse);
    });

    test('衰变后任何核变化使 undo 失效', () {
      final s = newState();
      buildUp(s, 6, 8);
      s.applyDecay(NucleusDecayType.betaMinusDecay); // → N-14 (7,7)
      expect(s.canUndoDecay, isTrue);
      expect(s.removeNeutron(), isTrue); // (7,6) N-13 存在
      expect(s.canUndoDecay, isFalse);
      expect(s.undoDecay(), isFalse);
    });

    test('无衰变时 undo 不可用', () {
      final s = newState();
      expect(s.undoDecay(), isFalse);
    });
  });

  group('无效核素回退(状态层, dt 驱动)', () {
    test('invalid 累计 1 秒后回退到上一个有效核素', () {
      final s = newState();
      s.addNeutron(); // (0,1) 存在
      s.settleAll();
      // [已确认] BANScreenView.step：核素存在的每一帧都会把当前计数记为
      // 「上一个有效核素」。状态层等价行为：有效状态下推进一帧写入快照。
      s.stepInvalidNuclideRollback(0.016);
      s.addNeutron(); // (0,2) 不存在
      s.settleAll();
      expect(s.isShowingInvalidNuclide, isTrue);
      expect(s.halfLifeNumber, BanConstants.nonexistentHalfLife);

      expect(s.stepInvalidNuclideRollback(0.5), isFalse);
      expect(s.neutronCount, 2); // 仍未回退
      expect(s.stepInvalidNuclideRollback(0.6), isTrue); // 累计 1.1 ≥ 1.0
      expect(s.neutronCount, 1); // 回退到 (0,1)
      expect(s.nuclideExists, isTrue);
    });

    test('0p0n 空核不触发回退', () {
      final s = newState();
      expect(s.stepInvalidNuclideRollback(2.0), isFalse);
      expect(s.isEmptyNucleus, isTrue);
    });

    test('半衰期未知(H-4)读数为 -1', () {
      final s = newState();
      buildUp(s, 1, 3); // H-4: 存在但半衰期未知
      expect(s.nuclideExists, isTrue);
      expect(s.halfLifeNumber, BanConstants.unknownHalfLife);
    });
  });

  group('Reset', () {
    test('修改 + 衰变后 reset 完全恢复初始状态', () {
      final s = newState();
      buildUp(s, 6, 8);
      s.applyDecay(NucleusDecayType.betaMinusDecay);
      s.reset();
      expect(s.protonCount, 0);
      expect(s.neutronCount, 0);
      expect(s.isEmptyNucleus, isTrue);
      expect(s.outgoingParticles, isEmpty);
      expect(s.canUndoDecay, isFalse);
      expect(s.isShowingInvalidNuclide, isFalse);
      expect(s.invalidNuclideElapsed, 0);
      // reset 后 id 计数器复位，可继续正常添加
      expect(s.addProton(), isNotNull);
      s.settleAll(); // 飞入到达后才入核
      expect(s.elementSymbol, 'H');
    });
  });
}
