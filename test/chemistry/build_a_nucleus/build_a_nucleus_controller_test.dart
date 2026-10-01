import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusController newController() =>
      BuildANucleusController(repository: repo);

  group('核子增减命令', () {
    test('添加质子 / 中子', () {
      final c = newController();
      expect(c.addProton(), isNotNull);
      expect(c.addNeutron(), isNotNull);
      expect(c.state.protonCount, 0); // 飞行中未计数（1F-1）
      c.state.settleAll(); // 到达后入核
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 1);
      expect(c.state.elementSymbol, 'H');
      expect(c.state.isStable, isTrue); // H-2
    });

    test('删除质子 / 中子', () {
      final c = newController();
      c.addPair();
      c.state.settleAll();
      expect(c.removeProton(), isTrue);
      expect(c.removeNeutron(), isTrue);
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.removeProton(), isFalse);
      expect(c.removeNeutron(), isFalse);
    });

    test('命令触发通知', () {
      final c = newController();
      var notified = 0;
      c.addListener(() => notified++);
      c.addProton();
      c.addNeutron();
      expect(notified, 2);
    });

    test('重复操作不会产生非法状态（规则拦截后幂等）', () {
      final c = newController();
      c.addNeutron(); // (0,1) 飞行中
      c.addNeutron(); // (0,2) 飞行中，有效计数越界
      c.state.settleAll(); // 到达后不存在态成立
      expect(c.state.isShowingInvalidNuclide, isTrue);
      // 无效态下所有增减被拦截
      expect(c.addNeutron(), isNull);
      expect(c.addProton(), isNull);
      expect(c.removeNeutron(), isFalse);
      expect(c.state.massNumber, 2);
    });
  });

  group('拖拽闭环', () {
    test('托盘落点在捕获区内 → 入核计数', () {
      final c = newController();
      final kept = c.dropFromTray(NucleonType.proton, 10, 10);
      expect(kept, isTrue);
      expect(c.state.protonCount, 1);
    });

    test('托盘落点在捕获区外 → 返回生成器不计数', () {
      final c = newController();
      final kept = c.dropFromTray(NucleonType.proton, 500, 0);
      expect(kept, isFalse);
      expect(c.state.protonCount, 0);
      expect(c.state.isEmptyNucleus, isTrue);
    });

    test('拖出核内已有核子 → 松手在区外 → 移除', () {
      final c = newController();
      c.addPair();
      c.addPair(); // He-4
      c.state.settleAll();
      final nucleon = c.state.neutrons.first;
      c.beginDrag(nucleon);
      expect(c.state.neutronCount, 1);
      c.moveDragged(nucleon, 300, 0);
      expect(c.endDrop(nucleon), isFalse);
      expect(c.state.neutronCount, 1);
    });

    test('拖出后松手在区内 → 回到核内', () {
      final c = newController();
      c.addPair();
      c.state.settleAll();
      final nucleon = c.state.protons.first;
      c.beginDrag(nucleon);
      c.moveDragged(nucleon, 20, 20);
      expect(c.endDrop(nucleon), isTrue);
      expect(c.state.protonCount, 1);
    });
  });

  group('衰变 / 撤销 / 重置', () {
    test('衰变命令 → 状态转换 + 可撤销', () {
      final c = newController();
      for (var i = 0; i < 6; i++) {
        c.addPair();
      }
      c.addNeutron();
      c.addNeutron(); // C-14（飞行中）
      // [已确认] DecayModel：有飞行中核子时衰变按钮禁用
      expect(c.state.isDecayEnabled(NucleusDecayType.betaMinusDecay), isFalse);
      c.state.settleAll(); // 全部到达
      expect(c.state.isDecayEnabled(NucleusDecayType.betaMinusDecay), isTrue);
      expect(c.applyDecay(NucleusDecayType.betaMinusDecay), isTrue);
      expect(c.state.elementSymbol, 'N');
      expect(c.undoDecay(), isTrue);
      expect(c.state.elementSymbol, 'C');
      expect(c.state.massNumber, 14);
    });

    test('Reset 命令恢复初始状态', () {
      final c = newController();
      c.addPair();
      c.applyDecay(NucleusDecayType.betaPlusDecay); // H-2 无 β+，应失败
      c.reset();
      expect(c.state.isEmptyNucleus, isTrue);
      expect(c.state.canUndoDecay, isFalse);
    });
  });

  group('时间推进入口（invalid rollback）', () {
    test('tick 驱动 1 秒回退', () {
      final c = newController();
      c.addNeutron(); // (0,1) 存在
      c.tick(0.016); // 有效态帧推进：记录快照（对标原版逐帧 step）
      c.addNeutron(); // (0,2) 不存在
      expect(c.tick(0.5), isFalse);
      expect(c.state.neutronCount, 2);
      expect(c.tick(0.6), isTrue); // 累计 1.1s → 回退
      expect(c.state.neutronCount, 1);
    });

    test('回退发生时通知监听者', () {
      final c = newController();
      c.addNeutron();
      c.tick(0.016);
      c.addNeutron();
      var notified = 0;
      c.addListener(() => notified++);
      c.tick(1.0);
      expect(notified, 1);
      expect(c.state.neutronCount, 1);
    });
  });
}
