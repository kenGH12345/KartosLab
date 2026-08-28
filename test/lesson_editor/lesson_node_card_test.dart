import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/lesson_editor/canvas/lesson_node_card.dart';

/// M2（代码评审）回归测试：dataFlow 类冲突节点在画布卡片上显示 ⚠ 角标。
void main() {
  Widget wrap({required bool isConflict}) {
    return MaterialApp(
      home: Scaffold(
        body: LessonNodeCard(
          title: '节点A',
          isEnd: false,
          isSelected: false,
          isConflict: isConflict,
          onTap: () {},
          onDragDelta: (_) {},
          onEdgeDragStart: () {},
          onEdgeDragUpdate: (_) {},
          onEdgeDragEnd: (_) {},
        ),
      ),
    );
  }

  testWidgets('isConflict=true 时显示冲突角标', (tester) async {
    await tester.pumpWidget(wrap(isConflict: true));
    expect(find.byKey(const ValueKey('node-conflict-badge')), findsOneWidget);
  });

  testWidgets('isConflict=false（默认）时不显示冲突角标', (tester) async {
    await tester.pumpWidget(wrap(isConflict: false));
    expect(find.byKey(const ValueKey('node-conflict-badge')), findsNothing);
  });
}
