import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';
import 'package:kratos/chemistry/states_of_matter/transform/som_coordinate_transform.dart';

void main() {
  group('SomCoordinateTransform', () {
    late SomCoordinateTransform mvt;

    setUp(() {
      mvt = SomCoordinateTransform();
    });

    test('layout bounds match PhET 834×504', () {
      expect(SomCoordinateTransform.layoutBoundsWidth, 834);
      expect(SomCoordinateTransform.layoutBoundsHeight, 504);
    });

    test('scale is VIEW_CONTAINER_WIDTH / 10000', () {
      expect(
        SomCoordinateTransform.scale,
        closeTo(280 / SomConstants.containerWidth, 1e-12),
      );
      expect(SomCoordinateTransform.scale, closeTo(0.028, 1e-12));
    });

    test('model (0,0) maps to (0.325W, 0.75H)', () {
      expect(mvt.originX, closeTo(834 * 0.325, 1e-9));
      expect(mvt.originY, closeTo(504 * 0.75, 1e-9));
      final p = mvt.modelToView(0, 0);
      expect(p.dx, closeTo(mvt.originX, 1e-9));
      expect(p.dy, closeTo(mvt.originY, 1e-9));
    });

    test('inverted Y: positive model Y decreases view Y', () {
      final bottom = mvt.modelToViewY(0);
      final top = mvt.modelToViewY(SomConstants.containerInitialHeight);
      expect(top, lessThan(bottom));
      expect(
        bottom - top,
        closeTo(
          SomConstants.containerInitialHeight * SomCoordinateTransform.scale,
          1e-9,
        ),
      );
    });

    test('container view width is 280', () {
      final bounds = mvt.particleContainerViewBounds();
      expect(bounds.width, closeTo(280, 1e-9));
      expect(bounds.height, closeTo(280, 1e-9));
    });

    test('atom radius maps with scale', () {
      expect(
        mvt.modelToViewScale(SomConstants.neonRadius),
        closeTo(SomConstants.neonRadius * 0.028, 1e-9),
      );
    });
  });
}
