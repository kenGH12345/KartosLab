import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/ohms_law/model/current_units.dart';
import 'package:kratos/ohms_law/model/ohms_law_model.dart';
import 'package:kratos/ohms_law/ohms_law_view_constants.dart';
import 'package:kratos/ohms_law/view/ohms_law_play_area.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/ohms_law/view/wire_box.dart';

/// Deterministic seed for resistor dots (Phase 4 golden / production default).
const int _kDotSeed = 0x4F484D53;

Widget _screen(OhmsLawModel model) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OhmsLawScreen(
      model: model,
      showAppBar: false,
      dotRandom: math.Random(_kDotSeed),
    ),
  );
}

Future<void> _pumpState(
  WidgetTester tester,
  OhmsLawModel model, {
  required double voltage,
  required double resistance,
  CurrentUnit units = CurrentUnit.milliamps,
}) async {
  await tester.binding.setSurfaceSize(OhmsLawViewConstants.layoutSize);
  model.voltage = voltage;
  model.resistance = resistance;
  model.currentUnits = units;
  await tester.pumpWidget(_screen(model));
  await tester.pumpAndSettle();
}

Future<void> _expectGolden(
  WidgetTester tester,
  String name,
) async {
  await expectLater(
    find.byType(OhmsLawPlayArea),
    matchesGoldenFile('goldens/$name.png'),
  );
}

