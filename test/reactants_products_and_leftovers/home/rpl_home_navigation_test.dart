import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart';
import 'package:kratos/reactants_products_and_leftovers/view/game_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_screen.dart';
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

Future<void> _enterRpl(WidgetTester tester) async {
  await tester.ensureVisible(
    find.text(ReactantsProductsAndLeftoversHome.title).first,
  );
  await tester.tap(find.text(ReactantsProductsAndLeftoversHome.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(ReactantsProductsAndLeftoversHome), findsOneWidget);
}

Future<void> _back(WidgetTester tester, _PopObserver observer) async {
  final before = observer.popCount;
  final backButton = find.byType(BackButton);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
  } else {
    await tester.tap(find.byType(IconButton).first);
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(observer.popCount, greaterThan(before));
  expect(find.byType(ReactantsProductsAndLeftoversHome), findsNothing);
}

void main() {
  testWidgets('Home → RPL → Sandwiches tab', (tester) async {
    await _openHome(tester);
    await _enterRpl(tester);
    expect(find.byType(SandwichesScreen), findsOneWidget);
    expect(find.text(RpalStrings.cheese), findsWidgets);
  });

  testWidgets('Home → RPL → Molecules tab', (tester) async {
    await _openHome(tester);
    await _enterRpl(tester);
    await tester.tap(find.text(RpalStrings.molecules));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MoleculesScreen), findsOneWidget);
    expect(find.text(RpalStrings.makeWater), findsWidgets);
  });

  testWidgets('Home → RPL → Game tab', (tester) async {
    await _openHome(tester);
    await _enterRpl(tester);
    await tester.tap(find.text(RpalStrings.game));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text(RpalStrings.chooseYourLevel), findsOneWidget);
  });

  testWidgets('Sandwiches ↔ Molecules ↔ Game tab switch', (tester) async {
    await _openHome(tester);
    await _enterRpl(tester);

    await tester.tap(find.text(RpalStrings.molecules));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MoleculesScreen), findsOneWidget);

    await tester.tap(find.text(RpalStrings.game));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GameScreen), findsOneWidget);

    await tester.tap(find.text(RpalStrings.sandwiches));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SandwichesScreen), findsOneWidget);
  });

  testWidgets('Back from RPL returns to Home once', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enterRpl(tester);
    await _back(tester, observer);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(observer.popCount, 1);
  });
}
