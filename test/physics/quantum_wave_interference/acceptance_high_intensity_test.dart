import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('High Intensity multi-step path', () {
    test('barrier / modes / time / snapshot / reset stay synchronized', () {
      final model = HighIntensityModel(random: SeededQwiRandom(201));
      model.clock.setSpeed(TimeSpeed.fast);
      model.scene.setEmitting(true);

      for (final cfg in [
        SlitConfiguration.noBarrier,
        SlitConfiguration.leftCovered,
        SlitConfiguration.bothOpen,
        SlitConfiguration.leftDetector,
        SlitConfiguration.rightDetector,
        SlitConfiguration.bothDetectors,
      ]) {
        model.scene.setSlitConfiguration(cfg);
        expect(model.scene.slitConfiguration, cfg);
        expect(model.scene.hits.length, 0); // clearScreen on slit change
        for (var i = 0; i < 40; i++) {
          model.step(1 / 60);
        }
      }

      // Mode switch must not reset hits / reinit physics params
      model.scene.detectionMode = DetectorMode.hits;
      model.scene.setEmitting(true);
      for (var i = 0; i < 200; i++) {
        model.step(1 / 60);
      }
      final hitsBeforeMode = model.scene.hits.length;
      final lambda = model.scene.wavelengthNm;
      final t0 = model.scene.solver.time;
      model.scene.setWaveDisplayMode(WaveDisplayMode.amplitude);
      expect(model.scene.hits.length, hitsBeforeMode);
      expect(model.scene.wavelengthNm, lambda);
      model.scene.setWaveDisplayMode(WaveDisplayMode.electricField);
      expect(model.scene.hits.length, hitsBeforeMode);
      model.step(1 / 60);
      expect(model.scene.solver.time, greaterThan(t0));

      // Pause freezes
      model.clock.isPlaying = false;
      final tPause = model.scene.solver.time;
      final hitsPause = model.scene.hits.length;
      model.step(1 / 60);
      expect(model.scene.solver.time, tPause);
      expect(model.scene.hits.length, hitsPause);

      // StepOnce = 1/60 regardless of speed
      model.clock.setSpeed(TimeSpeed.fast);
      model.stepOnce();
      expect(model.scene.solver.time, closeTo(tPause + 1 / 60, 1e-12));

      expect(model.scene.takeSnapshot(), isTrue);
      model.graphZoom.setLevel(6);
      expect(model.scene.wavelengthNm, lambda);

      model.reset();
      expect(model.scene.hits.length, 0);
      expect(model.scene.snapshots.length, 0);
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.scene.waveDisplayMode, WaveDisplayMode.electricField);
      expect(model.clock.speed, TimeSpeed.normal);
      expect(model.clock.isPlaying, isTrue);
      expect(model.graphZoom.level, 3); // HI default
    });

    test('speed changes only temporal progression, not wavelength/slits', () {
      final model = HighIntensityModel(random: SeededQwiRandom(202));
      model.scene.setEmitting(true);
      final l = model.scene.wavelengthNm;
      final sep = model.scene.slitSeparationMm;
      model.clock.setSpeed(TimeSpeed.slow);
      model.step(1 / 60);
      final tSlow = model.scene.solver.time;
      model.reset();
      model.scene.setEmitting(true);
      model.clock.setSpeed(TimeSpeed.fast);
      model.step(1 / 60);
      expect(model.scene.solver.time, greaterThan(tSlow));
      expect(model.scene.wavelengthNm, l);
      expect(model.scene.slitSeparationMm, sep);
    });

    test('rapid slit switching keeps UI selected state = model', () {
      final model = HighIntensityModel(random: SeededQwiRandom(203));
      model.scene.setEmitting(true);
      final configs = [
        SlitConfiguration.bothOpen,
        SlitConfiguration.leftCovered,
        SlitConfiguration.rightCovered,
        SlitConfiguration.bothOpen,
        SlitConfiguration.leftDetector,
        SlitConfiguration.rightDetector,
        SlitConfiguration.bothDetectors,
        SlitConfiguration.noBarrier,
      ];
      for (final c in configs) {
        model.scene.setSlitConfiguration(c);
        expect(model.scene.slitConfiguration, c);
        expect(model.scene.solver.noBarrier, c == SlitConfiguration.noBarrier);
        model.step(1 / 60);
      }
    });

    test('snapshot max 4 then no-op; Reset clears snapshots', () {
      final model = HighIntensityModel(random: SeededQwiRandom(204));
      for (var i = 0; i < 4; i++) {
        expect(model.scene.takeSnapshot(), isTrue);
      }
      expect(model.scene.takeSnapshot(), isFalse);
      model.reset();
      expect(model.scene.snapshots.length, 0);
    });
  });
}
