import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/screens/acid_base_solutions_home.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/screens/home_screen.dart';

/// Phase 6 — Home integration for Acid-Base Solutions.
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

  Future<void> openAbs(WidgetTester tester) async {
    final card = find.text(AcidBaseSolutionsHome.title);
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AcidBaseSolutionsHome), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AcidBaseSolutionsHome), findsNothing);
  }

  // H1–H3 card / category / title
  testWidgets('H1-H3 Home catalog card in 化学 / 溶液与浓度', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);

    expect(find.text('化学'), findsWidgets);
    expect(find.text('溶液与浓度'), findsOneWidget);
    expect(find.text(AcidBaseSolutionsHome.title), findsOneWidget);
    expect(find.text(AcidBaseSolutionsHome.subtitle), findsOneWidget);
    // Sibling cards remain
    expect(find.text('摩尔浓度'), findsOneWidget);
    expect(find.text('pH 标度'), findsOneWidget);
  });

  // H4–H5 navigation + Intro opens
  testWidgets('H4-H5 Home → AcidBaseSolutionsHome · default Intro',
      (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openAbs(tester);

    expect(find.byType(AcidBaseSolutionsHome), findsOneWidget);
    expect(find.byType(AbsIntroScreen), findsOneWidget);
    expect(find.text('Water (H₂O)'), findsOneWidget);
    expect(find.text('Intro'), findsWidgets);
    expect(find.text('My Solution'), findsWidgets);
  });

  // H6 My Solution reachable via tab
  testWidgets('H6 My Solution tab opens AbsMySolutionScreen', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openAbs(tester);

    await tester.tap(find.text('My Solution').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(AbsMySolutionScreen), findsOneWidget);
    expect(find.text('Acid'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('weak'), findsOneWidget);
    expect(find.text('strong'), findsOneWidget);
    // Intro may remain KeepAlive-mounted (KratosTabSwitcher); assert My Solution chrome.
    expect(find.text('Initial Concentration (mol/L):'), findsOneWidget);
  });

  // H7 Back to Home
  testWidgets('H7 Back returns to Home', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openAbs(tester);
    await backToHome(tester);
    expect(find.text(AcidBaseSolutionsHome.title), findsOneWidget);
  });

  // H8 Re-entry ×3
  testWidgets('H8 open → interact → back → reopen ×3', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);

    for (var i = 0; i < 3; i++) {
      await openAbs(tester);
      expect(find.byType(AbsIntroScreen), findsOneWidget);
      expect(find.text('Water (H₂O)'), findsOneWidget);

      await tester.tap(find.text('My Solution').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AbsMySolutionScreen), findsOneWidget);

      await tester.tap(find.text('Intro').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await backToHome(tester);
      expect(tester.takeException(), isNull);
    }

    await openAbs(tester);
    expect(find.byType(AbsIntroScreen), findsOneWidget);
    expect(find.text('Water (H₂O)'), findsOneWidget);
    await backToHome(tester);
  });

  // H9 State isolation across re-entry
  testWidgets('H9 re-entry restores Intro Water default', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openAbs(tester);

    await tester.tap(find.text('Strong Acid (HA)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Strong Acid (HA)'), findsOneWidget);

    await backToHome(tester);
    await openAbs(tester);
    // Fresh instance defaults to Water
    expect(find.text('Water (H₂O)'), findsOneWidget);
    await backToHome(tester);
  });

  // H10 Lifecycle cleanup (no crash after dispose cycles)
  testWidgets('H10 lifecycle dispose/reopen no exception', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    for (var i = 0; i < 3; i++) {
      await openAbs(tester);
      await tester.tap(find.text('My Solution').last);
      await tester.pump(const Duration(milliseconds: 100));
      await backToHome(tester);
    }
    expect(tester.takeException(), isNull);
  });

  // H11 Reset after re-entry acts on current instance
  testWidgets('H11 Reset after re-entry restores current screen defaults',
      (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openAbs(tester);

    await tester.tap(find.text('Weak Base (B)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(KratosResetAllButton), findsWidgets);
    final introReset = find.byType(KratosResetAllButton).first;
    await tester.ensureVisible(introReset);
    await tester.pump();
    await tester.tap(introReset, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Water (H₂O)'), findsOneWidget);

    await backToHome(tester);
    await openAbs(tester);
    await tester.tap(find.text('My Solution').last);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(AbsMySolutionScreen), findsOneWidget);
    final myReset = find.descendant(
      of: find.byType(AbsMySolutionScreen),
      matching: find.byType(KratosResetAllButton),
    );
    await tester.ensureVisible(myReset);
    await tester.pump();
    await tester.tap(myReset, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    // My Solution default spinner value
    expect(find.text('0.010'), findsOneWidget);
    await backToHome(tester);
  });

  testWidgets('metadata constants match Home card', (tester) async {
    expect(AcidBaseSolutionsHome.title, '酸碱溶液');
    expect(AcidBaseSolutionsHome.subtitle, contains('Intro'));
    expect(AcidBaseSolutionsHome.subtitle, contains('My Solution'));
  });

  testWidgets('builder target is formal host not demo', (tester) async {
    ignoreLayoutNoise();
    await setDesktop(tester);
    await pumpHome(tester);
    await openAbs(tester);
    expect(find.byType(AcidBaseSolutionsHome), findsOneWidget);
    expect(find.textContaining('QA'), findsNothing);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.textContaining('Preview'), findsNothing);
    await backToHome(tester);
  });
}
