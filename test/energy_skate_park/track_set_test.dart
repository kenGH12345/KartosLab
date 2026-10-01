import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/model/intro_model.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

void main() {
  group('TrackSet scene switch', () {
    test('IntroModel defaults to parabola physical only', () {
      final model = IntroModel();
      expect(model.scene, TrackScene.parabola);
      expect(model.tracks.length, 4);
      expect(model.tracks.where((t) => t.physical).length, 1);
      expect(model.activeTrack, same(model.tracks.first));
    });

    test('setScene switches physical track and detaches skater', () {
      final model = IntroModel();
      final parabola = model.tracks[0];
      model.skater.track = parabola;
      model.skater.parametricPosition = 0.2;
      model.skater.positionX = parabola.getX(0.2);
      model.skater.positionY = parabola.getY(0.2);

      model.setScene(TrackScene.loop);
      expect(model.scene, TrackScene.loop);
      expect(model.tracks[0].physical, isFalse);
      expect(model.tracks[3].physical, isTrue);
      expect(model.skater.track, isNull);
      expect(model.skater.positionY, 0);
    });

    test('isStickingToTrack default is true (PhET BooleanProperty true)', () {
      final model = IntroModel();
      expect(model.isStickingToTrack, isTrue);
    });
  });
}
