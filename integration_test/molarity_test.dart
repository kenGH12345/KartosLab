import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:kratos/main.dart';

/// molarity 集成测试（真实设备/模拟器 · ≥2 完整 scenario 冒烟）。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openMolarity(WidgetTester tester) async {
    await tester.pumpWidget(const KratosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('摩尔浓度 · 溶液配比 知识点'));
    await tester.pumpAndSettle();
  }

  testWidgets('入口 → default 场景渲染（AC-4.1）', (tester) async {
    await openMolarity(tester);
    expect(find.text('Molarity 自由探索'), findsOneWidget); // 场景标题
    expect(find.text('溶质'), findsOneWidget); // ComboBox
    expect(find.byType(Slider), findsNWidgets(2)); // 双滑块
    expect(find.byIcon(Icons.science_outlined), findsOneWidget); // 探究入口
  });

  testWidgets('拖体积滑块 → 浓度联动无异常（AC-2.2）', (tester) async {
    await openMolarity(tester);
    await tester.drag(find.byType(Slider).last, const Offset(80, 0));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byTooltip('重置'), findsOneWidget);
  });

  testWidgets('切换场景 → 饱和挑战（AC-3.3 · 场景池可用）', (tester) async {
    await openMolarity(tester);
    await tester.tap(find.text('切换场景'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('饱和挑战'));
    await tester.pumpAndSettle();
    expect(find.text('饱和挑战'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));
  });
}
