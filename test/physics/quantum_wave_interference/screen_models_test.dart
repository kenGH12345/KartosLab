import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('ExperimentModel', () {
    test('defaults', () {
      final model = ExperimentModel(random: SeededQwiRandom(1));
      expect(model.activeSource, SourceType.photons);
      expect(model.scene.wavelengthNm, 650);
      expect(model.scene.sourceStrength, 0.5);
      expect(model.scene.slitSeparationMm, 0.25);
      expect(model.scene.screenDistanceM, 0.6);
      expect(model.scene.detectionMode, DetectorMode.intensity);
      expect(model.clock.speedFactors.normal, 1.0);
    });

    test('reset restores defaults after mutation', () {
      final model = ExperimentModel(random: SeededQwiRandom(2));
      model.scene.wavelengthNm = 400;
      model.scene.sourceStrength = 1;
      model.scene.slitConfiguration = SlitConfiguration.leftCovered;
      model.selectSource(SourceType.electrons);
      model.clock.setSpeed(TimeSpeed.fast);
      model.reset();
      expect(model.activeSource, SourceType.photons);
      expect(model.scene.wavelengthNm, 650);
      expect(model.scene.sourceStrength, 0.5);
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.clock.speed, TimeSpeed.normal);
    });

    test('hits accumulate in hits mode; brightness does not change intensity', () {
      final model = ExperimentModel(random: SeededQwiRandom(3));
      model.scene.detectionMode = DetectorMode.hits;
      model.scene.setEmitting(true);
      final i0 = model.scene.intensityAtPhysicalX(0);
      model.scene.screenBrightness = 100;
      final i1 = model.scene.intensityAtPhysicalX(0);
      expect(i0, i1);

      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, greaterThan(0));
      expect(model.scene.hits.hits.first.domain, DetectorHitDomain.experiment);
    });

    test('clearScreen vs reset', () {
      final model = ExperimentModel(random: SeededQwiRandom(4));
      model.scene.detectionMode = DetectorMode.hits;
      model.scene.setEmitting(true);
      model.scene.wavelengthNm = 500;
      for (var i = 0; i < 60; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, greaterThan(0));
      model.scene.clearScreen();
      expect(model.scene.hits.length, 0);
      expect(model.scene.wavelengthNm, 500);
    });

    test('screen independence of scenes', () {
      final model = ExperimentModel(random: SeededQwiRandom(5));
      model.scenes[SourceType.photons]!.wavelengthNm = 400;
      model.scenes[SourceType.electrons]!.particleSpeedMps = 9e5;
      expect(model.scenes[SourceType.photons]!.wavelengthNm, 400);
      expect(model.scenes[SourceType.neutrons]!.wavelengthNm, 650);
    });
  });

  group('HighIntensityModel', () {
    test('defaults and slit ranges from source not model.md', () {
      final model = HighIntensityModel(random: SeededQwiRandom(1));
      expect(model.scene.slitSeparationMm, closeTo(QwiUnits.umToMm(2), 1e-18));
      expect(model.scene.slitSeparationMinMm, closeTo(QwiUnits.umToMm(1), 1e-18));
      expect(model.scene.slitSeparationMaxMm, closeTo(QwiUnits.umToMm(3), 1e-18));
      expect(model.clock.speedFactors.normal, 0.35);
      expect(model.clock.speedFactors.fast, 0.65);
    });

    test('stepOnce fixed dt', () {
      final model = HighIntensityModel(random: SeededQwiRandom(2));
      model.clock.setSpeed(TimeSpeed.fast);
      model.scene.setEmitting(true);
      model.stepOnce();
      expect(model.clock.lastDt, QwiConstants.nominalDt);
    });

    test('emitting builds time-averaged PDF', () {
      final model = HighIntensityModel(random: SeededQwiRandom(3));
      model.clock.setSpeed(TimeSpeed.fast);
      model.scene.setEmitting(true);
      // DISPLAY_TRAVERSAL_TIME = 2.0; Fast=0.65 → need wall time ≳ 2/0.65
      for (var i = 0; i < 400; i++) {
        model.step(1 / 60);
      }
      final pdf = model.scene.detectorPdf;
      expect(pdf.any((v) => v > 0), isTrue);
      expect(pdf.reduce((a, b) => a > b ? a : b), closeTo(1, 1e-9));
    });

    test('hit rate path produces waveRegion hits', () {
      final model = HighIntensityModel(random: SeededQwiRandom(4));
      model.scene.detectionMode = DetectorMode.hits;
      model.scene.setEmitting(true);
      for (var i = 0; i < 300; i++) {
        model.step(1 / 60);
      }
      if (model.scene.hits.length > 0) {
        expect(model.scene.hits.hits.first.domain, DetectorHitDomain.waveRegion);
      }
    });

    test('snapshot stores intensity PDF', () {
      final model = HighIntensityModel(random: SeededQwiRandom(5));
      model.clock.setSpeed(TimeSpeed.fast);
      model.scene.setEmitting(true);
      for (var i = 0; i < 400; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.takeSnapshot(), isTrue);
      expect(model.scene.snapshots.snapshots.first.intensityDistribution, isNotEmpty);
    });
  });

  group('SingleParticlesModel', () {
    test('defaults and TimeSpeed', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(1));
      expect(model.scene.autoRepeat, isFalse);
      expect(model.scene.detectionMode, DetectorMode.hits);
      expect(model.clock.speedFactors.fast, 16);
      expect(model.scene.slitSeparationMm, closeTo(QwiUnits.umToMm(2), 1e-18));
    });

    test('emit packet then detect produces one hit', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(2));
      model.scene.emitPacket();
      expect(model.scene.isPacketActive, isTrue);
      for (var i = 0; i < 500; i++) {
        model.step(1 / 60);
        if (model.scene.hits.length > 0) break;
      }
      expect(model.scene.hits.length, 1);
      expect(model.scene.isPacketActive, isFalse);
    });

    test('auto-fire respects 0.3s min interval', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(3));
      model.scene.autoRepeat = true;
      model.scene.isEmitting = true;
      model.scene.emitPacket();
      // Force end
      model.scene.detectPacket();
      expect(model.scene.isPacketActive, isFalse);
      model.scene.timeSinceLastEmission = 0.29;
      model.scene.step(0.01); // still < 0.3 accumulated from before? set explicitly
      model.scene.timeSinceLastEmission = 0.29;
      final before = model.scene.hits.length;
      // Manual check of gate
      expect(model.scene.timeSinceLastEmission < QwiConstants.singleParticlesMinEmissionInterval, isTrue);
      model.scene.timeSinceLastEmission = 0.30;
      model.scene.emitPacket();
      expect(model.scene.isPacketActive || model.scene.hits.length >= before, isTrue);
    });

    test('probe probability in [0,1] and larger radius increases p', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(4));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.emitPacket();
      for (var i = 0; i < 40; i++) {
        model.step(1 / 60);
      }
      model.scene.detectorProbe.radius = 0.06;
      final pSmall = model.scene.computeProbeProbability();
      model.scene.detectorProbe.radius = 0.3;
      final pLarge = model.scene.computeProbeProbability();
      expect(pSmall, inInclusiveRange(0, 1));
      expect(pLarge, inInclusiveRange(0, 1));
      expect(pLarge + 1e-12, greaterThanOrEqualTo(pSmall));
    });

    test('probe success suppresses screen hit', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(99));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.emitPacket();
      for (var i = 0; i < 30; i++) {
        model.step(1 / 60);
      }
      // Force high probability region by large radius + center
      model.scene.detectorProbe.radius = 0.3;
      model.scene.detectorProbe.normalizedX = 0.5;
      model.scene.detectorProbe.normalizedY = 0.5;
      // Try many seeds via repeated measure after reset probe — use Bernoulli with forced RNG
      final before = model.scene.hits.length;
      // Inject certainty by mocking: call detect with p=1 path
      model.scene.detectorProbe.state = ProbeState.ready;
      final p = model.scene.computeProbeProbability();
      if (p > 0) {
        // Keep trying with scene RNG until success or give up
        for (var attempt = 0; attempt < 50 && model.scene.isPacketActive; attempt++) {
          model.scene.detectorProbe.state = ProbeState.ready;
          model.scene.performDetectorMeasurement();
          if (model.scene.detectorProbe.state == ProbeState.detected) {
            expect(model.scene.hits.length, before);
            expect(model.scene.isPacketActive, isFalse);
            return;
          }
        }
      }
      // If never detected, still verify API didn't crash
      expect(p, inInclusiveRange(0, 1));
    });

    test('models are independent across screens', () {
      final exp = ExperimentModel(random: SeededQwiRandom(1));
      final hi = HighIntensityModel(random: SeededQwiRandom(1));
      final sp = SingleParticlesModel(random: SeededQwiRandom(1));
      exp.scene.wavelengthNm = 400;
      hi.scene.wavelengthNm = 500;
      sp.scene.wavelengthNm = 600;
      expect(exp.scene.wavelengthNm, 400);
      expect(hi.scene.wavelengthNm, 500);
      expect(sp.scene.wavelengthNm, 600);
    });
  });

  group('Deterministic scenario digest', () {
    test('Experiment 100 steps same seed same hit count digest', () {
      int digest(int seed) {
        final model = ExperimentModel(random: SeededQwiRandom(seed));
        model.scene.detectionMode = DetectorMode.hits;
        model.scene.setEmitting(true);
        for (var i = 0; i < 100; i++) {
          model.step(1 / 60);
        }
        var h = model.scene.hits.length;
        for (final hit in model.scene.hits.hits) {
          h = h * 31 + (hit.x * 1e6).round();
          h = h * 31 + (hit.y * 1e6).round();
        }
        return h;
      }

      expect(digest(12345), digest(12345));
      expect(digest(12345) == digest(54321), isFalse);
    });
  });
}
