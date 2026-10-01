import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_strings.dart';
import 'package:kratos/capacitor_lab_basics/screens/capacitor_lab_basics_home.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _enterClb(WidgetTester tester) async {
  await tester.ensureVisible(find.text(ClbStrings.title).first);
  await tester.tap(find.text(ClbStrings.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(CapacitorLabBasicsHome), findsOneWidget);
}

Future<void> _leaveClb(WidgetTester tester, _PopObserver observer) async {
  final before = observer.popCount;
  // Prefer BackButton (locale-independent); fall back to leading IconButton.
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
  testWidgets('Home lists Capacitor Lab: Basics card', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text(ClbStrings.title));
    expect(find.text(ClbStrings.title), findsOneWidget);
  });

  testWidgets('Home → CLB → switch tab → back → reopen', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final observer = _PopObserver();
    await tester.pumpWidget(
      MaterialApp(home: const HomeScreen(), navigatorObservers: [observer]),
    );
    await _enterClb(tester);
    expect(find.text(ClbStrings.screenCapacitance), findsWidgets);

    await tester.tap(find.text(ClbStrings.screenLightBulb));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(ClbStrings.screenLightBulb), findsWidgets);

    await _leaveClb(tester, observer);
    expect(find.byType(CapacitorLabBasicsHome), findsNothing);
    expect(find.text(ClbStrings.title), findsWidgets);

    await _enterClb(tester);
    expect(find.text(ClbStrings.screenCapacitance), findsWidgets);
  });

  testWidgets('reinitializeForTest recreates models; reset restores voltage',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey<CapacitorLabBasicsHomeState>();
    await tester.pumpWidget(
      MaterialApp(home: CapacitorLabBasicsHome(key: key)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final state = key.currentState!;
    final firstCap = state.capacitance;
    firstCap.circuit.battery.voltage = 1.5;
    expect(firstCap.circuit.battery.voltage, 1.5);

    state.reinitializeForTest();
    await tester.pump();
    expect(identical(state.capacitance, firstCap), isFalse);
    expect(state.capacitance.circuit.battery.voltage, 0);

    state.capacitance.circuit.battery.voltage = 0.75;
    state.capacitance.reset();
    expect(state.capacitance.circuit.battery.voltage, 0);
  });

  testWidgets('open/close twice disposes without crash', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final observer = _PopObserver();
    await tester.pumpWidget(
      MaterialApp(home: const HomeScreen(), navigatorObservers: [observer]),
    );

    for (var i = 0; i < 2; i++) {
      await _enterClb(tester);
      await _leaveClb(tester, observer);
      expect(find.byType(CapacitorLabBasicsHome), findsNothing);
    }
    expect(observer.popCount, 2);
  });
}
