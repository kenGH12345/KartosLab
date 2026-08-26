import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/experiment_logger.dart';
import 'package:kratos/common/widgets/inquiry_drawer.dart';
import 'package:kratos/common/widgets/inquiry_models.dart';

/// Completed 阶段回顾行为回归测试（IXD Spec v1.0 §2.2 + CON-007）。
///
/// 覆盖两个曾实证失败的缺陷：
/// 1. 按状态增删 IgnorePointer 包裹层 → element 树结构变化销毁子树 State
///    → 回顾显示「N 题未验证」而非学生真实作答
/// 2. InkWell 包裹整卡 → 点击回顾内容区穿透触发折叠
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  Map<String, dynamic> snap() => {'r': 1.0};

  const columns = [ColumnDef(key: 'r', label: 'R')];

  Future<void> useLargeViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('预测全部验证后展开回顾 → 显示真实作答与判定（CON-007 State 保留）',
      (tester) async {
    await useLargeViewport(tester);
    await tester.pumpWidget(wrap(InquiryDrawer(
      task: const InquiryTask(
        question: 'Q',
        predictions: [
          InquiryPrediction(
            id: 'p1',
            question: '电阻增大电流会？',
            options: ['增大', '减小'],
            answer: 1,
          ),
        ],
      ),
      columns: columns,
      snapshotProvider: snap,
      open: true,
    )));

    await tester.tap(find.text('减小'));
    await tester.pump();
    await tester.tap(find.text('验证我的猜测'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 600));

    // Completed 摘要显示实际正确数（§3.2「X/N 正确」）
    expect(find.textContaining('答对 1/1 题'), findsOneWidget);

    // 展开回顾 → 必须显示学生真实作答（而非「未验证」）
    await tester.tap(find.text('先猜一猜'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('你的答案'), findsOneWidget);
    expect(find.textContaining('题未验证'), findsNothing);
  });

  testWidgets('点击 Completed 回顾内容区不折叠卡片（仅 Header 可切换）',
      (tester) async {
    await useLargeViewport(tester);
    await tester.pumpWidget(wrap(InquiryDrawer(
      task: const InquiryTask(
        question: 'Q',
        steps: [InquiryStep(id: 's1', instruction: '步骤一')],
      ),
      columns: columns,
      snapshotProvider: snap,
      open: true,
    )));

    await tester.tap(find.text('我已了解任务，开始实验'));
    await tester.pump(const Duration(milliseconds: 600));

    // 点 Header 展开回顾
    await tester.tap(find.text('探究任务').first);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('步骤一'), findsOneWidget);

    // 点内容区 → 保持展开
    await tester.tap(find.text('步骤一'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('步骤一'), findsOneWidget);

    // 再点 Header → 折叠
    await tester.tap(find.text('探究任务').first);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('步骤一'), findsNothing);
  });

  testWidgets('答错时摘要显示实际正确数（不假定全对）', (tester) async {
    await useLargeViewport(tester);
    await tester.pumpWidget(wrap(InquiryDrawer(
      task: const InquiryTask(
        question: 'Q',
        predictions: [
          InquiryPrediction(
              id: 'p1', question: 'q1', options: ['A', 'B'], answer: 1),
          InquiryPrediction(
              id: 'p2', question: 'q2', options: ['C', 'D'], answer: 0),
        ],
      ),
      columns: columns,
      snapshotProvider: snap,
      open: true,
    )));

    // 第 1 题答错
    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text('验证我的猜测'));
    await tester.pump(const Duration(milliseconds: 1600));
    // 第 2 题答对
    await tester.tap(find.text('C'));
    await tester.pump();
    await tester.tap(find.text('验证我的猜测'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('答对 1/2 题'), findsOneWidget);
  });
}
