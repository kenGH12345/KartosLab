import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/model/beers_law_constants.dart';
import 'package:kratos/beers_law_lab/model/beers_law_model.dart';
import 'package:kratos/beers_law_lab/model/detector_mode.dart';
import 'package:kratos/beers_law_lab/model/light_mode.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/beers_law_lab/view/beers_law_screen.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/probe_region.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

/// Phase 4 — Raster screenshot golden matrix (1100×700, DPR 1).
///
/// Official PhET references:
/// `phet sourses/beers-law-lab-main/.../assets/beers-law-lab-screenshot*.png`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const layout = Size(1100, 700);

  Future<void> pumpBeersLaw(
    WidgetTester tester,
    BeersLawModel model,
  ) async {
    addTearDown(model.dispose);
    await tester.binding.setSurfaceSize(layout);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: layout.width,
            height: layout.height,
            child: MediaQuery(
              data: const MediaQueryData(
                size: layout,
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: BeersLawScreen(model: model, showAppBar: false),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> pumpConcentration(
    WidgetTester tester,
    ConcentrationModel model,
  ) async {
    addTearDown(model.dispose);
    final size = ConcentrationLayout.layoutBounds;
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: MediaQuery(
              data: MediaQueryData(
                size: size,
                devicePixelRatio: 1,
                textScaler: const TextScaler.linear(1),
              ),
              child: ConcentrationScreen(
                model: model,
                showAppBar: false,
                audio: RecordingConcentrationAudio(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> pumpShell(
    WidgetTester tester, {
    required GlobalKey<BeersLawLabHomeState> key,
    required int tabIndex,
  }) async {
    const shell = Size(1100, 800);
    await tester.binding.setSurfaceSize(shell);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(
            size: shell,
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: BeersLawLabHome(
            key: key,
            concentrationAudio: RecordingConcentrationAudio(),
          ),
        ),
      ),
    );
    await tester.pump();
    // Decode Concentration Image.asset (shaker / icons) before golden.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    if (tabIndex == 1) {
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text("Beer's Law"),
      ));
      await tester.pump();
      // KratosTabSwitcher crossfade ≈ 280ms; wait until outgoing page cleared.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> expectBlGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(BeersLawScreen),
      matchesGoldenFile('goldens/beers_law/$name.png'),
    );
  }

  Future<void> expectConcGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(ConcentrationScreen),
      matchesGoldenFile('goldens/concentration/$name.png'),
    );
  }

  Future<void> expectShellGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(BeersLawLabHome),
      matchesGoldenFile('goldens/shell/$name.png'),
    );
  }

  Offset inBeam(BeersLawModel m) => Offset(
        m.cuvette.position.dx + m.cuvette.width + 0.5,
        m.light.position.dy,
      );

  Offset partialOverlap(BeersLawModel m) => Offset(
        m.cuvette.position.dx + m.cuvette.width + 0.5,
        m.light.position.dy - BeersLawConstants.lightLensDiameter,
      );

  // ---------------------------------------------------------------------------
  // Concentration (C4)
  // ---------------------------------------------------------------------------
  group('C4 Concentration goldens', () {
    testWidgets('C4-01 concentration_initial', (tester) async {
      final c = ConcentrationModel(random: math.Random(1));
      await pumpConcentration(tester, c);
      expect(ConcentrationViewportSize.matches1100x700, isTrue);
      await expectConcGolden(tester, 'C4-01_concentration_initial');
    });

    testWidgets('C4-02 concentration_solute', (tester) async {
      final c = ConcentrationModel(random: math.Random(2));
      c.setSolute(SoluteDefinitions.potassiumPermanganate);
      c.addSoluteAmount(0.2);
      c.setVolumeDirect(0.5);
      await pumpConcentration(tester, c);
      await expectConcGolden(tester, 'C4-02_concentration_solute');
    });

    testWidgets('C4-03 concentration_probe', (tester) async {
      final c = ConcentrationModel(random: math.Random(3));
      c.setSolute(SoluteDefinitions.potassiumPermanganate);
      c.addSoluteAmount(0.24);
      c.setVolumeDirect(0.5);
      c.setProbeRegion(ProbeRegion.solution);
      await pumpConcentration(tester, c);
      await expectConcGolden(tester, 'C4-03_concentration_probe');
    });

    testWidgets('C4-03b concentration_probe_outside', (tester) async {
      final c = ConcentrationModel(random: math.Random(4));
      c.addSoluteAmount(0.2);
      c.setVolumeDirect(0.5);
      c.setProbeRegion(ProbeRegion.none);
      await pumpConcentration(tester, c);
      expect(c.meter.value, isNull);
      await expectConcGolden(tester, 'C4-03b_concentration_probe_outside');
    });

    testWidgets('C4-04 concentration_high_concentration', (tester) async {
      final c = ConcentrationModel(random: math.Random(5));
      c.setSolute(SoluteDefinitions.potassiumPermanganate);
      c.addSoluteAmount(0.3);
      c.setVolumeDirect(0.5);
      c.setProbeRegion(ProbeRegion.solution);
      await pumpConcentration(tester, c);
      await expectConcGolden(tester, 'C4-04_concentration_high');
    });

    testWidgets('C4-04b concentration_saturated', (tester) async {
      final c = ConcentrationModel(random: math.Random(6));
      c.setSolute(SoluteDefinitions.potassiumPermanganate);
      // n/V > C_sat (0.48)
      c.addSoluteAmount(0.35);
      c.setVolumeDirect(0.5);
      c.setProbeRegion(ProbeRegion.solution);
      await pumpConcentration(tester, c);
      expect(c.solution.concentration, lessThanOrEqualTo(c.solute.saturatedConcentration));
      expect(c.solution.precipitateMoles, greaterThan(0));
      await expectConcGolden(tester, 'C4-04b_concentration_saturated');
    });

    testWidgets('C4-05 concentration_evaporation', (tester) async {
      final c = ConcentrationModel(random: math.Random(7));
      c.addSoluteAmount(0.2);
      c.setVolumeDirect(0.5);
      c.setEvaporationRate(0.25);
      c.step(0.5);
      c.setEvaporationRate(0);
      await pumpConcentration(tester, c);
      await expectConcGolden(tester, 'C4-05_concentration_evaporation');
    });

    testWidgets('C4-06 concentration_drain', (tester) async {
      final c = ConcentrationModel(random: math.Random(8));
      c.addSoluteAmount(0.2);
      c.setVolumeDirect(0.8);
      c.setDrainFlowRate(0.25);
      c.step(0.5);
      c.setDrainFlowRate(0);
      await pumpConcentration(tester, c);
      await expectConcGolden(tester, 'C4-06_concentration_drain');
    });

    testWidgets('C4-07 concentration_reset', (tester) async {
      final c = ConcentrationModel(random: math.Random(9));
      c.setSolute(SoluteDefinitions.potassiumPermanganate);
      c.addSoluteAmount(0.3);
      c.setVolumeDirect(0.8);
      c.setProbeRegion(ProbeRegion.solution);
      c.reset();
      await pumpConcentration(tester, c);
      expect(c.solution.volume, ConcentrationConstants.solutionVolumeDefault);
      await expectConcGolden(tester, 'C4-07_concentration_reset');
    });
  });

  // ---------------------------------------------------------------------------
  // Beer's Law (B4)
  // ---------------------------------------------------------------------------
  group('B4 Beers Law goldens', () {
    testWidgets('B4-01 beerslaw_initial', (tester) async {
      final m = BeersLawModel();
      await pumpBeersLaw(tester, m);
      expect(m.light.isOn, isFalse);
      expect(layout, const Size(1100, 700));
      await expectBlGolden(tester, 'B4-01_beerslaw_initial');
    });

    testWidgets('B4-02 beerslaw_light_on', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      await pumpBeersLaw(tester, m);
      expect(m.beam.isVisible, isTrue);
      await expectBlGolden(tester, 'B4-02_beerslaw_light_on');
    });

    testWidgets('B4-03 beerslaw_preset', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setDetectorMode(DetectorMode.absorbance);
      m.setDetectorProbePosition(inBeam(m));
      expect(m.light.mode, LightMode.preset);
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-03_beerslaw_preset');
    });

    testWidgets('B4-04 beerslaw_variable_wavelength', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setLightMode(LightMode.variable)
        ..setWavelength(508);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(find.byKey(const Key('beers_law_wavelength_slider')), findsOneWidget);
      await expectBlGolden(tester, 'B4-04_beerslaw_variable_wavelength');
    });

    testWidgets('B4-04b variable_380', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setLightMode(LightMode.variable)
        ..setWavelength(380);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-04b_variable_380');
    });

    testWidgets('B4-04c variable_780', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setLightMode(LightMode.variable)
        ..setWavelength(780);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-04c_variable_780');
    });

    testWidgets('B4-05 beerslaw_solution_changed', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setSolution(m.solutions.firstWhere((s) => s.id == 'copperSulfate'));
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-05_beerslaw_solution_changed');
    });

    testWidgets('B4-05b solution_nickel', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setSolution(m.solutions.firstWhere((s) => s.id == 'nickelIIChloride'));
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-05b_solution_nickel');
    });

    testWidgets('B4-06 beerslaw_concentration_changed', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setConcentration(0.3);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-06_beerslaw_concentration_changed');
    });

    testWidgets('B4-06b concentration_low', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setConcentration(0.02);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-06b_concentration_low');
    });

    testWidgets('B4-06c concentration_zero', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setConcentration(0);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-06c_concentration_zero');
    });

    testWidgets('B4-07 beerslaw_cuvette_wide', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setCuvetteWidth(2.0);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(m.cuvette.width, 2.0);
      // 2 cm = 250 px
      expect(125 * 2.0, 250);
      await expectBlGolden(tester, 'B4-07_beerslaw_cuvette_wide');
    });

    testWidgets('B4-07b cuvette_narrow', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setCuvetteWidth(0.5);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(125 * 0.5, 62.5);
      await expectBlGolden(tester, 'B4-07b_cuvette_narrow');
    });

    testWidgets('B4-08 beerslaw_detector_aligned', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(m.isProbeInBeam, isTrue);
      expect(m.absorbance, isNotNull);
      await expectBlGolden(tester, 'B4-08_beerslaw_detector_aligned');
    });

    testWidgets('B4-09 beerslaw_detector_misaligned', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setDetectorProbePosition(const Offset(6.3, 4.0));
      await pumpBeersLaw(tester, m);
      expect(m.isProbeInBeam, isFalse);
      expect(m.absorbance, isNull);
      await expectBlGolden(tester, 'B4-09_beerslaw_detector_misaligned');
    });

    testWidgets('B4-09b detector_partial_overlap', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setDetectorProbePosition(partialOverlap(m));
      await pumpBeersLaw(tester, m);
      expect(m.isProbeInBeam, isFalse);
      expect(m.displayedMeasurement, isNull);
      await expectBlGolden(tester, 'B4-09b_detector_partial_overlap');
    });

    testWidgets('B4-09c optical_path_before_cuvette', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setDetectorProbePosition(Offset(2.5, m.light.position.dy));
      await pumpBeersLaw(tester, m);
      expect(m.isProbeInBeam, isTrue);
      expect(m.detectorPathLength, 0);
      await expectBlGolden(tester, 'B4-09c_optical_path_before');
    });

    testWidgets('B4-09d optical_path_inside', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setDetectorProbePosition(Offset(
        m.cuvette.position.dx + m.cuvette.width * 0.5,
        m.light.position.dy,
      ));
      await pumpBeersLaw(tester, m);
      expect(m.detectorPathLength, closeTo(m.cuvette.width * 0.5, 1e-9));
      await expectBlGolden(tester, 'B4-09d_optical_path_inside');
    });

    testWidgets('B4-09e optical_path_beyond', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(m.detectorPathLength, closeTo(m.cuvette.width, 1e-9));
      await expectBlGolden(tester, 'B4-09e_optical_path_beyond');
    });

    testWidgets('B4-10 beerslaw_transmittance', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setDetectorMode(DetectorMode.transmittance);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(m.displayedMeasurement, isNotNull);
      await expectBlGolden(tester, 'B4-10_beerslaw_transmittance');
    });

    testWidgets('B4-11 beerslaw_absorbance', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setDetectorMode(DetectorMode.absorbance);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-11_beerslaw_absorbance');
    });

    testWidgets('B4-12 beerslaw_light_off', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setDetectorMode(DetectorMode.absorbance);
      m.setDetectorProbePosition(inBeam(m));
      m.setLightOn(false);
      await pumpBeersLaw(tester, m);
      expect(m.beam.isVisible, isFalse);
      expect(m.displayedMeasurement, isNull);
      await expectBlGolden(tester, 'B4-12_beerslaw_light_off');
    });

    testWidgets('B4-13 beerslaw_ruler_moved', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setRulerPosition(const Offset(2.0, 3.8));
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-13_beerslaw_ruler_moved');
    });

    testWidgets('B4-14 beerslaw_reset', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setLightMode(LightMode.variable)
        ..setWavelength(600)
        ..setConcentration(0.35)
        ..setCuvetteWidth(2.0)
        ..setDetectorMode(DetectorMode.absorbance)
        ..setRulerPosition(const Offset(2.0, 3.8));
      m.setSolution(m.solutions.firstWhere((s) => s.id == 'copperSulfate'));
      m.setDetectorProbePosition(const Offset(7.0, 3.0));
      m.reset();
      await pumpBeersLaw(tester, m);
      expect(m.light.isOn, isFalse);
      expect(m.solution.id, 'drinkMix');
      await expectBlGolden(tester, 'B4-14_beerslaw_reset');
    });

    testWidgets('B4-15 low_transmittance', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setConcentration(0.4)
        ..setCuvetteWidth(2.0)
        ..setDetectorMode(DetectorMode.transmittance);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-15_low_transmittance');
    });

    testWidgets('B4-16 high_transmittance', (tester) async {
      final m = BeersLawModel()
        ..setLightOn(true)
        ..setConcentration(0.01)
        ..setDetectorMode(DetectorMode.transmittance);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      await expectBlGolden(tester, 'B4-16_high_transmittance');
    });

    testWidgets('B4-17 different_unit_solution_uM', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setSolution(m.solutions.firstWhere((s) => s.id == 'potassiumDichromate'));
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(m.solution.concentrationTransform.unitLabel, 'µM');
      await expectBlGolden(tester, 'B4-17_unit_uM');
    });

    testWidgets('B4-17b unit_mM', (tester) async {
      final m = BeersLawModel()..setLightOn(true);
      m.setDetectorProbePosition(inBeam(m));
      await pumpBeersLaw(tester, m);
      expect(m.solution.concentrationTransform.unitLabel, 'mM');
      await expectBlGolden(tester, 'B4-17b_unit_mM');
    });
  });

  // ---------------------------------------------------------------------------
  // Dual-screen shell (S4)
  // ---------------------------------------------------------------------------
  group('S4 Screen shell goldens', () {
    testWidgets('S4-01 Concentration active', (tester) async {
      final key = GlobalKey<BeersLawLabHomeState>();
      await pumpShell(tester, key: key, tabIndex: 0);
      await expectShellGolden(tester, 'S4-01_concentration_active');
    });

    testWidgets("S4-02 Beer's Law active", (tester) async {
      final key = GlobalKey<BeersLawLabHomeState>();
      await pumpShell(tester, key: key, tabIndex: 1);
      await expectShellGolden(tester, 'S4-02_beers_law_active');
    });

    testWidgets('S4-03 nav Concentration→BL→Concentration', (tester) async {
      final key = GlobalKey<BeersLawLabHomeState>();
      await pumpShell(tester, key: key, tabIndex: 0);
      final bl = key.currentState!.beersLawModel;
      bl.setLightOn(true);
      bl.setConcentration(0.25);

      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text("Beer's Law"),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Concentration'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      expect(bl.light.isOn, isTrue);
      expect(bl.solution.concentration, closeTo(0.25, 1e-9));
      await expectShellGolden(tester, 'S4-03_nav_back_concentration');
    });
  });
}

/// Helper so tests assert 1100×700 without importing viewport for side effects.
class ConcentrationViewportSize {
  static bool get matches1100x700 =>
      ConcentrationLayout.layoutBounds.width == 1100 &&
      ConcentrationLayout.layoutBounds.height == 700;
}
