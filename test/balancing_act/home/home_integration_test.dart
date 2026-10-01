import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';
import 'package:kratos/hookes_law/screens/hookes_law_home.dart';
import 'package:kratos/projectile_motion/screens/projectile_motion_home.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _openHome(WidgetTester tester, {NavigatorObserver? observer}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      navigatorObservers: [?observer],
    ),
  );
  await tester.pump();
}

Future<void> _enterBa(WidgetTester tester) async {
  await tester.ensureVisible(find.text(BalancingActHome.title).first);
  await tester.tap(find.text(BalancingActHome.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(BalancingActHome), findsOneWidget);
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(Tab, label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _back(WidgetTester tester) async {
  expect(find.byType(BackButton), findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

BalancingActHomeState _state(WidgetTester tester) {
  return tester.state<BalancingActHomeState>(find.byType(BalancingActHome));
}

void main() {
  // H1 / H2 — card + category
  testWidgets('H1/H2 Home lists Balancing Act under 物理 / 力学', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text('物理').first);
    expect(find.text('物理'), findsWidgets);
    await tester.ensureVisible(find.text('力学').first);
    expect(find.text('力学'), findsWidgets);
    await tester.ensureVisible(find.text(BalancingActHome.title).first);
    expect(find.text(BalancingActHome.title), findsOneWidget);
    expect(find.text(BalancingActHome.subtitle), findsOneWidget);
    expect(find.byIcon(Icons.scale_rounded), findsOneWidget);
  });

  // H8 — existing home neighbors still present
  testWidgets('H8 neighboring 力学 cards remain', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text(HookesLawHome.title).first);
    expect(find.text(HookesLawHome.title), findsOneWidget);
    await tester.ensureVisible(find.text(ProjectileMotionHome.title).first);
    expect(find.text(ProjectileMotionHome.title), findsOneWidget);
    await tester.ensureVisible(find.text(BalancingActHome.title).first);
    expect(find.text(BalancingActHome.title), findsOneWidget);
  });

  // H3 / H4 — navigation + root opens Intro
  testWidgets('H3/H4 card opens BalancingActHome on Intro', (tester) async {
    await _openHome(tester);
    await _enterBa(tester);
    expect(find.byType(BaIntroScreen), findsOneWidget);
    expect(find.text(BaStrings.screenIntro), findsWidgets);
    expect(find.byKey(const Key('ba_intro_viewport')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // H9 / H10 / H11 — tab screens
  testWidgets('H9–H11 tabs open Intro / Lab / Game', (tester) async {
    await _openHome(tester);
    await _enterBa(tester);

    expect(find.byType(BaIntroScreen), findsOneWidget);

    await _tab(tester, BaStrings.screenBalanceLab);
    expect(find.byType(BaBalanceLabScreen), findsOneWidget);
    expect(find.byKey(const Key('ba_lab_carousel')), findsOneWidget);

    await _tab(tester, BaStrings.screenGame);
    expect(find.byType(BaGameScreen), findsOneWidget);
    expect(find.text(BaStrings.selectLevel), findsOneWidget);

    await _tab(tester, BaStrings.screenIntro);
    expect(find.byKey(const Key('ba_intro_viewport')), findsOneWidget);
  });

  // H5 — back to Home
  testWidgets('H5 Back returns to HomeScreen', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enterBa(tester);
    await _back(tester);
    expect(observer.popCount, 1);
    expect(find.byType(BalancingActHome), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(BalancingActHome.title), findsOneWidget);
  });

  // H6 / H7 — re-entry fresh controllers, no duplicate lifecycle
  testWidgets('H6/H7 re-entry builds fresh controllers; clocks isolated',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enterBa(tester);

    final first = _state(tester);
    final staleIntro = first.intro;
    final staleLab = first.lab;
    final staleGame = first.game;

    // Mutate Intro
    final mass = staleIntro.model.fireExtinguisher1;
    staleIntro.beginDrag(mass, staleIntro.mvt.modelToView(mass.position));
    staleIntro.updateDrag(
      staleIntro.mvt.modelToView(const BaVector2(1.0, 0.9)),
    );
    staleIntro.endDrag();
    expect(staleIntro.model.plank.massesOnSurface, isNotEmpty);

    // Mutate Lab carousel
    staleLab.nextCarouselPage();
    expect(staleLab.model.carousel.pageIndex, 1);

    // Mutate Game
    staleGame.startLevel(1);
    expect(staleGame.model.gameState, BaGameState.presentingInteractiveChallenge);

    await _back(tester);
    expect(find.byType(BalancingActHome), findsNothing);

    await _enterBa(tester);
    final again = _state(tester);
    expect(identical(again.intro, staleIntro), isFalse);
    expect(identical(again.lab, staleLab), isFalse);
    expect(identical(again.game, staleGame), isFalse);
    expect(again.intro.model.plank.massesOnSurface, isEmpty);
    expect(again.lab.model.carousel.pageIndex, 0);
    expect(again.game.model.gameState, BaGameState.choosingLevel);
    expect(again.intro.clock.isRunning, isTrue);
    expect(observer.popCount, 1);
    expect(tester.takeException(), isNull);
  });

  // Re-entry stress ×3
  testWidgets('H6 stress Home→BA→Back ×3', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    for (var i = 0; i < 3; i++) {
      await _enterBa(tester);
      final s = _state(tester);
      s.intro.setForcesVisible(true);
      await _tab(tester, BaStrings.screenGame);
      s.game.startLevel(0);
      await _back(tester);
      expect(find.byType(BalancingActHome), findsNothing);
    }
    expect(observer.popCount, 3);
    expect(find.text(BalancingActHome.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Cross-sim: other sim then BA
  testWidgets('other 力学 sim then BA does not pollute', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text(HookesLawHome.title).first);
    await tester.tap(find.text(HookesLawHome.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HookesLawHome), findsOneWidget);
    await _back(tester);

    await _enterBa(tester);
    final s = _state(tester);
    expect(s.intro.model.plank.massesOnSurface, isEmpty);
    expect(s.game.model.gameState, BaGameState.choosingLevel);
    await _back(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  // Reset after Home entry
  testWidgets('Reset All after Home entry restores Intro defaults',
      (tester) async {
    await _openHome(tester);
    await _enterBa(tester);
    final s = _state(tester);
    final m = s.intro.model.fireExtinguisher1;
    s.intro.beginDrag(m, s.intro.mvt.modelToView(m.position));
    s.intro.updateDrag(s.intro.mvt.modelToView(const BaVector2(-1.0, 0.9)));
    s.intro.endDrag();
    s.intro.setSupportsEnabled(false);
    s.intro.resetAll();
    expect(s.intro.model.plank.massesOnSurface, isEmpty);
    expect(s.intro.model.columnState, ColumnState.doubleColumns);
    expect(s.intro.model.fireExtinguisher1.position, const BaVector2(2.7, 0));
  });
}
