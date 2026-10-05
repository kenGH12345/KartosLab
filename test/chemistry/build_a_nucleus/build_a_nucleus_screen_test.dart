import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// 最小页面壳的 Widget 测试：验证 Controller + 状态 + 拖拽闭环。
/// 注意：屏内 SimulationClock 常开，不能用 pumpAndSettle（与 color_vision 测试同一教训）。
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

  Future<BuildANucleusController> pumpShell(
    WidgetTester tester, {
    BuildANucleusController? controller,
  }) async {
    final c = controller ?? newController();
    await tester.pumpWidget(MaterialApp(home: BuildANucleusScreen(controller: c)));
    await tester.pump();
    return c;
  }

  /// 泵帧直到飞行核子全部到达（SimulationClock 每帧固定 1/60s，
  /// 飞入距离取决于布局，给足上界并提前退出）。
  Future<void> pumpFlight(WidgetTester tester, BuildANucleusController c) async {
    for (var i = 0; i < 400 && c.state.hasIncomingParticles; i++) {
      await tester.pump();
    }
    expect(c.state.hasIncomingParticles, isFalse, reason: '飞入应已完成');
  }

  testWidgets('初始渲染：空核 + 五个衰变按钮均禁用', (tester) async {
    final c = await pumpShell(tester);
    expect(tester.widget<Text>(find.byKey(const ValueKey('ban_element_name'))).data, '');
    expect(find.text('Protons: 0'), findsOneWidget);
    expect(find.text('Neutrons: 0'), findsOneWidget);
    for (final type in NucleusDecayType.values) {
      final btn = tester.widget<ButtonStyleButton>(
        find.byKey(ValueKey('ban_decay_${type.name}')),
      );
      expect(btn.onPressed, isNull, reason: type.name);
    }
    expect(c.state.isEmptyNucleus, isTrue);
  });

  testWidgets('箭头按钮：添加/删除质子中子并更新读数', (tester) async {
    final c = await pumpShell(tester);

    await tester.tap(find.byKey(const ValueKey('ban_add_proton')));
    await tester.pump();
    // [已确认] 飞入动画中未计数（到达才入核）
    expect(find.text('Protons: 0'), findsOneWidget);
    await pumpFlight(tester, c);
    expect(find.text('Protons: 1'), findsOneWidget);
    expect(find.text('Hydrogen - 1'), findsOneWidget);
    expect(find.text('Stable'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('ban_add_neutron')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ban_add_neutron')));
    await tester.pump();
    await pumpFlight(tester, c);
    expect(find.text('Protons: 1'), findsOneWidget);
    expect(find.text('Neutrons: 2'), findsOneWidget);
    expect(find.text('Hydrogen - 3'), findsOneWidget);
    expect(find.text('Unstable'), findsOneWidget);
    expect(c.state.isDecayEnabled(NucleusDecayType.betaMinusDecay), isTrue);

    await tester.tap(find.byKey(const ValueKey('ban_remove_neutron')));
    await tester.pump();
    expect(find.text('Protons: 1'), findsOneWidget);
    expect(find.text('Neutrons: 1'), findsOneWidget);
  });

  testWidgets('拖拽：从托盘拖中子到核中心 → 入核计数', (tester) async {
    final c = await pumpShell(tester);

    final canvas = tester.getRect(find.byKey(const ValueKey('ban_canvas')));
    final origin = BanConstants.atomOriginInCanvas(
      layoutWidth:
          tester.view.physicalSize.width / tester.view.devicePixelRatio,
      canvasSize: canvas.size,
    );
    final nucleus = Offset(canvas.left + origin.dx, canvas.top + origin.dy);
    final trayItem = tester.getCenter(find.text('Neutrons'));
    await tester.timedDragFrom(
      trayItem,
      nucleus - trayItem,
      const Duration(milliseconds: 300),
    );
    await tester.pump();

    expect(c.state.neutronCount, 1);
    expect(find.text('Protons: 0'), findsOneWidget);
    expect(find.text('Neutrons: 1'), findsOneWidget);
  });

  testWidgets('拖拽：落点在捕获区外 → 不计数', (tester) async {
    final c = await pumpShell(tester);

    final canvas = find.byKey(const ValueKey('ban_canvas'));
    final canvasTopLeft = tester.getTopLeft(canvas);
    final trayItem = tester.getCenter(find.text('Protons'));
    // 拖到画布左上角（世界坐标远<-100, <-100，在捕获半径外）
    await tester.timedDragFrom(
      trayItem,
      canvasTopLeft + const Offset(8, 8) - trayItem,
      const Duration(milliseconds: 300),
    );
    await tester.pump();

    expect(c.state.protonCount, 0);
    expect(find.text('Protons: 0'), findsOneWidget);
    expect(find.text('Neutrons: 0'), findsOneWidget);
  });

  testWidgets('衰变按钮：H-3 触发 β- 后可撤销，重置恢复空核', (tester) async {
    final c = await pumpShell(tester);

    await tester.tap(find.byKey(const ValueKey('ban_add_proton')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ban_add_neutron')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ban_add_neutron')));
    await tester.pump();
    await pumpFlight(tester, c); // 飞入到达后才计数/可衰变
    expect(find.text('Hydrogen - 3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('ban_decay_betaMinusDecay')));
    await tester.pump();
    expect(find.text('Helium - 3'), findsOneWidget);
    expect(c.state.elementSymbol, 'He');

    await tester.tap(find.byKey(const ValueKey('ban_undo_decay')));
    await tester.pump();
    expect(find.text('Hydrogen - 3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('ban_reset')));
    await tester.pump();
    expect(find.text('Protons: 0'), findsOneWidget);
    expect(find.text('Neutrons: 0'), findsOneWidget);
    expect(c.state.isEmptyNucleus, isTrue);
  });
}
