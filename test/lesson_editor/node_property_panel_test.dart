import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/success_condition.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';
import 'package:kratos/lesson_editor/screens/lesson_editor_screen.dart';

const _crossSimWarningKey = ValueKey('condition-cross-sim-warning');

/// 代码评审 B1/B2 修复的回归测试：
/// - AC-4 · 节点标题需可在属性面板中编辑（此前只读 Text，无法修改）
/// - AC-16 · 剧本 version/description 需可在"剧本设置"区编辑（此前无 UI）
void main() {
  const node = EditableNode(id: 'n1', title: '初始标题');
  const model = EditableLessonModel(
    lessonId: 'l1',
    name: '课时A',
    version: '1.0',
    description: '初始描述',
  );

  Widget wrap({
    required ValueChanged<String> onTitleChanged,
    required void Function({
      String? lessonId,
      String? name,
      String? version,
      String? description,
      String? entry,
    }) onMetaChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: NodePropertyPanel(
          model: model,
          node: node,
          nodeIds: const ['n1'],
          onAdvanceChanged: (_) {},
          onScenarioChanged: (_) {},
          onUnlockChanged: (_) {},
          onMetaChanged: onMetaChanged,
          onTitleChanged: onTitleChanged,
        ),
      ),
    );
  }

  testWidgets('AC-4 · 编辑节点标题触发 onTitleChanged', (tester) async {
    String? received;
    await tester.pumpWidget(
      wrap(
        onTitleChanged: (v) => received = v,
        onMetaChanged: ({lessonId, name, version, description, entry}) {},
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('title-n1')),
      '新标题',
    );

    expect(received, '新标题');
  });

  testWidgets('AC-16 · 编辑 version/description 触发 onMetaChanged', (tester) async {
    String? receivedVersion;
    String? receivedDescription;
    await tester.pumpWidget(
      wrap(
        onTitleChanged: (_) {},
        onMetaChanged: ({lessonId, name, version, description, entry}) {
          receivedVersion = version ?? receivedVersion;
          receivedDescription = description ?? receivedDescription;
        },
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('meta-version')),
      '2.0',
    );
    await tester.enterText(
      find.byKey(const ValueKey('meta-description')),
      '新描述',
    );

    expect(receivedVersion, '2.0');
    expect(receivedDescription, '新描述');
  });

  testWidgets('M2 · 解锁条件跨 sim 引用节点时显示 ⚠ 提示', (tester) async {
    const n1 = EditableNode(
      id: 'n1',
      title: '节点1',
      scenario: LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb'),
      unlock: LeafCondition(
        id: 'c1',
        type: 'nodeCompleted',
        description: '',
        params: {'nodeId': 'n2'},
      ),
    );
    const n2 = EditableNode(
      id: 'n2',
      title: '节点2',
      scenario: LessonScenarioRef(sim: 'optics', scenarioId: 'lens'),
    );
    const model2 = EditableLessonModel(
      lessonId: 'l1',
      name: '课时A',
      nodes: [n1, n2],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NodePropertyPanel(
            model: model2,
            node: n1,
            nodeIds: const ['n1', 'n2'],
            onAdvanceChanged: (_) {},
            onScenarioChanged: (_) {},
            onUnlockChanged: (_) {},
            onMetaChanged: ({lessonId, name, version, description, entry}) {},
            onTitleChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(_crossSimWarningKey), findsOneWidget);
  });

  testWidgets('m4 · 外部 rebuild（value 未变）时受控输入框保持光标位置', (tester) async {
    var title = 'abcd';
    var rebuildTick = 0;
    late StateSetter externalSetState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              externalSetState = setState;
              // ignore: unused_local_variable
              final tick = rebuildTick; // 仅触发 rebuild，不改 title
              final n = EditableNode(id: 'n1', title: title);
              final m = EditableLessonModel(
                lessonId: 'l1',
                name: '课时A',
                nodes: [n],
              );
              return NodePropertyPanel(
                model: m,
                node: n,
                nodeIds: const ['n1'],
                onAdvanceChanged: (_) {},
                onScenarioChanged: (_) {},
                onUnlockChanged: (_) {},
                onMetaChanged: ({lessonId, name, version, description, entry}) {},
                onTitleChanged: (v) => setState(() => title = v),
              );
            },
          ),
        ),
      ),
    );

    final titleFinder = find.descendant(
      of: find.byKey(const ValueKey('title-n1')),
      matching: find.byType(EditableText),
    );
    // 光标置于文本中间（第 2 个字符后）
    tester.widget<EditableText>(titleFinder).controller.selection =
        const TextSelection.collapsed(offset: 2);
    await tester.pump();

    // 外部触发 rebuild（模拟 _conflictWarnings 刷新；title 未变）
    externalSetState(() => rebuildTick++);
    await tester.pump();

    // 受控实现应保持文本与光标位置；老实现每次 build 重建 controller → 光标跳末尾
    final after = tester.widget<EditableText>(titleFinder).controller;
    expect(after.text, 'abcd');
    expect(after.selection.baseOffset, 2);
  });
}
