import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart';
import 'package:kratos/screens/home_screen.dart';

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
  final before = observer.popCount;
  final back = find.byType(BackButton);
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
  } else {
    await tester.tap(find.byType(IconButton).first);
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(observer.popCount, greaterThan(before));
}

void main() {
  testWidgets('open → back → reopen twice without exceptions', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);

    for (var round = 0; round < 2; round++) {
      await _enter(tester);
      final homeState = tester.state<ReactantsProductsAndLeftoversHomeState>(
        find.byType(ReactantsProductsAndLeftoversHome),
      );
      expect(homeState.sandwiches.selected.bread.quantity, 0);
      expect(homeState.molecules.selected.reactants[0].quantity, 0);
      expect(homeState.game.model.score, 0);

      await _back(tester, observer);
      expect(find.byType(ReactantsProductsAndLeftoversHome), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    }
  });

  testWidgets('dispose owned controllers on Back', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);
    await _enter(tester);

    final state = tester.state<ReactantsProductsAndLeftoversHomeState>(
      find.byType(ReactantsProductsAndLeftoversHome),
    );
    final sandwiches = state.sandwiches;
    final molecules = state.molecules;
    final game = state.game;

    var sandwichesNotified = false;
    var moleculesNotified = false;
    var gameNotified = false;
    sandwiches.addListener(() => sandwichesNotified = true);
    molecules.addListener(() => moleculesNotified = true);
    game.addListener(() => gameNotified = true);

    await _back(tester, observer);

    // After dispose, notifying should throw or be no-op depending on ChangeNotifier;
    // Flutter ChangeNotifier.dispose marks disposed — calling notifyListeners throws.
    expect(
      () => sandwiches.notifyListeners(),
      throwsA(isA<FlutterError>()),
    );
    expect(
      () => molecules.notifyListeners(),
      throwsA(isA<FlutterError>()),
    );
    expect(
      () => game.notifyListeners(),
      throwsA(isA<FlutterError>()),
    );
    expect(sandwichesNotified, isFalse);
    expect(moleculesNotified, isFalse);
    expect(gameNotified, isFalse);
  });
}
