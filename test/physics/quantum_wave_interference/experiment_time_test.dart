import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('pause stops hit accumulation', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(5)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    for (var i = 0; i < 60; i++) {
      c.stepWall(1 / 60);
    }
    final n = c.scene.hits.length;
    expect(n, greaterThan(0));
    c.setPlaying(false);
    for (var i = 0; i < 60; i++) {
      c.stepWall(1 / 60);
    }
    expect(c.scene.hits.length, n);
  });

  test('fast advances more hits than normal for same wall time', () {
    ExperimentController run(TimeSpeed speed) {
      final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(9)));
      c.setDetectionMode(DetectorMode.hits);
      c.setEmitting(true);
      c.setTimeSpeed(speed);
      for (var i = 0; i < 30; i++) {
        c.stepWall(1 / 60);
      }
      return c;
    }

    final normal = run(TimeSpeed.normal);
    final fast = run(TimeSpeed.fast);
    expect(fast.scene.hits.length, greaterThan(normal.scene.hits.length));
  });
}
