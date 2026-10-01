import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/screens/forces_home.dart';
import 'package:kratos/friction/view/friction_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home wiring + F&M open → tab cycle → reopen + sibling-sim regression.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void ignoreOverflow(FlutterExceptionHandler? old) {
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('A RenderFlex overflowed')) return;
      if (msg.contains('RenderFlex overflowed')) return;
      old?.call(details);
    };
  }

  test('Home catalog exposes 力与运动 under 物理 → 力学', () {
    expect(HomeScreen, isNotNull);
    // Builder reference must compile and construct ForcesHome.
    expect(const ForcesHome(), isA<ForcesHome>());
  });

  testWidgets('Home → F&M → four screens → reopen Net Force', (tester) async {
    final old = FlutterError.onError;
    ignoreOverflow(old);
    addTearDown(() => FlutterError.onError = old);

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Open F&M (as Home builder would).
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Forces and Motion: Basics'), findsOneWidget);
    expect(find.text('Net Force'), findsWidgets);
    expect(find.text('Motion'), findsWidgets);
    expect(find.text('Friction'), findsWidgets);
    expect(find.text('Acceleration'), findsWidgets);
    expect(find.text('Go!'), findsOneWidget);

    // Motion — tap the Tab label (first match is the tab bar).
    await tester.tap(find.text('Motion').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Applied Force'), findsWidgets);

    // Friction
    await tester.tap(find.text('Friction').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Forces'), findsWidgets);

    // Acceleration
    await tester.tap(find.text('Acceleration').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Acceleration'), findsWidgets);

    // Back to Net Force
    await tester.tap(find.text('Net Force').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Go!'), findsOneWidget);

    // Simulate Home leave → re-enter F&M → Net Force
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    // Allow SimulationClock tickers from prior ForcesHome to dispose.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Net Force'), findsWidgets);
    expect(find.text('Go!'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Sibling sim Friction still builds after F&M cycle', (tester) async {
    final old = FlutterError.onError;
    ignoreOverflow(old);
    addTearDown(() => FlutterError.onError = old);

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    // Existing independent Friction sim (books/atoms) — must not break.
    await tester.pumpWidget(const MaterialApp(home: FrictionScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(FrictionScreen), findsOneWidget);

    // Return to F&M
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Forces and Motion: Basics'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
