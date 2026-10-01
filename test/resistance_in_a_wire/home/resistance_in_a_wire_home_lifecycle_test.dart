import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_model.dart';
import 'package:kratos/resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';
import 'package:kratos/resistance_in_a_wire/view/riaw_play_area.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 5 — Home integration / lifecycle / sibling regression (H5-01 … H5-12).
///
/// Peer: `test/ohms_law/home/ohms_law_home_lifecycle_test.dart`
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

  Future<void> openRiaw(WidgetTester tester) async {
    final card = find.text(ResistanceInAWireScreen.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ResistanceInAWireScreen), findsOneWidget);
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
    expect(find.byType(ResistanceInAWireScreen), findsNothing);
  }

  ResistanceInAWireModel screenModel(WidgetTester tester) {
    final state = tester.state<ResistanceInAWireScreenState>(
      find.byType(ResistanceInAWireScreen),
    );
    return state.model;
  }

  void expectColdStart(ResistanceInAWireModel m) {
    expect(m.resistivity, 0.50);
    expect(m.length, 10.00);
    expect(m.area, 7.50);
    expect(m.resistance, closeTo(0.6666666666666666, 1e-9));
    expect(m.getFormattedResistanceValue(), '0.667');
  }

  group('H5 home entry', () {
    testWidgets('H5-01/02 card under 电学与电路 with title + subtitle',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('电学与电路'), findsOneWidget);
      expect(find.text(ResistanceInAWireScreen.title), findsOneWidget);
      expect(find.text(ResistanceInAWireScreen.subtitle), findsOneWidget);
      expect(find.byIcon(ResistanceInAWireScreen.homeIcon), findsWidgets);
    });

    testWidgets('H5-03 card opens ResistanceInAWireScreen (not demo/QA)',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(ResistanceInAWireScreen.title),
        ),
        findsOneWidget,
      );
      expect(find.byType(ResistanceInAWirePlayArea), findsOneWidget);
      expect(find.byKey(const Key('riaw_resistivity_slider')), findsOneWidget);
      expect(find.byKey(const Key('riaw_length_slider')), findsOneWidget);
      expect(find.byKey(const Key('riaw_area_slider')), findsOneWidget);
      expect(find.byKey(const Key('riaw_reset_all')), findsOneWidget);
      expectColdStart(screenModel(tester));
    });

    testWidgets('H5-06 exactly one Home card for 导线电阻', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text(ResistanceInAWireScreen.title), findsOneWidget);
      expect(find.text(ResistanceInAWireScreen.subtitle), findsOneWidget);
    });
  });

  group('H5 navigation / lifecycle', () {
    testWidgets('H5-04 Back returns Home and disposes screen', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);
      await backToHome(tester);
      expect(find.text(ResistanceInAWireScreen.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('H5-05/07-11 mutate → Back → reopen fresh cold start',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);

      final a = screenModel(tester);
      a.resistivity = 1.0;
      a.length = 15.0;
      a.area = 2.0;
      await tester.pump();
      expect(a.resistivity, 1.0);
      expect(a.length, 15.0);
      expect(a.area, 2.0);

      await backToHome(tester);
      await openRiaw(tester);

      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expectColdStart(b);
      await backToHome(tester);
    });

    testWidgets('H5-10 reopen ×3 independent fresh models', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      final models = <ResistanceInAWireModel>[];
      for (var i = 0; i < 3; i++) {
        await openRiaw(tester);
        final m = screenModel(tester);
        models.add(m);
        expectColdStart(m);
        m.resistivity = 0.2 + i * 0.1;
        await tester.pump();
        await backToHome(tester);
      }
      expect(identical(models[0], models[1]), isFalse);
      expect(identical(models[1], models[2]), isFalse);
    });

    testWidgets('H5-08 drag ρ then dispose — no orphan exception',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);

      await tester.drag(
        find.byKey(const Key('riaw_resistivity_slider')),
        const Offset(0, -40),
      );
      await tester.pump();
      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag L then immediately Back — safe dispose', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);
      await tester.drag(
        find.byKey(const Key('riaw_length_slider')),
        const Offset(0, 40),
      );
      await tester.pump();
      await backToHome(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag A then immediately Back — safe dispose', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);
      await tester.drag(
        find.byKey(const Key('riaw_area_slider')),
        const Offset(0, -30),
      );
      await tester.pump();
      await backToHome(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('H5-09 Reset after Home entry restores defaults',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);

      final model = screenModel(tester);
      model.resistivity = 1.0;
      model.length = 15.0;
      model.area = 2.0;
      await tester.pump();
      expect(model.resistivity, isNot(0.50));

      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expectColdStart(model);

      await backToHome(tester);
    });

    testWidgets('Reset ≠ Reopen: reset in-place; reopen creates new model',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);

      final a = screenModel(tester);
      a.resistivity = 0.8;
      a.length = 12.0;
      a.area = 5.0;
      await tester.pump();
      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expectColdStart(a);

      await backToHome(tester);
      await openRiaw(tester);
      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expectColdStart(b);
      await backToHome(tester);
    });
  });

  group('H5 sibling regression', () {
    testWidgets('H5-11/12 Ohm / Faraday / Molarity isolation', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      await openRiaw(tester);
      screenModel(tester).resistivity = 1.0;
      screenModel(tester).length = 18.0;
      await tester.pump();
      await backToHome(tester);

      final ohms = find.text(OhmsLawScreen.title);
      await tester.ensureVisible(ohms.first);
      await tester.tap(ohms.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(OhmsLawScreen), findsOneWidget);
      expect(find.byType(ResistanceInAWireScreen), findsNothing);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      final faraday = find.text(FaradaysLawScreen.title);
      await tester.ensureVisible(faraday.first);
      await tester.tap(faraday.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(FaradaysLawScreen), findsOneWidget);
      expect(find.byType(ResistanceInAWireScreen), findsNothing);

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
      expect(find.byType(ResistanceInAWireScreen), findsNothing);

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await openRiaw(tester);
      expectColdStart(screenModel(tester));
      await backToHome(tester);
    });

    testWidgets('H5-10 electricity category siblings listed once each',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      for (final title in [
        '电路搭建',
        'AC 虚拟实验室',
        OhmsLawScreen.title,
        ResistanceInAWireScreen.title,
        FaradaysLawScreen.title,
        '摩尔浓度',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });
  });

  group('isolation without Home', () {
    test('instances A/B independent — ρ/L/A do not leak', () {
      final a = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 15.0
        ..area = 2.0;
      final b = ResistanceInAWireModel();
      expect(b.resistivity, 0.50);
      expect(b.length, 10.00);
      expect(b.area, 7.50);
      expect(identical(a, b), isFalse);
      a.dispose();
      b.dispose();
    });
  });
}
