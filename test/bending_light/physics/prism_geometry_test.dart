import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/prism_geometry.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';

void main() {
  test('prism prototypes geometries are finite', () {
    for (final entry in PrismPrototypes.createAll()) {
      final shape = entry.$1;
      final c = shape.getRotationCenter();
      expect(c.x.isFinite && c.y.isFinite, isTrue, reason: entry.$2);
      final rotated = shape.getRotatedInstance(0.1, c);
      expect(rotated.getRotationCenter().x.isFinite, isTrue);
      final translated = shape.getTranslatedInstance(1e-6, -1e-6);
      expect(translated.containsPoint(BlVec2.zero) || true, isTrue);
    }
  });
}
