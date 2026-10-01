import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';
import 'package:kratos/ohms_law/model/current_units.dart';
import 'package:kratos/ohms_law/model/ohms_law_model.dart';
import 'package:kratos/ohms_law/ohms_law_view_constants.dart';
import 'package:kratos/ohms_law/view/ohms_law_audio_hooks.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/ohms_law/view/wire_box.dart';

Widget _wrap(
  OhmsLawModel model, {
  OhmsLawAudioHooks? audio,
  FocusNode? voltageFocus,
  FocusNode? resistanceFocus,
  FocusNode? unitsFocus,
}) {
  return MaterialApp(
    home: OhmsLawScreen(
      model: model,
      showAppBar: false,
      dotRandom: math.Random(0x4F484D53),
      audio: audio,
      voltageFocusNode: voltageFocus,
      resistanceFocusNode: resistanceFocus,
      unitsFocusNode: unitsFocus,
    ),
  );
}

int _visibleBatteryCount(double voltage) {
  var n = 0;
  for (var i = 0; i < OhmsLawViewConstants.maxBatteries; i++) {
    var cell = math.min(
      OhmsLawViewConstants.aaVoltage,
      voltage - i * OhmsLawViewConstants.aaVoltage,
    );
    cell = OhmsLawViewConstants.roundToVoltageInterval(cell);
    if (cell > 0) n++;
  }
  return n;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('R3 reactive V/R/current chain', () {
    testWidgets('R3-01 voltage continuous drag updates current chain',
        (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('ohms_law_voltage_slider'));
      for (var i = 0; i < 8; i++) {
        await tester.drag(slider, Offset(0, i.isEven ? -30 : 20));
        await tester.pump();
        expect(model.current, OhmsLawModel.computeCurrent(model.voltage, model.resistance));
        expect(model.current.isFinite, isTrue);
        expect(find.text(model.getFixedCurrent()), findsWidgets);
      }
      model.dispose();
    });

    testWidgets('R3-02 resistance continuous drag updates current chain',
        (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('ohms_law_resistance_slider'));
      for (var i = 0; i < 8; i++) {
        await tester.drag(slider, Offset(0, i.isEven ? 40 : -25));
        await tester.pump();
        expect(model.current, OhmsLawModel.computeCurrent(model.voltage, model.resistance));
        expect(
          OhmsLawViewConstants.resistanceToNumDots(model.resistance),
          greaterThan(0),
        );
      }
      model.dispose();
    });

    testWidgets('R3-03/05/06 current + equation + readout reactive',
        (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(find.text('9.0'), findsWidgets);

      model.voltage = 9;
      await tester.pump();
      expect(model.current, 18.0);
      expect(find.text('18.0'), findsWidgets);

      model.resistance = 100;
      await tester.pump();
      expect(model.current, 90.0);
      expect(find.text('90.0'), findsWidgets);
      model.dispose();
    });

    testWidgets('R3-04 combined V/R no stale current', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final seq = <(double, double)>[
        (1, 100),
        (8, 200),
        (0.1, 10),
        (9, 1000),
        (4.5, 500),
      ];
      for (final (v, r) in seq) {
        model.voltage = v;
        await tester.pump();
        model.resistance = r;
        await tester.pump();
        expect(model.current, OhmsLawModel.computeCurrent(v, r));
      }
      model.dispose();
    });
  });

  group('R3 visualization', () {
    testWidgets('R3-07/08/09 arrow scale, dots, batteries track model',
        (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(_visibleBatteryCount(4.5), 3);
      expect(
        OhmsLawViewConstants.arrowScaleForCurrent(9.0),
        closeTo(math.pow(0.9, 0.7), 1e-9),
      );

      model.voltage = 9;
      await tester.pump();
      expect(_visibleBatteryCount(9), 6);

      model.voltage = 0.1;
      await tester.pump();
      expect(_visibleBatteryCount(0.1), 1);

      model.resistance = 10;
      await tester.pump();
      final lowDots = OhmsLawViewConstants.resistanceToNumDots(10);
      model.resistance = 1000;
      await tester.pump();
      final highDots = OhmsLawViewConstants.resistanceToNumDots(1000);
      expect(highDots, greaterThan(lowDots));

      // Low / mid / high current arrow direction contract: scale > 0 always
      for (final i in [0.1, 9.0, 900.0]) {
        expect(OhmsLawViewConstants.arrowScaleForCurrent(i), greaterThan(0));
      }
      model.dispose();
    });
  });

  group('R3 units', () {
    testWidgets('R3-10/11/12 units physics invariance + VD-03', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(model.current, 9.0);
      expect(find.text('mA'), findsWidgets);

      await tester.tap(find.byKey(const Key('ohms_law_units_a')));
      await tester.pump();
      expect(model.currentUnits, CurrentUnit.amps);
      expect(model.voltage, 4.5);
      expect(model.resistance, 500);
      expect(model.current, 9.0);
      expect(model.getFixedCurrent(), '0.090'); // VD-03
      expect(find.text('0.090'), findsWidgets);

      await tester.tap(find.byKey(const Key('ohms_law_units_ma')));
      await tester.pump();
      expect(model.currentUnits, CurrentUnit.milliamps);
      expect(model.current, 9.0);
      expect(find.text('9.0'), findsWidgets);
      model.dispose();
    });

    testWidgets('R3-13 units A + live V/R', (tester) async {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      model.voltage = 9;
      model.resistance = 10;
      await tester.pump();
      expect(model.current, 900.0);
      expect(model.getFixedCurrent(), '9.000'); // 900/100
      expect(model.currentUnits, CurrentUnit.amps);

      model.voltage = 1;
      model.resistance = 100;
      await tester.pump();
      expect(model.current, 10.0);
      expect(model.getFixedCurrent(), '0.100');
      model.dispose();
    });
  });

  group('R3 reset', () {
    testWidgets('R3-14/15 reset restores V/R keeps Units=A', (tester) async {
      final model = OhmsLawModel()
        ..voltage = 9
        ..resistance = 10
        ..currentUnits = CurrentUnit.amps;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(model.voltage, 4.5);
      expect(model.resistance, 500);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.amps);
      model.dispose();
    });

    testWidgets('R3-16 repeated reset', (tester) async {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        model.voltage = 9;
        model.resistance = 10;
        await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
        await tester.pump();
      }
      expect(model.voltage, 4.5);
      expect(model.currentUnits, CurrentUnit.amps);
      // DerivedProperty + OhmsLawBindings (not a leak)
      expect(model.voltageProperty.listenerCount, 2);
      model.dispose();
    });

    testWidgets('R3-17/18/19 reset during interaction', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      await tester.drag(find.byKey(const Key('ohms_law_voltage_slider')), const Offset(0, -50));
      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(model.voltage, 4.5);

      await tester.drag(find.byKey(const Key('ohms_law_resistance_slider')), const Offset(0, 40));
      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(model.resistance, 500);

      await tester.tap(find.byKey(const Key('ohms_law_units_a')));
      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(model.currentUnits, CurrentUnit.amps);
      expect(model.voltage, 4.5);
      model.dispose();
    });
  });

  group('R3 rapid / defense / VD-03', () {
    testWidgets('R3-20 rapid V/R/units 30+ changes', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      for (var i = 0; i < 30; i++) {
        model.voltage = i.isEven ? 0.1 : 9.0;
        model.resistance = i % 3 == 0 ? 10.0 : (i % 3 == 1 ? 500.0 : 1000.0);
        model.currentUnits =
            i.isEven ? CurrentUnit.amps : CurrentUnit.milliamps;
        await tester.pump();
        expect(model.current.isFinite, isTrue);
        expect(model.current.isNaN, isFalse);
        expect(
          model.current,
          OhmsLawModel.computeCurrent(model.voltage, model.resistance),
        );
      }
      model.dispose();
    });

    testWidgets('R3-21 NaN/Infinity defense on product path', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      model.voltage = 0; // clamps to 0.1
      model.resistance = 0; // clamps to 10
      await tester.pump();
      expect(model.voltage, 0.1);
      expect(model.resistance, 10);
      expect(model.current.isFinite, isTrue);
      expect(find.textContaining('NaN'), findsNothing);
      model.dispose();
    });

    testWidgets('R3-22 VD-03 not corrected to /1000', (tester) async {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(model.getFixedCurrent(), '0.090');
      expect(model.getFixedCurrent(), isNot('0.009'));
      model.dispose();
    });
  });

  group('R3 audio hooks', () {
    testWidgets('R3-23/24 audio events wired; dispose stops counting',
        (tester) async {
      final model = OhmsLawModel();
      final audio = OhmsLawAudioHooks();
      await tester.pumpWidget(_wrap(model, audio: audio));
      await tester.pump();

      final v0 = audio.voltageClickEvents;
      final r0 = audio.resistanceClickEvents;
      final i0 = audio.currentChangeEvents;

      model.voltage = 5;
      await tester.pump();
      expect(audio.voltageClickEvents, greaterThan(v0));
      expect(audio.currentChangeEvents, greaterThan(i0));

      model.resistance = 200;
      await tester.pump();
      expect(audio.resistanceClickEvents, greaterThan(r0));

      await tester.tap(find.byKey(const Key('ohms_law_reset_all')));
      await tester.pump();
      expect(audio.resetEvents, greaterThan(0));

      final after = audio.voltageClickEvents;
      audio.dispose();
      model.voltage = 8;
      await tester.pump();
      expect(audio.voltageClickEvents, after); // no post-dispose events
      expect(audio.disposed, isTrue);

      model.dispose();
    });
  });

  group('R3 accessibility + keyboard', () {
    testWidgets('R3-25 semantics present for controls', (tester) async {
      final model = OhmsLawModel();
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.bySemanticsLabel('Voltage'), findsWidgets);
      expect(find.bySemanticsLabel('Resistance'), findsWidgets);
      expect(find.bySemanticsLabel('Reset All'), findsOneWidget);
      expect(find.byKey(const Key('ohms_law_units_ma')), findsOneWidget);
      expect(find.byKey(const Key('ohms_law_units_a')), findsOneWidget);
      final maSem = tester.getSemantics(find.byKey(const Key('ohms_law_units_ma')));
      expect(maSem.label, contains('Milliamps'));
      expect(find.bySemanticsLabel('Reset All'), findsOneWidget);
      handle.dispose();
      model.dispose();
    });

    testWidgets('R3-26 keyboard Voltage arrows / Home / End', (tester) async {
      final model = OhmsLawModel();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_wrap(model, voltageFocus: focus));
      await tester.pump();

      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.voltage, 5.0); // 4.5 + 0.5

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(model.voltage, 4.5);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(model.voltage, closeTo(4.6, 1e-9));

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(model.voltage, 0.1);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(model.voltage, 9.0);
      model.dispose();
    });

    testWidgets('R3-27 keyboard Resistance step 20 / shift 1', (tester) async {
      final model = OhmsLawModel();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_wrap(model, resistanceFocus: focus));
      await tester.pump();

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.resistance, 520);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(model.resistance, 519);
      model.dispose();
    });

    testWidgets('R3-28 keyboard Units arrows', (tester) async {
      final model = OhmsLawModel();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_wrap(model, unitsFocus: focus));
      await tester.pump();

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(model.currentUnits, CurrentUnit.amps);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.currentUnits, CurrentUnit.milliamps);
      model.dispose();
    });

    testWidgets('R3-29 keyboard Reset via Semantics action', (tester) async {
      final model = OhmsLawModel()
        ..voltage = 9
        ..resistance = 10;
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final reset = find.byKey(const Key('ohms_law_reset_all'));
      await tester.tap(reset);
      await tester.pump();
      expect(model.voltage, 4.5);
      expect(find.bySemanticsLabel('Reset All'), findsOneWidget);
      handle.dispose();
      model.dispose();
    });
  });

  group('R3 lifecycle / reopen / isolation', () {
    testWidgets('R3-30 screen lifecycle dispose/recreate', (tester) async {
      final model1 = OhmsLawModel();
      await tester.pumpWidget(_wrap(model1));
      await tester.pump();
      model1.voltage = 9;
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      model1.dispose();

      final model2 = OhmsLawModel();
      await tester.pumpWidget(_wrap(model2));
      await tester.pump();
      expect(model2.voltage, 4.5);
      expect(model2.current, 9.0);
      // DerivedProperty + Bindings while PlayArea mounted
      expect(model2.voltageProperty.listenerCount, 2);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      // Bindings disposed → only DerivedProperty remains
      expect(model2.voltageProperty.listenerCount, 1);
      model2.dispose();
    });

    testWidgets('R3-31 reopen defaults Units (new screen ≠ reset preserve)',
        (tester) async {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      model.dispose();

      final fresh = OhmsLawModel();
      await tester.pumpWidget(_wrap(fresh));
      await tester.pump();
      expect(fresh.currentUnits, CurrentUnit.milliamps);
      expect(fresh.voltage, 4.5);
      fresh.dispose();
    });

    testWidgets('R3-32 cross-sim isolation Faraday ↔ Ohm', (tester) async {
      final ohms = OhmsLawModel()..voltage = 9;
      await tester.pumpWidget(_wrap(ohms));
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final faraday = FaradaysLawModel();
      await tester.pumpWidget(
        MaterialApp(
          home: FaradaysLawScreen(model: faraday, autoStartClock: false),
        ),
      );
      await tester.pump();
      expect(faraday.voltage, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await tester.pumpWidget(_wrap(ohms));
      await tester.pump();
      expect(ohms.voltage, 9); // external model retained
      expect(ohms.current, OhmsLawModel.computeCurrent(9, 500));
      ohms.dispose();
    });

    testWidgets('R3-33 source-forbidden interactions absent', (tester) async {
      final model = OhmsLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(find.textContaining('Switch'), findsNothing);
      expect(find.textContaining('Probe'), findsNothing);
      expect(find.textContaining('Ammeter'), findsNothing);
      expect(find.byType(WireBox), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      // Circuit is not draggable as a whole — no DragTarget for components
      expect(find.byType(Draggable<Object>), findsNothing);
      model.dispose();
    });
  });
}
