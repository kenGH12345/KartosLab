import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('max 4 snapshots then no-op', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    for (var i = 0; i < 60; i++) {
      c.stepWall(1 / 60);
    }
    for (var i = 0; i < 4; i++) {
      expect(c.takeSnapshot(), isTrue);
    }
    expect(c.takeSnapshot(), isFalse);
    expect(c.scene.snapshots.length, 4);
  });

  test('snapshot captures hit count consistent with detector', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(3)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    for (var i = 0; i < 80; i++) {
      c.stepWall(1 / 60);
    }
    final n = c.scene.hits.length;
    expect(c.takeSnapshot(), isTrue);
    expect(c.scene.snapshots.snapshots.first.hits.length, n);
  });

  test('delete snapshot reindexes', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(4)));
    c.takeSnapshot();
    c.takeSnapshot();
    c.deleteSnapshot(0);
    expect(c.scene.snapshots.length, 1);
    expect(c.scene.snapshots.snapshots.first.snapshotNumber, 1);
  });
}
