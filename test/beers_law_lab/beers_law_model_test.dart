import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/model/beers_law_constants.dart';
import 'package:kratos/beers_law_lab/model/beers_law_model.dart';
import 'package:kratos/beers_law_lab/model/concentration_transform.dart';
import 'package:kratos/beers_law_lab/model/detector_mode.dart';
import 'package:kratos/beers_law_lab/model/light_mode.dart';
import 'package:kratos/beers_law_lab/model/molar_absorptivity_data.dart';
import 'package:kratos/beers_law_lab/model/solution_in_cuvette.dart';
import 'package:kratos/color_vision/model/visible_color.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';

Offset inBeamProbe(BeersLawModel m) => Offset(
      m.cuvette.position.dx + m.cuvette.width + 0.5,
      m.light.position.dy,
    );

void main() {
  group('BeersLawModel Phase 1', () {
    late BeersLawModel m;

    setUp(() {
      m = BeersLawModel();
    });

    // BLM-01
    test('BLM-01 light default OFF', () {
      expect(m.light.isOn, isFalse);
      expect(m.beam.isVisible, isFalse);
    });

    // BLM-02 / BLM-03
    test('BLM-02/03 wavelength range and step', () {
      expect(BeersLawConstants.minWavelength, 380);
      expect(BeersLawConstants.maxWavelength, 780);
      expect(BeersLawConstants.wavelengthStep, 1);
      expect(BeersLawConstants.numberOfVisibleWavelengths, 401);
    });

    // BLM-04
    test('BLM-04 PRESET forces λ_max', () {
      expect(m.light.mode, LightMode.preset);
      expect(m.light.wavelength, m.solution.lambdaMax);
      m.setLightMode(LightMode.variable);
      m.setWavelength(450);
      expect(m.light.wavelength, 450);
      m.setLightMode(LightMode.preset);
      expect(m.light.wavelength, m.solution.lambdaMax);
      // PRESET ignores setWavelength
      m.setWavelength(600);
      expect(m.light.wavelength, m.solution.lambdaMax);
    });

    // BLM-05
    test('BLM-05 VARIABLE allows 380..780 step 1', () {
      m.setLightMode(LightMode.variable);
      m.setWavelength(380);
      expect(m.light.wavelength, 380);
      m.setWavelength(780);
      expect(m.light.wavelength, 780);
      m.setWavelength(379);
      expect(m.light.wavelength, 380);
      m.setWavelength(781);
      expect(m.light.wavelength, 780);
    });

    // BLM-06 / BLM-07
    test('BLM-06/07 eight solutions, no NaCl, λ_max', () {
      expect(m.solutions.length, 8);
      expect(
        m.solutions.any((s) => s.formula == 'NaCl' || s.id == 'sodiumChloride'),
        isFalse,
      );
      expect(m.solutions.map((s) => s.id).toList(), [
        'drinkMix',
        'cobaltIINitrate',
        'cobaltChloride',
        'potassiumDichromate',
        'potassiumChromate',
        'nickelIIChloride',
        'copperSulfate',
        'potassiumPermanganate',
      ]);
      expect(m.solutions[0].lambdaMax, 508);
      for (final s in m.solutions) {
        expect(
          s.molarAbsorptivityData.values.length,
          401,
          reason: s.id,
        );
        expect(s.lambdaMax, inInclusiveRange(380, 780));
      }
    });

    // BLM-08
    test('BLM-08 concentration ranges and defaults', () {
      final expected = <String, List<double>>{
        'drinkMix': [0, 0.400, 0.100],
        'cobaltIINitrate': [0, 0.400, 0.100],
        'cobaltChloride': [0, 0.250, 0.100],
        'potassiumDichromate': [0, 0.000500, 0.000100],
        'potassiumChromate': [0, 0.000400, 0.000100],
        'nickelIIChloride': [0, 0.350, 0.100],
        'copperSulfate': [0, 0.200, 0.100],
        'potassiumPermanganate': [0, 0.000800, 0.000100],
      };
      for (final s in m.solutions) {
        final e = expected[s.id]!;
        expect(s.concentrationMin, e[0], reason: s.id);
        expect(s.concentrationMax, e[1], reason: s.id);
        expect(s.concentrationDefault, e[2], reason: s.id);
        expect(s.concentration, e[2], reason: s.id);
      }
    });

    // BLM-09
    test('BLM-09 mM conversion', () {
      final t = ConcentrationTransform.millimolar;
      expect(t.modelToView(1.0), 1000);
      expect(t.viewToModel(1000), 1.0);
      expect(t.modelToView(0.1), closeTo(100, 1e-9));
      expect(t.viewToModel(100), closeTo(0.1, 1e-9));
      expect(m.solutions[0].displayConcentration, closeTo(100, 1e-9));
      expect(m.solutions[0].concentrationTransform.unit,
          ConcentrationUnit.millimolar);
    });

    // BLM-10
    test('BLM-10 µM conversion', () {
      final t = ConcentrationTransform.micromolar;
      expect(t.modelToView(1.0), 1000000);
      expect(t.viewToModel(1000000), 1.0);
      expect(t.modelToView(0.0001), closeTo(100, 1e-9));
      final dichromate = m.solutions.firstWhere((s) => s.id == 'potassiumDichromate');
      expect(dichromate.concentrationTransform.unit, ConcentrationUnit.micromolar);
      expect(dichromate.displayConcentration, closeTo(100, 1e-9));
      // 1000× trap: 100 µM must NOT become 100 M
      dichromate.setDisplayConcentration(100);
      expect(dichromate.concentration, closeTo(0.0001, 1e-12));
    });

    // BLM-11 / 12 / 13
    test('BLM-11/12/13 cuvette width min max default snap', () {
      expect(m.cuvette.width, 1.0);
      m.setCuvetteWidth(0.5);
      expect(m.cuvette.width, 0.5);
      m.setCuvetteWidth(2.0);
      expect(m.cuvette.width, 2.0);
      m.setCuvetteWidth(0.4);
      expect(m.cuvette.width, 0.5);
      m.setCuvetteWidth(2.1);
      expect(m.cuvette.width, 2.0);
      m.setCuvetteWidth(0.74);
      m.snapCuvetteWidth();
      expect(m.cuvette.width, closeTo(0.7, 1e-9));
      expect(m.cuvette.height, 3.0);
      expect(m.cuvette.snapInterval, 0.1);
    });

    // BLM-14
    test('BLM-14 detector bounds', () {
      expect(m.detector.probeDragBounds, BeersLawConstants.detectorProbeDragBounds);
      m.setDetectorProbePosition(const Offset(-1, -1));
      expect(m.detector.probePosition.dx, 0);
      expect(m.detector.probePosition.dy, 0);
      m.setDetectorProbePosition(const Offset(100, 100));
      expect(m.detector.probePosition.dx, 7.9);
      expect(m.detector.probePosition.dy, 5.25);
    });

    // BLM-15 / 16 / 17
    test('BLM-15/16/17 in-beam requires light + vertical enclosure + x>light', () {
      m.setLightOn(true);
      m.setDetectorProbePosition(inBeamProbe(m));
      expect(m.isProbeInBeam, isTrue);

      // light off
      m.setLightOn(false);
      expect(m.isProbeInBeam, isFalse);
      expect(m.absorbance, isNull);

      m.setLightOn(true);
      // fully above beam
      m.setDetectorProbePosition(Offset(inBeamProbe(m).dx, m.light.minY - 1));
      expect(m.isProbeInBeam, isFalse);

      // partial overlap: probe does not fully enclose beam vertically
      m.setDetectorProbePosition(
        Offset(inBeamProbe(m).dx, m.light.position.dy + 0.2),
      );
      expect(m.isProbeInBeam, isFalse);

      // left of light
      m.setDetectorProbePosition(
          Offset(m.light.position.dx - 0.1, m.light.position.dy));
      expect(m.isProbeInBeam, isFalse);

      // valid enclosure
      m.setDetectorProbePosition(inBeamProbe(m));
      expect(m.isProbeInBeam, isTrue);
    });

    // BLM-18
    test('BLM-18 detector optical path clamp', () {
      m.setLightOn(true);
      m.setCuvetteWidth(1.0);
      final y = m.light.position.dy;

      // left of cuvette → b = 0
      m.setDetectorProbePosition(Offset(m.cuvette.position.dx - 0.1, y));
      // may be in beam if x > light.x
      expect(m.detectorPathLength, 0);

      // mid cuvette
      m.setDetectorProbePosition(Offset(m.cuvette.position.dx + 0.4, y));
      expect(m.detectorPathLength, closeTo(0.4, 1e-9));

      // right of cuvette → b = width
      m.setDetectorProbePosition(Offset(m.cuvette.right + 1, y));
      expect(m.detectorPathLength, closeTo(1.0, 1e-9));

      // not in beam → null
      m.setLightOn(false);
      expect(m.detectorPathLength, isNull);
    });

    // BLM-19 / 20
    test('BLM-19/20 A=a*b*C and T=10^-A', () {
      expect(SolutionInCuvette.getAbsorbance(1, 1, 0), 0);
      expect(SolutionInCuvette.getTransmittance(0), 1);
      expect(SolutionInCuvette.getTransmittance(1), closeTo(0.1, 1e-12));
      expect(SolutionInCuvette.getTransmittance(2), closeTo(0.01, 1e-12));

      m.setLightOn(true);
      m.setDetectorProbePosition(inBeamProbe(m));
      m.setCuvetteWidth(1.0);
      // Drink mix default C=0.1, λ=508, a≈5.06, b=width for full path but detector b=width when probe past right
      final a = m.solution.molarAbsorptivityData.wavelengthToMolarAbsorptivity(508);
      expect(a, closeTo(5.06, 1e-9));
      final expectedA = a * 1.0 * 0.1;
      expect(m.absorbance, closeTo(expectedA, 1e-9));
      expect(m.transmittance, closeTo(SolutionInCuvette.getTransmittance(expectedA), 1e-12));
    });

    // BLM-21 / 22
    test('BLM-21/22 light-off and invalid detector → null (not 0)', () {
      m.setLightOn(false);
      expect(m.absorbance, isNull);
      expect(m.transmittance, isNull);
      expect(m.displayedMeasurement, isNull);

      m.setLightOn(true);
      m.setDetectorProbePosition(const Offset(0.1, 0.1));
      expect(m.absorbance, isNull);
      expect(m.transmittance, isNull);
    });

    // BLM-23 / 24 / 25
    test('BLM-23/24/25 mode switch display-only', () {
      m.setLightOn(true);
      m.setDetectorProbePosition(inBeamProbe(m));
      expect(m.detector.mode, DetectorMode.transmittance);
      final t = m.transmittance!;
      final a = m.absorbance!;
      expect(m.displayedMeasurement, closeTo(100 * t, 1e-9));

      final cBefore = m.solution.concentration;
      final wBefore = m.cuvette.width;
      final wavelengthBefore = m.light.wavelength;
      final probeBefore = m.detector.probePosition;

      m.setDetectorMode(DetectorMode.absorbance);
      expect(m.displayedMeasurement, closeTo(a, 1e-9));
      expect(m.solution.concentration, cBefore);
      expect(m.cuvette.width, wBefore);
      expect(m.light.wavelength, wavelengthBefore);
      expect(m.detector.probePosition, probeBefore);
      expect(m.transmittance, closeTo(t, 1e-12));
    });

    // BLM-26
    test('BLM-26 ruler drag and J jump; no physics side effects', () {
      expect(m.ruler.length, 2.1);
      expect(m.ruler.position, BeersLawConstants.rulerPosition);
      final c0 = m.solution.concentration;
      m.setRulerPosition(const Offset(2, 2));
      expect(m.ruler.position, const Offset(2, 2));
      expect(m.solution.concentration, c0);
      expect(m.cuvette.width, 1.0);

      m.jumpRuler();
      expect(m.rulerJumpPositionIndex, 1);
      expect(m.ruler.position, m.rulerJumpPositions[1].position);
      m.jumpRuler();
      expect(m.rulerJumpPositionIndex, 2);
      m.jumpRuler();
      expect(m.rulerJumpPositionIndex, 0);
    });

    // BLM-27
    test('BLM-27 reset restores core state; preserves jump indices and snapInterval', () {
      m.setLightOn(true);
      m.setLightMode(LightMode.variable);
      m.setWavelength(600);
      m.setSolution(m.solutions[3]);
      m.setConcentration(0.0002);
      m.setCuvetteWidth(1.5);
      m.cuvette.snapInterval = 0.2;
      m.setDetectorProbePosition(const Offset(1, 1));
      m.setDetectorMode(DetectorMode.absorbance);
      m.setRulerPosition(const Offset(3, 3));
      m.detectorProbeJumpPositionIndex = 2;
      m.rulerJumpPositionIndex = 1;

      m.reset();

      expect(m.solution.id, 'drinkMix');
      expect(m.solution.concentration, 0.100);
      expect(m.light.isOn, isFalse);
      expect(m.light.mode, LightMode.preset);
      expect(m.light.wavelength, m.solution.lambdaMax);
      expect(m.cuvette.width, 1.0);
      expect(m.cuvette.snapInterval, 0.2); // NOT reset
      expect(m.detector.probePosition, BeersLawConstants.detectorProbePosition);
      expect(m.detector.mode, DetectorMode.transmittance);
      expect(m.ruler.position, BeersLawConstants.rulerPosition);
      expect(m.detectorProbeJumpPositionIndex, 2); // NOT reset
      expect(m.rulerJumpPositionIndex, 1); // NOT reset
      // other solutions reset
      expect(m.solutions[3].concentration, m.solutions[3].concentrationDefault);
    });

    // BLM-28
    test('BLM-28 solution switch sets λ_max and units', () {
      m.setSolution(m.solutions[6]); // CuSO4
      expect(m.light.wavelength, m.solutions[6].lambdaMax);
      expect(m.solutions[6].lambdaMax, 780);
      expect(m.solution.concentrationTransform.unit, ConcentrationUnit.millimolar);

      m.setSolution(m.solutions[7]); // KMnO4
      expect(m.light.wavelength, m.solutions[7].lambdaMax);
      expect(m.solution.concentrationTransform.unit, ConcentrationUnit.micromolar);
    });

    // BLM-29
    test('BLM-29 wavelength→color via VisibleColor', () {
      final c508 = VisibleColor.wavelengthToColor(508);
      expect(c508.a, 1.0);
      // green-ish for ~508 nm
      expect(c508.g, greaterThan(c508.b));
      m.setLightMode(LightMode.variable);
      m.setWavelength(508);
      expect(m.beam.wavelengthColor, c508);
    });

    // BLM-30
    test('BLM-30 molar absorptivity lookup', () {
      final data = MolarAbsorptivityData.drinkMix;
      expect(data.values.length, 401);
      expect(data.lambdaMax, 508);
      expect(data.wavelengthToMolarAbsorptivity(508), closeTo(5.06, 1e-9));
      expect(data.wavelengthToMolarAbsorptivity(380), data.values[0]);
      expect(data.wavelengthToMolarAbsorptivity(780), data.values[400]);
    });

    test('detector jump landmarks', () {
      m.jumpDetectorProbe();
      expect(m.detectorProbeJumpPositionIndex, 1);
      expect(m.detector.probePosition.dy, m.light.position.dy);
    });

    test('C=0 with light+aligned → A=0 T=1', () {
      m.setLightOn(true);
      m.setDetectorProbePosition(inBeamProbe(m));
      m.setConcentration(0);
      expect(m.absorbance, 0);
      expect(m.transmittance, 1);
    });

    test('fluid color water at C=0', () {
      m.setConcentration(0);
      expect(m.solution.fluidColor, BeersLawConstants.waterColor);
    });

    test('mode switch does not mutate when light off', () {
      m.setDetectorMode(DetectorMode.absorbance);
      expect(m.displayedMeasurement, isNull);
      m.setDetectorMode(DetectorMode.transmittance);
      expect(m.displayedMeasurement, isNull);
    });
  });

  group('Screen isolation', () {
    test('BeersLawModel ≠ ConcentrationModel; no shared state', () {
      final bl = BeersLawModel();
      final conc = ConcentrationModel();
      final v0 = conc.solution.volume;
      final n0 = conc.solution.soluteMoles;

      bl.setConcentration(0.2);
      bl.setLightOn(true);
      bl.setCuvetteWidth(1.8);

      expect(conc.solution.volume, v0);
      expect(conc.solution.soluteMoles, n0);
      expect(identical(bl.runtimeType, conc.runtimeType), isFalse);

      // Concentration step still works independently
      conc.setSolventFlowRate(ConcentrationConstants.faucetMaxFlowRate);
      conc.step(0.1);
      expect(conc.solution.volume, greaterThan(v0));
      expect(bl.solution.concentration, 0.2);
    });
  });

  group('Existing Concentration contract freeze', () {
    test('C = min(C_sat, n/V); precipitate; drain; evaporate', () {
      final conc = ConcentrationModel();
      expect(ConcentrationConstants.solutionVolumeDefault, 0.5);
      expect(ConcentrationConstants.soluteAmountMax, 7);
      expect(ConcentrationConstants.shakerMaxDispensingRate, 0.2);

      conc.solution.setSoluteMoles(1);
      conc.solution.setVolume(0.5);
      final csat = conc.solution.saturatedConcentration;
      expect(conc.solution.concentration, lessThanOrEqualTo(csat));
      expect(
        conc.solution.concentration,
        closeTo((1 / 0.5).clamp(0, csat), 1e-9),
      );

      // precipitate = max(0, n - V*Csat)
      final expectedP = (1 - 0.5 * csat).clamp(0.0, double.infinity);
      expect(conc.solution.precipitateMoles, closeTo(expectedP, 1e-9));
    });
  });
}
