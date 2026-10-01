import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

/// Phase 6 — Experiment multi-step behavioral acceptance (model-level real user path).
void main() {
  group('Experiment multi-step path', () {
    test('parameter changes → hits → histogram → snapshot → delete → Reset All', () {
      final model = ExperimentModel(random: SeededQwiRandom(101));
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.scene.detectionMode, DetectorMode.intensity);

      // Single slit (top covered → bottom open)
      model.scene.slitConfiguration = SlitConfiguration.leftCovered;
      model.scene.onPhysicsParameterChanged();
      expect(model.scene.hits.length, 0);

      // Experiment UI uses fixed per-source slitWidth; Fraunhofer backend must
      // still respond to slit-width changes (physics consistency).
      final slitW = QwiUnits.mmToM(model.scene.defaults.slitWidthMm);
      final iNarrow = FraunhoferSolver.getExactDetectorIntensity(
        FraunhoferOptions(
          positionOnScreenM: 0.002,
          effectiveWavelengthM: 650e-9,
          screenDistanceM: model.scene.screenDistanceM,
          slitWidthM: slitW * 0.7,
          slitSeparationM: QwiUnits.mmToM(model.scene.slitSeparationMm),
          slitSetting: SlitConfiguration.leftCovered,
        ),
      );
      final iWider = FraunhoferSolver.getExactDetectorIntensity(
        FraunhoferOptions(
          positionOnScreenM: 0.002,
          effectiveWavelengthM: 650e-9,
          screenDistanceM: model.scene.screenDistanceM,
          slitWidthM: slitW,
          slitSeparationM: QwiUnits.mmToM(model.scene.slitSeparationMm),
          slitSetting: SlitConfiguration.leftCovered,
        ),
      );
      expect(iNarrow == iWider, isFalse);

      model.scene.wavelengthNm = 500;
      model.scene.onPhysicsParameterChanged();
      final i500 = model.scene.intensityAtPhysicalX(0.004);
      model.scene.wavelengthNm = 650;
      model.scene.onPhysicsParameterChanged();
      final i650 = model.scene.intensityAtPhysicalX(0.004);
      expect(i500 == i650, isFalse);

      model.scene.slitConfiguration = SlitConfiguration.bothOpen;
      model.scene.onPhysicsParameterChanged();
      final sepA = model.scene.slitSeparationMm;
      final fringeA = model.scene.intensityAtPhysicalX(0.003);
      model.scene.slitSeparationMm = sepA * 1.4;
      model.scene.onPhysicsParameterChanged();
      final fringeB = model.scene.intensityAtPhysicalX(0.003);
      expect(fringeA == fringeB, isFalse);

      final dist0 = model.scene.screenDistanceM;
      model.scene.screenDistanceM = dist0 * 1.2;
      model.scene.onPhysicsParameterChanged();
      expect(model.scene.screenDistanceM, isNot(dist0));

      // Hits accumulate
      model.scene.detectionMode = DetectorMode.hits;
      model.scene.setEmitting(true);
      for (var i = 0; i < 200; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, greaterThan(10));
      final hist = HitsHistogramData.fromHits(model.scene.hits.hits);
      expect(hist.binCount, 100);
      expect(hist.bins.reduce((a, b) => a + b), model.scene.hits.length);

      expect(model.scene.takeSnapshot(), isTrue);
      model.scene.wavelengthNm = 420;
      model.scene.onPhysicsParameterChanged();
      expect(model.scene.takeSnapshot(), isTrue);
      expect(model.scene.snapshots.length, 2);
      model.scene.snapshots.deleteAt(0);
      expect(model.scene.snapshots.length, 1);

      model.reset();
      expect(model.scene.wavelengthNm, 650);
      expect(model.scene.hits.length, 0);
      expect(model.scene.snapshots.length, 0);
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.scene.detectionMode, DetectorMode.intensity);
      expect(model.clock.isPlaying, isTrue);
      expect(model.clock.speed, TimeSpeed.normal);
    });

    test('statistics: 1000 hits histogram non-degenerate and deterministic', () {
      List<int> run(int seed) {
        final model = ExperimentModel(random: SeededQwiRandom(seed));
        model.scene.detectionMode = DetectorMode.hits;
        model.scene.setEmitting(true);
        for (var i = 0; i < 20000 && model.scene.hits.length < 1000; i++) {
          model.step(1 / 60);
        }
        expect(model.scene.hits.length, 1000);
        return HitsHistogramData.fromHits(model.scene.hits.hits).bins;
      }

      final a = run(77);
      final b = run(77);
      expect(a, b);
      expect(a.any((c) => c > 0), isTrue);
      // Not all mass in a single bin (would indicate mapping collapse).
      expect(a.where((c) => c > 0).length, greaterThan(3));
    });

    test('clearScreen preserves wavelength and snapshots; Reset All clears snapshots', () {
      final model = ExperimentModel(random: SeededQwiRandom(12));
      model.scene.wavelengthNm = 480;
      model.scene.detectionMode = DetectorMode.hits;
      model.scene.setEmitting(true);
      for (var i = 0; i < 80; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.takeSnapshot(), isTrue);
      model.scene.clearScreen();
      expect(model.scene.hits.length, 0);
      expect(model.scene.wavelengthNm, 480);
      expect(model.scene.snapshots.length, 1);
      model.reset();
      expect(model.scene.snapshots.length, 0);
      expect(model.scene.wavelengthNm, 650);
    });

    test('repeated Reset stabilizes defaults', () {
      final model = ExperimentModel(random: SeededQwiRandom(3));
      for (var r = 0; r < 5; r++) {
        model.scene.wavelengthNm = 400 + r * 10;
        model.scene.detectionMode = DetectorMode.hits;
        model.scene.setEmitting(true);
        model.step(1 / 60);
        model.scene.takeSnapshot();
        model.reset();
        expect(model.scene.wavelengthNm, 650);
        expect(model.scene.hits.length, 0);
        expect(model.scene.snapshots.length, 0);
        expect(model.scene.isEmitting, isFalse);
      }
    });

    test('zoom / ruler do not change Fraunhofer intensity', () {
      final model = ExperimentModel(random: SeededQwiRandom(4));
      final i0 = model.scene.intensityAtPhysicalX(0);
      model.graphZoom.setLevel(6);
      model.ruler.visible = true;
      model.ruler.positionX = 10;
      model.setDetectorScreenScaleIndex(2);
      expect(model.scene.intensityAtPhysicalX(0), i0);
      expect(model.scene.wavelengthNm, 650);
    });
  });
}
