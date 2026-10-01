import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/constants/qwi_constants.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('intensity graph has 200 samples', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    final g = c.scene.intensityGraph();
    expect(g.positions.length, 200);
    expect(g.intensities.length, 200);
    expect(g.positions.first, lessThan(0));
    expect(g.positions.last, greaterThan(0));
  });

  test('hits histogram 100 bins after accumulation', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(2)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    for (var i = 0; i < 90; i++) {
      c.stepWall(1 / 60);
    }
    final hist = c.scene.hitsHistogram();
    expect(hist.binCount, QwiConstants.hitsGraphBinCount);
    expect(hist.bins.length, 100);
    expect(hist.bins.any((b) => b > 0), isTrue);
  });
}
