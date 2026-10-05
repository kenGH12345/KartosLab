import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// Phase 1F-1：箭头按钮飞入动画。
/// 依据：BANScreenView.createParticleFromStack（生成器创建 → 300px/s 飞核中心
/// → animationEndedEmitter 到达 → particleAtom.addParticle 此刻才计数 →
/// reconfigure 设卡位 destination）；DecayModel（飞行中衰变禁用）；
/// NucleonCreatorsNode（有效计数含 incoming）。
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

  group('飞入时序（对标 createParticleFromStack）', () {
    test('创建于生成器位置，飞向核中心，到达前不计数', () {
      final c = newController();
      final n = c.state.addProton(fromX: 50, fromY: 300);
      expect(n, isNotNull);
      expect(n!.x, 50);
      expect(n.y, 300);
      expect((n.destX, n.destY), (0.0, 0.0)); // 目的地 = 核中心
      expect(c.state.protonCount, 0); // 未到达不计数
      expect(c.state.hasIncomingParticles, isTrue);
    });

    test('飞入为固定 0.6s（consistentTime: true），与距离无关', () {
      // [已确认] BANParticle.setAnimationDestination：speed = 距离/0.6s
      final c = newController();
      c.state.addProton(fromX: 0, fromY: 300); // speed = 500 px/s
      c.tick(0.5); // 飞行 250px，未到达
      expect(c.state.protonCount, 0);
      expect(c.state.incomingNucleons.single.y, closeTo(50, 1e-6));
      c.tick(0.1); // 累计 0.6s → 到达
      expect(c.state.protonCount, 1);
      expect(c.state.hasIncomingParticles, isFalse);
      expect(c.state.elementSymbol, 'H');

      // 距离 10 倍也同样是 0.6s 到达（证明是定时而非定速）
      final c2 = newController();
      c2.state.addProton(fromX: 0, fromY: 3000);
      c2.tick(0.59);
      expect(c2.state.protonCount, 0);
      c2.tick(0.02);
      expect(c2.state.protonCount, 1);
    });

    test('到达后触发重排：卡位为 destination（继续归位动画）', () {
      final c = newController();
      c.state.addProton(fromX: 0, fromY: 30);
      c.state.addNeutron(fromX: 0, fromY: 30);
      c.tick(0.6); // 双双到达核中心（0.6s 定时）
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 1);
      // H-2：2 核子并排卡位（距中心 r=10）→ destination 已指向卡位。
      // 注意：同一大步长帧内位置可能已归位，故断言 destination（时序无关）。
      final p = c.state.protons.first;
      expect(p.destX * p.destX + p.destY * p.destY, closeTo(100, 1e-6));
    });

    test('多个飞行核子共存并各自到达（按发射时刻先后）', () {
      final c = newController();
      c.state.addProton(fromX: 0, fromY: 300); // t=0 发射，t=0.6 到达
      c.tick(0.3);
      c.state.addProton(fromX: 0, fromY: 300); // t=0.3 发射，t=0.9 到达
      expect(c.state.incomingNucleons, hasLength(2));
      c.tick(0.3); // t=0.6：第一个到达
      expect(c.state.protonCount, 1);
      expect(c.state.hasIncomingParticles, isTrue);
      // 第二个到达 → (2,0) 不存在；无效核素计时 0.3s < 1s，不回退
      c.tick(0.3);
      expect(c.state.protonCount, 2);
      expect(c.state.isShowingInvalidNuclide, isTrue);
    });

    test('飞行中衰变按钮禁用（hasIncomingParticles）', () {
      final c = newController();
      c.state.addProton();
      c.state.addNeutron();
      c.state.addNeutron(); // H-3 组成中（飞行中）
      expect(c.state.availableDecays, isEmpty); // 核内还是空的
      c.state.settleAll();
      expect(c.state.isDecayEnabled(NucleusDecayType.betaMinusDecay), isTrue);
      // 再发射一个飞行核子 → 禁用
      c.state.addNeutron(fromX: 0, fromY: 300);
      expect(c.state.isDecayEnabled(NucleusDecayType.betaMinusDecay), isFalse);
      c.state.settleAll(); // H-4：ENSDF 只有中子发射（1A 锚点已锁定该数据）
      expect(c.state.isDecayEnabled(NucleusDecayType.betaMinusDecay), isFalse);
      expect(c.state.isDecayEnabled(NucleusDecayType.neutronEmission), isTrue);
    });

    test('飞行中计入有效计数（生成器规则）', () {
      final c = newController();
      c.state.addNeutron(); // 飞行中 → 有效 (0,1)
      c.state.settleAll(); // (0,1) 存在
      // 再添加一个飞行中子 → 有效 (0,2) 不存在 + 核非空 → 全部禁用
      c.state.addNeutron(fromX: 0, fromY: 300);
      expect(c.state.protonCount + c.state.neutronCount, 1); // 核内仍 (0,1)
      expect(c.state.canAddNeutron, isFalse);
      expect(c.state.canAddProton, isFalse);
      expect(c.state.canRemoveNeutron, isFalse);
    });

    test('reset 清空飞行中核子', () {
      final c = newController();
      c.state.addProton(fromX: 0, fromY: 300);
      expect(c.state.hasIncomingParticles, isTrue);
      c.reset();
      expect(c.state.hasIncomingParticles, isFalse);
      expect(c.state.incomingNucleons, isEmpty);
      expect(c.state.isEmptyNucleus, isTrue);
    });
  });

  group('Widget：箭头飞入闭环', () {
    testWidgets('点击箭头 → 飞行中读数不变且衰变禁用 → 到达后更新', (tester) async {
      final c = newController();
      await tester.pumpWidget(
          MaterialApp(home: BuildANucleusScreen(controller: c)));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('ban_add_proton')));
      await tester.pump();
      // 飞行中：读数不变
      expect(find.text('Protons: 0'), findsOneWidget);
      expect(c.state.hasIncomingParticles, isTrue);

      // 泵帧直到到达
      for (var i = 0; i < 400 && c.state.hasIncomingParticles; i++) {
        await tester.pump();
      }
      expect(find.text('Protons: 1'), findsOneWidget);
      expect(find.text('Hydrogen - 1'), findsOneWidget);
    });
  });
}
