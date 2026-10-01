import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_enums.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart';
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
    find.text(ReactantsProductsAndLeftoversHome.title).first,
  );
  await tester.tap(find.text(ReactantsProductsAndLeftoversHome.title).first);
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

ReactantsProductsAndLeftoversHomeState _homeState(WidgetTester tester) {
  return tester.state<ReactantsProductsAndLeftoversHomeState>(
    find.byType(ReactantsProductsAndLeftoversHome),
  );
}

void main() {
  testWidgets(
    'modify Sandwiches → Back → re-enter Sandwiches is fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.sandwiches.selectRecipe(first.sandwiches.recipes[1]);
      first.sandwiches.setReactantQuantity(first.sandwiches.selected.bread, 6);
      expect(first.sandwiches.selected.name, RpalStrings.meatAndCheese);

      await _back(tester, observer);
      await _enter(tester);

      final again = _homeState(tester);
      expect(identical(again.sandwiches, first.sandwiches), isFalse);
      expect(again.sandwiches.selected.name, RpalStrings.cheese);
      expect(again.sandwiches.selected.bread.quantity, 0);
    },
  );

  testWidgets(
    'modify Molecules → Back → re-enter Molecules is fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.molecules.selectReaction(first.molecules.reactions[2]);
      first.molecules.setReactantQuantity(
        first.molecules.selected.reactants[0],
        5,
      );
      await tester.tap(find.text(RpalStrings.molecules));
      await tester.pump(const Duration(milliseconds: 400));

      await _back(tester, observer);
      await _enter(tester);
      await tester.tap(find.text(RpalStrings.molecules));
      await tester.pump(const Duration(milliseconds: 400));

      final again = _homeState(tester);
      expect(identical(again.molecules, first.molecules), isFalse);
      expect(again.molecules.selected.name, RpalStrings.makeWater);
      expect(again.molecules.selected.reactants[0].quantity, 0);
    },
  );

  testWidgets(
    'progress Game → Back → re-enter Game is fresh settings',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.game.play(0);
      first.game.model.challenge!.showAnswer();
      first.game.check();
      expect(first.game.model.score, 2);
      expect(first.game.model.gamePhase, GamePhase.play);

      await tester.tap(find.text(RpalStrings.game));
      await tester.pump(const Duration(milliseconds: 400));

      await _back(tester, observer);
      await _enter(tester);
      await tester.tap(find.text(RpalStrings.game));
      await tester.pump(const Duration(milliseconds: 400));

      final again = _homeState(tester);
      expect(identical(again.game, first.game), isFalse);
      expect(again.game.model.gamePhase, GamePhase.settings);
      expect(again.game.model.score, 0);
      expect(again.game.model.challenge, isNull);
      expect(again.game.model.playState, PlayState.none);
      expect(find.text(RpalStrings.chooseYourLevel), findsOneWidget);
    },
  );

  testWidgets(
    'dirty all three screens → leave → reopen all fresh',
    (tester) async {
      final observer = _PopObserver();
      await _pumpHome(tester, observer: observer);
      await _enter(tester);

      final first = _homeState(tester);
      first.sandwiches.setReactantQuantity(first.sandwiches.selected.bread, 8);
      first.molecules.selectReaction(first.molecules.reactions[1]);
      first.game.play(1);
      first.game.model.challenge!.showAnswer();
      first.game.check();

      await _back(tester, observer);
      await _enter(tester);

      final again = _homeState(tester);
      expect(again.sandwiches.selected.bread.quantity, 0);
      expect(again.molecules.selected.name, RpalStrings.makeWater);
      expect(again.game.model.gamePhase, GamePhase.settings);
      expect(again.game.model.score, 0);
    },
  );
}
