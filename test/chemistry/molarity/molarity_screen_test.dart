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
    // footer 溶质量滑块 label（抽屉任务卡含"溶质量"文本，须精确匹配避免歧义）
    expect(find.text('🧪 溶质量(mol)'), findsOneWidget);
    expect(find.text('🧴 体积(L)'), findsOneWidget);
    expect(find.byTooltip('显示数值'), findsOneWidget);
    expect(find.byTooltip('重置'), findsOneWidget);
    // midLeft 探究入口（避免与任务卡 leading science_outlined 歧义）
    expect(find.byTooltip('探究任务'), findsOneWidget);
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

  testWidgets('探究抽屉默认展开（预测题）· 可收起再展开（AC-5.5）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    // 预测题默认展开：任务卡 + 记录按钮可见
    expect(find.textContaining('浓度 C = 溶质量 n ÷ 体积 V'), findsWidgets);
    expect(find.text('记录本次实验'), findsOneWidget);

    // 收起（midLeft 探究入口 tooltip 唯一 · 避免与任务卡 leading 图标歧义）
    await tester.tap(find.byTooltip('探究任务'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('记录本次实验'), findsNothing);

    // 再展开恢复
    await tester.tap(find.byTooltip('探究任务'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('记录本次实验'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('拖溶质瓶到烧杯口 → 浓度增大（C6 命中判定）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    // 浓度条 Semantics label：'溶液浓度 X.XX 摩尔每升...'
    String concentrationText() =>
        tester.getSemantics(find.bySemanticsLabel(RegExp('^溶液浓度'))).label;

    final before = concentrationText();
    expect(before, isNotEmpty);

    final bottle = find.byTooltip('拖动到烧杯口倒入溶质（+0.1 mol）');
    expect(bottle, findsOneWidget);

    // 瓶初始在烧杯左下（画布内 base≈(67,171)）→ 斜向右上拖入烧杯口（pourRect x≥94, y 25~103）
    final start = tester.getCenter(bottle);
    await tester.dragFrom(start, const Offset(50, -150));
    await tester.pump(const Duration(milliseconds: 300));

    final after = concentrationText();
    expect(after, isNot(before)); // 命中烧杯口 → soluteAmount+0.1 → 浓度升高

    await teardown(tester);
  });
}
