import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// Phase 1E-1：核内核子直接拖动。
/// 行为依据：shred ParticleView（SoundDragListener, applyOffset:false）、
/// BANModel.userControlledListener、BANScreenView.dragEndedListener / step。
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

  group('State：拖拽中核子的计数与规则', () {
    test('拖出即不计入核内，但计入有效计数（生成器规则）', () {
      final c = newController();
      c.addPair(); // H-2 (1,1)
      c.state.settleAll(); // 1F-1 起飞入到达才计数
      final s = c.state;
      final neutron = s.neutrons.first;

      c.beginDrag(neutron);
      expect(s.neutronCount, 0); // 核内不计
      expect(s.draggedNucleons, contains(neutron));
      // 有效计数仍为 (1,1)：下箭头用核内计数 → 中子为 0 → 禁删
      expect(s.canRemoveNeutron, isFalse);
      expect(s.canRemoveProton, isTrue); // 核内质子 1

      // 放回后恢复
      neutron.x = 10;
      c.endDrop(neutron);
      expect(s.neutronCount, 1);
      expect(s.draggedNucleons, isEmpty);
      expect(s.canRemoveNeutron, isTrue);
    });

    test('拖拽中 invalid 回退暂停，松手按规则判定', () {
      final c = newController();
      c.addProton();
      c.addNeutron();
      c.addNeutron(); // H-3 (1,2)
      c.state.settleAll();
      final s = c.state;
      final proton = s.protons.first;

      c.beginDrag(proton); // 核内 (0,2)：不存在且非空
      expect(s.isShowingInvalidNuclide, isTrue);

      // 拖拽中累计超过 1 秒也不触发回退（[已确认] userControlled 检查）
      expect(c.tick(1.5), isFalse);
      expect(s.neutronCount, 2);

      // 松手在捕获区外：移除会造成不存在核素 → 强制收回（[已确认] dragEndedListener）
      proton.x = 500;
      expect(c.endDrop(proton), isTrue);
      expect(s.protonCount, 1);
      expect(s.neutronCount, 2);
    });

    test('松手回核后 zLayer 由重排恢复（不再是最前层 0）', () {
      final c = newController();
      c.addPair();
      c.addPair(); // He-4
      c.state.settleAll();
      final s = c.state;
      final neutron = s.neutrons.first;
      c.beginDrag(neutron);
      expect(neutron.zLayer, 0);
      neutron.x = 5;
      c.endDrop(neutron); // 回到核内 → 质量数变化 → 重排赋层
      expect(neutron.zLayer, greaterThan(0));
    });
  });

  group('Controller：命中测试', () {
    test('命中半径内的核子，未命中返回 null', () {
      final c = newController();
      c.addProton(); // 单核子居中 (0,0)
      c.state.settleAll(); // 1F-1：飞入到达后才是核内核子
      expect(c.hitTestNucleon(0, 0), isNotNull);
      expect(
        c.hitTestNucleon(BanConstants.nucleonRadius - 1, 0),
        isNotNull,
      );
      expect(
        c.hitTestNucleon(BanConstants.nucleonRadius + 1, 0),
        isNull,
      );
    });

    test('重叠时取 zLayer 最小（最前）者', () {
      final c = newController();
      c.addPair();
      c.addPair(); // He-4 菱形：位置分离
      c.state.settleAll();
      final s = c.state;
      // 人工制造重叠：把两个核子放同一坐标，不同 zLayer
      final a = s.protons.first;
      final b = s.neutrons.first;
      a.x = 50;
      a.y = 50;
      a.zLayer = 3;
      b.x = 50;
      b.y = 50;
      b.zLayer = 1;
      expect(c.hitTestNucleon(50, 50), same(b));
    });
  });

  group('Widget：画布内直接拖拽', () {
    Future<(BuildANucleusController, Rect)> pumpWith(
      WidgetTester tester,
      BuildANucleusController c,
    ) async {
      await tester.pumpWidget(
          MaterialApp(home: BuildANucleusScreen(controller: c)));
      await tester.pump();
      final rect = tester.getRect(find.byKey(const ValueKey('ban_canvas')));
      return (c, rect);
    }

    Offset toScreen(WidgetTester tester, Rect canvas, double wx, double wy) {
      final origin = BanConstants.atomOriginInCanvas(
        layoutWidth:
            tester.view.physicalSize.width / tester.view.devicePixelRatio,
        canvasSize: canvas.size,
      );
      return Offset(canvas.left + origin.dx + wx, canvas.top + origin.dy + wy);
    }

    testWidgets('拖核内中子到捕获区外 → 移出核（He-4 → He-3）', (tester) async {
      final c = newController();
      c.addPair();
      c.addPair(); // He-4
      c.state.settleAll();
      final (_, canvas) = await pumpWith(tester, c);

      final target = c.state.neutrons.first;
      final start = toScreen(tester, canvas, target.x, target.y);
      final gesture = await tester.startGesture(start);
      await tester.pump();
      // 拖动中：核素读数立即更新（[已确认] userControlled 移出 particleAtom）
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(find.text('质子: 2'), findsOneWidget);
      expect(find.text('中子: 1'), findsOneWidget);
      expect(find.text('Helium - 3'), findsOneWidget);

      await gesture.moveTo(toScreen(tester, canvas, 400, 0));
      await gesture.up();
      await tester.pump();
      expect(c.state.neutronCount, 1);
      expect(c.state.elementSymbol, 'He');
    });

    testWidgets('拖核内质子在捕获区内松手 → 留在核内', (tester) async {
      final c = newController();
      c.addPair();
      c.addPair();
      c.state.settleAll();
      final (_, canvas) = await pumpWith(tester, c);

      final target = c.state.protons.first;
      final start = toScreen(tester, canvas, target.x, target.y);
      final gesture = await tester.startGesture(start);
      await gesture.moveTo(toScreen(tester, canvas, 40, 40));
      await gesture.up();
      await tester.pump();

      expect(c.state.protonCount, 2);
      expect(find.text('Helium - 4'), findsOneWidget);
    });

    testWidgets('点按空白画布不触发拖拽', (tester) async {
      final c = newController();
      c.addPair();
      c.state.settleAll();
      final (_, canvas) = await pumpWith(tester, c);

      final gesture = await tester.startGesture(toScreen(tester, canvas, 300, 200));
      await gesture.up();
      await tester.pump();
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 1);
      expect(c.state.draggedNucleons, isEmpty);
    });
  });
}
