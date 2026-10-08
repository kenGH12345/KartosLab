import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_constants.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_model.dart';
import 'package:kratos/resistance_in_a_wire/resistance_in_a_wire_view_constants.dart';
import 'package:kratos/resistance_in_a_wire/view/formula_equation.dart';
import 'package:kratos/resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';
import 'package:kratos/resistance_in_a_wire/view/riaw_play_area.dart';
import 'package:kratos/resistance_in_a_wire/view/static_arrow.dart';
import 'package:kratos/resistance_in_a_wire/view/wire_node.dart';

/// Deterministic seed for impurity dots (golden / regression only).
const int _kDotSeed = 0x52494157;

Widget _screen(ResistanceInAWireModel model) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ResistanceInAWireScreen(
      model: model,
      showAppBar: false,
      dotRandom: math.Random(_kDotSeed),
    ),
  );
}

Future<void> _pumpState(
  WidgetTester tester,
  ResistanceInAWireModel model, {
  required double resistivity,
  required double length,
  required double area,
}) async {
  await tester.binding.setSurfaceSize(ResistanceInAWireViewConstants.layoutSize);
  model.resistivity = resistivity;
  model.length = length;
  model.area = area;
  await tester.pumpWidget(_screen(model));
  await tester.pumpAndSettle();
}

