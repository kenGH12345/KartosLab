import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/charges_and_fields/caf_strings.dart';
import 'package:kratos/charges_and_fields/screens/charges_and_fields_home.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _enterCaf(WidgetTester tester) async {
  await tester.ensureVisible(find.text(CafStrings.title).first);
  await tester.tap(find.text(CafStrings.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(ChargesAndFieldsHome), findsOneWidget);
}

Future<void> _leaveCaf(WidgetTester tester, _PopObserver observer) async {
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
}

void main() {
  testWidgets('Home lists Charges and Fields under 电学与电路', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text(CafStrings.title));
    expect(find.text(CafStrings.title), findsOneWidget);
    expect(find.text('电学与电路'), findsOneWidget);
  });

  testWidgets('Home → CAF → Electric Field → back → reopen', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final observer = _PopObserver();
    await tester.pumpWidget(
      MaterialApp(home: const HomeScreen(), navigatorObservers: [observer]),
    );
    await _enterCaf(tester);
    expect(find.text(CafStrings.electricField), findsWidgets);

    await _leaveCaf(tester, observer);
    expect(find.byType(ChargesAndFieldsHome), findsNothing);

    await _enterCaf(tester);
    expect(find.text(CafStrings.electricField), findsWidgets);
  });

  testWidgets('reinitializeForTest recreates model', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey<ChargesAndFieldsHomeState>();
    await tester.pumpWidget(
      MaterialApp(home: ChargesAndFieldsHome(key: key)),
    );
    await tester.pump();
    final before = key.currentState!.model;
    key.currentState!.reinitializeForTest();
    await tester.pump();
    expect(identical(before, key.currentState!.model), isFalse);
  });
}
