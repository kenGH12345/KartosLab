import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('clearScreen keeps wavelength; reset clears all', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    c.setWavelengthNm(500);
    for (var i = 0; i < 60; i++) {
      c.stepWall(1 / 60);
    }
    expect(c.scene.hits.length, greaterThan(0));
    c.clearScreen();
    expect(c.scene.hits.length, 0);
    expect(c.scene.wavelengthNm, 500);

    c.setEmitting(true);
    for (var i = 0; i < 40; i++) {
      c.stepWall(1 / 60);
    }
    c.takeSnapshot();
    c.selectSource(SourceType.electrons);
    c.setSlitConfiguration(SlitConfiguration.leftCovered);
    c.reset();
    expect(c.model.activeSource, SourceType.photons);
    expect(c.scene.wavelengthNm, 650);
    expect(c.scene.hits.length, 0);
    expect(c.scene.snapshots.length, 0);
    expect(c.scene.slitConfiguration, SlitConfiguration.bothOpen);
    expect(c.scene.isEmitting, isFalse);
  });
}
