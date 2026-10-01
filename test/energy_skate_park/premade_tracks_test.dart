import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/model/premade_tracks.dart';

void main() {
  group('PremadeTracks', () {
    test('parabola CPs match PremadeTracks.ts defaults', () {
      final cps = PremadeTracks.createParabolaControlPoints();
      expect(cps.length, 3);
      expect(cps[0].x, closeTo(-4, 1e-12));
      expect(cps[0].y, closeTo(6, 1e-12));
      expect(cps[1].x, closeTo(0, 1e-12));
      expect(cps[1].y, closeTo(0, 1e-12));
      expect(cps[2].x, closeTo(4, 1e-12));
      expect(cps[2].y, closeTo(6, 1e-12));
    });

    test('ramp / double-well / loop CP counts and key coords', () {
      final ramp = PremadeTracks.createRampControlPoints();
      expect(ramp.length, 3);
      expect(ramp[0].x, -4);
      expect(ramp[0].y, 6);
      expect(ramp[2].y, 0);

      final well = PremadeTracks.createDoubleWellControlPoints();
      expect(well.length, 5);
      expect(well[1].y, closeTo(0.0166015, 1e-9));

      final loop = PremadeTracks.createLoopControlPoints();
      expect(loop.length, 7);
      expect(loop[3].x, 0);
      expect(loop[3].y, 4);
    });
  });
}