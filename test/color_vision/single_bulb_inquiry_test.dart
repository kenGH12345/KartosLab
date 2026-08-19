// test/color_vision/single_bulb_inquiry_test.dart
// req-single-bulb-inquiry · single_bulb 屏接入做中学探究抽屉验收测试。
// 覆盖 AC-1/2/3/4/5/6（spec/需求简述.md §6 · design/技术方案.md §6 验证计划）。
//
// 实现约束（magic_lab_ac44_test.dart 先例）：
// - widget test 场景用内联 JSON 构造（rootBundle 真实 IO 在 fake async 测试里可能挂起）
// - AC-4 场景资产走真实 manifest+JSON 加载（纯 test() 非 fake async）
// - SingleBulbScreen 的 SimulationClock 持续 tick → 固定帧 pump + 结束卸载树
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/color_vision/config/color_vision_scenario.dart';
import 'package:kratos/color_vision/config/color_vision_scenario_manager.dart';
import 'package:kratos/color_vision/screens/single_bulb_screen.dart';
import 'package:kratos/common/widgets/inquiry_drawer.dart';

const _question = '白光通过不同颜色的滤光片后，人眼看到什么颜色？你能总结出减色法规律吗？';

/// 与 assets/scenarios/color-vision/single-inquiry-subtractive.json 同构的内联场景。
ColorVisionScenario _inquiryScenario() => ColorVisionScenario.fromJson({
      'scenarioId': 'single-inquiry-subtractive',
      'name': '滤光片减色探究',
      'description': '白光通过不同颜色的滤光片后，人眼看到什么颜色？动手记录并归纳减色法规律。',
      'version': '1.0',
      'screen': 'singleBulb',
      'initialParams': {
        'filterType': 'red',
        'showPhotonView': true,
        'personPosition': 320,
      },
      'inquiryTask': {
        'question': _question,
        'steps': [
          {'id': 'step-1', 'instruction': '选择白光 + 红色滤光片，点击「记录本次实验」记下看到的颜色。'},
          {'id': 'step-2', 'instruction': '保持白光，分别换绿色、蓝色滤光片，各记录一次看到颜色。'},
          {'id': 'step-3', 'instruction': '回顾记录表：滤光片颜色与看到的颜色有什么关系？写下你的结论。'},
        ],
        'referenceConclusion':
            '减色法：白光含 R+G+B，红色滤光片只透红，绿色只透绿，蓝色只透蓝。',
        'snapshotColumns': [
          {'key': 'bulbMode', 'label': '光源', 'source': 'param'},
          {'key': 'wavelength', 'label': '波长(nm)', 'source': 'param'},
          {'key': 'filter', 'label': '滤光片', 'source': 'param'},
          {'key': 'perceivedColor', 'label': '看到颜色', 'source': 'reading'},
        ],
      },
    });

