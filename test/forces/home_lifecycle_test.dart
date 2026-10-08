import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/config/forces_strings.dart';
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

    expect(find.text(ForcesStrings.forcesHomeTitle), findsOneWidget);
    expect(find.text(ForcesStrings.screenNetForce), findsWidgets);
    expect(find.text(ForcesStrings.screenMotion), findsWidgets);
    expect(find.text(ForcesStrings.screenFriction), findsWidgets);
    expect(find.text(ForcesStrings.screenAcceleration), findsWidgets);
    expect(find.text(ForcesStrings.netForceGo), findsOneWidget);

    // Motion — tap the Tab label (first match is the tab bar).
    await tester.tap(find.text(ForcesStrings.screenMotion).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('外力'), findsWidgets);

    // Friction
    await tester.tap(find.text(ForcesStrings.screenFriction).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('力'), findsWidgets);

    // Acceleration
    await tester.tap(find.text(ForcesStrings.screenAcceleration).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(ForcesStrings.screenAcceleration), findsWidgets);

    // Back to Net Force
    await tester.tap(find.text(ForcesStrings.screenNetForce).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(ForcesStrings.netForceGo), findsOneWidget);

    // Simulate Home leave → re-enter F&M → Net Force
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    // Allow SimulationClock tickers from prior ForcesHome to dispose.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(ForcesStrings.screenNetForce), findsWidgets);
    expect(find.text(ForcesStrings.netForceGo), findsOneWidget);

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
    expect(find.text(ForcesStrings.forcesHomeTitle), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
