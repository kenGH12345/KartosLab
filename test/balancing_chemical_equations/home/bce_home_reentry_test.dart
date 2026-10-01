import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';
import 'package:kratos/balancing_chemical_equations/game/game_state.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/screens/balancing_chemical_equations_home.dart';
import 'package:kratos/screens/home_screen.dart';

/// KartosLab Home pattern: pop disposes *Home → re-entry is source defaults.
class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _pumpHome(WidgetTester tester, {NavigatorObserver? observer}) async {
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

Future<void> _enter(WidgetTester tester) async {
  await tester.ensureVisible(
    find.text(BalancingChemicalEquationsHome.title).first,
  );
  await tester.tap(find.text(BalancingChemicalEquationsHome.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _back(WidgetTester tester, _PopObserver observer) async {
  final back = find.byType(BackButton);
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
  } else {
    await tester.tap(find.byType(IconButton).first);
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

BalancingChemicalEquationsHomeState _homeState(WidgetTester tester) {
  return tester.state<BalancingChemicalEquationsHomeState>(
    find.byType(BalancingChemicalEquationsHome),
  );
}

void main() {
  testWidgets(
    'modify Intro → Back → re-enter Intro is fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.intro.selectById('intro.separateWater');
      first.intro.selectedEquation.reactants.first.coefficient = 3;
      first.intro.setViewMode(ViewMode.barCharts);
      expect(first.intro.selectedId, 'intro.separateWater');

      await _back(tester, observer);
      await _enter(tester);

      final again = _homeState(tester);
      expect(identical(again.intro, first.intro), isFalse);
      expect(again.intro.selectedId, 'intro.makeAmmonia');
      expect(again.intro.selectedEquation.reactants.first.coefficient, 1);
      expect(again.intro.viewMode, ViewMode.particles);
    },
  );

  testWidgets(
    'modify Equations → Back → re-enter Equations is fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.equations.selectedEquation.reactants.first.coefficient = 4;
      await tester.tap(find.text(BceStrings.screenEquations));
      await tester.pump(const Duration(milliseconds: 400));

      await _back(tester, observer);
      await _enter(tester);
      await tester.tap(find.text(BceStrings.screenEquations));
      await tester.pump(const Duration(milliseconds: 400));

      final again = _homeState(tester);
      expect(identical(again.equations, first.equations), isFalse);
      expect(again.equations.selectedEquation.reactants.first.coefficient, 1);
    },
  );

  testWidgets(
    'progress Game → Back → re-enter Game is fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.game.selectLevel(first.game.levels.first);
      first.game.challenge.balance();
      first.game.check();
      expect(first.game.score, 2);
      expect(first.game.gameState, GameState.next);

      await tester.tap(find.text(BceStrings.screenGame));
      await tester.pump(const Duration(milliseconds: 400));

      await _back(tester, observer);
      await _enter(tester);
      await tester.tap(find.text(BceStrings.screenGame));
      await tester.pump(const Duration(milliseconds: 400));

      final again = _homeState(tester);
      expect(identical(again.game, first.game), isFalse);
      expect(again.game.gameState, GameState.levelSelection);
      expect(again.game.score, 0);
      expect(again.game.timer.isRunning, isFalse);
    },
  );

  testWidgets(
    'dirty all three screens → leave → reopen all fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.intro.selectedEquation.reactants.first.coefficient = 2;
      first.equations.selectedEquation.products.first.coefficient = 0;
      first.game.selectLevel(first.game.levels[1]);
      first.game.challenge.balance();
      first.game.check();

      await _back(tester, observer);
      await _enter(tester);

      final again = _homeState(tester);
      expect(again.intro.selectedEquation.reactants.first.coefficient, 1);
      expect(again.equations.selectedEquation.products.first.coefficient, 1);
      expect(again.game.gameState, GameState.levelSelection);
      expect(again.game.score, 0);
    },
  );

  testWidgets(
    'Home → Game → Home → Game ×3 — single timer instance per entry',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);

      for (var i = 0; i < 3; i++) {
        await _enter(tester);
        final state = _homeState(tester);
        state.game.setTimerEnabled(true);
        state.game.selectLevel(state.game.levels.first);
        expect(state.game.timer.isRunning, isTrue);
        final timer = state.game.timer;
        await tester.tap(find.text(BceStrings.screenGame));
        await tester.pump(const Duration(milliseconds: 200));
        await _back(tester, observer);
        expect(timer.isRunning, isFalse);
        expect(find.byType(BalancingChemicalEquationsHome), findsNothing);
      }
    },
  );
}
