import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/main.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 8 — Android Chinese runtime (device/emulator).
/// Continuous sims: never `pumpAndSettle` after enter.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester, [int n = 24]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  Future<void> launchHome(WidgetTester tester) async {
    await tester.pumpWidget(const KratosApp());
    await pumpFrames(tester, 50);
  }

  Future<void> openSim(WidgetTester tester, String title) async {
    final target = find.text(title).hitTestable();
    // Prefer the home SingleChildScrollView — avoid multi-Scrollable ambiguity.
    final scrollables = find.byType(Scrollable);
    final scrollable = scrollables.evaluate().length == 1
        ? scrollables
        : find.descendant(
            of: find.byType(HomeScreen),
            matching: find.byType(Scrollable),
          );
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.text(title),
        280,
        scrollable: scrollable.first,
      );
    } else {
      await tester.ensureVisible(target.first);
    }
    await pumpFrames(tester, 6);
    await tester.tap(find.text(title).first);
    await pumpFrames(tester, 40);
  }

  Future<void> goBackHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    final icon = find.byIcon(Icons.arrow_back);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first, warnIfMissed: false);
    } else if (icon.evaluate().isNotEmpty) {
      await tester.tap(icon.first, warnIfMissed: false);
    } else {
      final nav = find.byType(Navigator);
      if (nav.evaluate().isNotEmpty) {
        await Navigator.of(tester.element(nav.first)).maybePop();
      } else {
        await tester.pageBack();
      }
    }
    await pumpFrames(tester, 30);
    expect(find.byType(HomeScreen), findsOneWidget);
  }

  testWidgets('P8 Home Chinese chrome', (tester) async {
    await launchHome(tester);
    expect(find.text('Kratos 仿真实验室'), findsOneWidget);
    expect(find.text('碰撞实验室'), findsOneWidget);
    expect(find.textContaining('物理'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('P8 Collision Lab path', (tester) async {
    await launchHome(tester);
    await openSim(tester, '碰撞实验室');
    expect(find.byType(BackButton), findsOneWidget);
    final paint = find.byType(CustomPaint);
    if (paint.evaluate().isNotEmpty) {
      final box = tester.getRect(paint.first);
      final g = await tester.startGesture(
        Offset(box.left + box.width * 0.4, box.top + box.height * 0.5),
      );
      await pumpFrames(tester, 3);
      await g.moveBy(const Offset(80, 40));
      await pumpFrames(tester, 6);
      await g.up();
    }
    final reset = find.byType(KratosResetAllButton);
    if (reset.evaluate().isNotEmpty) {
      await tester.tap(reset.first, warnIfMissed: false);
      await pumpFrames(tester, 12);
    }
    expect(tester.takeException(), isNull);
    await goBackHome(tester);
  });

  testWidgets('P8 Buoyancy tabs + drag', (tester) async {
    await launchHome(tester);
    await openSim(tester, '浮力');
    for (final tab in ['比较', '探索', '实验室', '形状', '应用']) {
      final t = find.text(tab);
      if (t.evaluate().isEmpty) continue;
      await tester.tap(t.first, warnIfMissed: false);
      await pumpFrames(tester, 14);
    }
    expect(tester.takeException(), isNull);
    await goBackHome(tester);
  });

  testWidgets('P8 high-risk sample set', (tester) async {
    await launchHome(tester);
    for (final title in [
      '电路搭建',
      '气体性质',
      '量子测量',
      '摩尔浓度',
      'pH 标度',
      '物质的状态',
      '化学方程式配平',
      '酸碱溶液',
      '傅里叶：合成波',
      '交流虚拟实验室',
      '量子波干涉',
    ]) {
      await openSim(tester, title);
      expect(tester.takeException(), isNull, reason: title);
      final reset = find.byType(KratosResetAllButton);
      if (reset.evaluate().isNotEmpty) {
        await tester.tap(reset.first, warnIfMissed: false);
        await pumpFrames(tester, 10);
      }
      await goBackHome(tester);
    }
  });

  testWidgets('P8 domain smoke', (tester) async {
    await launchHome(tester);
    for (final title in [
      '力与运动',
      '矢量加法',
      '密度',
      '欧姆定律',
      '几何光学',
      '波的干涉',
      '构建原子',
    ]) {
      await openSim(tester, title);
      expect(tester.takeException(), isNull, reason: title);
      await goBackHome(tester);
    }
  });
}
