import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('Cross-screen isolation & re-entry', () {
    test('Experiment wavelength does not leak into HI or SP', () {
      final exp = ExperimentModel(random: SeededQwiRandom(1));
      final hi = HighIntensityModel(random: SeededQwiRandom(1));
      final sp = SingleParticlesModel(random: SeededQwiRandom(1));
      exp.scene.wavelengthNm = 400;
      expect(hi.scene.wavelengthNm, 650);
      expect(sp.scene.wavelengthNm, 650);
      hi.scene.wavelengthNm = 500;
      hi.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      expect(sp.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(exp.scene.wavelengthNm, 400);
    });

    test('HI hits / packets do not appear on SP or Experiment', () {
      final exp = ExperimentModel(random: SeededQwiRandom(2));
      final hi = HighIntensityModel(random: SeededQwiRandom(2));
      final sp = SingleParticlesModel(random: SeededQwiRandom(2));
      hi.scene.detectionMode = DetectorMode.hits;
      hi.scene.setEmitting(true);
      hi.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 300; i++) {
        hi.step(1 / 60);
      }
      expect(hi.scene.hits.length, greaterThan(0));
      expect(exp.scene.hits.length, 0);
      expect(sp.scene.hits.length, 0);
      expect(sp.scene.isPacketActive, isFalse);
    });

    test('navigation cycle Exp→HI→SP→Exp preserves independent ownership', () {
      final exp = ExperimentModel(random: SeededQwiRandom(3));
      final hi = HighIntensityModel(random: SeededQwiRandom(3));
      final sp = SingleParticlesModel(random: SeededQwiRandom(3));

      exp.scene.detectionMode = DetectorMode.hits;
      exp.scene.setEmitting(true);
      for (var i = 0; i < 60; i++) {
        exp.step(1 / 60);
      }
      final expHits = exp.scene.hits.length;
      exp.scene.takeSnapshot();

      hi.scene.setEmitting(true);
      for (var i = 0; i < 80; i++) {
        hi.step(1 / 60);
      }
      hi.scene.takeSnapshot();

      sp.scene.setAutoRepeat(true);
      sp.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 2000 && sp.scene.hits.length < 5; i++) {
        sp.step(1 / 60);
      }
      sp.scene.takeSnapshot();

      // "Return" to Experiment — state intact
      expect(exp.scene.hits.length, expHits);
      expect(exp.scene.snapshots.length, 1);
      expect(hi.scene.snapshots.length, 1);
      expect(sp.scene.snapshots.length, 1);
      // Independent model ownership (Exp has no wave solver).
      expect(identical(exp, hi), isFalse);
      expect(identical(hi.scene.solver, sp.scene.solver), isFalse);
      expect(hi.scene.hits.length, isNot(exp.scene.hits.length));
    });

    test('re-enter via reset ×20 does not accumulate snapshots/hits', () {
      final sp = SingleParticlesModel(random: SeededQwiRandom(4));
      final hi = HighIntensityModel(random: SeededQwiRandom(4));
      final exp = ExperimentModel(random: SeededQwiRandom(4));
      for (var cycle = 0; cycle < 20; cycle++) {
        exp.scene.wavelengthNm = 420;
        exp.scene.takeSnapshot();
        hi.scene.setEmitting(true);
        hi.step(1 / 60);
        hi.scene.takeSnapshot();
        sp.scene.setAutoRepeat(true);
        sp.scene.timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
        sp.scene.fireOnce();
        sp.scene.takeSnapshot();

        exp.reset();
        hi.reset();
        sp.reset();

        expect(exp.scene.snapshots.length, 0);
        expect(hi.scene.snapshots.length, 0);
        expect(sp.scene.snapshots.length, 0);
        expect(exp.scene.hits.length, 0);
        expect(hi.scene.hits.length, 0);
        expect(sp.scene.hits.length, 0);
        expect(sp.scene.isPacketActive, isFalse);
        expect(sp.scene.autoRepeat, isFalse);
      }
    });

    test('Reset All on one screen does not reset another', () {
      final exp = ExperimentModel(random: SeededQwiRandom(5));
      final hi = HighIntensityModel(random: SeededQwiRandom(5));
      exp.scene.wavelengthNm = 410;
      hi.scene.wavelengthNm = 520;
      exp.reset();
      expect(exp.scene.wavelengthNm, 650);
      expect(hi.scene.wavelengthNm, 520);
    });
  });
}
