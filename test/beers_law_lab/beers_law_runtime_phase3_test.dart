import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/model/beers_law_constants.dart';
import 'package:kratos/beers_law_lab/model/beers_law_model.dart';
import 'package:kratos/beers_law_lab/model/concentration_transform.dart';
import 'package:kratos/beers_law_lab/model/detector_mode.dart';
import 'package:kratos/beers_law_lab/model/light_mode.dart';
import 'package:kratos/beers_law_lab/model/solution_in_cuvette.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/beers_law_lab/view/beers_law_screen.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/probe_region.dart';
import 'package:kratos/concentration/model/solute_form.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

/// Phase 3 鈥?Behavioral / Runtime / Accessibility acceptance (R3-01..R3-30).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('R3 Concentration runtime', () {
    late ConcentrationModel c;

    setUp(() => c = ConcentrationModel());

    // R3-01
    test('R3-01 faucet OFF unchanged; ON increases volume via step(dt)', () {
      final v0 = c.solution.volume;
      c.step(0.2);
      expect(c.solution.volume, v0);

      c.setSolventFlowRate(ConcentrationConstants.faucetMaxFlowRate);
      c.step(0.1);
      expect(c.solution.volume, closeTo(v0 + 0.025, 1e-9));
      expect(ConcentrationConstants.faucetMaxFlowRate, 0.25);

      // clamp at 1 L
      c.setVolumeDirect(0.99);
      c.setSolventFlowRate(0.25);
      c.step(1.0);
      expect(c.solution.volume, 1.0);
    });

    // R3-02
    test('R3-02 drain removes volume + proportional solute; C unchanged', () {
      c.addSoluteAmount(0.5);
      c.setVolumeDirect(0.5);
      final conc0 = c.solution.concentration;
      final n0 = c.solution.soluteMoles;

      c.setDrainFlowRate(0.25);
      c.step(0.1); // 螖V = 0.025
      final dV = 0.025;
      expect(c.solution.volume, closeTo(0.5 - dV, 1e-9));
      expect(c.solution.soluteMoles, closeTo(n0 - conc0 * dV, 1e-9));
      expect(c.solution.concentration, closeTo(conc0, 1e-9));
    });

    // R3-03
    test('R3-03 evaporation: volume鈫?moles fixed 鈫?C rises', () {
      c.addSoluteAmount(0.2);
      c.setVolumeDirect(0.5);
      final n0 = c.solution.soluteMoles;
      final c0 = c.solution.concentration;

      c.setEvaporationRate(0.25);
      c.step(0.1);
      expect(c.solution.volume, closeTo(0.475, 1e-9));
      expect(c.solution.soluteMoles, n0);
      expect(c.solution.concentration, greaterThan(c0));
    });

    // R3-04 / R3-05
    test('R3-04/05 shaker motion dispenses; stationary does not', () {
      c.setSoluteForm(SoluteForm.solid);
      final n0 = c.solution.soluteMoles;

      // Stationary: step without moving 鈫?no dispense
      for (var i = 0; i < 5; i++) {
        c.step(1 / 60);
      }
      expect(c.solution.soluteMoles, n0);
      expect(c.shaker.dispensingRate, 0);

      // Move shaker 鈫?dispensingRate max while moving
      c.setShakerPosition(
        c.shaker.position + const Offset(10, 0),
      );
      c.step(1 / 60);
      expect(c.shaker.dispensingRate, ConcentrationConstants.shakerMaxDispensingRate);
      expect(
        ConcentrationConstants.shakerMaxDispensingRate,
        0.2,
      );

      // Advance particles until dissolve
      for (var i = 0; i < 120; i++) {
        if (i % 10 == 0) {
          c.setShakerPosition(c.shaker.position + const Offset(2, 0));
        }
        c.step(1 / 60);
      }
      expect(c.solution.soluteMoles, greaterThan(n0));
    });

    test('R3-05 particle dissolve does not double-count forever', () {
      c.setSoluteForm(SoluteForm.solid);
      // Source order: shaker.step() updates rate AFTER particle spawn,
      // so particles appear on the frame after motion.
      c.setShakerPosition(c.shaker.position + const Offset(5, 0));
      c.step(1 / 60); // rate becomes max
      c.step(1 / 60); // spawn with previous-frame rate
      final spawned = c.shakerParticles.count;
      expect(spawned, greaterThan(0));

      // Let them fall/dissolve without more dispensing
      for (var i = 0; i < 300; i++) {
        c.step(1 / 60);
      }
      expect(c.shakerParticles.count, 0);
      expect(c.solution.soluteMoles, greaterThan(0));
      expect(c.solution.soluteMoles, lessThanOrEqualTo(7));
    });

    // Dropper
    test('R3-dropper continuous stock add: 螖n = C_stock路螖V', () {
      c.setSoluteForm(SoluteForm.solution);
      final stock = c.solute.stockSolutionConcentration;
      final v0 = c.solution.volume;
      final n0 = c.solution.soluteMoles;

      c.setDropperDispensing(true);
      c.step(0.1); // 螖V = 0.05 * 0.1 = 0.005
      expect(c.solution.volume, closeTo(v0 + 0.005, 1e-9));
      expect(
        c.solution.soluteMoles,
        closeTo(n0 + stock * 0.005, 1e-9),
      );

      c.setDropperDispensing(false);
      final n1 = c.solution.soluteMoles;
      c.step(0.1);
      expect(c.solution.soluteMoles, n1);
    });

    // R3-06
    test('R3-06 probe regions: solution / water / stock / none', () {
      c.addSoluteAmount(0.3);
      c.setVolumeDirect(0.5);

      c.setProbeRegion(ProbeRegion.solution);
      expect(c.meter.value, closeTo(c.solution.concentration, 1e-9));

      c.setProbeRegion(ProbeRegion.waterStream);
      expect(c.meter.value, 0);

      c.setProbeRegion(ProbeRegion.stockSolution);
      expect(c.meter.value, c.solute.stockSolutionConcentration);

      c.setProbeRegion(ProbeRegion.none);
      expect(c.meter.value, isNull);
    });

    // R3-07
    test('R3-07 saturation: C capped at C_sat; precipitate > 0', () {
      final csat = c.solute.saturatedConcentration;
      c.setVolumeDirect(0.5);
      c.addSoluteAmount(csat * 0.5 + 1.0); // oversaturated
      expect(c.solution.concentration, closeTo(csat, 1e-9));
      expect(c.solution.concentration, lessThanOrEqualTo(csat));
      expect(c.solution.precipitateMoles, greaterThan(0));
      c.solution.updateIsSaturated();
      expect(c.solution.isSaturated, isTrue);
    });

    // R3-08
    test('R3-08 remove solute clears moles; volume unchanged', () {
      c.addSoluteAmount(1);
      c.setVolumeDirect(0.5);
      c.removeSolute();
      expect(c.solution.soluteMoles, 0);
      expect(c.solution.volume, 0.5);
      expect(c.shakerParticles.count, 0);
    });

    // R3-09
    test('R3-09 concentration reset restores defaults', () {
      c.setSoluteForm(SoluteForm.solution);
      c.addSoluteAmount(2);
      c.setVolumeDirect(0.8);
      c.setSolventFlowRate(0.1);
      c.setDrainFlowRate(0.1);
      c.setEvaporationRate(0.1);
      c.setProbeRegion(ProbeRegion.solution);
      c.setShakerPosition(const Offset(300, 100));
      c.jumpProbeToNext();

      c.reset();

      expect(c.solution.volume, ConcentrationConstants.solutionVolumeDefault);
      expect(c.solution.soluteMoles, 0);
      expect(c.soluteForm, SoluteForm.solid);
      expect(c.solventFaucet.flowRate, 0);
      expect(c.drainFaucet.flowRate, 0);
      expect(c.evaporator.evaporationRate, 0);
      expect(c.meter.value, isNull);
      expect(c.meter.probePosition, ConcentrationConstants.probeInitialPosition);
      expect(c.shakerParticles.count, 0);
    });
  });

  group('R3 Beers Law reactive runtime', () {
    late BeersLawModel m;

    setUp(() => m = BeersLawModel());

    Offset inBeam() => Offset(
          m.cuvette.position.dx + m.cuvette.width + 0.5,
          m.light.position.dy,
        );

    // R3-10
    test('R3-10 light OFF: beam hidden, A/T null; ON: beam visible', () {
      expect(m.light.isOn, isFalse);
      expect(m.beam.isVisible, isFalse);
      expect(m.absorbance, isNull);
      expect(m.displayedMeasurement, isNull);

      // Default probe is already beam-aligned; move out before ON check.
      m.setDetectorProbePosition(
        Offset(m.detector.probePosition.dx, 0.2),
      );
      m.setLightOn(true);
      expect(m.beam.isVisible, isTrue);
      expect(m.absorbance, isNull);

      m.setDetectorProbePosition(inBeam());
      expect(m.absorbance, isNotNull);
    });

    // R3-11 / R3-12
    test('R3-11/12 wavelength + PRESET/VARIABLE reactive', () {
      m.setLightMode(LightMode.variable);
      m.setWavelength(450);
      expect(m.light.wavelength, 450);
      final a450 = m.solution.molarAbsorptivityData
          .wavelengthToMolarAbsorptivity(450);

      m.setLightOn(true);
      m.setDetectorProbePosition(inBeam());
      final a1 = m.absorbance!;

      m.setWavelength(600);
      expect(m.light.wavelength, 600);
      expect(m.absorbance, isNot(a1)); // a(位) changed 鈫?A changed

      m.setLightMode(LightMode.preset);
      expect(m.light.wavelength, m.solution.lambdaMax);
      m.setWavelength(400); // ignored in PRESET
      expect(m.light.wavelength, m.solution.lambdaMax);
      expect(a450, greaterThan(0));
    });

    // R3-13
    test('R3-13 all 8 solutions switch: 位max, unit, range; no NaCl', () {
      expect(m.solutions.length, 8);
      expect(m.solutions.any((s) => s.formula == 'NaCl'), isFalse);
      for (final s in m.solutions) {
        m.setSolution(s);
        expect(m.solution.id, s.id);
        expect(m.light.wavelength, s.lambdaMax);
        expect(s.concentrationTransform.scale, anyOf(1000, 1000000));
        expect(s.molarAbsorptivityData.values.length, 401);
      }
    });

    // R3-14
    test('R3-14 unit conversion mM / 碌M no 1000脳 error', () {
      final mm = ConcentrationTransform.millimolar;
      final um = ConcentrationTransform.micromolar;
      expect(mm.modelToView(1), 1000);
      expect(mm.viewToModel(1000), 1);
      expect(mm.modelToView(0.1), closeTo(100, 1e-12));
      expect(um.modelToView(1), 1000000);
      expect(um.viewToModel(100), closeTo(0.0001, 1e-12));

      final dichromate =
          m.solutions.firstWhere((s) => s.id == 'potassiumDichromate');
      m.setSolution(dichromate);
      m.setDisplayConcentration(100);
      expect(m.solution.concentration, closeTo(0.0001, 1e-12));
    });

    // R3-15
    test('R3-15 concentration control updates A/T/color immediately', () {
      m.setLightOn(true);
      m.setDetectorProbePosition(inBeam());
      m.setConcentration(0.1);
      final a1 = m.absorbance!;
      final t1 = m.transmittance!;
      final color1 = m.solution.fluidColor;

      m.setConcentration(0.3);
      expect(m.absorbance!, greaterThan(a1));
      expect(m.transmittance!, lessThan(t1));
      expect(m.solution.fluidColor, isNot(color1));
    });

    // R3-16
    test('R3-16 cuvette width: beam full-width vs detector clamp path', () {
      m.setLightOn(true);
      m.setCuvetteWidth(1.5);
      m.snapCuvetteWidth();
      expect(m.cuvette.width, closeTo(1.5, 1e-9));

      // Detector mid-cuvette 鈫?b = probe.x - cuvette.x
      m.setDetectorProbePosition(
        Offset(m.cuvette.position.dx + 0.6, m.light.position.dy),
      );
      expect(m.detectorPathLength, closeTo(0.6, 1e-9));
      expect(m.detectorPathLength, isNot(m.cuvette.width));

      // Past right 鈫?b = width
      m.setDetectorProbePosition(
        Offset(m.cuvette.right + 1, m.light.position.dy),
      );
      expect(m.detectorPathLength, closeTo(m.cuvette.width, 1e-9));

      // Beam viz uses full width transmittance (solutionInCuvette)
      expect(m.solutionInCuvette.absorbance, isNotNull);
    });

    // R3-17 / R3-18
    test('R3-17/18 detector drag + in-beam enclosure rule', () {
      m.setLightOn(true);
      m.setDetectorProbePosition(inBeam());
      expect(m.isProbeInBeam, isTrue);

      m.setDetectorProbePosition(
        Offset(inBeam().dx, m.light.position.dy + 0.25),
      );
      expect(m.isProbeInBeam, isFalse);

      m.setDetectorProbePosition(
        Offset(m.light.position.dx - 0.2, m.light.position.dy),
      );
      expect(m.isProbeInBeam, isFalse);
    });

    // R3-19
    test('R3-19 optical path clamp cases', () {
      m.setLightOn(true);
      m.setCuvetteWidth(1.0);
      final y = m.light.position.dy;

      m.setDetectorProbePosition(Offset(m.cuvette.position.dx - 0.2, y));
      expect(m.detectorPathLength, 0);

      m.setDetectorProbePosition(Offset(m.cuvette.position.dx, y));
      expect(m.detectorPathLength, 0);

      m.setDetectorProbePosition(Offset(m.cuvette.position.dx + 0.5, y));
      expect(m.detectorPathLength, closeTo(0.5, 1e-9));

      m.setDetectorProbePosition(Offset(m.cuvette.right, y));
      expect(m.detectorPathLength, closeTo(1.0, 1e-9));

      m.setDetectorProbePosition(Offset(m.cuvette.right + 2, y));
      expect(m.detectorPathLength, closeTo(1.0, 1e-9));
    });

    // R3-20
    test('R3-20 null reading never becomes 0 or 100%', () {
      m.setLightOn(false);
      expect(m.absorbance, isNull);
      expect(m.transmittance, isNull);
      expect(m.displayedMeasurement, isNull);

      m.setLightOn(true);
      m.setDetectorProbePosition(const Offset(0.5, 0.5));
      expect(m.displayedMeasurement, isNull);
    });

    // R3-21
    test('R3-21 T/A mode switch: display only; physics frozen', () {
      m.setLightOn(true);
      m.setDetectorProbePosition(inBeam());
      final a = m.absorbance!;
      final t = m.transmittance!;
      final c0 = m.solution.concentration;
      final w0 = m.cuvette.width;
      final lambda0 = m.light.wavelength;

      expect(m.displayedMeasurement, closeTo(100 * t, 1e-9));
      m.setDetectorMode(DetectorMode.absorbance);
      expect(m.displayedMeasurement, closeTo(a, 1e-9));
      expect(m.solution.concentration, c0);
      expect(m.cuvette.width, w0);
      expect(m.light.wavelength, lambda0);
      expect(m.absorbance, closeTo(a, 1e-12));
      expect(m.transmittance, closeTo(t, 1e-12));

      // Formatter decimals
      expect(BeersLawConstants.decimalPlacesTransmittance, 2);
      expect(BeersLawConstants.decimalPlacesAbsorbance, 2);
      expect(SolutionInCuvette.getTransmittance(1), closeTo(0.1, 1e-12));
    });

    // R3-22
    test('R3-22 ruler move does not mutate physics', () {
      final c0 = m.solution.concentration;
      final w0 = m.cuvette.width;
      final p0 = m.detector.probePosition;
      m.setRulerPosition(const Offset(2, 2));
      expect(m.ruler.position, const Offset(2, 2));
      expect(m.solution.concentration, c0);
      expect(m.cuvette.width, w0);
      expect(m.detector.probePosition, p0);
      m.jumpRuler();
      expect(m.solution.concentration, c0);
    });

    // R3-23
    test('R3-23 Beers Law reset; jump indices / snapInterval preserved', () {
      m.setLightOn(true);
      m.setLightMode(LightMode.variable);
      m.setWavelength(600);
      m.setSolution(m.solutions[2]);
      m.setConcentration(0.2);
      m.setCuvetteWidth(1.7);
      m.cuvette.snapInterval = 0.2;
      m.setDetectorMode(DetectorMode.absorbance);
      m.setDetectorProbePosition(const Offset(1, 1));
      m.setRulerPosition(const Offset(3, 3));
      m.detectorProbeJumpPositionIndex = 2;
      m.rulerJumpPositionIndex = 1;

      m.reset();

      expect(m.solution.id, 'drinkMix');
      expect(m.solution.concentration, 0.100);
      expect(m.light.isOn, isFalse);
      expect(m.light.mode, LightMode.preset);
      expect(m.cuvette.width, 1.0);
      expect(m.cuvette.snapInterval, 0.2);
      expect(m.detectorProbeJumpPositionIndex, 2);
      expect(m.rulerJumpPositionIndex, 1);
    });

    test('reactive: concentration change updates without clock tick', () {
      var notifies = 0;
      m.addListener(() => notifies++);
      m.setConcentration(0.2);
      expect(notifies, 1);
      m.setLightOn(true);
      expect(notifies, 2);
    });
  });

  group('R3 Screen shell / lifecycle', () {
    // R3-24 / R3-25 / R3-26
    testWidgets('R3-24/25/26 switch 脳10 preserves isolation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final homeKey = GlobalKey<BeersLawLabHomeState>();
      await tester.pumpWidget(MaterialApp(home: BeersLawLabHome(key: homeKey)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final state = homeKey.currentState!;
      final conc = state.concentrationModel;
      final bl = state.beersLawModel;

      conc.addSoluteAmount(0.4);
      conc.setVolumeDirect(0.7);
      bl.setConcentration(0.22);
      bl.setLightOn(true);
      bl.setCuvetteWidth(1.4);

      Finder tab(String label) => find.descendant(
            of: find.byType(TabBar),
            matching: find.text(label),
          );

      for (var i = 0; i < 10; i++) {
        await tester.tap(tab("Beer's Law"));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(tab('Concentration'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(identical(state.concentrationModel, conc), isTrue);
      expect(identical(state.beersLawModel, bl), isTrue);
      expect(conc.solution.volume, closeTo(0.7, 1e-9));
      expect(conc.solution.soluteMoles, closeTo(0.4, 1e-9));
      expect(bl.solution.concentration, closeTo(0.22, 1e-9));
      expect(bl.light.isOn, isTrue);
      expect(bl.cuvette.width, closeTo(1.4, 1e-9));
    });

    // R3-29
    testWidgets('R3-29 Reset All is per-screen, not global', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final homeKey = GlobalKey<BeersLawLabHomeState>();
      await tester.pumpWidget(MaterialApp(home: BeersLawLabHome(key: homeKey)));
      await tester.pump();

      final conc = homeKey.currentState!.concentrationModel;
      final bl = homeKey.currentState!.beersLawModel;
      conc.addSoluteAmount(0.5);
      conc.setVolumeDirect(0.8);
      bl.setLightOn(true);
      bl.setConcentration(0.3);

      // Switch to Beer's Law and reset that screen only
      await tester.tap(find.descendant(
        of: find.byType(TabBar),
        matching: find.text("Beer's Law"),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byKey(const Key('beers_law_reset_all')));
      await tester.pump();

      expect(bl.light.isOn, isFalse);
      expect(bl.solution.concentration, 0.100);
      // Concentration untouched
      expect(conc.solution.soluteMoles, closeTo(0.5, 1e-9));
      expect(conc.solution.volume, closeTo(0.8, 1e-9));
    });

    // R3-27 / R3-28
    testWidgets('R3-27/28 dispose + reopen: no double clock / fresh models',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final key1 = GlobalKey<BeersLawLabHomeState>();
      await tester.pumpWidget(MaterialApp(home: BeersLawLabHome(key: key1)));
      await tester.pump();
      final c1 = key1.currentState!.concentrationModel;
      c1.setSolventFlowRate(0.25);
      c1.step(0.1);
      final vAfter = c1.solution.volume;

      // Tear down product
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      // Reopen 鈥?new models at defaults
      final key2 = GlobalKey<BeersLawLabHomeState>();
      await tester.pumpWidget(MaterialApp(home: BeersLawLabHome(key: key2)));
      await tester.pump();
      final c2 = key2.currentState!.concentrationModel;
      final bl2 = key2.currentState!.beersLawModel;

      expect(identical(c1, c2), isFalse);
      expect(c2.solution.volume, ConcentrationConstants.solutionVolumeDefault);
      expect(c2.solventFaucet.flowRate, 0);
      expect(bl2.light.isOn, isFalse);
      expect(vAfter, greaterThan(ConcentrationConstants.solutionVolumeDefault));
    });

    // R3-30
    test('R3-30 rapid interaction: shaker + faucet + BL reactive burst', () {
      final conc = ConcentrationModel();
      final bl = BeersLawModel();

      for (var i = 0; i < 40; i++) {
        conc.setSolventFlowRate(0.25);
        conc.setShakerPosition(conc.shaker.position + Offset(i.isEven ? 3 : -3, 0));
        conc.step(1 / 60);
        bl.setLightOn(i.isEven);
        bl.setConcentration(0.05 + (i % 5) * 0.02);
        bl.setCuvetteWidth(0.5 + (i % 10) * 0.1);
      }
      expect(conc.solution.volume, lessThanOrEqualTo(1.0));
      expect(conc.solution.soluteMoles, lessThanOrEqualTo(7));
      expect(bl.solution.concentration, inInclusiveRange(0, 0.4));
      expect(bl.cuvette.width, inInclusiveRange(0.5, 2.0));
    });

    testWidgets('ConcentrationScreen clock stops after dispose', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final model = ConcentrationModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConcentrationScreen(model: model, showAppBar: false),
          ),
        ),
      );
      await tester.pump();
      model.setSolventFlowRate(0.25);
      await tester.pump(const Duration(milliseconds: 200));
      final mid = model.solution.volume;

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();
      // External step after dispose of screen clock should still work on model,
      // but clock must not keep stepping 鈥?wait without calling step.
      final frozen = model.solution.volume;
      await tester.pump(const Duration(milliseconds: 300));
      expect(model.solution.volume, frozen);
      expect(mid, greaterThanOrEqualTo(ConcentrationConstants.solutionVolumeDefault));
    });

    testWidgets('BeersLawScreen Semantics labels present (a11y partial)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final model = BeersLawModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeersLawScreen(model: model, showAppBar: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Light'), findsOneWidget);
      expect(find.bySemanticsLabel('Detector probe'), findsOneWidget);
      expect(find.bySemanticsLabel('Ruler'), findsOneWidget);
      expect(find.bySemanticsLabel('Cuvette width'), findsOneWidget);
    });
  });
}

