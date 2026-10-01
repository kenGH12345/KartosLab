import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_screen.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_view.dart';
import 'package:kratos/charges_and_fields/screens/charges_and_fields_home.dart';
import 'package:kratos/friction/view/friction_screen.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 5 — Home integration / lifecycle / sibling regression (H5-01 … H5-08).
///
/// Peer pattern: `test/john_travoltage/home/john_travoltage_home_lifecycle_test.dart`
void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openBalloons(WidgetTester tester) async {
    final card = find.text(BalloonsStaticElectricityScreen.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BalloonsStaticElectricityScreen), findsOneWidget);
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
    expect(find.byType(BalloonsStaticElectricityScreen), findsNothing);
  }

  BalloonsStaticElectricityModel screenModel(WidgetTester tester) {
    final state = tester.state<BalloonsStaticElectricityScreenState>(
      find.byType(BalloonsStaticElectricityScreen),
    );
    return state.model;
  }

  void expectInitial(BalloonsStaticElectricityModel m) {
    expect(m.yellowBalloon.charge, 0);
    expect(m.greenBalloon.charge, 0);
    expect(m.sweater.charge, 0);
    expect(m.greenBalloon.isVisible, isFalse);
    expect(m.wall.isVisible, isTrue);
    expect(m.showCharges, ShowCharges.allCharges);
    expect(
      m.yellowBalloon.position,
      BaseConstants.yellowInitialPosition,
    );
  }

  group('H5 home entry', () {
    testWidgets('H5-01 / H5-02 card exists under 电学与电路', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('电学与电路'), findsOneWidget);
      expect(find.text(BalloonsStaticElectricityScreen.title), findsOneWidget);
      expect(
        find.text(BalloonsStaticElectricityScreen.subtitle),
        findsOneWidget,
      );
      expect(
        find.byIcon(BalloonsStaticElectricityScreen.homeIcon),
        findsWidgets,
      );
      // Sibling cards still present in same category.
      expect(find.text(JohnTravoltageScreen.title), findsOneWidget);
      expect(find.text(ChargesAndFieldsHome.title), findsOneWidget);
    });

    testWidgets('H5-03 card opens BalloonsStaticElectricityScreen',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openBalloons(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(BalloonsStaticElectricityScreen.title),
        ),
        findsOneWidget,
      );
      expect(find.byType(BalloonsStaticElectricityPlayArea), findsOneWidget);
      expectInitial(screenModel(tester));
      // Must not open sibling sims.
      expect(find.byType(JohnTravoltageScreen), findsNothing);
      expect(find.byType(ChargesAndFieldsHome), findsNothing);
    });
  });

  group('H5 navigation / lifecycle', () {
    testWidgets('H5-04 Back returns Home and disposes screen', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openBalloons(tester);
      await backToHome(tester);
      expect(find.text(BalloonsStaticElectricityScreen.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('H5-05 / H5-07 mutate then Back then re-enter → fresh',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openBalloons(tester);

      final a = screenModel(tester);
      a.yellowBalloon.charge = -12;
      a.setTwoBalloons(true);
      a.setShowCharges(ShowCharges.chargeDifferences);
      a.removeWall();
      await tester.pump();
      expect(a.yellowBalloon.charge, -12);
      expect(a.greenBalloon.isVisible, isTrue);
      expect(a.wall.isVisible, isFalse);

      await backToHome(tester);
      await openBalloons(tester);

      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expectInitial(b);
      await backToHome(tester);
    });

    testWidgets('H5-06 reopen ×3 independent fresh models', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      final models = <BalloonsStaticElectricityModel>[];
      for (var i = 0; i < 3; i++) {
        await openBalloons(tester);
        final m = screenModel(tester);
        models.add(m);
        expectInitial(m);
        m.yellowBalloon.charge = -5 - i;
        await tester.pump();
        await backToHome(tester);
      }
      expect(identical(models[0], models[1]), isFalse);
      expect(identical(models[1], models[2]), isFalse);
    });

    testWidgets('leave while charged — no orphan exception', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openBalloons(tester);

      final m = screenModel(tester);
      m.yellowBalloon.charge = -30;
      m.yellowBalloon.setPosition(const BaseVec2(520, 100));
      await tester.pump(const Duration(milliseconds: 100));
      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });

  group('H5 sibling regression', () {
    testWidgets('H5-08 Balloons ↔ JT ↔ CAF no contamination', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      await openBalloons(tester);
      screenModel(tester).yellowBalloon.charge = -9;
      await tester.pump();
      await backToHome(tester);

      final jt = find.text(JohnTravoltageScreen.title);
      await tester.ensureVisible(jt.first);
      await tester.tap(jt.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(JohnTravoltageScreen), findsOneWidget);
      expect(find.byType(BalloonsStaticElectricityScreen), findsNothing);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      final caf = find.text(ChargesAndFieldsHome.title);
      await tester.ensureVisible(caf.first);
      await tester.tap(caf.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ChargesAndFieldsHome), findsOneWidget);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Friction (力与运动) still listed — category not corrupted.
      expect(find.text(FrictionScreen.title), findsOneWidget);

      await openBalloons(tester);
      expectInitial(screenModel(tester));
      await backToHome(tester);
    });

    testWidgets('electricity category siblings still listed', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      for (final title in [
        '电路搭建',
        'AC 虚拟实验室',
        ChargesAndFieldsHome.title,
        JohnTravoltageScreen.title,
        BalloonsStaticElectricityScreen.title,
      ]) {
        expect(find.text(title), findsOneWidget);
      }
    });
  });
}
