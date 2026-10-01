import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/constants/qwi_constants.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('wavelength change clears hits', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    for (var i = 0; i < 60; i++) {
      c.stepWall(1 / 60);
    }
    expect(c.scene.hits.length, greaterThan(0));
    c.setWavelengthNm(500);
    expect(c.scene.hits.length, 0);
    expect(c.scene.wavelengthNm, 500);
  });

  test('parameter ranges from source', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setWavelengthNm(1000);
    expect(c.scene.wavelengthNm, QwiConstants.photonWavelengthPropertyMaxNm);
    c.setWavelengthNm(100);
    expect(c.scene.wavelengthNm, QwiConstants.photonWavelengthPropertyMinNm);

    c.setScreenDistanceM(0.1);
    expect(c.scene.screenDistanceM, QwiConstants.experimentScreenDistanceMinM);
    c.setScreenDistanceM(9);
    expect(c.scene.screenDistanceM, QwiConstants.experimentScreenDistanceMaxM);

    c.setSlitSeparationMm(0);
    expect(c.scene.slitSeparationMm, c.scene.defaults.slitSeparationMinMm);
  });

  test('matter speed path for electrons', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.selectSource(SourceType.electrons);
    final before = c.scene.effectiveWavelengthM;
    c.setParticleSpeedMps(1e6);
    expect(c.scene.particleSpeedMps, 1e6);
    expect(c.scene.effectiveWavelengthM, isNot(before));
  });

  test('time speed normal/fast only', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setTimeSpeed(TimeSpeed.slow);
    expect(c.model.clock.speed, TimeSpeed.normal);
    c.setTimeSpeed(TimeSpeed.fast);
    expect(c.model.clock.speed, TimeSpeed.fast);
  });

  test('brightness does not alter intensity', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    final i0 = c.scene.intensityAtPhysicalX(0);
    c.setScreenBrightness(100);
    expect(c.scene.intensityAtPhysicalX(0), i0);
  });
}
