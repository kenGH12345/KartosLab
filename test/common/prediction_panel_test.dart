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

  group('PredictionPanel', () {
    testWidgets('predictions 为空时不渲染内容', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [])),
      ));
      expect(find.byType(PredictionPanel), findsOneWidget);
      expect(find.text('先猜一猜'), findsNothing);
    });

    testWidgets('未选择时验证按钮禁用', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [prediction])),
      ));
      expect(find.text('先猜一猜'), findsOneWidget);
      expect(find.textContaining('第 1 题'), findsOneWidget);
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

    testWidgets('多题独立选择与验证', (tester) async {
      const p2 = InquiryPrediction(
        id: 'p2',
        question: '电阻增大后，灯泡亮度会？',
        options: ['变亮', '变暗', '不变'],
        answer: 1,
      );
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PredictionPanel(predictions: [prediction, p2]),
          ),
        ),
      ));
      await tester.tap(find.text('电流减小'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测').first);
      await tester.pump();
      expect(find.text('猜对了！'), findsOneWidget);
      // 第 2 题未选择，验证按钮仍可独立操作
      final second = tester.widget<FilledButton>(find.byType(FilledButton).last);
      expect(second.onPressed, isNull);
    });

    testWidgets('验证后改答案 → 验证结果重置，需重新验证', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: PredictionPanel(predictions: [prediction])),
      ));
      // 选「电流增大」（错）→ 验证 → 显示「猜错了」
      await tester.tap(find.text('电流增大'));
      await tester.pump();
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(find.textContaining('猜错了'), findsOneWidget);
      // 改选「电流减小」→ 验证结果应消失，验证按钮恢复
      await tester.tap(find.text('电流减小'));
      await tester.pump();
      expect(find.textContaining('猜错了'), findsNothing);
      expect(find.text('验证我的猜测'), findsOneWidget);
      // 重新验证 → 显示「猜对了」
      await tester.tap(find.text('验证我的猜测'));
      await tester.pump();
      expect(find.text('猜对了！'), findsOneWidget);
    });
  });
}
