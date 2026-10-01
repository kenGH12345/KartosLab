import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/screens/balancing_chemical_equations_home.dart';
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
    find.text(BalancingChemicalEquationsHome.title).first,
  );
  await tester.tap(find.text(BalancingChemicalEquationsHome.title).first);
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
      final homeState = tester.state<BalancingChemicalEquationsHomeState>(
        find.byType(BalancingChemicalEquationsHome),
      );
      expect(homeState.intro.selectedEquation.reactants.first.coefficient, 1);
      expect(homeState.equations.selectedEquation.reactants.first.coefficient, 1);
      expect(homeState.game.score, 0);
      expect(homeState.game.timer.isRunning, isFalse);

      await _back(tester, observer);
      expect(find.byType(BalancingChemicalEquationsHome), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    }
  });

  testWidgets('dispose owned models on Back — no stale notify', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);
    await _enter(tester);

    final state = tester.state<BalancingChemicalEquationsHomeState>(
      find.byType(BalancingChemicalEquationsHome),
    );
    final intro = state.intro;
    final equations = state.equations;
    final game = state.game;
    final timer = game.timer;

    await _back(tester, observer);

    expect(
      () => intro.notifyListeners(),
      throwsA(isA<FlutterError>()),
    );
    expect(
      () => equations.notifyListeners(),
      throwsA(isA<FlutterError>()),
    );
    expect(
      () => game.notifyListeners(),
      throwsA(isA<FlutterError>()),
    );
    // Timer must not keep ticking on Home
    expect(timer.isRunning, isFalse);
  });
}
