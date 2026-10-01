import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/model/field_lines.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

void main() {
  group('FieldLinesModel', () {
    test('ellipse count and parameters match source LINE_DESCRIPTION', () {
      expect(kFieldLineEllipseSpecs, hasLength(4));
      expect(kFieldLineEllipseSpecs[0].a, 600);
      expect(kFieldLineEllipseSpecs[0].b, 300);
      expect(kFieldLineEllipseSpecs[1].a, 350);
      expect(kFieldLineEllipseSpecs[2].a, 180);
      expect(kFieldLineEllipseSpecs[3].a, 90);
      expect(kFieldLineEllipseSpecs[3].b, 25);
    });

    test('visible toggles and tracks magnet position / polarity', () {
      var visible = false;
      var position = const Offset(647, 200);
      var orientation = MagnetOrientation.ns;

      final model = FieldLinesModel(
        visibleGetter: () => visible,
        magnetPositionGetter: () => position,
        orientationGetter: () => orientation,
      );

      expect(model.geometry.visible, isFalse);
      expect(model.geometry.arrowDirectionFlipped, isFalse);

      visible = true;
      position = const Offset(400, 200);
      orientation = MagnetOrientation.sn;

      final g = model.geometry;
      expect(g.visible, isTrue);
      expect(g.magnetPosition, const Offset(400, 200));
      expect(g.orientation, MagnetOrientation.sn);
      expect(g.arrowDirectionFlipped, isTrue);
      expect(g.ellipses, same(kFieldLineEllipseSpecs));
    });
  });
}
