import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/experiment_intro_panel.dart';
import 'package:kratos/common/widgets/inquiry_models.dart';

InquiryPrediction _p(String id, String q) => InquiryPrediction(
      id: id,
      question: q,
      options: const ['电流增大', '电流减小', '不变'],
      answer: 0,
      explanation: '解析',
    );

void main() {
  final task = InquiryTask(
    question: '改变滑动变阻器，电流如何变化？',
    steps: const [
      InquiryStep(id: 's1', instruction: '调节滑片'),
      InquiryStep(id: 's2', instruction: '观察电流'),
    ],
    predictions: [_p('p1', '电流会怎样变化？')],
  );

  testWidgets('含预测题时弹窗显示跳转入口而非内嵌预测题', (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExperimentIntroPanel(
          description: '说明',
          task: task,
          onOpenInquiry: () => opened = true,
        ),
      ),
    ));
    await tester.tap(find.text('说明'));
    await tester.pumpAndSettle();

    // 显示跳转入口文案
    expect(find.textContaining('去猜一猜'), findsOneWidget);
    // 不再内嵌预测题（无「验证我的猜测」按钮）
    expect(find.text('验证我的猜测'), findsNothing);

    await tester.tap(find.text('去猜一猜'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
    // 弹窗已关闭
    expect(find.textContaining('去猜一猜'), findsNothing);
  });

  testWidgets('未传 onOpenInquiry 时不显示跳转入口', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExperimentIntroPanel(
          description: '说明',
          task: task,
        ),
      ),
    ));
    await tester.tap(find.text('说明'));
    await tester.pumpAndSettle();

    expect(find.textContaining('去猜一猜'), findsNothing);
  });
}
