import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';
import 'package:kratos/hookes_law/screens/hookes_law_home.dart';
import 'package:kratos/ohms_law/model/current_units.dart';
import 'package:kratos/ohms_law/model/ohms_law_model.dart';
import 'package:kratos/ohms_law/view/ohms_law_play_area.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 5 — Home integration / lifecycle / sibling regression (H5-01 … H5-12).
///
/// Peer: `test/faradays_law/home/faradays_law_home_lifecycle_test.dart`
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

  Future<void> openOhmsLaw(WidgetTester tester) async {
    final card = find.text(OhmsLawScreen.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OhmsLawScreen), findsOneWidget);
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
    expect(find.byType(OhmsLawScreen), findsNothing);
  }

  OhmsLawModel screenModel(WidgetTester tester) {
    final state = tester.state<OhmsLawScreenState>(
      find.byType(OhmsLawScreen),
    );
    return state.model;
  }

  void expectColdStart(OhmsLawModel m) {
    expect(m.voltage, 4.5);
    expect(m.resistance, 500.0);
    expect(m.current, closeTo(9.0, 1e-9));
    expect(m.currentUnits, CurrentUnit.milliamps);
  }

  group('H5 home entry', () {
    // H5-01 / H5-02
    testWidgets('H5-01/02 card under 电学与电路 with title + subtitle',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('电学与电路'), findsOneWidget);
      expect(find.text(OhmsLawScreen.title), findsOneWidget);
      expect(find.text(OhmsLawScreen.subtitle), findsOneWidget);
      expect(find.byIcon(OhmsLawScreen.homeIcon), findsWidgets);
    });

    // H5-03
    testWidgets('H5-03 card opens OhmsLawScreen (not demo/QA)', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(OhmsLawScreen.title),
        ),
        findsOneWidget,
      );
      expect(find.byType(OhmsLawPlayArea), findsOneWidget);
      expect(find.byKey(const Key('ohms_law_voltage_slider')), findsOneWidget);
      expect(find.byKey(const Key('ohms_law_resistance_slider')), findsOneWidget);
      expect(find.byKey(const Key('ohms_law_reset_all')), findsOneWidget);
      expectColdStart(screenModel(tester));
    });

    // H5-06 duplicate entry
    testWidgets('H5-06 exactly one Home card for Ohm\'s Law', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text(OhmsLawScreen.title), findsOneWidget);
      expect(find.text(OhmsLawScreen.subtitle), findsOneWidget);
    });
  });

  group('H5 navigation / lifecycle', () {
    // H5-04
    testWidgets('H5-04 Back returns Home and disposes screen', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);
      await backToHome(tester);
      expect(find.text(OhmsLawScreen.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    // H5-05 / H5-07..H5-12 reopen + fresh
    testWidgets('H5-05/07-11 mutate → Back → reopen fresh cold start',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);

      final a = screenModel(tester);
      a.voltage = 9.0;
      a.resistance = 10.0;
      a.currentUnits = CurrentUnit.amps;
      await tester.pump();
      expect(a.voltage, 9.0);
      expect(a.currentUnits, CurrentUnit.amps);

      await backToHome(tester);
      await openOhmsLaw(tester);

      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expectColdStart(b);
      await backToHome(tester);
    });

    testWidgets('H5-06/10 reopen ×3 independent fresh models', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      final models = <OhmsLawModel>[];
      for (var i = 0; i < 3; i++) {
        await openOhmsLaw(tester);
        final m = screenModel(tester);
        models.add(m);
        expectColdStart(m);
        m.voltage = 1.0 + i;
        m.currentUnits = CurrentUnit.amps;
        await tester.pump();
        await backToHome(tester);
      }
      expect(identical(models[0], models[1]), isFalse);
      expect(identical(models[1], models[2]), isFalse);
    });

    testWidgets('H5-08 interact then dispose — no orphan exception',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);

      await tester.drag(
        find.byKey(const Key('ohms_law_voltage_slider')),
        const Offset(0, -40),
      );
      await tester.pump();
      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag Resistance then immediately Back — safe dispose',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);
      await tester.drag(
        find.byKey(const Key('ohms_law_resistance_slider')),
        const Offset(0, 40),
      );
      await tester.pump();
      await backToHome(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('toggle Units then immediately Back — safe dispose',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);
      await tester.tap(find.byKey(const Key('ohms_law_units_a')));
      await tester.pump();
      expect(screenModel(tester).currentUnits, CurrentUnit.amps);
      await backToHome(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Reset preserves Units=A after Home entry', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);

      final model = screenModel(tester);
      model.voltage = 9.0;
      model.resistance = 100.0;
      await tester.tap(find.byKey(const Key('ohms_law_units_a')));
      await tester.pump();
      expect(model.currentUnits, CurrentUnit.amps);

      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, closeTo(9.0, 1e-9));
      expect(model.currentUnits, CurrentUnit.amps);

      await backToHome(tester);
    });

    testWidgets('Reset ≠ Reopen: Units=A reset stays A; reopen → mA',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);

      final a = screenModel(tester);
      a.voltage = 2.0;
      await tester.tap(find.byKey(const Key('ohms_law_units_a')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(a.voltage, 4.5);
      expect(a.currentUnits, CurrentUnit.amps);

      await backToHome(tester);
      await openOhmsLaw(tester);
      expectColdStart(screenModel(tester));
      await backToHome(tester);
    });
  });

  group('H5 sibling regression', () {
    // H5-12
    testWidgets('H5-12 Faraday / Hooke / Molarity isolation', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      await openOhmsLaw(tester);
      screenModel(tester).currentUnits = CurrentUnit.amps;
      screenModel(tester).voltage = 8.0;
      await tester.pump();
      await backToHome(tester);

      final faraday = find.text(FaradaysLawScreen.title);
      await tester.ensureVisible(faraday.first);
      await tester.tap(faraday.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(FaradaysLawScreen), findsOneWidget);
      expect(find.byType(OhmsLawScreen), findsNothing);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      final hooke = find.text(HookesLawHome.title);
      await tester.ensureVisible(hooke.first);
      await tester.tap(hooke.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(HookesLawHome), findsOneWidget);
      expect(find.byType(OhmsLawScreen), findsNothing);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final molarity = find.text('摩尔浓度');
      await tester.ensureVisible(molarity.first);
      await tester.tap(molarity.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MolarityScreen), findsOneWidget);
      expect(find.byType(OhmsLawScreen), findsNothing);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await openOhmsLaw(tester);
      expectColdStart(screenModel(tester));
      await backToHome(tester);
    });

    testWidgets('electricity category siblings still listed once each',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      for (final title in [
        '电路搭建',
        'AC 虚拟实验室',
        OhmsLawScreen.title,
        FaradaysLawScreen.title,
        HookesLawHome.title,
        '摩尔浓度',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });
  });

  group('isolation without Home', () {
    test('instances A/B independent — Units does not leak', () {
      final a = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      a.voltage = 9.0;
      final b = OhmsLawModel();
      expect(b.currentUnits, CurrentUnit.milliamps);
      expect(b.voltage, 4.5);
      expect(identical(a, b), isFalse);
    });
  });
}
