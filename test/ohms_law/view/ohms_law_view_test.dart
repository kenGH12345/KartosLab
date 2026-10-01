import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/ohms_law/model/current_units.dart';
import 'package:kratos/ohms_law/model/ohms_law_model.dart';
import 'package:kratos/ohms_law/ohms_law_view_constants.dart';
import 'package:kratos/ohms_law/view/controls/control_panel.dart';
import 'package:kratos/ohms_law/view/controls/units_radio.dart';
import 'package:kratos/ohms_law/view/formula_equation.dart';
import 'package:kratos/ohms_law/view/ohms_law_play_area.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/ohms_law/view/wire_box.dart';

Widget _wrap(OhmsLawModel model) {
  return MaterialApp(
    home: OhmsLawScreen(
      model: model,
      showAppBar: false,
      dotRandom: math.Random(0x4F484D53),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V2 canvas / background / structure', () {
    testWidgets('V2-01/02 canvas and background color', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.byType(OhmsLawPlayArea), findsOneWidget);
      final colored = tester.widgetList<ColoredBox>(find.byType(ColoredBox));
      expect(
        colored.any((c) => c.color == OhmsLawViewConstants.background),
        isTrue,
      );
      model.dispose();
    });

    testWidgets('V2-03..12 core nodes present', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.byType(FormulaEquation), findsOneWidget);
      expect(find.byType(WireBox), findsOneWidget);
      expect(find.byType(OhmsLawControlPanel), findsOneWidget);
      expect(find.byType(UnitsRadioGroup), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('voltage'), findsOneWidget);
      expect(find.text('resistance'), findsOneWidget);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Milliamps (mA)'), findsOneWidget);
      expect(find.text('Amps (A)'), findsOneWidget);
      expect(find.textContaining('current'), findsWidgets);
      expect(find.text('9.0'), findsWidgets);
      expect(find.text('mA'), findsWidgets);
      model.dispose();
    });

    testWidgets('V2-13 initial state defaults', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.milliamps);
      expect(find.text('4.5'), findsWidgets);
      expect(find.text('500'), findsWidgets);
      model.dispose();
    });
  });

  group('V2 voltage / resistance / current states', () {
    testWidgets('V2-14 voltage slider drag updates model and readout',
        (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('ohms_law_voltage_slider'));
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(0, -80));
      await tester.pump();

      expect(model.voltage, greaterThan(4.5));
      expect(model.current, greaterThan(9.0));
      model.dispose();
    });

    testWidgets('V2-15 resistance slider drag updates model', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('ohms_law_resistance_slider'));
      await tester.drag(slider, const Offset(0, 60));
      await tester.pump();

      expect(model.resistance, lessThan(500));
      expect(model.current, greaterThan(9.0));
      model.dispose();
    });

    testWidgets('V2-16 high current state (V max R min)', (tester) async {
      final model = OhmsLawModel()
        ..voltage = 9
        ..resistance = 10;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(model.current, 900.0);
      expect(find.text('900.0'), findsWidgets);
      model.dispose();
    });
  });

  group('V2 units + reset', () {
    testWidgets('V2-11/17 units radio switches display only', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.text('mA'), findsWidgets);
      await tester.tap(find.byKey(const Key('ohms_law_units_a')));
      await tester.pump();

      expect(model.currentUnits, CurrentUnit.amps);
      expect(model.current, 9.0); // physics unchanged
      expect(find.text('0.090'), findsWidgets); // VD-03
      expect(find.text('A'), findsWidgets);
      model.dispose();
    });

    testWidgets('V2-12/18 reset restores V/R, preserves units', (tester) async {
      final model = OhmsLawModel()
        ..voltage = 9
        ..resistance = 10
        ..currentUnits = CurrentUnit.amps;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();

      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.amps);
      expect(find.text('0.090'), findsWidgets);
      model.dispose();
    });
  });

  group('V2 visual state matrix', () {
    testWidgets('V01–V14 state smoke (no crash)', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final states = <void Function()>[
        () {}, // V01 initial
        () => model.voltage = 0.1, // V02
        () => model.voltage = 4.5, // V03
        () => model.voltage = 9.0, // V04
        () => model.resistance = 10, // V05
        () => model.resistance = 500, // V06
        () => model.resistance = 1000, // V07
        () {
          model.voltage = 0.1;
          model.resistance = 1000;
        }, // V08 low I
        () {
          model.voltage = 9;
          model.resistance = 10;
        }, // V09 high I
        () {
          model.voltage = 2;
          model.resistance = 200;
        }, // V10
        () => model.currentUnits = CurrentUnit.milliamps, // V11
        () => model.currentUnits = CurrentUnit.amps, // V12
        () => model.reset(), // V13
        () {
          model.currentUnits = CurrentUnit.amps;
          model.voltage = 9;
          model.reset();
        }, // V14
      ];

      for (final apply in states) {
        apply();
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(model.current.isFinite, isTrue);
      }
      model.dispose();
    });
  });

  group('V2 golden / layout', () {
    testWidgets('V2-19/20 layout size and layering widgets', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1024,
            height: 768,
            child: OhmsLawScreen(
              model: model,
              showAppBar: false,
              dotRandom: math.Random(0x4F484D53),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(OhmsLawViewConstants.layoutSize, const Size(1024, 618));
      expect(find.byType(FormulaEquation), findsOneWidget);
      expect(find.byType(WireBox), findsOneWidget);
      // Formula before circuit in tree — both present
      expect(find.byType(OhmsLawControlPanel), findsOneWidget);
      model.dispose();
    });

    testWidgets('Units does not overlap ControlPanel readouts', (tester) async {
      final model = OhmsLawModel();
      await tester.binding.setSurfaceSize(const Size(1024, 618));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: OhmsLawScreen(
            model: model,
            showAppBar: false,
            dotRandom: math.Random(0x4F484D53),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50)); // measure chrome

      final panel = tester.getRect(find.byType(OhmsLawControlPanel));
      final units = tester.getRect(find.byType(UnitsRadioGroup));
      final formula = tester.getRect(find.byType(FormulaEquation));
      final wire = tester.getRect(find.byType(WireBox));

      // Source: units.left ≈ controlPanel.left
      expect(units.left, closeTo(panel.left, 4));
      // Units below panel (no readout collide).
      expect(units.top, greaterThanOrEqualTo(panel.bottom - 1));
      // Panel docked on the right — must not swallow formula / wire centers.
      expect(panel.left, greaterThan(formula.center.dx));
      expect(panel.left, greaterThan(wire.center.dx));
      // Right inset ≈ 50 in layout coords (surface = layout size, scale 1).
      expect(
        OhmsLawViewConstants.layoutWidth - panel.right,
        closeTo(50, 2),
      );
      model.dispose();
    });

    testWidgets('golden initial frame (pixel)', (tester) async {
      final model = OhmsLawModel();
      await tester.binding.setSurfaceSize(const Size(1024, 618));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: OhmsLawScreen(
            model: model,
            showAppBar: false,
            dotRandom: math.Random(0x4F484D53),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OhmsLawPlayArea),
        matchesGoldenFile('goldens/ohms_law_initial.png'),
      );
      model.dispose();
    });
  });
}
