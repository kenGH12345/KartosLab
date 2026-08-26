import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/chemistry/molarity/view/painters/beaker_painter.dart';
import 'package:kratos/chemistry/molarity/view/painters/precipitate_painter.dart';
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

    // 状态机（IXD Spec v1.0）：默认进入猜测阶段 Active，后续阶段 Locked——
    // 任务内容与记录按钮在解锁前不可见（一次一阶段 · 渐进披露）
    expect(find.text('先猜一猜'), findsOneWidget); // 猜测卡 Header
    expect(find.textContaining('第 1/'), findsOneWidget); // 单题推进模式
    expect(find.text('记录本次实验'), findsNothing); // 操作/记录卡未解锁

    // 收起（midLeft 探究入口 tooltip 唯一 · 避免与任务卡 leading 图标歧义）
    await tester.tap(find.byTooltip('探究任务'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('先猜一猜'), findsNothing);

    // 再展开恢复（Offstage 保 State · 预测阶段保持）
    await tester.tap(find.byTooltip('探究任务'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('先猜一猜'), findsOneWidget);

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

  testWidgets('过饱和 → 沉淀粒子堆积在烧杯底部（回归：居中悬浮不可见）', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    // 换低饱和浓度溶质（K₂Cr₂O₇ 饱和 0.50）并拉满溶质量 → C=2.0 > 0.5 过饱和
    await tester.tap(find.text('饮料粉'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('重铬酸钾').last);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Slider).first, const Offset(400, 0));
    await tester.pump(const Duration(milliseconds: 300));

    // 饱和指示出现（过饱和状态确认）
    expect(find.text('Saturated!'), findsOneWidget);

    // 沉淀粒子容器必须贴烧杯底部（bottomCenter），而非 Stack 居中悬浮
    final beaker = tester.renderObject<RenderBox>(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BeakerPainter));
    final precip = tester.renderObject<RenderBox>(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is PrecipitatePainter));

    final beakerBottom =
        beaker.localToGlobal(Offset.zero).dy + beaker.size.height;
    final precipBottom =
        precip.localToGlobal(Offset.zero).dy + precip.size.height;
    expect(precipBottom, closeTo(beakerBottom, beaker.size.height * 0.06),
        reason: '沉淀容器应贴烧杯底部（修复前居中对齐导致粒子悬浮在烧杯中部）');

    await teardown(tester);
  });
}
