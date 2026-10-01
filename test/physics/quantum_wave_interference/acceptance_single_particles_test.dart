import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';

void main() {
  group('Single Particles lifecycle acceptance', () {
    test('10 manual particles: one hit each, no ghost packet', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(301));
      for (var p = 0; p < 10; p++) {
        model.scene.timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
        model.scene.fireOnce();
        expect(model.scene.isPacketActive, isTrue);
        final before = model.scene.hits.length;
        for (var i = 0; i < 600 && model.scene.isPacketActive; i++) {
          model.stepOnce();
        }
        expect(model.scene.isPacketActive, isFalse);
        expect(model.scene.hits.length, before + 1);
        expect(model.scene.solver.packetReEmission, isNull);
      }
      expect(model.scene.hits.length, 10);
    });

    test('probe success → zero screen hit; failure → projection continues', () {
      // Success
      var gotSuccess = false;
      for (var seed = 40; seed < 120 && !gotSuccess; seed++) {
        final model = SingleParticlesModel(random: SeededQwiRandom(seed));
        model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
        model.scene.timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
        model.scene.emitPacket();
        for (var i = 0; i < 45; i++) {
          model.stepOnce();
        }
        if (!model.scene.isPacketActive) {
          continue;
        }
        model.scene.detectorProbe.radius = 0.4;
        model.scene.detectorProbe.normalizedX = 0.55;
        model.scene.detectorProbe.normalizedY = 0.5;
        model.scene.detectorProbe.state = ProbeState.ready;
        final before = model.scene.hits.length;
        model.scene.performDetectorMeasurement();
        if (model.scene.detectorProbe.state == ProbeState.detected) {
          expect(model.scene.hits.length, before);
          expect(model.scene.isPacketActive, isFalse);
          gotSuccess = true;
        }
      }
      expect(gotSuccess, isTrue);

      // Failure + continue
      final model = SingleParticlesModel(random: SeededQwiRandom(9));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.emitPacket();
      for (var i = 0; i < 40; i++) {
        model.stepOnce();
      }
      model.scene.detectorProbe.radius = 0.02;
      model.scene.detectorProbe.normalizedX = 0.05;
      model.scene.detectorProbe.normalizedY = 0.05;
      var failed = false;
      for (var a = 0; a < 40 && model.scene.isPacketActive; a++) {
        model.scene.detectorProbe.state = ProbeState.ready;
        model.scene.performDetectorMeasurement();
        if (model.scene.detectorProbe.state == ProbeState.notDetected) {
          failed = true;
          expect(model.scene.solver.measurementProjections, isNotEmpty);
          expect(model.scene.isPacketActive, isTrue);
          final t = model.scene.solver.time;
          model.stepOnce();
          expect(model.scene.solver.time, greaterThan(t));
          break;
        }
      }
      expect(failed, isTrue);
    });

    test('move probe after detect returns to ready (source geometry handler)', () {
      final c = SingleParticlesController(
        model: SingleParticlesModel(random: SeededQwiRandom(55)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      c.setSlitConfiguration(SlitConfiguration.noBarrier);
      c.scene.detectorProbe.state = ProbeState.detected;
      c.scene.detectorProbe.probability = 0.9;
      c.moveProbe(0.4, 0.4);
      expect(c.scene.detectorProbe.state, ProbeState.ready);
      c.scene.detectorProbe.state = ProbeState.notDetected;
      c.setProbeRadius(0.2);
      expect(c.scene.detectorProbe.state, ProbeState.ready);
    });

    test('Auto Fire + Pause freezes; Step advances exactly 1/60', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(302));
      model.scene.setAutoRepeat(true);
      model.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 300; i++) {
        model.step(1 / 60);
      }
      final hits = model.scene.hits.length;
      final t = model.scene.solver.time;
      final active = model.scene.isPacketActive;
      model.clock.isPlaying = false;
      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, hits);
      expect(model.scene.solver.time, t);
      expect(model.scene.isPacketActive, active);

      model.stepOnce();
      if (active) {
        expect(model.scene.solver.time, closeTo(t + 1 / 60, 1e-12));
      }
      // Must not burst-fire many packets on a single step while paused clock path used stepOnce
      expect(model.scene.hits.length, lessThanOrEqualTo(hits + 1));
    });

    test('Auto Fire + Reset clears packet and does not resume old session', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(303));
      model.scene.setAutoRepeat(true);
      model.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 400; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, greaterThan(0));
      model.reset();
      expect(model.scene.autoRepeat, isFalse);
      expect(model.scene.isEmitting, isFalse);
      expect(model.scene.isPacketActive, isFalse);
      expect(model.scene.hits.length, 0);
      // After reset, without re-enabling, stepping must not emit
      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, 0);
      expect(model.scene.isPacketActive, isFalse);
    });

    test('slit change during active packet clears via clearScreen (source)', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(304));
      model.scene.emitPacket();
      expect(model.scene.isPacketActive, isTrue);
      model.scene.setSlitConfiguration(SlitConfiguration.leftDetector);
      expect(model.scene.isPacketActive, isFalse);
      expect(model.scene.hits.length, 0);
      expect(model.scene.slitConfiguration, SlitConfiguration.leftDetector);
    });

    test('which-path changes hit distribution vs bothOpen (same seed)', () {
      List<int> hist(SlitConfiguration cfg) {
        final model = SingleParticlesModel(random: SeededQwiRandom(11));
        model.scene.setSlitConfiguration(cfg);
        model.scene.setAutoRepeat(true);
        model.clock.setSpeed(TimeSpeed.fast);
        for (var i = 0; i < 12000 && model.scene.hits.length < 40; i++) {
          model.step(1 / 60);
        }
        return HitsHistogramData.fromHits(model.scene.hits.hits).bins;
      }

      final both = hist(SlitConfiguration.bothOpen);
      final which = hist(SlitConfiguration.leftDetector);
      expect(both.reduce((a, b) => a + b), greaterThan(0));
      expect(which.reduce((a, b) => a + b), greaterThan(0));
      expect(both, isNot(equals(which)));
    });

    test('100-hit sequence deterministic for same seed', () {
      List<double> seq(int seed) {
        final model = SingleParticlesModel(random: SeededQwiRandom(seed));
        model.scene.setAutoRepeat(true);
        model.clock.setSpeed(TimeSpeed.fast);
        for (var i = 0; i < 30000 && model.scene.hits.length < 100; i++) {
          model.step(1 / 60);
        }
        expect(model.scene.hits.length, 100);
        return model.scene.hits.hits.map((h) => h.x).toList();
      }

      expect(seq(4242), seq(4242));
    });

    test('multi-step realistic path: probe → auto fire → snapshot → zoom → reset', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(305));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.probeVisible = true;
      model.scene.timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
      model.scene.fireOnce();
      for (var i = 0; i < 30; i++) {
        model.stepOnce();
      }
      model.scene.setSlitConfiguration(SlitConfiguration.bothOpen);
      model.scene.setAutoRepeat(true);
      model.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 3000 && model.scene.hits.length < 8; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, greaterThanOrEqualTo(3));
      expect(model.scene.takeSnapshot(), isTrue);
      model.graphZoom.setLevel(1);
      model.graphZoom.setLevel(6);
      expect(model.scene.wavelengthNm, 650);
      model.clock.isPlaying = false;
      model.clock.setSpeed(TimeSpeed.fast);
      model.reset();
      expect(model.scene.hits.length, 0);
      expect(model.scene.snapshots.length, 0);
      expect(model.scene.autoRepeat, isFalse);
      expect(model.graphZoom.level, 6);
    });
  });
}
