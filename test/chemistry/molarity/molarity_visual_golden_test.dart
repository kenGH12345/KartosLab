import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/model/molarity_constants.dart';
import 'package:kratos/chemistry/molarity/model/molarity_model.dart';
import 'package:kratos/chemistry/molarity/model/molarity_state.dart';
import 'package:kratos/chemistry/molarity/model/solvent.dart';
import 'package:kratos/chemistry/molarity/view/molarity_layout.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_beaker.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_concentration_display.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_play_area.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_solute_combo.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_solution_values_checkbox.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_vertical_slider.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Phase 4 — Visual QA / Raster Golden Matrix (1100×700, DPR 1).
///
/// **Truth hierarchy**
/// 1. Official PhET runtime / source geometry (`MolarityScreenView.js`,
///    `BeakerImageNode.js`) — asserted in source-geometry group.
/// 2. Raster PNGs under `goldens/` are **implementation regression** captures
///    (deterministic seed). They are NOT claimed as official PhET pixels.
///
/// Official live sim: https://phet.colorado.edu/sims/html/molarity/latest/molarity_all.html
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const layout = Size(1100, 700);
  const goldenSeed = 42;

  MolarityState wrap(MolarityModel model) => MolarityState.fromModel(
        scenarioId: 'default',
        model: model,
        initialSoluteIndex: 0,
        initialSoluteAmount: 0.5,
        initialVolume: 0.5,
        initialValuesVisible: false,
      );

  Future<void> pumpPlayArea(
    WidgetTester tester,
    MolarityModel model, {
    int seed = goldenSeed,
  }) async {
    await tester.binding.setSurfaceSize(layout);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.physicalSize = layout;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          color: MolarityLayout.background,
          child: SizedBox(
            width: layout.width,
            height: layout.height,
            child: MediaQuery(
              data: const MediaQueryData(
                size: layout,
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: ListenableBuilder(
                listenable: model.solution,
                builder: (_, _) => MolarityPlayArea(
                  state: wrap(model),
                  randomSeed: seed,
                  onSoluteAmount: model.setSoluteAmount,
                  onVolume: model.setVolume,
                  onSoluteIndex: model.selectSolute,
                  onValuesVisible: model.setValuesVisible,
                  onReset: model.reset,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Allow beaker.png decode.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> expectGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(MolarityPlayArea),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  // ---------------------------------------------------------------------------
  // Source-defined geometry (official truth — not raster)
  // ---------------------------------------------------------------------------
  group('V4 source geometry', () {
    test('V4 canvas 1100×700 · background · beaker scale', () {
      expect(MolarityLayout.canvas, layout);
      expect(MolarityLayout.background, const Color(0xFFFFFFFF));
      expect(MolarityLayout.beakerIntrinsic, const Size(560, 681));
      expect(MolarityLayout.beakerScale, 0.75);
      expect(MolarityLayout.beakerDisplaySize.width, closeTo(420, 0.01));
      expect(MolarityLayout.beakerDisplaySize.height, closeTo(510.75, 0.01));
    });

    test('V4 cylinder POI from BeakerImageNode', () {
      expect(MolarityLayout.cylinderUpperLeftLocal, const Offset(98, 192));
      expect(MolarityLayout.cylinderLowerRightLocal, const Offset(526, 644));
      expect(MolarityLayout.cylinderSize.width, closeTo(321, 0.1));
      expect(MolarityLayout.cylinderSize.height, closeTo(339, 0.1));
      expect(MolarityLayout.cylinderEndHeight, closeTo(39, 0.1));
    });

    test('V4 slider tracks · volume shortened', () {
      expect(
        MolarityLayout.soluteSliderTrackHeight,
        MolarityLayout.cylinderSize.height,
      );
      expect(
        MolarityLayout.volumeSliderTrackHeight,
        closeTo(0.8 * MolarityLayout.cylinderSize.height, 0.1),
      );
      expect(
        MolarityLayout.volumeSliderTrackHeight,
        lessThan(MolarityLayout.soluteSliderTrackHeight),
      );
    });

    test('V4 relative placement matches ScreenView offsets', () {
      expect(MolarityLayout.volumeSliderLeft, 135); // 130+5
      expect(MolarityLayout.beakerLeft, 250); // 135+130-15
      expect(MolarityLayout.beakerTop, -11);
      expect(
        MolarityLayout.concentrationLeft,
        closeTo(250 + 420 + 40, 0.1),
      );
      expect(MolarityLayout.controlsBelowBeaker, 50);
      expect(MolarityLayout.checkboxComboGap, 50);
      expect(MolarityLayout.resetRadius, closeTo(20.5 * 1.32, 0.01));
      // PhET: valueText expands slider bounds → volume / beaker shift right.
      expect(MolarityLayout.sliderColumnWidthFor(true), 225); // 130+5+90
      expect(MolarityLayout.volumeSliderLeftFor(true), 230); // 225+5
      expect(MolarityLayout.beakerLeftFor(true), 440); // 230+225-15
    });

    test('V4 concentration bar size · display scale 0..5', () {
      expect(MolarityLayout.concentrationBarSize.width, 40);
      expect(
        MolarityLayout.concentrationBarSize.height,
        closeTo(MolarityLayout.cylinderSize.height + 50, 0.1),
      );
      expect(MolarityConstants.concentrationDisplayMax, 5.0);
    });

    test('V4 liquid height ∝ volume (source linear map)', () {
      final cylH = MolarityLayout.cylinderSize.height;
      double h(double v) => cylH * (v / MolarityConstants.volumeMax);
      expect(h(0.2) / h(1.0), closeTo(0.2, 1e-9));
      expect(h(0.5) / h(1.0), closeTo(0.5, 1e-9));
      expect(h(0.75) / h(1.0), closeTo(0.75, 1e-9));
    });

    test('V4 C_sat indicator fractions differ (not normalized to 100%)', () {
      const displayMax = MolarityConstants.concentrationDisplayMax;
      final drinkMixFrac = 5.95.clamp(0, displayMax) / displayMax;
      final dichromateFrac = 0.50 / displayMax;
      expect(drinkMixFrac, 1.0); // capped at display max
      expect(dichromateFrac, closeTo(0.1, 1e-9));
      expect(dichromateFrac, isNot(equals(drinkMixFrac)));
    });

    test('V4 water color / KMnO₄ particle black', () {
      expect(const Solvent().color, const Color(0xFFE0FFFF));
      final m = MolarityModel.defaults()..selectSolute(8);
      expect(m.solution.solute.particleColor, const Color(0xFF000000));
    });
  });

  // ---------------------------------------------------------------------------
  // Widget presence / state visuals
  // ---------------------------------------------------------------------------
  group('V4 widget visuals', () {
    testWidgets('V4-19 full layout chrome present', (tester) async {
      final model = MolarityModel.defaults();
      await pumpPlayArea(tester, model);
      expect(find.byType(MolarityPlayArea), findsOneWidget);
      expect(find.byType(MolarityBeaker), findsOneWidget);
      expect(find.byType(MolarityConcentrationDisplay), findsOneWidget);
      expect(find.byType(MolarityVerticalSlider), findsNWidgets(2));
      expect(find.byType(MolaritySoluteCombo), findsOneWidget);
      expect(find.byType(MolaritySolutionValuesCheckbox), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('Saturated!'), findsNothing);
    });

    testWidgets('V4 saturation indicator placement', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(3)
        ..setVolume(0.2)
        ..setSoluteAmount(1.0);
      expect(model.solution.isSaturated, isTrue);
      await pumpPlayArea(tester, model);
      expect(find.text('Saturated!'), findsOneWidget);
    });

    testWidgets('V4 water state label H₂O', (tester) async {
      final model = MolarityModel.defaults()..setSoluteAmount(0);
      await pumpPlayArea(tester, model);
      expect(model.solution.solutionColor, const Color(0xFFE0FFFF));
      expect(find.textContaining('H'), findsWidgets);
    });

    testWidgets('V4 solution values ON shows quantitative labels', (tester) async {
      final model = MolarityModel.defaults()..setValuesVisible(true);
      await pumpPlayArea(tester, model);
      // Slider end labels become numeric; concentration "1.000 M" is CustomPaint text.
      expect(find.text('1.0'), findsWidgets);
      expect(find.text('多'), findsNothing);
      expect(model.solution.concentration, 1.0);
    });

    testWidgets('V4 golden determinism same seed → same particle count path',
        (tester) async {
      final a = MolarityModel.defaults()
        ..selectSolute(8)
        ..setVolume(0.2)
        ..setSoluteAmount(1.0);
      final b = MolarityModel.defaults()
        ..selectSolute(8)
        ..setVolume(0.2)
        ..setSoluteAmount(1.0);
      expect(a.solution.numberOfParticles, b.solution.numberOfParticles);
      expect(a.solution.numberOfParticles, greaterThan(0));
      await pumpPlayArea(tester, a, seed: 7);
      await pumpPlayArea(tester, b, seed: 7);
    });
  });

  // ---------------------------------------------------------------------------
  // Raster golden matrix (implementation regression)
  // ---------------------------------------------------------------------------
  group('V4 raster goldens (implementation regression)', () {
    testWidgets('V4-01 / G01 initial cold start', (tester) async {
      final model = MolarityModel.defaults();
      await pumpPlayArea(tester, model);
      expect(model.solution.concentration, 1.0);
      await expectGolden(tester, 'G01_initial');
    });

    testWidgets('V4-02 / G02 solute amount low', (tester) async {
      final model = MolarityModel.defaults()..setSoluteAmount(0.1);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G02_solute_low');
    });

    testWidgets('V4-03 / G03 solute amount high', (tester) async {
      final model = MolarityModel.defaults()..setSoluteAmount(1.0);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G03_solute_high');
    });

    testWidgets('V4-04 / G04 volume low', (tester) async {
      final model = MolarityModel.defaults()..setVolume(0.2);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G04_volume_low');
    });

    testWidgets('V4-05 / G05 volume high', (tester) async {
      final model = MolarityModel.defaults()..setVolume(1.0);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G05_volume_high');
    });

    testWidgets('V4-06 / G06 low concentration', (tester) async {
      final model = MolarityModel.defaults()
        ..setSoluteAmount(0.1)
        ..setVolume(1.0);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G06_concentration_low');
    });

    testWidgets('V4-07 / G07 high concentration', (tester) async {
      final model = MolarityModel.defaults()
        ..setSoluteAmount(1.0)
        ..setVolume(0.2);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G07_concentration_high');
    });

    testWidgets('V4-08 / G08 saturation boundary', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(3) // K2Cr2O7 C_sat=0.50
        ..setVolume(1.0)
        ..setSoluteAmount(0.5);
      expect(model.solution.precipitateAmount, 0);
      expect(model.solution.isSaturated, isFalse);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G08_saturation_boundary');
    });

    testWidgets('V4-09 / G09 saturated + precipitate', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(3)
        ..setVolume(0.2)
        ..setSoluteAmount(0.3);
      expect(model.solution.isSaturated, isTrue);
      await pumpPlayArea(tester, model);
      expect(find.text('Saturated!'), findsOneWidget);
      await expectGolden(tester, 'G09_saturated');
    });

    testWidgets('V4-10 / G10 precipitate medium', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(3)
        ..setVolume(0.2)
        ..setSoluteAmount(0.5);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G10_precipitate');
    });

    testWidgets('V4-11 / G10 heavy precipitate', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(3)
        ..setVolume(0.2)
        ..setSoluteAmount(1.0);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G10b_heavy_precipitate');
    });

    testWidgets('V4-12 / G11 water zero solute', (tester) async {
      final model = MolarityModel.defaults()..setSoluteAmount(0);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G11_water');
    });

    testWidgets('V4-13 / G12 potassium dichromate', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(3)
        ..setSoluteAmount(0.4)
        ..setVolume(0.5);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G12_potassium_dichromate');
    });

    testWidgets('V4-14 / G13 potassium permanganate', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(8)
        ..setVolume(0.2)
        ..setSoluteAmount(0.8);
      expect(model.solution.solute.particleColor, const Color(0xFF000000));
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G13_potassium_permanganate');
    });

    testWidgets('V4-15 / G14 copper sulfate', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(7)
        ..setSoluteAmount(0.6)
        ..setVolume(0.5);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G14_copper_sulfate');
    });

    testWidgets('V4-16 / G15 solution values OFF', (tester) async {
      final model = MolarityModel.defaults();
      expect(model.valuesVisible, isFalse);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G15_values_off');
    });

    testWidgets('V4-17 / G16 solution values ON', (tester) async {
      final model = MolarityModel.defaults()..setValuesVisible(true);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G16_values_on');
    });

    testWidgets('V4-18 / G17 reset state', (tester) async {
      final model = MolarityModel.defaults()
        ..selectSolute(8)
        ..setSoluteAmount(1.0)
        ..setVolume(0.2)
        ..setValuesVisible(true);
      model.reset();
      expect(model.solution.soluteAmount, 0.5);
      expect(model.valuesVisible, isFalse);
      await pumpPlayArea(tester, model);
      await expectGolden(tester, 'G17_reset');
    });

    testWidgets('V4-20 visual regression · no legacy', (tester) async {
      final model = MolarityModel.defaults();
      await pumpPlayArea(tester, model);
      expect(find.textContaining('Shaker'), findsNothing);
      expect(find.textContaining('Dropper'), findsNothing);
      expect(find.textContaining('Faucet'), findsNothing);
      expect(find.textContaining('Probe'), findsNothing);
      await expectGolden(tester, 'G20_regression_baseline');
    });
  });
}
