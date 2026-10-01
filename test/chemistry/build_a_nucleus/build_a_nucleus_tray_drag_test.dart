import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// Phase 1E-2：生成器拖出 + 归位动画。
/// 依据：NucleonCreatorNode（按下即创建+拖拽）、Particle.step（300px/s 匀速）、
/// animateAndRemoveParticle（飞回生成器后销毁）、reconfigureNucleus（落点→卡位动画）。
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

  Offset nucleusOnScreen(WidgetTester tester, Rect canvas) {
    final origin = BanConstants.atomOriginInCanvas(
      layoutWidth:
          tester.view.physicalSize.width / tester.view.devicePixelRatio,
      canvasSize: canvas.size,
    );
    return Offset(canvas.left + origin.dx, canvas.top + origin.dy);
  }

  group('归位运动（对标 Particle.step · 300 px/s 匀速）', () {
    test('匀速推进：速度 300px/s，按 dt 线性位移', () {
      final c = newController();
      final n = c.startTrayDrag(NucleonType.neutron, 0, 0);
      c.moveDragged(n, 300, 0); // 拖到捕获区外
      final kept = c.endDrop(n, returnX: 0, returnY: 0);
      expect(kept, isFalse);
      expect(c.state.returningNucleons, contains(n));

      c.tick(0.5); // 300px/s × 0.5s = 150px
      expect(n.x, closeTo(150, 1e-6));
      expect(c.state.returningNucleons, contains(n)); // 未到达
    });

    test('归位完成 → 核子从世界移除', () {
      final c = newController();
      final n = c.startTrayDrag(NucleonType.proton, 0, 0);
      c.moveDragged(n, 300, 0);
      c.endDrop(n, returnX: 0, returnY: 0);

      c.tick(0.5);
      c.tick(0.5); // 累计 300px → 到达
      expect(c.state.returningNucleons, isEmpty);
      expect(c.state.protonCount, 0);
    });

    test('成功入核：核子从落点向排布卡位归位', () {
      final c = newController();
      c.addPair(); // (1,1) H-2
      c.state.settleAll(); // 1F-1：飞入到达 + 到卡位
      final n = c.startTrayDrag(NucleonType.neutron, 0, 0);
      c.moveDragged(n, 30, 0); // 捕获区内落点
      expect(c.endDrop(n, returnX: 0, returnY: 200), isTrue);
      expect(c.state.neutronCount, 2);
      // 落点非卡位 → 处于归位动画中（destination 由重排设定）
      expect(n.isAnimating, isTrue);
      c.state.moveAllNucleonsToDestination();
      expect(n.isAnimating, isFalse);
    });
  });

  group('生成器语义', () {
    test('无限供应：连续拖出互不相同的核子', () {
      final c = newController();
      final a = c.startTrayDrag(NucleonType.proton, 0, 0);
      final b = c.startTrayDrag(NucleonType.proton, 0, 0);
      final d = c.startTrayDrag(NucleonType.proton, 0, 0);
      expect({a.id, b.id, d.id}, hasLength(3));
      expect(c.state.draggedNucleons, hasLength(3));
    });

    test('拖动期间生成器规则用有效计数', () {
      final c = newController();
      c.addNeutron(); // (0,1) 自由中子，存在
      // 拖出一个新中子：有效计数 (0,2) 不存在 + 核非空 → 全部禁用
      c.startTrayDrag(NucleonType.neutron, 0, 0);
      expect(c.state.canAddNeutron, isFalse);
      expect(c.state.canAddProton, isFalse);
      expect(c.state.canRemoveNeutron, isFalse);
    });

    test('拖拽开始取消进行中动画', () {
      final c = newController();
      final n = c.state.createFreeNucleon(NucleonType.proton, x: 5, y: 5);
      n.setDestination(100, 100); // 模拟进行中动画
      c.state.beginFreeDrag(n);
      expect(n.isAnimating, isFalse);
      expect(n.zLayer, 0);
    });

    test('reset 清空拖拽中与归位中核子', () {
      final c = newController();
      final n = c.startTrayDrag(NucleonType.proton, 0, 0);
      c.moveDragged(n, 300, 0);
      c.endDrop(n, returnX: 0, returnY: 0); // 进入归位
      final m = c.startTrayDrag(NucleonType.neutron, 0, 0); // 拖拽中
      expect(m, isNotNull);
      c.reset();
      expect(c.state.returningNucleons, isEmpty);
      expect(c.state.draggedNucleons, isEmpty);
    });
  });

  group('Widget：生成器拖出闭环', () {
    Future<(BuildANucleusController, Rect)> pumpShell(
        WidgetTester tester, BuildANucleusController c) async {
      await tester.pumpWidget(
          MaterialApp(home: BuildANucleusScreen(controller: c)));
      await tester.pump();
      return (c, tester.getRect(find.byKey(const ValueKey('ban_canvas'))));
    }

    testWidgets('按下生成器 → 实时跟随 → 画布中心松手入核', (tester) async {
      final c = newController();
      final (_, canvas) = await pumpShell(tester, c);
      final atNucleus = nucleusOnScreen(tester, canvas);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('中子')));
      await tester.pump();
      // 按下即创建：拖拽中 1 个，核内 0 个（[已确认] startSyntheticDrag）
      expect(c.state.draggedNucleons, hasLength(1));
      expect(c.state.neutronCount, 0);

      await gesture.moveTo(atNucleus);
      await tester.pump();
      // 跟随指针：核子中心对齐核原点（layoutW/3，画布局部）
      final dragged = c.state.draggedNucleons.first;
      expect(dragged.x, closeTo(0, 1));
      expect(dragged.y, closeTo(0, 1));

      await gesture.up();
      await tester.pump();
      expect(c.state.neutronCount, 1);
      expect(c.state.draggedNucleons, isEmpty);
      expect(find.text('Cluster'), findsNothing); // 占位文案不含英文
      expect(find.text('质子: 0'), findsOneWidget);
      expect(find.text('中子: 1'), findsOneWidget);
    });

    testWidgets('捕获区外松手 → 归位动画 → 到达后消失', (tester) async {
      final c = newController();
      final (_, canvas) = await pumpShell(tester, c);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('质子')));
      await gesture.moveTo(Offset(canvas.left + 8, canvas.top + 8));
      await gesture.up();
      await tester.pump();
      // 进入归位（不计数）
      expect(c.state.protonCount, 0);
      expect(c.state.returningNucleons, hasLength(1));

      // SimulationClock 每帧固定 dt=1/60s（不看真实流逝）→ 每次 pump 推进 5px；
      // 归位距离取决于布局，给足上界并提前退出。
      for (var i = 0; i < 400 && c.state.returningNucleons.isNotEmpty; i++) {
        await tester.pump();
      }
      expect(c.state.returningNucleons, isEmpty);
      expect(c.state.protonCount, 0);
    });

    testWidgets('多指同时拖出两个核子（原版支持多粒子用户控制）', (tester) async {
      final c = newController();
      final (_, canvas) = await pumpShell(tester, c);

      final g1 = await tester.startGesture(tester.getCenter(find.text('质子')));
      final g2 = await tester.startGesture(tester.getCenter(find.text('中子')));
      await tester.pump();
      expect(c.state.draggedNucleons, hasLength(2));

      final atNucleus = nucleusOnScreen(tester, canvas);
      await g1.moveTo(atNucleus);
      await g2.moveTo(atNucleus);
      await g1.up();
      await g2.up();
      await tester.pump();
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 1);
      expect(find.text('Hydrogen - 2'), findsOneWidget);
    });

    testWidgets('取消拖拽（pointer cancel）按松手处理', (tester) async {
      final c = newController();
      final (_, canvas) = await pumpShell(tester, c);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('质子')));
      await gesture.moveTo(nucleusOnScreen(tester, canvas));
      await gesture.cancel();
      await tester.pump();
      // cancel 也走 drop 判定：在捕获区内 → 入核
      expect(c.state.protonCount, 1);
      expect(c.state.draggedNucleons, isEmpty);
    });
  });
}
