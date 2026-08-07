import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geometric_optics/common/widgets/conclusion_panel.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('提交前参考结论不渲染（结论先消失）', (tester) async {
    await tester.pumpWidget(wrap(const ConclusionPanel(
      question: '电流和电阻的关系？',
      referenceConclusion: 'I = V/R',
    )));
    expect(find.text('参考结论'), findsNothing);
    expect(find.text('I = V/R'), findsNothing);
    expect(find.text('提交我的结论'), findsOneWidget);
  });

  testWidgets('提交后展开参考结论', (tester) async {
    await tester.pumpWidget(wrap(const ConclusionPanel(
      question: '电流和电阻的关系？',
      referenceConclusion: 'I = V/R',
    )));
    await tester.enterText(find.byType(TextField), '电流随电阻减小而增大');
    await tester.tap(find.text('提交我的结论'));
    await tester.pump();
    expect(find.text('参考结论'), findsOneWidget);
    expect(find.text('I = V/R'), findsOneWidget);
    expect(find.text('你的结论'), findsOneWidget);
    expect(find.text('电流随电阻减小而增大'), findsOneWidget);
  });

  testWidgets('空输入不允许提交', (tester) async {
    await tester.pumpWidget(wrap(const ConclusionPanel(
      question: 'q',
      referenceConclusion: 'r',
    )));
    await tester.tap(find.text('提交我的结论'));
    await tester.pump();
    expect(find.textContaining('请先写下你的发现'), findsOneWidget);
    expect(find.text('参考结论'), findsNothing);
  });

  testWidgets('referenceConclusion == null 时仅自由输入无对照', (tester) async {
    await tester.pumpWidget(wrap(const ConclusionPanel(question: 'q')));
    await tester.enterText(find.byType(TextField), '我的想法');
    await tester.tap(find.text('提交我的结论'));
    await tester.pump();
    expect(find.text('你的结论'), findsOneWidget);
    expect(find.text('参考结论'), findsNothing);
  });

  testWidgets('提交后可再次编辑并更新结论，参考结论保持可见', (tester) async {
    await tester.pumpWidget(wrap(const ConclusionPanel(
      question: 'q',
      referenceConclusion: '参考',
    )));
    await tester.enterText(find.byType(TextField), '第一版');
    await tester.tap(find.text('提交我的结论'));
    await tester.pump();
    await tester.tap(find.text('修改结论'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '第二版');
    await tester.tap(find.text('更新'));
    await tester.pump();
    expect(find.text('第二版'), findsOneWidget);
    expect(find.text('参考结论'), findsOneWidget);
  });
}
