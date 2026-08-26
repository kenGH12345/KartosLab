import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/inquiry_models.dart';
import 'package:kratos/common/widgets/prediction_panel.dart';

void main() {
  const prediction = InquiryPrediction(
    id: 'p1',
    question: '保持电压不变，电阻从 5Ω 调到 50Ω，电流会怎样变化？',
    options: ['电流增大', '电流减小', '电流不变'],
    answer: 1,
    explanation: '欧姆定律 I = V / R',
  );

  const p2 = InquiryPrediction(
    id: 'p2',
    question: '电阻增大后，灯泡亮度会？',
    options: ['变亮', '变暗', '不变'],
    answer: 1,
  );

  /// 单题推进模式下验证后有 1.5s 判定展示期（PRED-002）。
  Future<void> settle(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 1600));

  group('PredictionPanel（单题推进模式）', () {
    testWidgets('predictions 为空时不渲染内容', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [])),
      ));
      expect(find.byType(PredictionPanel), findsOneWidget);
      expect(find.textContaining('第 1 题'), findsNothing);
    });

    testWidgets('未选择时验证按钮禁用（PRED-001）', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [prediction])),
      ));
      expect(find.textContaining('第 1/1 题'), findsOneWidget);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('选对答案 → 验证显示「猜对了」+ 解析', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [prediction])),
      ));
      await tester.tap(find.text('电流减小'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(find.text('猜对了！'), findsOneWidget);
      expect(find.textContaining('欧姆定律'), findsOneWidget);
    });

    testWidgets('选错答案 → 验证显示正确答案 + 解析', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [prediction])),
      ));
      await tester.tap(find.text('电流增大'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(find.textContaining('猜错了'), findsOneWidget);
      expect(find.textContaining('正确答案是「电流减小」'), findsOneWidget);
      expect(find.textContaining('欧姆定律'), findsOneWidget);
    });

    testWidgets('验证前可自由改选答案（PRED-003 单题模式语义）', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [prediction])),
      ));
      // 先选错项再改选正确项：验证按钮始终可用
      await tester.tap(find.text('电流增大'));
      await tester.pump();
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNotNull);
      await tester.tap(find.text('电流减小'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(find.text('猜对了！'), findsOneWidget);
    });

    testWidgets('验证后判定展示期间选项锁定，1.5s 后进入下一题（PRED-002）',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PredictionPanel(predictions: [prediction, p2]),
          ),
        ),
      ));
      // 第 1 题：选择并验证
      await tester.tap(find.text('电流减小'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(find.text('猜对了！'), findsOneWidget);
      // 判定展示期间：验证结果保留、下一题未出现
      expect(find.textContaining('电阻增大后'), findsNothing);
      expect(find.textContaining('即将进入下一题'), findsOneWidget);

      // 1.5s 后自动推进第 2 题
      await settle(tester);
      expect(find.textContaining('第 2/2 题'), findsOneWidget);
      expect(find.textContaining('电阻增大后'), findsOneWidget);
      expect(find.text('猜对了！'), findsNothing);
      // 第 2 题未选择，验证按钮禁用
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('全部验证完成 → onAllVerified 触发一次（PRED-004）',
        (tester) async {
      var allVerifiedCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PredictionPanel(
            predictions: const [prediction, p2],
            onAllVerified: () => allVerifiedCount++,
          ),
        ),
      ));
      // 第 1 题
      await tester.tap(find.text('电流减小'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await settle(tester);
      // 第 2 题
      await tester.tap(find.text('变暗'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(allVerifiedCount, 0); // 判定展示期内尚未触发
      await settle(tester);
      expect(allVerifiedCount, 1); // 1.5s 后触发阶段流转
    });

    testWidgets('review 模式：只读展示全部题目与判定', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PredictionPanel(predictions: [prediction, p2], review: true),
          ),
        ),
      ));
      expect(find.textContaining('第 1 题'), findsOneWidget);
      expect(find.textContaining('第 2 题'), findsOneWidget);
      // 未作答 → 不显示判定
      expect(find.textContaining('猜对了'), findsNothing);
      expect(find.textContaining('你的答案'), findsNothing);
      // 无验证按钮（只读回顾）
      expect(find.text('验证我的猜测'), findsNothing);
    });
  });
}
