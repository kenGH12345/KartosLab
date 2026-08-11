import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';

/// 主屏测试：预加载 manager（同步构建 · 无异步加载窗口）· 固定帧 pump ·
/// 结束卸载树（color_vision magic_lab 同款模式 · 避免跨测试动画污染）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MolarityScenarioManager> preloaded(WidgetTester tester) async {
    final manager = MolarityScenarioManager();
    // rootBundle 为真实 IO · 必须 runAsync 才能在 FakeAsync 测试里完成
    await tester.runAsync(() => manager.loadScenarios());
    return manager;
  }

  Future<void> pumpScreen(WidgetTester tester, MolarityScenarioManager manager) async {
    await tester.pumpWidget(MaterialApp(home: MolarityScreen(manager: manager)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  }

  testWidgets('主屏渲染：NineGrid 布局 + 核心控件（AC-4.1）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    expect(find.text('溶质'), findsOneWidget); // SoluteComboBox label
    expect(find.textContaining('溶质量'), findsOneWidget);
    expect(find.textContaining('体积'), findsOneWidget);
    expect(find.byTooltip('显示数值'), findsOneWidget);
    expect(find.byTooltip('重置'), findsOneWidget);
    expect(find.byIcon(Icons.science_outlined), findsOneWidget); // 探究入口
    expect(find.byType(Slider), findsNWidgets(2));

    await teardown(tester);
  });

  testWidgets('拖动滑块 → 无异常（AC-2.1/2.2）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    await tester.drag(find.byType(Slider).last, const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byTooltip('重置'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('重置恢复初始参数（AC-2.6）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    await tester.drag(find.byType(Slider).last, const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('重置'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byTooltip('重置'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('打开探究抽屉显示任务卡（AC-5.5）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    await tester.tap(find.byIcon(Icons.science_outlined));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('浓度 C = 溶质量 n ÷ 体积 V'), findsWidgets);
    expect(find.text('记录本次实验'), findsOneWidget);

    await teardown(tester);
  });
}
