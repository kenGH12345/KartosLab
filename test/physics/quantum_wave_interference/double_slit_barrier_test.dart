import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/constants/qwi_constants.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/display_slit_layout.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';

void main() {
  group('DisplaySlitLayout', () {
    test('maps mid-range separation to mid pixel span scaled by height', () {
      final layout = DisplaySlitLayout.compute(
        slitSeparation: 2,
        slitSeparationMin: 1,
        slitSeparationMax: 3,
        regionHeight: QwiConstants.waveRegionHeight,
      );
      expect(
        layout.displaySlitSeparation,
        closeTo(
          (DisplaySlitLayout.minDisplaySlitSeparationPx +
                  DisplaySlitLayout.maxDisplaySlitSeparationPx) /
              2,
          0.5,
        ),
      );
      expect(layout.displaySlitWidth, DisplaySlitLayout.displaySlitWidthPx);
    });
  });

  group('barrier drag', () {
    test('setBarrierFractionX clamps and restarts emit', () {
      final c = HighIntensityController(model: HighIntensityModel());
      c.setEmitting(true);
      c.setBarrierFractionX(0.9);
      expect(
        c.scene.solver.barrierFractionX,
        QwiConstants.barrierPositionFractionMax,
      );
      c.setBarrierFractionX(0.1);
      expect(
        c.scene.solver.barrierFractionX,
        QwiConstants.barrierPositionFractionMin,
      );
    });
  });
}
