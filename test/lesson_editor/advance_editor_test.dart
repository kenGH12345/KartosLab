import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/success_condition.dart';
import 'package:kratos/lesson_editor/panels/advance_editor.dart';

const _crossSimWarningKey = ValueKey('condition-cross-sim-warning');

/// 代码评审 M3 修复的回归测试：
/// 删除 routes 末项（兜底路由）后，原倒数第二项"晋升"为新末项时，
/// 其 [LessonRoute.when] 必须被自动清空为 null（D7 兜底路由不变量），
/// 否则会导致保存校验失败且 UI 无法自行修复（末项隐藏条件编辑器）。
void main() {
  testWidgets('M3 · 删除末项路由后，新末项 when 被自动清空', (tester) async {
    // 3 条路由的属性面板内容较高，默认 800x600 测试视口会溢出，
    // 放大视口避免 RenderFlex overflow 干扰末项 IconButton 的命中判定。
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const advance = LessonAdvance(
      type: 'routes',
      routes: [
        LessonRoute(
          to: 'b',
          when: LeafCondition(id: 'c1', type: 'nodeCompleted', description: '条件1'),
        ),
        LessonRoute(
          to: 'c',
          when: LeafCondition(id: 'c2', type: 'nodeCompleted', description: '条件2'),
        ),
        LessonRoute(to: 'd'), // 末项兜底：when == null
      ],
    );

    LessonAdvance? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdvanceEditor(
            advance: advance,
            nodeIds: const ['a', 'b', 'c', 'd'],
            selfId: 'a',
            isEndNode: false,
            onChanged: (v) => received = v,
          ),
        ),
      ),
    );

    // 删除末项（兜底路由行，index=2），触发 onRemove。
    // 注：非末项的 ConditionTreeEditor 自身也带 Icons.close（删除条件），
    // 故不能用 find.byIcon(Icons.close).at(n) 做全局序号定位，改用行级 Key。
    await tester.tap(find.byKey(const ValueKey('route-remove-2')));
    await tester.pump();

    expect(received, isNotNull);
    final routes = received!.routes!;
    expect(routes.length, 2);
    expect(routes.last.to, 'c');
    expect(routes.last.when, isNull,
        reason: '新末项（原第2条）的 when 必须被强制清空为 null');
  });

  testWidgets('M2 · routes.when 条件树叶子跨 sim 引用时显示 ⚠ 提示', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const advance = LessonAdvance(
      type: 'routes',
      routes: [
        LessonRoute(
          to: 'b',
          when: LeafCondition(
            id: 'c1',
            type: 'nodeCompleted',
            description: '条件1',
            params: {'nodeId': 'b'},
          ),
        ),
        LessonRoute(to: 'c'), // 末项兜底
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdvanceEditor(
            advance: advance,
            nodeIds: const ['a', 'b', 'c'],
            selfId: 'a',
            isEndNode: false,
            onChanged: (_) {},
            // a 属于 circuit，条件引用的 b 属于 optics → 跨 sim
            ownerSim: 'circuit',
            nodeSims: const {'a': 'circuit', 'b': 'optics', 'c': 'circuit'},
          ),
        ),
      ),
    );

    expect(find.byKey(_crossSimWarningKey), findsOneWidget);
  });

  testWidgets('M2 · 同 sim 引用时不显示 ⚠ 提示', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const advance = LessonAdvance(
      type: 'routes',
      routes: [
        LessonRoute(
          to: 'b',
          when: LeafCondition(
            id: 'c1',
            type: 'nodeCompleted',
            description: '条件1',
            params: {'nodeId': 'b'},
          ),
        ),
        LessonRoute(to: 'c'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdvanceEditor(
            advance: advance,
            nodeIds: const ['a', 'b', 'c'],
            selfId: 'a',
            isEndNode: false,
            onChanged: (_) {},
            ownerSim: 'circuit',
            nodeSims: const {'a': 'circuit', 'b': 'circuit', 'c': 'circuit'},
          ),
        ),
      ),
    );

    expect(find.byKey(_crossSimWarningKey), findsNothing);
  });
}
