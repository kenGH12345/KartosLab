import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_model.dart';
import 'package:kratos/resistance_in_a_wire/resistance_in_a_wire_view_constants.dart';
import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';
import 'package:kratos/resistance_in_a_wire/view/controls/control_panel.dart';
import 'package:kratos/resistance_in_a_wire/view/formula_equation.dart';
import 'package:kratos/resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';
import 'package:kratos/resistance_in_a_wire/view/riaw_play_area.dart';
import 'package:kratos/resistance_in_a_wire/view/static_arrow.dart';
import 'package:kratos/resistance_in_a_wire/view/wire_node.dart';

const int _kDotSeed = 0x52494157; // 'RIAW'

Widget _wrap(ResistanceInAWireModel model) {
  return MaterialApp(
    home: ResistanceInAWireScreen(
      model: model,
      showAppBar: false,
      dotRandom: math.Random(_kDotSeed),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V2 canvas / background / structure', () {
    testWidgets('V2-17/18 canvas and background #FFFFDF', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.byType(ResistanceInAWirePlayArea), findsOneWidget);
      final colored = tester.widgetList<ColoredBox>(find.byType(ColoredBox));
      expect(
        colored.any((c) => c.color == ResistanceInAWireViewConstants.background),
        isTrue,
      );
      expect(ResistanceInAWireViewConstants.layoutSize, const Size(1024, 618));
      expect(
        ResistanceInAWireViewConstants.background,
        const Color(0xFFFFFFDF),
      );
      model.dispose();
    });

    testWidgets('V2-19..31 core nodes present', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.byType(FormulaEquation), findsOneWidget);
      expect(find.byType(WireNode), findsOneWidget);
      expect(find.byType(StaticArrow), findsOneWidget);
      expect(find.byType(ResistanceInAWireControlPanel), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text(RiawStrings.resistivity), findsOneWidget);
      expect(find.text(RiawStrings.length), findsOneWidget);
      expect(find.text(RiawStrings.area), findsOneWidget);
      expect(find.textContaining('电阻 ='), findsOneWidget);
      expect(find.textContaining('0.667'), findsOneWidget);
      expect(find.text('0.50'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('7.50'), findsOneWidget);
      model.dispose();
    });

    testWidgets('V2-01 initial defaults', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      expect(model.getFormattedResistanceValue(), '0.667');
      model.dispose();
    });
  });

  group('V2 resistance precision', () {
    testWidgets('V2-27 1≤R<10 shows 2 decimals (1.33 not 1.333)',
        (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 15.0;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(model.getFormattedResistanceValue(), '1.33');
      expect(find.textContaining('1.33'), findsOneWidget);
      expect(find.textContaining('1.333'), findsNothing);
      model.dispose();
    });
  });

  group('V2 sliders reactive', () {
    testWidgets('V2-32 reactive ρ', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final baseline = model.resistance;
      await tester.drag(
        find.byKey(const Key('riaw_resistivity_slider')),
        const Offset(0, -60),
      );
      await tester.pump();

      expect(model.resistivity, greaterThan(0.5));
      expect(model.resistance, greaterThan(baseline));
      model.dispose();
    });

    testWidgets('V2-33 reactive L', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final baseline = model.resistance;
      await tester.drag(
        find.byKey(const Key('riaw_length_slider')),
        const Offset(0, -40),
      );
      await tester.pump();

      expect(model.length, greaterThan(10.0));
      expect(model.resistance, greaterThan(baseline));
      model.dispose();
    });

    testWidgets('V2-34 reactive A', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final baseline = model.resistance;
      await tester.drag(
        find.byKey(const Key('riaw_area_slider')),
        const Offset(0, 40),
      );
      await tester.pump();

      expect(model.area, lessThan(7.5));
      expect(model.resistance, greaterThan(baseline));
      model.dispose();
    });
  });

  group('V2 reset', () {
    testWidgets('V2-31 reset restores defaults', (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 0.01;
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final reset = tester.widget<KratosResetAllButton>(
        find.byKey(const Key('riaw_reset_all')),
      );
      expect(reset.radius, 30);

      await tester.tap(find.byKey(const Key('riaw_reset_all')));
      await tester.pump();

      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      expect(model.getFormattedResistanceValue(), '0.667');
      model.dispose();
    });
  });

  group('V2 visual state matrix smoke', () {
    testWidgets('V2-01..16 state smoke', (tester) async {
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      final states = <void Function()>[
        () {}, // initial
        () => model.resistivity = 0.01,
        () => model.resistivity = 0.5,
        () => model.resistivity = 1.0,
        () => model.length = 0.1,
        () => model.length = 10.0,
        () => model.length = 20.0,
        () => model.area = 0.01,
        () => model.area = 7.5,
        () => model.area = 15.0,
        () {
          model.resistivity = 0.01;
          model.length = 0.1;
          model.area = 15.0;
        }, // low R
        () {
          model.resistivity = 0.5;
          model.length = 10.0;
          model.area = 7.5;
        }, // mid R
        () {
          model.resistivity = 1.0;
          model.length = 20.0;
          model.area = 0.01;
        }, // high R
        () {
          model.resistivity = 0.8;
          model.length = 15.0;
          model.area = 2.0;
        }, // combined
        () {
          model.resistivity = 1.0;
          model.length = 20.0;
          model.area = 0.01;
        }, // formula extreme
        () => model.reset(),
      ];

      for (final apply in states) {
        apply();
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      model.dispose();
    });
  });

  group('V2 geometry / dots contracts', () {
    test('V2-21/22 wire length/thickness mapping', () {
      final wMin = ResistanceInAWireViewConstants.lengthToWidth(0.1);
      final wMid = ResistanceInAWireViewConstants.lengthToWidth(10);
      final wMax = ResistanceInAWireViewConstants.lengthToWidth(20);
      expect(wMin, 15);
      expect(wMax, 500);
      expect(wMid, greaterThan(wMin));
      expect(wMid, lessThan(wMax));

      final hMin = ResistanceInAWireViewConstants.areaToHeight(0.01);
      final hMid = ResistanceInAWireViewConstants.areaToHeight(7.5);
      final hMax = ResistanceInAWireViewConstants.areaToHeight(15);
      expect(hMax, closeTo(180, 1e-9));
      expect(hMid, greaterThan(hMin));
      expect(hMid, lessThan(hMax));
    });

    test('V2-24 dot density increases with ρ', () {
      final low = ResistanceInAWireViewConstants.resistivityToNumDots(0.01);
      final mid = ResistanceInAWireViewConstants.resistivityToNumDots(0.5);
      final high = ResistanceInAWireViewConstants.resistivityToNumDots(1.0);
      expect(mid, greaterThan(low));
      expect(high, greaterThan(mid));
    });

    test('V2-36 golden determinism: same seed → same dots', () {
      final a = WireNode.buildDotCenters(math.Random(_kDotSeed));
      final b = WireNode.buildDotCenters(math.Random(_kDotSeed));
      expect(a.length, b.length);
      expect(a, b);
      final c = WireNode.buildDotCenters(math.Random(_kDotSeed + 1));
      expect(c, isNot(a));
    });

    test('V2-20 formula scale grows; R uncapped (VD-02)', () {
      final model = ResistanceInAWireModel();
      final mid = model.formulaScaleMagnitude(model.resistance, 2.0 / 3.0);
      expect(mid, closeTo(8.0, 1e-12));
      model
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 0.01;
      final high = model.formulaScaleMagnitude(model.resistance, 2.0 / 3.0);
      expect(high, greaterThan(1000));
      model.dispose();
    });
  });

  group('V2 keyboard', () {
    testWidgets('V2 ρ keyboard step 0.05', (tester) async {
      final focus = FocusNode();
      final model = ResistanceInAWireModel();
      await tester.pumpWidget(
        MaterialApp(
          home: ResistanceInAWireScreen(
            model: model,
            showAppBar: false,
            dotRandom: math.Random(_kDotSeed),
            resistivityFocusNode: focus,
          ),
        ),
      );
      await tester.pump();
      focus.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.resistivity, closeTo(0.55, 1e-9));

      focus.dispose();
      model.dispose();
    });
  });
}
