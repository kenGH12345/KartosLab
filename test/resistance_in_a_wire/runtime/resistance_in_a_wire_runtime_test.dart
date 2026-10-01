import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/ohms_law/model/ohms_law_model.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_model.dart';
import 'package:kratos/resistance_in_a_wire/resistance_in_a_wire_view_constants.dart';
import 'package:kratos/resistance_in_a_wire/view/formula_equation.dart';
import 'package:kratos/resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';
import 'package:kratos/resistance_in_a_wire/view/riaw_audio_hooks.dart';
import 'package:kratos/resistance_in_a_wire/view/riaw_play_area.dart';
import 'package:kratos/resistance_in_a_wire/view/static_arrow.dart';
import 'package:kratos/resistance_in_a_wire/view/wire_node.dart';

const int _kDotSeed = 0x52494157;

Widget _wrap(
  ResistanceInAWireModel model, {
  ResistanceInAWireAudioHooks? audio,
  FocusNode? rhoFocus,
  FocusNode? lengthFocus,
  FocusNode? areaFocus,
  math.Random? dotRandom,
}) {
  return MaterialApp(
    home: ResistanceInAWireScreen(
      model: model,
      showAppBar: false,
      dotRandom: dotRandom ?? math.Random(_kDotSeed),
      audio: audio,
      resistivityFocusNode: rhoFocus,
      lengthFocusNode: lengthFocus,
      areaFocusNode: areaFocus,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('R3 reactive ρ/L/A chains', () {
    testWidgets('R3-01 resistivity continuous drag', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('riaw_resistivity_slider'));
      var lastDots =
          ResistanceInAWireViewConstants.resistivityToNumDots(model.resistivity);
      for (var i = 0; i < 8; i++) {
        await tester.drag(slider, Offset(0, i.isEven ? -35 : 25));
        await tester.pump();
        expect(
          model.resistance,
          ResistanceInAWireModel.computeResistance(
            model.resistivity,
            model.length,
            model.area,
          ),
        );
        expect(find.textContaining(model.getFormattedResistanceValue()),
            findsOneWidget);
        final dots = ResistanceInAWireViewConstants.resistivityToNumDots(
          model.resistivity,
        );
        if (model.resistivity > 0.5) {
          expect(dots, greaterThanOrEqualTo(lastDots));
        }
        lastDots = dots;
      }
      model.dispose();
    });

    testWidgets('R3-02 length continuous drag', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('riaw_length_slider'));
      final w0 = ResistanceInAWireViewConstants.lengthToWidth(model.length);
      for (var i = 0; i < 8; i++) {
        await tester.drag(slider, Offset(0, i.isEven ? -30 : 20));
        await tester.pump();
        expect(
          model.resistance,
          ResistanceInAWireModel.computeResistance(
            model.resistivity,
            model.length,
            model.area,
          ),
        );
        final w = ResistanceInAWireViewConstants.lengthToWidth(model.length);
        expect(w, greaterThan(0));
        if (model.length > 10) expect(w, greaterThan(w0));
      }
      model.dispose();
    });

    testWidgets('R3-03 area continuous drag', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final slider = find.byKey(const Key('riaw_area_slider'));
      final h0 = ResistanceInAWireViewConstants.areaToHeight(model.area);
      for (var i = 0; i < 8; i++) {
        await tester.drag(slider, Offset(0, i.isEven ? 30 : -20));
        await tester.pump();
        expect(
          model.resistance,
          ResistanceInAWireModel.computeResistance(
            model.resistivity,
            model.length,
            model.area,
          ),
        );
        final h = ResistanceInAWireViewConstants.areaToHeight(model.area);
        expect(h, greaterThan(0));
        if (model.area < 7.5) expect(h, lessThan(h0));
      }
      model.dispose();
    });

    testWidgets('R3-04/05/06 resistance + formula + readout reactive',
        (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(find.textContaining('0.667'), findsOneWidget);
      expect(find.byType(FormulaEquation), findsOneWidget);

      model.resistivity = 1.0;
      await tester.pump();
      expect(model.resistance, closeTo(10.0 / 7.5, 1e-12));
      expect(find.textContaining(model.getFormattedResistanceValue()),
          findsOneWidget);

      model.length = 20;
      await tester.pump();
      expect(
        model.resistance,
        ResistanceInAWireModel.computeResistance(1.0, 20, 7.5),
      );

      model.area = 15;
      await tester.pump();
      expect(model.getFormattedResistanceValue(), '1.33');
      expect(find.textContaining('1.33'), findsOneWidget);
      model.dispose();
    });

    testWidgets('R3-07/08/09 impurity + wire L/A mappings', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final lowDots =
          ResistanceInAWireViewConstants.resistivityToNumDots(0.01);
      final highDots =
          ResistanceInAWireViewConstants.resistivityToNumDots(1.0);
      expect(highDots, greaterThan(lowDots));

      expect(ResistanceInAWireViewConstants.lengthToWidth(0.1), 15);
      expect(ResistanceInAWireViewConstants.lengthToWidth(20), 500);
      expect(
        ResistanceInAWireViewConstants.areaToHeight(15),
        closeTo(180, 1e-9),
      );

      model.resistivity = 0.01;
      await tester.pump();
      model.resistivity = 1.0;
      await tester.pump();
      expect(find.byType(WireNode), findsOneWidget);
      model.dispose();
    });

    testWidgets('R3-10/11 combined ρ/L/A no stale R', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final seq = <(double, double, double)>[
        (0.01, 0.1, 15),
        (1.0, 20, 0.01),
        (0.5, 10, 7.5),
        (0.8, 5, 2),
        (0.25, 15, 10),
      ];
      for (final (rho, l, a) in seq) {
        model.resistivity = rho;
        await tester.pump();
        model.length = l;
        await tester.pump();
        model.area = a;
        await tester.pump();
        expect(
          model.resistance,
          ResistanceInAWireModel.computeResistance(rho, l, a),
        );
        expect(
          find.textContaining('resistance = ${model.getFormattedResistanceValue()}'),
          findsOneWidget,
        );
      }
      model.dispose();
    });
  });

  group('R3 precision / bounds / finite', () {
    testWidgets('R3-12 dynamic resistance precision matrix', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      // R < 1 → 3 decimals
      expect(model.getFormattedResistanceValue(), '0.667');

      // 1 ≤ R < 10 → 2 decimals
      model
        ..resistivity = 1.0
        ..length = 20
        ..area = 15;
      await tester.pump();
      expect(model.getFormattedResistanceValue(), '1.33');
      expect(find.textContaining('1.333'), findsNothing);

      // 10 ≤ R < 100 → 1 decimal
      model
        ..resistivity = 1.0
        ..length = 20
        ..area = 1.0;
      await tester.pump();
      expect(model.resistance, 20.0);
      expect(model.getFormattedResistanceValue(), '20.0');

      // R ≥ 100 → 0 decimals
      model.area = 0.1;
      await tester.pump();
      expect(model.resistance, 200.0);
      expect(model.getFormattedResistanceValue(), '200');

      // R < 0.001 → 4 decimals
      model
        ..resistivity = 0.01
        ..length = 0.1
        ..area = 15;
      await tester.pump();
      expect(model.getFormattedResistanceValue(), '0.0001');
      model.dispose();
    });

    testWidgets('R3-13 slider bounds clamp', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      model.resistivity = -1;
      model.length = 999;
      model.area = 0;
      await tester.pump();
      expect(model.resistivity, 0.01);
      expect(model.length, 20.0);
      expect(model.area, 0.01);
      model.dispose();
    });

    testWidgets('R3-14 finite / NaN / Infinity defense', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      for (final rho in [0.01, 0.5, 1.0]) {
        for (final l in [0.1, 10.0, 20.0]) {
          for (final a in [0.01, 7.5, 15.0]) {
            model
              ..resistivity = rho
              ..length = l
              ..area = a;
            await tester.pump();
            expect(model.resistance.isFinite, isTrue);
            expect(model.resistance.isNaN, isFalse);
            expect(find.textContaining('NaN'), findsNothing);
          }
        }
      }
      model.dispose();
    });
  });

  group('R3 reset', () {
    testWidgets('R3-15 reset to defaults', (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1
        ..length = 20
        ..area = 0.01;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      expect(model.getFormattedResistanceValue(), '0.667');
      expect(find.textContaining('0.667'), findsOneWidget);
      model.dispose();
    });

    testWidgets('R3-16 repeated reset', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        model
          ..resistivity = 1
          ..length = 20
          ..area = 0.01;
        await tester.tap(find.byKey(const Key('riaw_reset_all')));
        await tester.pump();
      }
      expect(model.resistivity, 0.5);
      // DerivedProperty + Bindings while mounted
      expect(model.resistivityProperty.listenerCount, 2);
      model.dispose();
    });

    testWidgets('R3-17/18/19 reset during ρ/L/A interaction', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      await tester.drag(
        find.byKey(const Key('riaw_resistivity_slider')),
        const Offset(0, -50),
      );
      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expect(model.resistivity, 0.5);

      await tester.drag(
        find.byKey(const Key('riaw_length_slider')),
        const Offset(0, -40),
      );
      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expect(model.length, 10.0);

      await tester.drag(
        find.byKey(const Key('riaw_area_slider')),
        const Offset(0, 40),
      );
      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expect(model.area, 7.5);
      expect(model.getFormattedResistanceValue(), '0.667');
      model.dispose();
    });
  });

  group('R3 rapid / randomness', () {
    testWidgets('R3-20 rapid 30+ combined changes', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      for (var i = 0; i < 30; i++) {
        model.resistivity = i.isEven ? 0.01 : 1.0;
        model.length = i % 3 == 0 ? 0.1 : (i % 3 == 1 ? 10.0 : 20.0);
        model.area = i % 3 == 0 ? 15.0 : (i % 3 == 1 ? 7.5 : 0.01);
        await tester.pump();
        expect(model.resistance.isFinite, isTrue);
        expect(
          model.resistance,
          ResistanceInAWireModel.computeResistance(
            model.resistivity,
            model.length,
            model.area,
          ),
        );
      }
      model.dispose();
    });

    test('R3-21 deterministic golden random boundary', () {
      final a = WireNode.buildDotCenters(math.Random(_kDotSeed));
      final b = WireNode.buildDotCenters(math.Random(_kDotSeed));
      expect(a, b);
      // Production path uses undeterministic Random when null — contract only.
      expect(WireNode.buildDotCenters(math.Random(1)), isNot(a));
    });
  });

  group('R3 audio hooks', () {
    testWidgets('R3-22/23 audio bin contract + lifecycle', (tester) async {
      final model = ResistanceInAWireModel();
      final audio = ResistanceInAWireAudioHooks();
      await tester.pumpWidget(_wrap(model, audio: audio));
      await tester.pump();

      final r0 = audio.resistivitySoundEvents;
      // Tiny change within same bin may not fire (source ParameterMonitor).
      model.resistivity = 0.51;
      await tester.pump();
      // Large jump to max → must fire (bin change and/or max).
      model.resistivity = 1.0;
      await tester.pump();
      expect(audio.resistivitySoundEvents, greaterThan(r0));
      expect(audio.lastPlaybackRate, greaterThan(0));

      final l0 = audio.lengthSoundEvents;
      model.length = 20;
      await tester.pump();
      expect(audio.lengthSoundEvents, greaterThan(l0));

      final a0 = audio.areaSoundEvents;
      model.area = 0.01;
      await tester.pump();
      expect(audio.areaSoundEvents, greaterThan(a0));

      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expect(audio.resetEvents, greaterThan(0));

      final after = audio.resistivitySoundEvents;
      audio.dispose();
      model.resistivity = 0.2;
      await tester.pump();
      expect(audio.resistivitySoundEvents, after);
      expect(audio.disposed, isTrue);
      model.dispose();
    });

    test('R3-22 playback rate formula matches source', () {
      final mid = ResistanceInAWireAudioHooks.playbackRateForResistance(
        2.0 / 3.0,
      );
      final high =
          ResistanceInAWireAudioHooks.playbackRateForResistance(2000);
      final low = ResistanceInAWireAudioHooks.playbackRateForResistance(
        ResistanceInAWireModel.getMinResistance(),
      );
      expect(low, greaterThan(high)); // higher R → lower pitch
      expect(mid, greaterThan(0));
    });
  });

  group('R3 accessibility + keyboard', () {
    testWidgets('R3-24 semantics present', (tester) async {
      final model = ResistanceInAWireModel();
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.bySemanticsLabel('rho, Resistivity'), findsWidgets);
      expect(find.bySemanticsLabel('L, Length'), findsWidgets);
      expect(find.bySemanticsLabel('A, Area'), findsWidgets);
      expect(find.bySemanticsLabel('Reset All'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Resistance Equation')), findsWidgets);
      expect(find.bySemanticsLabel('The Wire'), findsWidgets);
      handle.dispose();
      model.dispose();
    });

    testWidgets('R3-25 keyboard ρ step 0.05 / Home / End', (tester) async {
      final model = ResistanceInAWireModel();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_wrap(model, rhoFocus: focus));
      await tester.pump();
      focus.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.resistivity, closeTo(0.55, 1e-9));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(model.resistivity, closeTo(0.54, 1e-9));

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(model.resistivity, 0.01);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(model.resistivity, 1.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(model.resistivity, 1.0); // already max
      model.dispose();
    });

    testWidgets('R3-26 keyboard L step 1', (tester) async {
      final model = ResistanceInAWireModel();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_wrap(model, lengthFocus: focus));
      await tester.pump();
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.length, 11.0);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();
      expect(model.length, closeTo(1.0, 1e-9)); // 11 - 10
      model.dispose();
    });

    testWidgets('R3-27 keyboard A step 1', (tester) async {
      final model = ResistanceInAWireModel();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_wrap(model, areaFocus: focus));
      await tester.pump();
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(model.area, 6.5);
      model.dispose();
    });

    testWidgets('R3-28 keyboard Reset via tap + Semantics (Enter not forced)',
        (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1
        ..length = 20
        ..area = 0.01;
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();
      expect(model.resistivity, 0.5);
      expect(find.bySemanticsLabel('Reset All'), findsOneWidget);
      final btn = tester.widget<KratosResetAllButton>(
        find.byKey(const Key('riaw_reset_all')),
      );
      expect(btn.radius, 30);
      handle.dispose();
      model.dispose();
    });
  });

  group('R3 lifecycle / reopen / isolation', () {
    testWidgets('R3-29/30 lifecycle dispose/recreate', (tester) async {
      final model1 = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model1));
      await tester.pump();
      model1.resistivity = 1;
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      model1.dispose();

      final model2 = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model2));
      await tester.pump();
      expect(model2.resistivity, 0.5);
      expect(model2.getFormattedResistanceValue(), '0.667');
      expect(model2.resistivityProperty.listenerCount, 2);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(model2.resistivityProperty.listenerCount, 1);
      model2.dispose();
    });

    testWidgets('R3-30 reopen starts at defaults', (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1
        ..length = 20
        ..area = 0.01;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      model.dispose();

      final fresh = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(fresh));
      await tester.pump();
      expect(fresh.resistivity, 0.5);
      expect(fresh.length, 10.0);
      expect(fresh.area, 7.5);
      fresh.dispose();
    });

    testWidgets('R3-31 cross-sim isolation Ohm ↔ RIAW', (tester) async {
      final riaw = ResistanceInAWireModel()..resistivity = 1.0;
      await tester.pumpWidget(_wrap(riaw));
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final ohms = OhmsLawModel()..voltage = 9;
      await tester.pumpWidget(
        MaterialApp(
          home: OhmsLawScreen(
            model: ohms,
            showAppBar: false,
            dotRandom: math.Random(0x4F484D53),
          ),
        ),
      );
      await tester.pump();
      expect(ohms.voltage, 9);
      expect(riaw.resistivity, 1.0); // external model retained, not shared

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await tester.pumpWidget(_wrap(riaw));
      await tester.pump();
      expect(riaw.resistivity, 1.0);
      expect(riaw.resistance, closeTo(10.0 / 7.5, 1e-12));
      riaw.dispose();
      ohms.dispose();
    });

    testWidgets('R3-32 source-forbidden interactions absent', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(find.textContaining('battery'), findsNothing);
      expect(find.textContaining('Switch'), findsNothing);
      expect(find.textContaining('voltage'), findsNothing);
      expect(find.textContaining('current'), findsNothing);
      expect(find.textContaining('temperature'), findsNothing);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(StaticArrow), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.byType(ResistanceInAWirePlayArea), findsOneWidget);
      model.dispose();
    });

    testWidgets('R3-33 VD-02 R scale remains uncapped at extreme',
        (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1
        ..length = 20
        ..area = 0.01;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      final scale = model.formulaScaleMagnitude(model.resistance, 2.0 / 3.0);
      expect(scale, greaterThan(1000));
      expect(tester.takeException(), isNull);
      model.dispose();
    });
  });
}
