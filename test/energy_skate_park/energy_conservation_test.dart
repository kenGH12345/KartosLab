import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_model.dart';
import 'package:kratos/energy_skate_park/model/premade_tracks.dart';

void main() {
  group('Energy conservation (frictionless parabola)', () {
    test('total energy within PhET heuristic tolerance over many frames', () {
      final track = PremadeTracks.createParabola(physical: true);
      final model = EspModel(
        tracks: [track],
        friction: 0,
        isStickingToTrack: true,
      );

      // Place skater on left side of parabola (parametric near 0).
      final u = 0.05;
      model.skater.track = track;
      model.skater.parametricPosition = u;
      model.skater.parametricSpeed = 0;
      model.skater.positionX = track.getX(u);
      model.skater.positionY = track.getY(u);
      model.skater.velocityX = 0;
      model.skater.velocityY = 0;
      model.skater.thermalEnergy = 0;
      model.skater.isOnTopSideOfTrack = true;
      model.skater.gravityMagnitude = EspConstants.earthGravity;
      model.skater.referenceHeight = 0;
      model.skater.updateEnergy();

      final e0 = model.skater.toSkaterState().getTotalEnergy();
      expect(e0, greaterThan(0));

      // ~5 seconds of sim time at 60 Hz.
      for (var i = 0; i < 300; i++) {
        model.manualStep();
        expect(model.skater.track, isNotNull,
            reason: 'should stay on track with sticking');
      }

      final e1 = model.skater.toSkaterState().getTotalEnergy();
      // PhET correctEnergy heuristics leave residual on order ~1e-2..1e-6;
      // allow ~1e-2 absolute for long runs.
      expect((e1 - e0).abs(), lessThan(1e-2),
          reason: 'e0=$e0 e1=$e1 delta=${e1 - e0}');
    });
  });
}