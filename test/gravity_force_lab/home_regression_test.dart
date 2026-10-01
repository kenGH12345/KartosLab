import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/gfl_strings.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_strings.dart';
import 'package:kratos/gravity_force_lab_basics/screens/gflb_home.dart';
import 'package:kratos/hookes_law/screens/hookes_law_home.dart';
import 'package:kratos/masses_and_springs_basics/screens/masb_home.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _openHome(
  WidgetTester tester, {
  NavigatorObserver? observer,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      navigatorObservers: [
        ?observer,
      ],
    ),
  );
  await tester.pump();
}

Future<void> _tapTitle(WidgetTester tester, String title) async {
  await tester.ensureVisible(find.text(title).first);
  await tester.tap(find.text(title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _back(WidgetTester tester) async {
  final backButton = find.byType(BackButton);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
  } else {
    await tester.pageBack();
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('Basics still opens Basics; Full still opens Full',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);

    await _tapTitle(tester, GflbHome.title);
    expect(find.byType(GflbHome), findsOneWidget);
    expect(find.byType(GravityForceLabScreen), findsNothing);
    expect(find.text(GflbStrings.billionKg), findsWidgets);
    expect(find.text(GflStrings.decimalNotation), findsNothing);

    await _back(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await _tapTitle(tester, GravityForceLabScreen.title);
    expect(find.byType(GravityForceLabScreen), findsOneWidget);
    expect(find.byType(GflbHome), findsNothing);
    expect(find.text(GflStrings.decimalNotation), findsOneWidget);
    expect(find.text(GflStrings.scientificNotation), findsOneWidget);
    expect(find.text(GflStrings.hidden), findsOneWidget);
    expect(find.text(GflbStrings.billionKg), findsNothing);
    expect(find.text('Distance'), findsNothing);

    final full = tester
        .state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
    expect(full.model.mass1.value, GravityForceConstants.initialMass1);
    expect(GravityForceConstants.gravitationalConstant, 6.67408e-11);
  });

  testWidgets('Home → Basics → Back → Home → Full isolation', (tester) async {
    await _openHome(tester);

    await _tapTitle(tester, GflbHome.title);
    final basics =
        tester.state<GflbHomeState>(find.byType(GflbHome));
    basics.model.setMassValue(1, 5e9);
    await tester.pump();
    await _back(tester);

    await _tapTitle(tester, GravityForceLabScreen.title);
    final full = tester
        .state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
    expect(full.model.mass1.value, 100); // kg, not billion
    expect(full.model.mass1.value, isNot(5e9));
    await _back(tester);

    await _tapTitle(tester, GflbHome.title);
    final basics2 = tester.state<GflbHomeState>(find.byType(GflbHome));
    expect(basics2.model.mass1.value, 2e9); // Basics default, fresh
  });

  testWidgets('sibling cards in 力学 still listed; no route title collision',
      (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text(MasbHome.title).first);
    expect(find.text(MasbHome.title), findsOneWidget);
    await tester.ensureVisible(find.text(HookesLawHome.title).first);
    expect(find.text(HookesLawHome.title), findsOneWidget);

    // Full and Basics both present exactly once.
    expect(find.text(GravityForceLabScreen.title), findsOneWidget);
    expect(find.text(GflbHome.title), findsOneWidget);
    expect(find.text(GflStrings.subtitle), findsOneWidget);
    expect(find.text(GflbStrings.subtitle), findsOneWidget);
  });

  testWidgets('Home visual: Full card uses Full accent/icon metadata',
      (tester) async {
    await _openHome(tester);
    expect(GravityForceLabScreen.accentColor.toARGB32(), 0xFFFDF498);
    expect(GravityForceLabScreen.homeIcon, Icons.language_rounded);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    // Basics uses public_rounded (may share icon codepoint with other cards).
    expect(find.byIcon(Icons.public_rounded), findsWidgets);
    expect(find.text(GravityForceLabScreen.title), findsOneWidget);
    expect(find.text(GflbHome.title), findsOneWidget);
  });
}
