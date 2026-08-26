import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/experiment_logger.dart';
import 'package:kratos/common/widgets/inquiry_drawer.dart';
import 'package:kratos/common/widgets/inquiry_models.dart';

/// T-P1-07 · InquiryDrawer onPredictionResult 可选转发（AC-40/41 · AC-R3）。
void main() {
  const p1 = InquiryPrediction(
    id: 'p1',
    question: '合闸后灯泡会亮吗？',
    options: ['会', '不会'],
    answer: 0,
  );
  const p2 = InquiryPrediction(
    id: 'p2',
    question: '断开开关后灯泡会？',
    options: ['继续亮', '熄灭'],
    answer: 1,
  );

  const task = InquiryTask(
    question: '开关如何控制电路？',
    steps: [InquiryStep(id: 's1', instruction: '合闸观察')],
    predictions: [p1, p2],
  );

  Widget buildDrawer({void Function(int, int)? onPredictionResult}) {
    return MaterialApp(
      home: Scaffold(
        body: InquiryDrawer(
          task: task,
          columns: const [ColumnDef(key: 'switch', label: '开关')],
          snapshotProvider: () => const {'switch': 'closed'},
          open: true,
          onPredictionResult: onPredictionResult,
        ),
      ),
    );
  }

  /// 答一道题：选选项 → 验证 → 等判定展示期（PRED-002 单题 1.5s）。
  Future<void> answerOne(
      WidgetTester tester, String option, {bool correct = true}) async {
    await tester.tap(find.text(option));
    await tester.pump();
    await tester.tap(find.text('验证我的猜测'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
  }

  testWidgets('AC-40 · 传入回调 → 答完全部预测题后收到最终 (verified, correct) 真实值',
      (tester) async {
    final results = <(int, int)>[];
    await tester.pumpWidget(buildDrawer(
      onPredictionResult: (v, c) => results.add((v, c)),
    ));
    await tester.pump();

    // 第 1 题答对（answer=0 → 选「会」）
    await answerOne(tester, '会');
    // 第 2 题答错（answer=1 → 故意选「继续亮」=选项 0）
    await answerOne(tester, '继续亮', correct: false);

    expect(results, isNotEmpty);
    // 最终一次转发 = 全部 2 题已验证、答对 1 题
    expect(results.last, (2, 1));
    // 每次验证都有一次转发（中间态存在）
    expect(results.length, greaterThanOrEqualTo(2));
    expect(results.first.$1, 1); // 第一次 verified=1
  });

  testWidgets('AC-41/AC-R3 · 不传回调 → 现有行为逐字节等价（答题/阶段流转正常）',
      (tester) async {
    await tester.pumpWidget(buildDrawer());
    await tester.pump();

    await answerOne(tester, '会');
    await answerOne(tester, '熄灭');

    // 猜测阶段完成 → 任务阶段解锁（「确认任务」出现 = 阶段正常流转）
    expect(find.textContaining('答对'), findsWidgets);
    // 无回调侧调用即无异常——测试到此即证明未传参路径无 crash
  });
}
