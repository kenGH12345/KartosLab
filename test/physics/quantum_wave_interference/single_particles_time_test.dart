import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('SingleParticles time', () {
    test('continuous step multiplies by TimeSpeed', () {
      final slow = SingleParticlesModel(random: SeededQwiRandom(1));
      final fast = SingleParticlesModel(random: SeededQwiRandom(1));
      slow.scene.emitPacket();
      fast.scene.emitPacket();
      slow.clock.setSpeed(TimeSpeed.slow);
      fast.clock.setSpeed(TimeSpeed.fast);
      slow.step(1 / 60);
      fast.step(1 / 60);
      expect(fast.scene.solver.time, greaterThan(slow.scene.solver.time));
      expect(slow.scene.solver.time, closeTo((1 / 60) * 0.15, 1e-9));
      expect(fast.scene.solver.time, closeTo((1 / 60) * 16.0, 1e-9));
    });

    test('pause stops auto-fire and hits', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(2));
      model.scene.setAutoRepeat(true);
      model.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 200; i++) {
        model.step(1 / 60);
      }
      final hits = model.scene.hits.length;
      model.clock.isPlaying = false;
      for (var i = 0; i < 200; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.hits.length, hits);
    });

    test('speed does not change wavelength mass velocity slits', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(3));
      model.selectSource(SourceType.electrons);
      final v = model.scene.particleSpeedMps;
      final l = model.scene.effectiveWavelengthM;
      final sep = model.scene.slitSeparationMm;
      model.clock.setSpeed(TimeSpeed.fast);
      model.step(1 / 60);
      expect(model.scene.particleSpeedMps, v);
      expect(model.scene.effectiveWavelengthM, l);
      expect(model.scene.slitSeparationMm, sep);
    });
  });
}
