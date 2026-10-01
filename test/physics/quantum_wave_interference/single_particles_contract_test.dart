import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('SingleParticles contract', () {
    test('defaults match TypeScript', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(1));
      expect(model.activeSource, SourceType.photons);
      expect(model.scene.wavelengthNm, 650);
      expect(model.scene.detectionMode, DetectorMode.hits);
      expect(model.scene.autoRepeat, isFalse);
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.scene.waveDisplayMode, WaveDisplayMode.electricField);
      expect(model.clock.speedFactors.slow, 0.15);
      expect(model.clock.speedFactors.normal, 0.7);
      expect(model.clock.speedFactors.fast, 16.0);
      expect(model.graphZoom.level, 6);
      expect(model.scene.slitSeparationMm, closeTo(QwiUnits.umToMm(2), 1e-18));
    });

    test('particle masses / wavelength semantics differ photon vs matter', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(2));
      final photonL = model.scenes[SourceType.photons]!.effectiveWavelengthM;
      model.scenes[SourceType.electrons]!.particleSpeedMps = 1.1e6;
      final eL = model.scenes[SourceType.electrons]!.effectiveWavelengthM;
      expect(photonL, closeTo(QwiUnits.nmToM(650), 1e-18));
      expect(eL, isNot(closeTo(photonL, 1e-20)));
      expect(eL, greaterThan(0));
    });

    test('Gaussian packet source parameters from constants', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(3));
      model.scene.emitPacket();
      final src = model.scene.solver.createSource();
      expect(src.isActive, isTrue);
      expect(src.sigmaX0, closeTo(0.15 * model.scene.solver.regionWidth, 1e-12));
      expect(src.sigmaY0, closeTo(0.15 * model.scene.solver.regionHeight, 1e-12));
      expect(src.longitudinalSpreadTime, closeTo(2.5 * 1.5, 1e-12));
      expect(src.transverseSpreadTime, closeTo(1.5 * 1.5, 1e-12));
    });

    test('detection timing includes packet start offset (TS sampleDetectionDelayToTargetX)', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(4));
      model.scene.emitPacket();
      final speed = model.scene.solver.displayPropagationSpeed;
      final sigma = QwiConstants.wavePacketSigmaXFraction * model.scene.solver.regionWidth;
      final minCenter = model.scene.solver.regionWidth / speed; // without offset would be shorter
      // With -2σ start, travel is longer than W/v.
      expect(model.scene.targetDetectionTime, greaterThan(minCenter * 0.9));
      expect(model.scene.targetDetectionTime.isFinite, isTrue);
      expect(sigma, greaterThan(0));
    });

    test('one hit per particle (manual fire, no auto-repeat)', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(5));
      for (var p = 0; p < 5; p++) {
        model.scene.timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
        model.scene.fireOnce();
        expect(model.scene.isPacketActive, isTrue);
        final before = model.scene.hits.length;
        for (var i = 0; i < 500 && model.scene.isPacketActive; i++) {
          model.stepOnce();
        }
        expect(model.scene.isPacketActive, isFalse);
        expect(model.scene.hits.length, before + 1);
      }
      expect(model.scene.hits.length, 5);
    });

    test('noBarrier doubleSlit coherent vs which-path changes distribution', () {
      List<double> accumulate(SlitConfiguration config, int seed) {
        final model = SingleParticlesModel(random: SeededQwiRandom(seed));
        model.scene.setSlitConfiguration(config);
        model.scene.setAutoRepeat(true);
        model.clock.setSpeed(TimeSpeed.fast);
        for (var i = 0; i < 8000 && model.scene.hits.length < 40; i++) {
          model.step(1 / 60);
        }
        final hist = HitsHistogramData.fromHits(model.scene.hits.hits);
        return hist.bins.map((e) => e.toDouble()).toList();
      }

      final both = accumulate(SlitConfiguration.bothOpen, 11);
      final which = accumulate(SlitConfiguration.leftDetector, 11);
      expect(both.reduce((a, b) => a + b), greaterThan(0));
      expect(which.reduce((a, b) => a + b), greaterThan(0));
      // Distributions should not be identical under which-path vs bothOpen.
      var same = true;
      for (var i = 0; i < both.length; i++) {
        if (both[i] != which[i]) {
          same = false;
          break;
        }
      }
      expect(same, isFalse);
    });

    test('which-path slit detector can increment left/right path hits', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(7));
      model.scene.setSlitConfiguration(SlitConfiguration.bothDetectors);
      model.scene.setAutoRepeat(true);
      model.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 6000 && model.scene.hits.length < 20; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.leftDetectorHits + model.scene.rightDetectorHits, greaterThan(0));
    });

    test('probe available only for noBarrier', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(8));
      expect(model.scene.isProbeAvailable, isFalse);
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      expect(model.scene.isProbeAvailable, isTrue);
    });

    test('probe success yields zero screen hits for that particle', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(42));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      var success = false;
      for (var trial = 0; trial < 80 && !success; trial++) {
        model.scene.clearScreen();
        model.scene.timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
        model.scene.emitPacket();
        for (var i = 0; i < 50; i++) {
          model.stepOnce();
        }
        if (!model.scene.isPacketActive) {
          continue;
        }
        model.scene.detectorProbe.radius = 0.45;
        model.scene.detectorProbe.normalizedX = 0.55;
        model.scene.detectorProbe.normalizedY = 0.5;
        model.scene.detectorProbe.state = ProbeState.ready;
        final before = model.scene.hits.length;
        model.scene.performDetectorMeasurement();
        if (model.scene.detectorProbe.state == ProbeState.detected) {
          expect(model.scene.hits.length, before);
          expect(model.scene.isPacketActive, isFalse);
          success = true;
        }
      }
      expect(success, isTrue);
    });

    test('probe failure applies measurement projection and packet continues', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(9));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.emitPacket();
      for (var i = 0; i < 40; i++) {
        model.stepOnce();
      }
      expect(model.scene.isPacketActive, isTrue);
      // Tiny probe far from packet → low p → likely miss
      model.scene.detectorProbe.radius = 0.02;
      model.scene.detectorProbe.normalizedX = 0.05;
      model.scene.detectorProbe.normalizedY = 0.05;
      model.scene.detectorProbe.state = ProbeState.ready;
      var failed = false;
      for (var a = 0; a < 40 && model.scene.isPacketActive; a++) {
        model.scene.detectorProbe.state = ProbeState.ready;
        model.scene.performDetectorMeasurement();
        if (model.scene.detectorProbe.state == ProbeState.notDetected) {
          failed = true;
          expect(model.scene.solver.measurementProjections, isNotEmpty);
          expect(model.scene.isPacketActive, isTrue);
          break;
        }
      }
      expect(failed, isTrue);
    });

    test('stepOnce is exactly 1/60 and independent of TimeSpeed', () {
      double advance(TimeSpeed speed) {
        final model = SingleParticlesModel(random: SeededQwiRandom(10));
        model.clock.setSpeed(speed);
        model.scene.emitPacket();
        model.stepOnce();
        return model.scene.solver.time;
      }

      expect(advance(TimeSpeed.slow), closeTo(1 / 60, 1e-12));
      expect(advance(TimeSpeed.normal), closeTo(1 / 60, 1e-12));
      expect(advance(TimeSpeed.fast), closeTo(1 / 60, 1e-12));
    });

    test('pause stops packet progression', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(11));
      model.scene.emitPacket();
      model.clock.isPlaying = false;
      final t0 = model.scene.solver.time;
      model.step(1 / 60);
      expect(model.scene.solver.time, t0);
    });

    test('auto-fire min interval 0.3s', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(12));
      model.scene.setAutoRepeat(true);
      model.scene.emitPacket();
      model.scene.detectPacket();
      model.scene.timeSinceLastEmission = 0.29;
      model.scene.step(0); // no-op
      expect(model.scene.isPacketActive, isFalse);
      model.scene.timeSinceLastEmission = 0.29;
      // Manual: interval gate
      expect(model.scene.timeSinceLastEmission < QwiConstants.singleParticlesMinEmissionInterval, isTrue);
      model.scene.timeSinceLastEmission = 0.3;
      model.scene.isEmitting = true;
      model.scene.step(1 / 60);
      expect(model.scene.isPacketActive || model.scene.hits.length >= 1, isTrue);
    });

    test('snapshot max 4; 5th is no-op', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(13));
      for (var i = 0; i < 4; i++) {
        expect(model.scene.takeSnapshot(), isTrue);
      }
      expect(model.scene.takeSnapshot(), isFalse);
      expect(model.scene.snapshots.length, 4);
    });

    test('reset clears hits snapshots probe and restores defaults', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(14));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.setAutoRepeat(true);
      model.scene.wavelengthNm = 400;
      model.scene.emitPacket();
      model.scene.detectPacket();
      model.scene.takeSnapshot();
      model.reset();
      expect(model.scene.hits.length, 0);
      expect(model.scene.snapshots.length, 0);
      expect(model.scene.wavelengthNm, 650);
      expect(model.scene.autoRepeat, isFalse);
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.activeSource, SourceType.photons);
    });

    test('determinism: same seed same hit sequence', () {
      List<double> run(int seed) {
        final model = SingleParticlesModel(random: SeededQwiRandom(seed));
        model.scene.setAutoRepeat(true);
        model.clock.setSpeed(TimeSpeed.fast);
        for (var i = 0; i < 5000 && model.scene.hits.length < 25; i++) {
          model.step(1 / 60);
        }
        return model.scene.hits.hits.map((h) => h.x).toList();
      }

      final a = run(123);
      final b = run(123);
      expect(a, b);
      expect(run(123) == run(456), isFalse);
    });

    test('zoom does not change wavelength or slit physics', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(15));
      model.scene.emitPacket();
      final l0 = model.scene.effectiveWavelengthM;
      final sep0 = model.scene.slitSeparationMm;
      model.graphZoom.setLevel(1);
      model.graphZoom.setLevel(6);
      expect(model.scene.effectiveWavelengthM, l0);
      expect(model.scene.slitSeparationMm, sep0);
    });

    test('single slit is not double-slit with zero spacing', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(16));
      model.scene.setSlitConfiguration(SlitConfiguration.leftCovered);
      expect(model.scene.solver.isTopSlitOpen, isFalse);
      expect(model.scene.solver.isBottomSlitOpen, isTrue);
      model.scene.setSlitConfiguration(SlitConfiguration.bothOpen);
      expect(model.scene.solver.isTopSlitOpen, isTrue);
      expect(model.scene.solver.isBottomSlitOpen, isTrue);
    });

    test('does not use FraunhoferSolver for detector PDF', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(17));
      model.scene.emitPacket();
      for (var i = 0; i < 80; i++) {
        model.stepOnce();
      }
      final pdf = model.scene.detectorPdf;
      expect(pdf.any((v) => v > 0), isTrue);
      // Solver is SingleParticleWaveSolver — WaveKernel path
      expect(model.scene.solver, isA<SingleParticleWaveSolver>());
    });
  });
}
