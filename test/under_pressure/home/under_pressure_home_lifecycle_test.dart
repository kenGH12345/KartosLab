import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/screens/home_screen.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/screens/under_pressure_home.dart';
import 'package:kratos/under_pressure/view/under_pressure_screen.dart';

/// Phase 6 — Home → Under Pressure integration / lifecycle.
/// Clock may run — avoid pumpAndSettle while sim is on the stack.
void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openUnderPressure(WidgetTester tester) async {
    final card = find.text(UnderPressureHome.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(UnderPressureHome), findsOneWidget);
    expect(find.byType(UnderPressureScreen), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(UnderPressureHome), findsNothing);
  }

  UnderPressureHomeState homeState(WidgetTester tester) {
    return tester.state<UnderPressureHomeState>(
      find.byType(UnderPressureHome),
    );
  }

  group('Home card / category', () {
    testWidgets('card listed under 物理 → 密度与浮力', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('物理'), findsWidgets);
      expect(find.text('密度与浮力'), findsOneWidget);
      expect(find.text(UnderPressureHome.title), findsOneWidget);
      expect(find.text(UnderPressureHome.subtitle), findsOneWidget);
      expect(find.byIcon(UnderPressureHome.homeIcon), findsOneWidget);
    });

    testWidgets('tap opens UnderPressureScreen with AppBar', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(UnderPressureHome.title),
        ),
        findsOneWidget,
      );
      final c = homeState(tester).controller;
      expect(c.model.currentScene, UnderPressureScene.square);
      expect(c.model.fluidDensity, UnderPressureConstants.waterDensity);
      expect(c.model.gravity, UnderPressureConstants.earthGravity);
    });
  });

  group('Back / re-entry', () {
    testWidgets('Back returns to Home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      await backToHome(tester);
    });

    testWidgets('Chamber then Back still returns Home (no nested route)',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      homeState(tester).controller.setScene(UnderPressureScene.chamber);
      await tester.pump();
      await backToHome(tester);
    });

    testWidgets('Mystery then Back returns Home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      homeState(tester).controller.setScene(UnderPressureScene.mystery);
      await tester.pump();
      await backToHome(tester);
    });

    testWidgets('re-entry ×3 starts fresh defaults', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      for (var i = 0; i < 3; i++) {
        await openUnderPressure(tester);
        final c = homeState(tester).controller;
        c.setDensity(1300);
        c.setGravity(15);
        c.setScene(UnderPressureScene.trapezoid);
        c.setInputFlow(0.5);
        await tester.pump();
        await backToHome(tester);
        await openUnderPressure(tester);
        final c2 = homeState(tester).controller;
        expect(c2.model.currentScene, UnderPressureScene.square);
        expect(c2.model.fluidDensity, UnderPressureConstants.waterDensity);
        expect(c2.model.gravity, UnderPressureConstants.earthGravity);
        expect(c2.model.square.inputFaucet.flowRate, 0);
        await backToHome(tester);
      }
    });
  });

  group('Lifecycle / isolation / reset', () {
    testWidgets('stress Home ↔ UP navigation', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      for (var i = 0; i < 4; i++) {
        await openUnderPressure(tester);
        await backToHome(tester);
      }
      // Peer sim then back to UP
      final density = find.text('密度');
      await tester.ensureVisible(density.first);
      await tester.tap(density.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final back = find.byType(BackButton);
      if (back.evaluate().isNotEmpty) {
        await tester.tap(back);
      } else {
        await tester.pageBack();
      }
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await openUnderPressure(tester);
      expect(find.byType(UnderPressureScreen), findsOneWidget);
      await backToHome(tester);
    });

    testWidgets('chamber mass state does not survive re-entry', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      final c = homeState(tester).controller;
      c.setScene(UnderPressureScene.chamber);
      final lo = c.model.chamber.leftOpening;
      final mass = c.model.chamber.masses[0];
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset(
          (lo.x1 + lo.x2) / 2,
          lo.y2 + c.model.chamber.leftWaterHeight + mass.height / 2,
        ),
      );
      c.endMassDrag(0);
      expect(c.model.chamber.stack, isNotEmpty);
      await backToHome(tester);
      await openUnderPressure(tester);
      final c2 = homeState(tester).controller;
      expect(c2.model.chamber.stack, isEmpty);
      expect(c2.model.currentScene, UnderPressureScene.square);
      await backToHome(tester);
    });

    testWidgets('Reset All after Home re-entry restores defaults',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      final c = homeState(tester).controller;
      c.setDensity(1400);
      c.setGravity(20);
      c.setAtmosphere(false);
      c.setRulerVisible(true);
      c.setGridVisible(true);
      c.setScene(UnderPressureScene.mystery);
      c.setMysteryFluidIndex(1);
      c.resetAll();
      expect(c.model.currentScene, UnderPressureScene.square);
      expect(c.model.fluidDensity, UnderPressureConstants.waterDensity);
      expect(c.model.gravity, UnderPressureConstants.earthGravity);
      expect(c.model.isAtmosphere, isTrue);
      expect(c.model.isRulerVisible, isFalse);
      expect(c.model.mystery.customFluidDensityIndex, 0);
      await backToHome(tester);
    });

    testWidgets('dispose stops clock — no double volume on re-entry',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openUnderPressure(tester);
      final c1 = homeState(tester).controller;
      c1.setInputFlow(1.0);
      // Advance via model (clock may also tick); record volume then leave
      c1.model.step(0.2);
      final vLeaving = c1.model.square.volume;
      expect(vLeaving > 1.5, isTrue);
      await backToHome(tester);
      await openUnderPressure(tester);
      final c2 = homeState(tester).controller;
      expect(c2.model.square.volume, closeTo(1.5, 1e-9));
      expect(identical(c1, c2), isFalse);
      await backToHome(tester);
    });
  });
}
