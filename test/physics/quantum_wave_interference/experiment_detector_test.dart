import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/render_data/experiment/detector_render_data.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('intensity mode render data empty hits; hits mode keeps intensity samples', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setEmitting(true);
    final intensity = DetectorRenderData.fromModel(c.model);
    expect(intensity.mode, DetectorMode.intensity);
    expect(intensity.fraunhofer.intensities, isNotEmpty);

    c.setDetectionMode(DetectorMode.hits);
    for (var i = 0; i < 80; i++) {
      c.stepWall(1 / 60);
    }
    final hits = DetectorRenderData.fromModel(c.model);
    expect(hits.mode, DetectorMode.hits);
    expect(hits.hits, isNotEmpty);
  });

  test('zoom does not change full half-width in render data', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setEmitting(true);
    final d0 = DetectorRenderData.fromModel(c.model);
    c.setDetectorScreenScaleIndex(3);
    final d1 = DetectorRenderData.fromModel(c.model);
    expect(d0.fraunhofer.fullScreenHalfWidthM, d1.fraunhofer.fullScreenHalfWidthM);
    expect(d1.fraunhofer.visibleHalfWidthM, lessThan(d0.fraunhofer.visibleHalfWidthM));
  });
}
