import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('SingleParticles lifecycle', () {
    test('independent of Experiment and HighIntensity state', () {
      final exp = ExperimentModel(random: SeededQwiRandom(1));
      final hi = HighIntensityModel(random: SeededQwiRandom(1));
      final sp = SingleParticlesModel(random: SeededQwiRandom(1));
      exp.scene.wavelengthNm = 400;
      hi.scene.wavelengthNm = 500;
      sp.scene.wavelengthNm = 600;
      exp.scene.setEmitting(true);
      hi.scene.setEmitting(true);
      sp.scene.emitPacket();
      expect(sp.scene.wavelengthNm, 600);
      expect(exp.scene.wavelengthNm, 400);
      expect(hi.scene.wavelengthNm, 500);
      expect(identical(sp.scene.solver, hi.scene.solver), isFalse);
    });

    test('re-enter via reset restores source-defined initial state', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(2));
      model.selectSource(SourceType.neutrons);
      model.scene.setAutoRepeat(true);
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.reset();
      expect(model.activeSource, SourceType.photons);
      expect(model.scene.slitConfiguration, SlitConfiguration.bothOpen);
      expect(model.scene.isPacketActive, isFalse);
      expect(model.scene.hits.length, 0);
    });

    test('clearScreen during active packet cancels packet', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(3));
      model.scene.emitPacket();
      expect(model.scene.isPacketActive, isTrue);
      model.scene.clearScreen();
      expect(model.scene.isPacketActive, isFalse);
      expect(model.scene.hits.length, 0);
    });

    test('scenes per source are independent', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(4));
      model.scenes[SourceType.photons]!.wavelengthNm = 420;
      model.scenes[SourceType.electrons]!.particleSpeedMps = 9e5;
      expect(model.scenes[SourceType.photons]!.wavelengthNm, 420);
      expect(model.scenes[SourceType.neutrons]!.wavelengthNm, 650);
    });
  });
}
