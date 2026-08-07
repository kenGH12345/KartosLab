import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geometric_optics/common/widgets/inquiry_models.dart';
import 'package:geometric_optics/common/widgets/inquiry_task_panel.dart';

void main() {
  group('InquiryTaskPanel', () {
    testWidgets('task == null 时不渲染（SizedBox.shrink）', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: InquiryTaskPanel(task: null)),
      ));
      expect(find.byType(InquiryTaskPanel), findsOneWidget);
      expect(find.text('探究任务'), findsNothing);
      expect(find.textContaining('发现什么规律'), findsNothing);
    });

    testWidgets('task 非空显示 question', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InquiryTaskPanel(
            task: InquiryTask(
              question: '改变电阻值，观察电流变化，你能发现什么规律？',
            ),
          ),
        ),
      ));
      expect(find.text('探究任务'), findsOneWidget);
      expect(find.text('改变电阻值，观察电流变化，你能发现什么规律？'), findsOneWidget);
    });

    testWidgets('steps 存在时按序渲染 instruction 与 hint', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InquiryTaskPanel(
            task: const InquiryTask(
              question: '探究问题',
              steps: [
                InquiryStep(id: 's1', instruction: '第一步：改变电阻', hint: '提示：调小一点'),
                InquiryStep(id: 's2', instruction: '第二步：观察电流'),
              ],
            ),
          ),
        ),
      ));
      // ExpansionTile 默认展开
      expect(find.text('第一步：改变电阻'), findsOneWidget);
      expect(find.text('第二步：观察电流'), findsOneWidget);
      expect(find.text('提示：调小一点'), findsOneWidget);
    });

    testWidgets('只读（无提交/编辑交互）', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InquiryTaskPanel(
            task: InquiryTask(question: '只读问题', steps: const [InquiryStep(id: 's1', instruction: '步骤一')]),
          ),
        ),
      ));
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