Future<void> _pumpScreen(
  WidgetTester tester, {
  ColorVisionScenario? scenario,
  Size size = const Size(1600, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: SingleBulbScreen(scenario: scenario)),
  ));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 20));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AC-4: 场景资产（真实 manifest + JSON 加载）', () {
    test('single-inquiry-subtractive 已注册且字段完整', () async {
      final mgr = ColorVisionScenarioManager();
      await mgr.loadScenarios();

      final s = mgr.findById('single-inquiry-subtractive');
      expect(s, isNotNull, reason: 'manifest 必须注册新探究场景');
      expect(s!.screen, CVScreen.singleBulb, reason: '场景必须归属 singleBulb 屏');

      final task = s.inquiryTask!;
      expect(task.question, isNotEmpty);
      expect(task.steps.length, greaterThanOrEqualTo(2));
      expect(task.referenceConclusion, isNotNull);
      expect(task.snapshotColumns.length, greaterThanOrEqualTo(2));
      expect(
        task.snapshotColumns.any((c) => c.source == 'param'),
        isTrue,
        reason: '至少 1 个 param 列',
      );
      expect(
        task.snapshotColumns.any((c) => c.source == 'reading'),
        isTrue,
        reason: '至少 1 个 reading 列',
      );
      // 快照 key 与 screen snapshotProvider 逐项一致（AC-3 硬约束）
      expect(
        task.snapshotColumns.map((c) => c.key).toList(),
        ['bulbMode', 'wavelength', 'filter', 'perceivedColor'],
      );
      expect(task.predictions, isEmpty, reason: '本需求不含预测题（AC-5 前置）');
    });
  });

  group('AC-1/AC-2/AC-5: 抽屉接入 · 入口按钮 · 进度条', () {
    testWidgets('含 inquiryTask → 抽屉默认展开 + 入口按钮存在（AC-1/AC-2）', (tester) async {
      await _pumpScreen(tester, scenario: _inquiryScenario());

      expect(find.byType(InquiryDrawer), findsOneWidget);
      // find 默认 skipOffstage：抽屉 open 时任务问题可见
      expect(find.text(_question), findsWidgets);
      // 入口按钮（topRight）+ 抽屉内任务卡 leading（inquiry_task_panel.dart:33）同图标 → ≥1
      expect(find.byIcon(Icons.science_outlined), findsAtLeastNWidgets(1));
      expect(find.byTooltip('探究任务'), findsOneWidget,
          reason: 'topRight 入口按钮必须存在（tooltip 定位）');
      await _teardown(tester);
    });

    testWidgets('无 inquiryTask → 入口按钮隐藏 · 抽屉不渲染内容（AC-1 回退安全）', (tester) async {
      await _pumpScreen(tester); // scenario == null

      expect(find.byIcon(Icons.science_outlined), findsNothing);
      expect(find.text('记录本次实验'), findsNothing);
      expect(find.text('归纳结论'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('点击入口按钮切换抽屉开合（AC-2）', (tester) async {
      await _pumpScreen(tester, scenario: _inquiryScenario());

      await tester.tap(find.byTooltip('探究任务'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_question), findsNothing, reason: '关闭后 Offstage 隐藏内容');

      await tester.tap(find.byTooltip('探究任务'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_question), findsWidgets, reason: '再次打开内容恢复');
      await _teardown(tester);
    });

    testWidgets('无预测题 → 进度条 2 节点（记录/归纳），无「猜测」（AC-5）', (tester) async {
      await _pumpScreen(tester, scenario: _inquiryScenario());

      expect(find.text('记录'), findsOneWidget);
      expect(find.text('归纳'), findsOneWidget);
      expect(find.text('猜测'), findsNothing, reason: '无 predictions 时不应出现猜测节点');
      await _teardown(tester);
    });
  });

  group('AC-3: 记录链路（snapshotProvider → ExperimentLogger）', () {
    testWidgets('白光+红滤光片记录一次 → 行数据正确（光源/波长占位/滤光片/看到颜色）', (tester) async {
      await _pumpScreen(tester, scenario: _inquiryScenario());

      await tester.ensureVisible(find.text('记录本次实验'));
      await tester.tap(find.text('记录本次实验'));
      await tester.pump(const Duration(milliseconds: 100));

      // 记录后表格渲染：param 列头带 * 后缀（experiment_logger.dart:220），reading 列头原文
      expect(find.text('光源*'), findsOneWidget, reason: 'bulbMode param 列头');
      expect(find.text('看到颜色'), findsOneWidget,
          reason: 'perceivedColor reading 列头（footer 为「看到颜色：红色」完整文本，不冲突）');
      // 白光 + 红滤光片 → 白光 / —（波长占位）/ 红色 / Red（colorName 返回英文名）
      expect(find.text('白光'), findsAtLeastNWidgets(2),
          reason: 'bulbMode 行值 + footer 光源 chip');
      expect(find.text('红色'), findsAtLeastNWidgets(2),
          reason: 'filter 行值 + footer 滤光片 chip');
      expect(find.text('Red'), findsOneWidget,
          reason: 'perceivedColor 行值（ColorModel.colorName 英文名 · color_model.dart:32）');
      expect(find.text('—'), findsOneWidget, reason: '波长占位符（白光模式无波长）');
      expect(find.text('实验记录（1/20）'), findsOneWidget, reason: '行数计数更新');
      await _teardown(tester);
    });

    testWidgets('记录后关闭再打开抽屉 → 记录 State 保持（AC-6 · Offstage 保 State）', (tester) async {
      await _pumpScreen(tester, scenario: _inquiryScenario());

      await tester.ensureVisible(find.text('记录本次实验'));
      await tester.tap(find.text('记录本次实验'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byTooltip('探究任务'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byTooltip('探究任务'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('实验记录（1/20）'), findsOneWidget,
          reason: '关闭再打开后记录不丢（Offstage 保 State）');
      await _teardown(tester);
    });
  });

  group('AC-6: 布局合规（抽屉展开态无溢出）', () {
    for (final size in [
      const Size(320, 480),
      const Size(1024, 768),
      const Size(1920, 1080),
    ]) {
      testWidgets('抽屉展开 · ${size.width}x${size.height} 无 overflow', (tester) async {
        await _pumpScreen(tester, scenario: _inquiryScenario(), size: size);
        expect(tester.takeException(), isNull,
            reason: '抽屉展开时 ${size.width}x${size.height} 不得溢出');
        await _teardown(tester);
      });
    }
  });
}
