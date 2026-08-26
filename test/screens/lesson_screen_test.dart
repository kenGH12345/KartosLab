import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/lesson_runtime.dart';
import 'package:kratos/screens/lesson_screen.dart';

/// T-P1-10 · LessonScreen widget 测试（stub hostBuilder 端到端）。
void main() {
  LessonPlan linearPlan() => LessonPlan.fromJson(
        {
          'lessonId': 'ls-lesson',
          'name': '宿主屏测试课时',
          'version': '1.0',
          'description': 'x',
          'entry': 'a',
          'nodes': [
            {
              'id': 'a',
              'title': '节点A',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
              'advance': {'type': 'next'},
            },
            {
              'id': 'b',
              'title': '节点B',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-2'},
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {'id': 'n-end', 'title': '课时完成', 'scenario': null, 'advance': null},
          ],
        },
        scenarioPlayable: (_, _) => true,
      );

  /// stub host：显示节点 id + 提供「模拟场景完成」按钮触发钩子。
  Widget stubHost(BuildContext context, LessonNode node, LessonHooks hooks) {
    return Column(
      children: [
        Text('STUB-${node.id}', key: ValueKey('stub-${node.id}')),
        TextButton(
          onPressed: hooks.onScenarioSuccess,
          child: const Text('模拟场景完成'),
        ),
      ],
    );
  }

  Future<void> pumpLesson(WidgetTester tester, LessonPlan plan) async {
    await tester.pumpWidget(MaterialApp(
      home: LessonScreen(plan: plan, simHostBuilder: stubHost),
    ));
    await tester.pump();
  }

  /// T-P2-03 · 带 unlock 门禁的剧本：b 需要 a 完成后才解锁。
  LessonPlan unlockPlan() => LessonPlan.fromJson(
        {
          'lessonId': 'unlock-lesson',
          'name': '门禁课时',
          'version': '1.0',
          'description': 'x',
          'entry': 'a',
          'nodes': [
            {
              'id': 'a',
              'title': '节点A',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
              'advance': {'type': 'onCompleted', 'to': 'b'},
            },
            {
              'id': 'b',
              'title': '节点B',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-2'},
              'unlock': {
                'id': 'u-b',
                'type': 'nodeCompleted',
                'description': '完成A',
                'params': {'nodeId': 'a'},
              },
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {'id': 'n-end', 'title': '课时完成', 'scenario': null, 'advance': null},
          ],
        },
        scenarioPlayable: (_, _) => true,
      );

  testWidgets('T-P2-03 · 锁定 chip 点击 → 无跳转 + SnackBar「节点未解锁」（AC-34）',
      (tester) async {
    await pumpLesson(tester, unlockPlan());
    // a 未完成 → b 锁定；点击 b chip（标题行是"门禁课时 · 节点A"，'节点B' 唯一在 chip）
    await tester.tap(find.text('节点B'));
    await tester.pump();
    await tester.pump(); // postFrameCallback → SnackBar

    expect(find.text('节点未解锁'), findsOneWidget);
    expect(find.byKey(const ValueKey('stub-a')), findsOneWidget); // 未跳转
    expect(find.byKey(const ValueKey('stub-b')), findsNothing);
  });

  /// T-P2-06 · 含预测转发的 stub host：按钮模拟 InquiryDrawer 的
  /// onPredictionResult 转发（verified/correct）。
  Widget predictionStubHost(BuildContext context, LessonNode node, LessonHooks hooks) {
    return Column(
      children: [
        Text('STUB-${node.id}', key: ValueKey('stub-${node.id}')),
        TextButton(
          onPressed: () => hooks.onPredictionResult?.call(3, 3),
          child: const Text('提交预测 3/3'),
        ),
        TextButton(
          onPressed: () => hooks.onPredictionResult?.call(3, 2),
          child: const Text('提交预测 2/3'),
        ),
        TextButton(
          onPressed: hooks.onScenarioSuccess,
          child: const Text('模拟场景完成'),
        ),
      ],
    );
  }

  /// 含 routes 分流剧本（a 节点按预测得分分流 b/c）。
  LessonPlan branchPlan() => LessonPlan.fromJson(
        {
          'lessonId': 'branch-lesson',
          'name': '分流课时',
          'version': '1.0',
          'description': 'x',
          'entry': 'a',
          'nodes': [
            {
              'id': 'a',
              'title': '节点A',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-1'},
              'advance': {
                'type': 'routes',
                'routes': [
                  {
                    'to': 'b',
                    'when': {
                      'id': 'g1',
                      'type': 'predictionScore',
                      'description': '正确率≥80%',
                      'params': {
                        'nodeId': 'a',
                        'metric': 'ratio',
                        'operator': 'gte',
                        'threshold': 0.8,
                      },
                    },
                  },
                  {'to': 'c', 'when': null},
                ],
              },
            },
            {
              'id': 'b',
              'title': '节点B',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-2'},
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {
              'id': 'c',
              'title': '节点C',
              'scenario': {'sim': 'circuit', 'scenarioId': 's-3'},
              'advance': {'type': 'onCompleted', 'to': 'n-end'},
            },
            {'id': 'n-end', 'title': '课时完成', 'scenario': null, 'advance': null},
          ],
        },
        scenarioPlayable: (_, _) => true,
      );

  testWidgets('AC-42 · 转发链路端到端：预测 3/3 → 分流挑战线（b）', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LessonScreen(plan: branchPlan(), simHostBuilder: predictionStubHost),
    ));
    await tester.pump();

    await tester.tap(find.text('提交预测 3/3'));
    await tester.pump();
    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();

    expect(find.byKey(const ValueKey('stub-b')), findsOneWidget); // ratio=1 ≥ 0.8
  });

  testWidgets('AC-42 · 转发链路端到端：预测 2/3 → 走兜底复习线（c）', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LessonScreen(plan: branchPlan(), simHostBuilder: predictionStubHost),
    ));
    await tester.pump();

    await tester.tap(find.text('提交预测 2/3'));
    await tester.pump();
    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();

    expect(find.byKey(const ValueKey('stub-c')), findsOneWidget); // ratio=0.67 < 0.8
  });

  testWidgets('Major-4 · jumpTo 回已完成节点 → 不弹「已完成 X → 进入 Y」流转提示',
      (tester) async {
    await pumpLesson(tester, unlockPlan());
    // a 完成 → 自动流转到 b（弹一次完成提示）
    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('已完成「'), findsOneWidget);
    // 等 SnackBar 彻底过期（2s duration + 进出动画：分帧推进 5s）
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('已完成「'), findsNothing); // 旧提示已消失
    // jumpTo 回已完成节点 a → 跳转成功但不弹流转提示（Major-4 抑制）
    await tester.tap(find.text('节点A'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('stub-a')), findsOneWidget);
    expect(find.textContaining('已完成「'), findsNothing,
        reason: 'jumpTo 非完成流转，不应弹完成提示');
  });

  testWidgets('T-P2-03 · a 完成后 b 解锁 → 点击 chip 跳转（AC-35）', (tester) async {
    await pumpLesson(tester, unlockPlan());
    await tester.tap(find.text('模拟场景完成')); // a 完成 → 自动流转到 b
    await tester.pump();
    // 自动流转已到 b；为验证点击路径，先跳回 a（a 已解锁）
    await tester.tap(find.text('节点A'));
    await tester.pump();
    expect(find.byKey(const ValueKey('stub-a')), findsOneWidget);
    // 再点 b chip → 跳转（b 已解锁）
    await tester.tap(find.text('节点B'));
    await tester.pump();
    expect(find.byKey(const ValueKey('stub-b')), findsOneWidget);
  });

  testWidgets('初始渲染：AppBar 含剧本名+当前节点标题（AC-19）+ stub host 显示 entry 节点',
      (tester) async {
    await pumpLesson(tester, linearPlan());
    expect(find.textContaining('宿主屏测试课时 · 节点A'), findsOneWidget);
    expect(find.byKey(const ValueKey('stub-a')), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });

  testWidgets('AC-21 · 模拟完成 → 节点切换 + SnackBar 流转反馈', (tester) async {
    await pumpLesson(tester, linearPlan());

    await tester.tap(find.text('模拟场景完成'));
    await tester.pump(); // runtime 流转
    await tester.pump(); // postFrameCallback → SnackBar

    expect(find.byKey(const ValueKey('stub-b')), findsOneWidget);
    expect(find.textContaining('已完成「节点A」→ 进入「节点B」'), findsOneWidget);
  });

  testWidgets('AC-22 · 流转至终点 → 完成视图（🎉 + 节点回顾 + 返回首页）', (tester) async {
    await pumpLesson(tester, linearPlan());

    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // 等 AnimatedSwitcher 结束（旧 child 出树）
    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();

    expect(find.text('课时完成！'), findsOneWidget);
    expect(find.text('🎉'), findsOneWidget);
    // 回顾列表（SnackBar 残留文本可能同名 → findsWidgets 不断言唯一）
    expect(find.text('节点A'), findsWidgets);
    expect(find.text('节点B'), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.text('返回首页'), findsOneWidget);
  });

  testWidgets('AC-22 · 完成视图「返回首页」按钮可 pop', (tester) async {
    // 首页 → push LessonScreen → 完成 → pop 回首页
    final plan = linearPlan();
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => LessonScreen(plan: plan, simHostBuilder: stubHost),
          )),
          child: const Text('进入课时'),
        ),
      ),
    ));
    await tester.tap(find.text('进入课时'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // 等过渡动画结束
    await tester.tap(find.text('模拟场景完成'));
    await tester.pump();
    // SnackBar（duration 2s）悬浮底部会遮挡「返回首页」按钮命中 → 等其过期
    await tester.pump(const Duration(milliseconds: 2500));

    await tester.tap(find.text('返回首页'));
    await tester.pumpAndSettle(); // 等 pop 转场动画完成（首页无持续动画，settle 安全）

    expect(find.text('进入课时'), findsOneWidget); // 已 pop 回首页
    expect(find.text('课时完成！'), findsNothing);
  });
}