Future<void> _expectGolden(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(ResistanceInAWirePlayArea),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V4 visual contracts (source-derived, non-pixel)', () {
    test('V4-01 canvas / background / reset radius', () {
      expect(ResistanceInAWireViewConstants.layoutSize, const Size(1024, 618));
      expect(
        ResistanceInAWireViewConstants.background,
        const Color(0xFFFFFFDF),
      );
      expect(ResistanceInAWireViewConstants.resetRadius, 30);
      expect(ResistanceInAWireViewConstants.blue, const Color(0xFF0F0FFB));
      expect(ResistanceInAWireViewConstants.red, const Color(0xFFFF2222));
    });

    test('V4-02 formula scale grows; R uncapped (VD-02)', () {
      final model = ResistanceInAWireModel();
      final mid = model.formulaScaleMagnitude(model.resistance, 2.0 / 3.0);
      expect(mid, closeTo(8.0, 1e-12));
      model
        ..resistivity = 1
        ..length = 20
        ..area = 0.01;
      final high = model.formulaScaleMagnitude(model.resistance, 2.0 / 3.0);
      expect(high, greaterThan(1000));
      model.dispose();
    });

    test('V4-03/04 wire length min/max mapping', () {
      expect(ResistanceInAWireViewConstants.lengthToWidth(0.1), 15);
      expect(ResistanceInAWireViewConstants.lengthToWidth(20), 500);
      expect(
        ResistanceInAWireViewConstants.lengthToWidth(10),
        greaterThan(15),
      );
    });

    test('V4-05/06 wire thickness min/max mapping', () {
      final hMin = ResistanceInAWireViewConstants.areaToHeight(0.01);
      final hMax = ResistanceInAWireViewConstants.areaToHeight(15);
      expect(hMax, closeTo(180, 1e-9));
      expect(hMin, lessThan(hMax));
      expect(hMin, greaterThan(0));
    });

    test('V4-07/08 dot density min/max', () {
      final low =
          ResistanceInAWireViewConstants.resistivityToNumDots(0.01);
      final high =
          ResistanceInAWireViewConstants.resistivityToNumDots(1.0);
      expect(high, greaterThan(low));
      expect(low, greaterThan(0));
    });

    test('V4-09/10 resistance precision bands', () {
      final model = ResistanceInAWireModel();
      expect(model.getFormattedResistanceValue(), '0.667'); // R < 1

      model
        ..resistivity = 1
        ..length = 20
        ..area = 15;
      expect(model.getFormattedResistanceValue(), '1.33'); // 1≤R<10

      model.area = 1;
      expect(model.getFormattedResistanceValue(), '20.0'); // 10≤R<100

      model.area = 0.01;
      expect(model.getFormattedResistanceValue(), '2000'); // R≥100
      model.dispose();
    });

    test('V4-11 golden determinism same seed', () {
      final a = WireNode.buildDotCenters(math.Random(_kDotSeed));
      final b = WireNode.buildDotCenters(math.Random(_kDotSeed));
      expect(a, b);
      expect(a.length, ResistanceInAWireViewConstants.numberOfDots.floor());
    });

    test('V4-12 formula layout anchors (no multiply glyph)', () {
      expect(ResistanceInAWireViewConstants.equalsLocalX, 100);
      expect(ResistanceInAWireViewConstants.rLocalX, 0);
      expect(ResistanceInAWireViewConstants.rhoLocalX, 220);
      expect(ResistanceInAWireViewConstants.lengthLocalX, 320);
      expect(ResistanceInAWireViewConstants.areaLocalX, 270);
      expect(ResistanceInAWireViewConstants.fractionLineWidth, 6);
    });

    test('V4-13 wire gradient / perspective constants', () {
      expect(ResistanceInAWireViewConstants.perspectiveFactor, 0.4);
      expect(ResistanceInAWireViewConstants.wireDark, const Color(0xFF8C4828));
      expect(ResistanceInAWireViewConstants.wireMid, const Color(0xFFE8B282));
      expect(ResistanceInAWireViewConstants.dotRadius, 2);
    });

    test('V4-14 slider readout always 2 decimals at defaults', () {
      final model = ResistanceInAWireModel();
      expect(model.getFormattedSliderValue(0.5), '0.50');
      expect(model.getFormattedSliderValue(10), '10.00');
      expect(model.getFormattedSliderValue(7.5), '7.50');
      expect(ResistanceInAWireConstants.sliderReadoutDecimals, 2);
      model.dispose();
    });
  });

  group('V4 widget smoke (structure)', () {
    testWidgets('V4-15 core nodes on initial canvas', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 7.5);
      expect(find.byType(FormulaEquation), findsOneWidget);
      expect(find.byType(WireNode), findsOneWidget);
      expect(find.byType(StaticArrow), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.textContaining('电阻 = 0.667 ohms'), findsOneWidget);
      expect(find.text('0.50'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('7.50'), findsOneWidget);
      final reset = tester.widget<KratosResetAllButton>(
        find.byKey(const Key('riaw_reset_all')),
      );
      expect(reset.radius, 30);
      model.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Raster goldens — implementation regression (NOT official pixel truth).
  // Matrix ID ↔ file: requirements/.../PHASE_4_GOLDEN_MATRIX.md
  // -------------------------------------------------------------------------
  group('V4 golden matrix (implementation regression)', () {
    testWidgets('G01 Initial / G02 Normal Formula / G12 Mid R / defaults',
        (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 7.5);
      await _expectGolden(tester, 'g01_initial');
      model.dispose();
    });

    testWidgets('G03 Small R / G11 Low R / G28 ρMin LMin AMax', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.01, length: 0.1, area: 15);
      expect(model.getFormattedResistanceValue(), '0.0001');
      await _expectGolden(tester, 'g03_small_r');
      model.dispose();
    });

    testWidgets('G04 Large R / G26/G27 ρMax LMax AMin', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 20, area: 0.01);
      expect(model.getFormattedResistanceValue(), '2000');
      await _expectGolden(tester, 'g04_large_r');
      model.dispose();
    });

    testWidgets('G05 Small ρ / G20 Minimum ρ', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.01, length: 10, area: 7.5);
      await _expectGolden(tester, 'g05_rho_low');
      model.dispose();
    });

    testWidgets('G06 Large ρ / G22 Maximum ρ', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 10, area: 7.5);
      await _expectGolden(tester, 'g06_rho_high');
      model.dispose();
    });

    testWidgets('G07 Small L / G14 Minimum Length', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 0.1, area: 7.5);
      await _expectGolden(tester, 'g07_l_low');
      model.dispose();
    });

    testWidgets('G08 Large L / G16 Maximum Length', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 20, area: 7.5);
      await _expectGolden(tester, 'g08_l_high');
      model.dispose();
    });

    testWidgets('G09 Small A / G17 Minimum Area', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 0.01);
      await _expectGolden(tester, 'g09_a_low');
      model.dispose();
    });

    testWidgets('G10 Large A / G19 Maximum Area', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 15);
      await _expectGolden(tester, 'g10_a_high');
      model.dispose();
    });

    testWidgets('G13 High R readout band 10≤R<100 (R=20.0)', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 20, area: 1.0);
      expect(model.getFormattedResistanceValue(), '20.0');
      await _expectGolden(tester, 'g13_r_20');
      model.dispose();
    });

    testWidgets('G_precision 1≤R<10 → 1.33 ohms', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 20, area: 15);
      expect(model.getFormattedResistanceValue(), '1.33');
      expect(find.textContaining('1.333'), findsNothing);
      await _expectGolden(tester, 'g13b_r_1_33');
      model.dispose();
    });

    testWidgets('G23 ρLow + LLow + ALow', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(
        tester,
        model,
        resistivity: 0.01,
        length: 0.1,
        area: 0.01,
      );
      await _expectGolden(tester, 'g23_combo_lll');
      model.dispose();
    });

    testWidgets('G24 ρLow + LHigh + AHigh', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.01, length: 20, area: 15);
      await _expectGolden(tester, 'g24_combo_lhh');
      model.dispose();
    });

    testWidgets('G25 ρHigh + LLow + AHigh', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 0.1, area: 15);
      await _expectGolden(tester, 'g25_combo_hlh');
      model.dispose();
    });

    testWidgets('G29 Reset', (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 0.8
        ..length = 15
        ..area = 2;
      await tester.binding
          .setSurfaceSize(ResistanceInAWireViewConstants.layoutSize);
      await tester.pumpWidget(_screen(model));
      await tester.pumpAndSettle();
      model.reset();
      await tester.pumpAndSettle();
      expect(model.getFormattedResistanceValue(), '0.667');
      await _expectGolden(tester, 'g29_reset');
      model.dispose();
    });

    testWidgets('G30 Reset from extreme', (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 20
        ..area = 0.01;
      await tester.binding
          .setSurfaceSize(ResistanceInAWireViewConstants.layoutSize);
      await tester.pumpWidget(_screen(model));
      await tester.pumpAndSettle();
      model.reset();
      await tester.pumpAndSettle();
      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      await _expectGolden(tester, 'g30_reset_extreme');
      model.dispose();
    });

    // Phase 2 filename continuity (aliases → same visuals as matrix).
    testWidgets('P2 continuity g02_rho_low', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.01, length: 10, area: 7.5);
      await _expectGolden(tester, 'g02_rho_low');
      model.dispose();
    });

    testWidgets('P2 continuity g03_rho_high', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 10, area: 7.5);
      await _expectGolden(tester, 'g03_rho_high');
      model.dispose();
    });

    testWidgets('P2 continuity g04_l_low', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 0.1, area: 7.5);
      await _expectGolden(tester, 'g04_l_low');
      model.dispose();
    });

    testWidgets('P2 continuity g05_l_high', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 20, area: 7.5);
      await _expectGolden(tester, 'g05_l_high');
      model.dispose();
    });

    testWidgets('P2 continuity g06_a_low', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 0.01);
      await _expectGolden(tester, 'g06_a_low');
      model.dispose();
    });

    testWidgets('P2 continuity g07_a_high', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 15);
      await _expectGolden(tester, 'g07_a_high');
      model.dispose();
    });

    testWidgets('P2 continuity g08_low_r', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.01, length: 0.1, area: 15);
      await _expectGolden(tester, 'g08_low_r');
      model.dispose();
    });

    testWidgets('P2 continuity g09_mid_r', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.5, length: 10, area: 7.5);
      await _expectGolden(tester, 'g09_mid_r');
      model.dispose();
    });

    testWidgets('P2 continuity g10_high_r', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 1.0, length: 20, area: 0.01);
      await _expectGolden(tester, 'g10_high_r');
      model.dispose();
    });

    testWidgets('P2 continuity g11_combined', (tester) async {
      final model = ResistanceInAWireModel();
      await _pumpState(tester, model, resistivity: 0.8, length: 18, area: 1.0);
      await _expectGolden(tester, 'g11_combined');
      model.dispose();
    });

    testWidgets('P2 continuity g12_reset', (tester) async {
      final model = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 20
        ..area = 0.01;
      await tester.binding
          .setSurfaceSize(ResistanceInAWireViewConstants.layoutSize);
      await tester.pumpWidget(_screen(model));
      await tester.pumpAndSettle();
      model.reset();
      await tester.pumpAndSettle();
      await _expectGolden(tester, 'g12_reset');
      model.dispose();
    });
  });
}
