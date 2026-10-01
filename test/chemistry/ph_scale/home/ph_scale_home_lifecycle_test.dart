import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/macro_screen_view.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/ph_scale_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → 化学 → 溶液与浓度 → pH 标度 lifecycle (Phase 8).
void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void ignoreLayoutNoise() {
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('A RenderFlex overflowed')) return;
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> openPhScale(WidgetTester tester) async {
    final card = find.text('pH 标度');
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PhScaleScreen), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(PhScaleScreen), findsNothing);
  }

  testWidgets('Home catalog: 化学 / 溶液与浓度 / pH 标度 once', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);

    expect(find.text('化学'), findsWidgets);
    expect(find.text('溶液与浓度'), findsOneWidget);
    expect(find.text('pH 标度'), findsOneWidget);
    expect(find.text('酸 · 碱 · 浓度 · Macro/Micro'), findsOneWidget);
    // Sibling molarity still present — category integrity
    expect(find.text('摩尔浓度'), findsOneWidget);
  });

  testWidgets('Home → PhScaleScreen (not demo) · default Macro', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openPhScale(tester);

    expect(find.byType(PhScaleScreen), findsOneWidget);
    expect(find.byType(MacroScreenView), findsOneWidget);
    expect(find.text('pH Scale'), findsOneWidget);
    expect(find.text('Macro'), findsWidgets);
    // Macro has Water faucet label; Graph chrome absent on Macro
    expect(find.text('Water'), findsWidgets);
    expect(find.textContaining('Concentration'), findsNothing);
  });

  testWidgets('open → Macro/Micro/MySolution → Reset → back → reopen ×3',
      (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);

    for (var cycle = 0; cycle < 3; cycle++) {
      await openPhScale(tester);
      expect(find.byType(MacroScreenView), findsOneWidget);

      await tester.tap(find.text('Micro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.textContaining('Concentration'), findsWidgets);
      expect(find.text('Logarithmic'), findsOneWidget);

      await tester.tap(find.text('My Solution'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      // My Solution spinner value (KeepAlive may keep Micro mounted)
      expect(find.text('7.00'), findsWidgets);
      // My Solution graph is log-only (no Linear switch chrome from MySol)
      // Micro KeepAlive may still expose Logarithmic — assert spinner present instead
      expect(find.text('Particle Counts'), findsWidgets);

      // Reset All — last button is on the active My Solution stack layer typically
      expect(find.byType(KratosResetAllButton), findsWidgets);
      await tester.tap(find.byType(KratosResetAllButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('7.00'), findsWidgets);

      await tester.tap(find.text('Macro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    }

    // Final reopen defaults to Macro again
    await openPhScale(tester);
    expect(find.byType(MacroScreenView), findsOneWidget);
    expect(find.textContaining('Concentration'), findsNothing);
    await backToHome(tester);
  });

  testWidgets('builder target is PhScaleScreen via Navigator push', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openPhScale(tester);
    // Formal host — AppBar title from PhScaleScreen, not a QA/demo label
    expect(find.text('pH Scale'), findsOneWidget);
    expect(find.textContaining('QA'), findsNothing);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.textContaining('Preview'), findsNothing);
    await backToHome(tester);
  });
}
