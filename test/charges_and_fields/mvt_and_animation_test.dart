import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/charges_and_fields/model/charges_and_fields_model.dart';
import 'package:kratos/charges_and_fields/model/vec2.dart';
import 'package:kratos/charges_and_fields/transform/caf_mvt.dart';
import 'package:flutter/material.dart';

void main() {
  group('CafMvt', () {
    test('origin maps to layout center with inverted Y', () {
      final mvt = CafMvt.fromLayout(const Size(1024, 618));
      final v = mvt.modelToView(CafVec2.zero);
      expect(v.dx, closeTo(512, 1e-9));
      expect(v.dy, closeTo(309, 1e-9));

      // +Y model → smaller view Y
      final up = mvt.modelToView(const CafVec2(0, 1));
      expect(up.dy, lessThan(v.dy));

      // round-trip
      final back = mvt.viewToModel(up);
      expect(back.x, closeTo(0, 1e-9));
      expect(back.y, closeTo(1, 1e-9));
    });

    test('scale is layoutWidth / 8', () {
      final mvt = CafMvt.fromLayout(const Size(1024, 618));
      expect(mvt.scale, closeTo(128.0, 1e-9));
      expect(mvt.modelToViewDelta(1), closeTo(128.0, 1e-9));
    });
  });

  group('return-to-bin animation', () {
    test('charge animates home and disposes', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      p.position = const CafVec2(2, 2);
      var returned = false;
      p.onReturnedToOrigin = () {
        returned = true;
        model.removeChargedParticle(p);
      };
      p.beginReturnAnimation();
      // distance ≈ 2.828 m at 2 m/s → ~1.42 s → ~90 frames @ 60fps
      for (var i = 0; i < 120; i++) {
        model.tick(1 / 60);
      }
      expect(returned, isTrue);
      expect(model.chargedParticles, isEmpty);
    });
  });
}
