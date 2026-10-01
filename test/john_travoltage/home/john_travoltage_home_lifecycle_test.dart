import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/charges_and_fields/screens/charges_and_fields_home.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → 电学与电路 → John Travoltage lifecycle (peer: faradays_law_home_lifecycle).
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

  Future<void> openJohn(WidgetTester tester) async {
    final card = find.text(JohnTravoltageScreen.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(JohnTravoltageScreen), findsOneWidget);
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
    expect(find.byType(JohnTravoltageScreen), findsNothing);
  }

  JohnTravoltageModel screenModel(WidgetTester tester) {
    final state = tester.state<JohnTravoltageScreenState>(
      find.byType(JohnTravoltageScreen),
    );
    return state.model;
  }

  void expectInitial(JohnTravoltageModel m) {
    expect(m.electronCount, 0);
    expect(m.sparkVisible, isFalse);
    expect(m.arm.angle, JohnTravoltageConstants.armInitialAngle);
    expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
  }

  group('home entry', () {
    testWidgets('Home lists John under 电学与电路', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('电学与电路'), findsOneWidget);
      expect(find.text(JohnTravoltageScreen.title), findsOneWidget);
      expect(find.text(JohnTravoltageScreen.subtitle), findsOneWidget);
    });

    testWidgets('tap card opens JohnTravoltageScreen with AppBar',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openJohn(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(JohnTravoltageScreen.title),
        ),
        findsOneWidget,
      );
      expect(find.byType(JohnTravoltagePlayArea), findsOneWidget);
      expectInitial(screenModel(tester));
    });
  });

  group('navigation / lifecycle', () {
    testWidgets('Back returns Home and disposes screen', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openJohn(tester);
      await backToHome(tester);
      expect(find.text(JohnTravoltageScreen.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('mutate then Back then re-enter → fresh initial',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openJohn(tester);

      final a = screenModel(tester);
      a.createElectron();
      a.createElectron();
      a.setArmAngle(0.2);
      // Avoid carpet charge side-effect from leg motion
      await tester.pump();
      expect(a.electronCount, greaterThanOrEqualTo(2));
      expect(a.arm.angle, closeTo(0.2, 1e-9));

      await backToHome(tester);
      await openJohn(tester);

      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expectInitial(b);
      await backToHome(tester);
    });

    testWidgets('re-entry ×3 independent fresh models', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      final models = <JohnTravoltageModel>[];
      for (var i = 0; i < 3; i++) {
        await openJohn(tester);
        final m = screenModel(tester);
        models.add(m);
        expectInitial(m);
        m.createElectron();
        await tester.pump();
        await backToHome(tester);
      }
      expect(identical(models[0], models[1]), isFalse);
      expect(identical(models[1], models[2]), isFalse);
    });

    testWidgets('leave during charge — no orphan exception', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openJohn(tester);

      final m = screenModel(tester);
      for (var i = 0; i < 20; i++) {
        m.createElectron();
      }
      await tester.pump(const Duration(milliseconds: 100));
      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });

  group('home regression / sibling', () {
    testWidgets('John ↔ Charges and Fields no contamination', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      await openJohn(tester);
      screenModel(tester).createElectron();
      await tester.pump();
      await backToHome(tester);

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
      expect(find.byType(HomeScreen), findsOneWidget);

      await openJohn(tester);
      expectInitial(screenModel(tester));
      await backToHome(tester);
    });
  });
}
