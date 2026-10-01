import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_model.dart';
import 'package:kratos/energy_skate_park/model/premade_tracks.dart';

void main() {
  group('Friction → thermal', () {
    test('thermal energy rises with friction on parabola', () {
      final track = PremadeTracks.createParabola(physical: true);
      final model = EspModel(
        tracks: [track],
        friction: EspConstants.maxFriction,
        isStickingToTrack: true,
      );

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
      model.skater.updateEnergy();

      for (var i = 0; i < 180; i++) {
        model.manualStep();
      }

      expect(model.skater.thermalEnergy, greaterThan(0.01),
          reason: 'friction should convert mechanical → thermal');
    });
  });

  group('Leave track when stick=false', () {
    test('loop skater can leave track with stick disabled', () {
      final track = PremadeTracks.createLoop(physical: true);
      final model = EspModel(
        tracks: [track],
        friction: 0,
        isStickingToTrack: false,
      );

      // Place near top of loop with significant parametric speed.
      final u = 0.35;
      model.skater.track = track;
      model.skater.parametricPosition = u;
      model.skater.parametricSpeed = 8;
      model.skater.positionX = track.getX(u);
      model.skater.positionY = track.getY(u);
      final tangent = track.getUnitParallelVector(u);
      model.skater.velocityX = tangent.x * 8;
      model.skater.velocityY = tangent.y * 8;
      model.skater.isOnTopSideOfTrack = true;
      model.skater.updateEnergy();

      var left = false;
      for (var i = 0; i < 240; i++) {
        model.manualStep();
        if (model.skater.track == null) {
          left = true;
          break;
        }
      }
      expect(left, isTrue,
          reason: 'without sticking, high-speed loop should allow leaveTrack');
    });
  });
}