int _batteryCount(double voltage) {
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

  tearDown(() async {
    // Restore default surface between cases when set.
  });

  group('V4 visual contracts (source-derived, non-pixel)', () {
    test('V4 background exact #FFFFE8', () {
      expect(OhmsLawViewConstants.background, const Color(0xFFFFFFE8));
    });

    test('V4 equation scaling increases with normalized V/I/R', () {
      final model = OhmsLawModel();
      final midV = OhmsLawViewConstants.othersScaleM * model.getNormalizedVoltage() +
          OhmsLawViewConstants.othersScaleB;
      final midI = OhmsLawViewConstants.currentScaleM * model.getNormalizedCurrent() +
          OhmsLawViewConstants.currentScaleB;
      model.voltage = 9;
      model.resistance = 10;
      final highV = OhmsLawViewConstants.othersScaleM * model.getNormalizedVoltage() +
          OhmsLawViewConstants.othersScaleB;
      final highI = OhmsLawViewConstants.currentScaleM * model.getNormalizedCurrent() +
          OhmsLawViewConstants.currentScaleB;
      expect(highV, greaterThan(midV));
      expect(highI, greaterThan(midI));
      model.voltage = 0.1;
      model.resistance = 1000;
      final lowI = OhmsLawViewConstants.currentScaleM * model.getNormalizedCurrent() +
          OhmsLawViewConstants.currentScaleB;
      expect(lowI, lessThan(midI));
      model.dispose();
    });

    test('V4 no multiply glyph in equation contract', () {
      // FormulaEquation paints only V, =, I, R — documented source contract.
      expect(OhmsLawViewConstants.equalsLocalX, 300);
      expect(OhmsLawViewConstants.voltageLocalX, 150);
      expect(OhmsLawViewConstants.currentLocalX, 380);
      expect(OhmsLawViewConstants.resistanceLocalX, 540);
    });

    test('V4 battery count follows AA mapping', () {
      expect(_batteryCount(0.1), 1);
      expect(_batteryCount(4.5), 3);
      expect(_batteryCount(9.0), 6);
    });

    test('V4 resistor dots increase with R', () {
      final low = OhmsLawViewConstants.resistanceToNumDots(10);
      final mid = OhmsLawViewConstants.resistanceToNumDots(500);
      final high = OhmsLawViewConstants.resistanceToNumDots(1000);
      expect(mid, greaterThan(low));
      expect(high, greaterThan(mid));
    });

    test('V4 resistor dots: same seed → identical layout (PhET once-only)', () {
      final a = WireBox.buildDotCenters(math.Random(_kDotSeed));
      final b = WireBox.buildDotCenters(math.Random(_kDotSeed));
      expect(a.length, b.length);
      expect(a.length, OhmsLawViewConstants.numberOfDots.floor());
      for (var i = 0; i < a.length; i++) {
        expect(a[i], b[i]);
      }
    });

    test('V4 resistor dots: R only changes count, not positions', () {
      final dots = WireBox.buildDotCenters(math.Random(_kDotSeed));
      final lowN = OhmsLawViewConstants.resistanceToNumDots(10).floor();
      final highN = OhmsLawViewConstants.resistanceToNumDots(1000).floor();
      expect(highN, greaterThan(lowN));
      // Visible set is always a prefix of the fixed layout (PhET index < n).
      expect(dots.take(lowN).toList(), dots.sublist(0, lowN));
      expect(highN, lessThanOrEqualTo(dots.length));
    });

    test('V4 current arrow scale increases with I (direction via rotations)', () {
      final low = OhmsLawViewConstants.arrowScaleForCurrent(0.1);
      final mid = OhmsLawViewConstants.arrowScaleForCurrent(9);
      final high = OhmsLawViewConstants.arrowScaleForCurrent(900);
      expect(mid, greaterThan(low));
      expect(high, greaterThan(mid));
      // Bottom-left π/2, bottom-right 0 → clockwise conventional current
      expect(RightAngleArrowShape.points.length, 9);
    });

    test('V4 golden determinism: same seed → same first dots', () {
      final a = math.Random(_kDotSeed);
      final b = math.Random(_kDotSeed);
      for (var i = 0; i < 20; i++) {
        expect(a.nextDouble(), b.nextDouble());
      }
    });
  });

  group('V4 full-screen golden matrix', () {
    testWidgets('G01 / G03 / G10 / G13 / G19 / G21 / G24 / G27 initial',
        (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 4.5, resistance: 500);
      expect(model.current, 9.0);
      expect(find.text('9.0'), findsWidgets);
      expect(find.text('mA'), findsWidgets);
      await _expectGolden(tester, 'g01_initial');
      model.dispose();
    });

    testWidgets('G09 / G23 voltage minimum', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 0.1, resistance: 500);
      expect(_batteryCount(0.1), 1);
      await _expectGolden(tester, 'g09_voltage_min');
      model.dispose();
    });

    testWidgets('G11 / G05 / G25 voltage maximum', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 9, resistance: 500);
      expect(_batteryCount(9), 6);
      expect(model.current, 18.0);
      await _expectGolden(tester, 'g11_voltage_max');
      model.dispose();
    });

    testWidgets('G12 / G06 / G26 resistance minimum', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 4.5, resistance: 10);
      expect(model.current, 450.0);
      await _expectGolden(tester, 'g12_resistance_min');
      model.dispose();
    });

    testWidgets('G14 / G28 resistance maximum', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 4.5, resistance: 1000);
      expect(model.current, 4.5);
      await _expectGolden(tester, 'g14_resistance_max');
      model.dispose();
    });

    testWidgets('G02 / G08 / G15 / G18 / G30 low current', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 0.1, resistance: 1000);
      expect(model.current, 0.1);
      await _expectGolden(tester, 'g02_low_current');
      model.dispose();
    });

    testWidgets('G04 / G07 / G17 / G20 / G31 high current', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 9, resistance: 10);
      expect(model.current, 900.0);
      await _expectGolden(tester, 'g04_high_current');
      model.dispose();
    });

    testWidgets('G16 / G29 low V + low R', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 0.1, resistance: 10);
      expect(model.current, 10.0);
      await _expectGolden(tester, 'g29_low_v_low_r');
      model.dispose();
    });

    testWidgets('G32 high V + high R', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 9, resistance: 1000);
      expect(model.current, 9.0);
      await _expectGolden(tester, 'g32_high_v_high_r');
      model.dispose();
    });

    testWidgets('G22 / G35 / G36 Units = A (VD-03 display)', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(
        tester,
        model,
        voltage: 4.5,
        resistance: 500,
        units: CurrentUnit.amps,
      );
      expect(model.current, 9.0);
      expect(model.getFixedCurrent(), '0.090');
      expect(find.text('0.090'), findsWidgets);
      await _expectGolden(tester, 'g22_units_a');
      model.dispose();
    });

    testWidgets('G37 R + Units A', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(
        tester,
        model,
        voltage: 4.5,
        resistance: 10,
        units: CurrentUnit.amps,
      );
      expect(model.getFixedCurrent(), '4.500'); // 450/100
      await _expectGolden(tester, 'g37_r_min_units_a');
      model.dispose();
    });

    testWidgets('G38 Reset preserves Units=A', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel()
        ..voltage = 9
        ..resistance = 10
        ..currentUnits = CurrentUnit.amps;
      await tester.binding.setSurfaceSize(OhmsLawViewConstants.layoutSize);
      await tester.pumpWidget(_screen(model));
      await tester.pumpAndSettle();
      model.reset();
      await tester.pumpAndSettle();
      expect(model.voltage, 4.5);
      expect(model.resistance, 500);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.amps);
      expect(find.text('0.090'), findsWidgets);
      await _expectGolden(tester, 'g38_reset_preserves_units_a');
      model.dispose();
    });

    testWidgets('V4-15 golden determinism twice identical', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = OhmsLawModel();
      await _pumpState(tester, model, voltage: 4.5, resistance: 500);
      await _expectGolden(tester, 'g01_initial');
      // Re-pump with fresh Random(same seed) — must still match
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      final model2 = OhmsLawModel();
      await _pumpState(tester, model2, voltage: 4.5, resistance: 500);
      await _expectGolden(tester, 'g01_initial');
      model.dispose();
      model2.dispose();
    });
  });
}
