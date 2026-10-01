import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_play_area.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_vertical_slider.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Screen smoke tests after Phase 2 PhET layout rebuild.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MolarityScenarioManager> preloaded(WidgetTester tester) async {
    final manager = MolarityScenarioManager();
    await tester.runAsync(() => manager.loadScenarios());
    return manager;
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    MolarityScenarioManager manager,
  ) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 1100,
          height: 700,
          child: MolarityScreen(manager: manager),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('主屏：PhET play area + 核心控件', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    expect(find.byType(MolarityPlayArea), findsOneWidget);
    expect(find.byType(MolarityVerticalSlider), findsNWidgets(2));
    expect(find.text('溶质:'), findsOneWidget);
    expect(find.text('显示数值'), findsOneWidget);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.byTooltip('探究任务'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));

    await teardown(tester);
  });

  testWidgets('拖动滑块 → 无异常', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    await tester.drag(
      find.byType(Slider).first,
      const Offset(0, -40),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byType(KratosResetAllButton), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('重置恢复初始参数', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    await tester.tap(find.text('显示数值'));
    await tester.pump();

    await tester.tap(find.byType(KratosResetAllButton));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('多'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('探究抽屉可开关', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    // Default closed for PhET visual primacy.
    expect(find.text('记录本次实验'), findsNothing);

    await tester.tap(find.byTooltip('探究任务'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('记录本次实验'), findsOneWidget);

    await tester.tap(find.byTooltip('探究任务'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('记录本次实验'), findsNothing);

    await teardown(tester);
  });

  testWidgets('无溶质瓶/水龙头遗留交互', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    expect(find.byTooltip('拖动到烧杯口倒入溶质（+0.1 mol）'), findsNothing);
    expect(find.byTooltip('拖动到烧杯口加水（+0.1 L）'), findsNothing);

    await teardown(tester);
  });
}
