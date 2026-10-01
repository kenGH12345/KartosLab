import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/transform/bl_mvt.dart';

void main() {
  group('BlMvt', () {
    test('intro viewOrigin is (286, 252)', () {
      final mvt = BlMvt.intro();
      expect(mvt.viewOrigin.dx, 286);
      expect(mvt.viewOrigin.dy, 252);
      expect(
        mvt.scale,
        BendingLightConstants.layoutBoundsHeight /
            BendingLightConstants.modelHeight,
      );
    });

    test('prisms / moreTools origins', () {
      expect(BlMvt.prisms().viewOrigin, const Offset(148, 209));
      expect(BlMvt.moreTools().viewOrigin, const Offset(388, 252));
    });

    test('worldToScreen maps origin to viewOrigin', () {
      final mvt = BlMvt.intro();
      final s = mvt.worldToScreen(BlVec2.zero);
      expect(s.dx, closeTo(286, 1e-9));
      expect(s.dy, closeTo(252, 1e-9));
    });

    test('worldToScreen / screenToWorld roundtrip', () {
      final mvt = BlMvt.intro();
      const world = BlVec2(1.2e-6, -3.4e-6);
      final screen = mvt.worldToScreen(world);
      final back = mvt.screenToWorld(screen);
      expect(back.x, closeTo(world.x, 1e-18));
      expect(back.y, closeTo(world.y, 1e-18));
    });

    test('inverted Y: model +y maps above viewOrigin', () {
      final mvt = BlMvt.intro();
      final up = mvt.worldToScreen(const BlVec2(0, 1e-6));
      expect(up.dy, lessThan(mvt.viewOrigin.dy));
    });
  });
}
