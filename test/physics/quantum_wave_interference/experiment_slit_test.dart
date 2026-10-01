import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('noBarrier rejected on Experiment controller', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setSlitConfiguration(SlitConfiguration.noBarrier);
    expect(c.scene.slitConfiguration, SlitConfiguration.bothOpen);
  });

  test('detector-on-slit configs accepted', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    for (final cfg in [
      SlitConfiguration.leftDetector,
      SlitConfiguration.rightDetector,
      SlitConfiguration.bothDetectors,
    ]) {
      c.setSlitConfiguration(cfg);
      expect(c.scene.slitConfiguration, cfg);
      expect(c.scene.slitConfiguration.hasAnyDetector, isTrue);
    }
  });

  test('separation change alters off-axis intensity', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    final i0 = c.scene.intensityAtPhysicalX(0.002);
    c.setSlitSeparationMm(0.5);
    final i1 = c.scene.intensityAtPhysicalX(0.002);
    expect(i0 == i1, isFalse);
  });
}
