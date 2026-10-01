import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_screen.dart';
import 'package:kratos/balancing_chemical_equations/game/game_screen.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_screen.dart';
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
  testWidgets('Back from Intro returns to Home', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);
    await _enter(tester);
    expect(find.byType(IntroScreen), findsOneWidget);
    await _back(tester, observer);
    expect(find.byType(BalancingChemicalEquationsHome), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Back from Equations returns to Home', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);
    await _enter(tester);
    await tester.tap(find.text(BceStrings.screenEquations));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(EquationsScreen), findsOneWidget);
    await _back(tester, observer);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Back from Game returns to Home', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);
    await _enter(tester);
    await tester.tap(find.text(BceStrings.screenGame));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GameScreen), findsOneWidget);
    await _back(tester, observer);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Home → BCE → Home ×3 cycles', (tester) async {
    final observer = _PopObserver();
    await _pumpHome(tester, observer: observer);
    for (var i = 0; i < 3; i++) {
      await _enter(tester);
      expect(find.byType(BalancingChemicalEquationsHome), findsOneWidget);
      await _back(tester, observer);
      expect(find.byType(HomeScreen), findsOneWidget);
    }
  });
}
