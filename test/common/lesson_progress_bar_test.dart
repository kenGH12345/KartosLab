import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/lesson_runtime.dart';
import 'package:kratos/common/widgets/lesson_progress_bar.dart';

/// T-P1-09 · LessonProgressBar 单测（三态 chips + 实时更新 + 窄视口无溢出）。
void main() {
  LessonPlan threeNodePlan() => LessonPlan.fromJson(
        {
          'lessonId': 'pb-lesson',
          'name': '进度条测试课时',
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

  Widget wrap(LessonRuntime rt, {Size? screen}) {
    return MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: rt,
          builder: (_, _) => LessonProgressBar(runtime: rt),
        ),
      ),
    );
  }

  testWidgets('三态 chips 渲染：当前 ▶ / 未完成淡灰 / 终点节点 chip', (tester) async {
    final rt = LessonRuntime()..load(threeNodePlan());
    await tester.pumpWidget(wrap(rt));

    expect(find.text('节点A'), findsWidgets); // 标题行 + chip
    expect(find.text('0/2'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget); // 当前节点
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2)); // 未完成×2
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.lock), findsNothing); // P1 isUnlocked 恒 true
  });

  testWidgets('AC-20 · runtime 推进后标题/计数/chips 实时更新', (tester) async {
    final rt = LessonRuntime()..load(threeNodePlan());
    await tester.pumpWidget(wrap(rt));

    rt.onScenarioSuccess(); // a 完成 → current=b
    await tester.pump();

    expect(find.text('1/2'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget); // a ✓
    expect(find.byIcon(Icons.play_arrow), findsOneWidget); // b ▶

    rt.onScenarioSuccess(); // b 完成 → 终点
    await tester.pump();
    expect(find.text('2/2'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });

  testWidgets('T-P2-03 · onNodeTap 非空 → 点击 chip 触发回调', (tester) async {
    final rt = LessonRuntime()..load(threeNodePlan());
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: rt,
          builder: (_, _) => LessonProgressBar(
            runtime: rt,
            onNodeTap: (id) => tapped = id,
          ),
        ),
      ),
    ));
    await tester.tap(find.text('节点B'));
    expect(tapped, 'b');
  });

  testWidgets('320px 窄视口无 overflow 异常（L0-2）', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final rt = LessonRuntime()..load(threeNodePlan());
    await tester.pumpWidget(wrap(rt));
    // 无 overflow 异常即通过（chips 横向滚动兜底）
    expect(find.byType(LessonProgressBar), findsOneWidget);
  });
}
