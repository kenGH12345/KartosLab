import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/transform/efac_mvt.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/belt_geometry.dart';

void main() {
  group('BeltGeometry (Belt.ts)', () {
    late BeltGeometry belt;

    setUp(() {
      belt = BeltGeometry(
        wheel1Center: EfacLayoutConstants.beltWheel1Center,
        wheel1Radius: EfacLayoutConstants.rearWheelRadius,
        wheel2Center: EfacLayoutConstants.beltWheel2Center,
        wheel2Radius: EfacLayoutConstants.generatorWheelRadius,
      );
    });

    test('wheel centers match SystemsModel.ts offsets', () {
      expect(
        EfacLayoutConstants.beltWheel1Center,
        EfacLayoutConstants.sourceSelected +
            EfacLayoutConstants.centerOfBackWheelOffset,
      );
      expect(
        EfacLayoutConstants.beltWheel2Center,
        EfacLayoutConstants.converterSelected +
            EfacLayoutConstants.generatorWheelCenterOffset,
      );
    });

    test('contactAngle = asin((r2-r1)/distance)', () {
      final dist =
          (belt.wheel2Center - belt.wheel1Center).distance;
      final expected =
          math.asin((belt.wheel2Radius - belt.wheel1Radius) / dist);
      expect(belt.contactAngle, closeTo(expected, 1e-12));
    });

    test('tangent points lie on wheel circles', () {
      expect(
        (belt.wheel1ArcStart - belt.wheel1Center).distance,
        closeTo(belt.wheel1Radius, 1e-12),
      );
      expect(
        (belt.wheel1ArcEnd - belt.wheel1Center).distance,
        closeTo(belt.wheel1Radius, 1e-12),
      );
      expect(
        (belt.wheel2ArcStart - belt.wheel2Center).distance,
        closeTo(belt.wheel2Radius, 1e-12),
      );
      expect(
        (belt.wheel2ArcEnd - belt.wheel2Center).distance,
        closeTo(belt.wheel2Radius, 1e-12),
      );
    });

    test('arc span is π + 2·contactAngle (Belt.ts clockwise wrap)', () {
      expect(
        belt.arcSweepMagnitude,
        closeTo(math.pi + 2 * belt.contactAngle, 1e-12),
      );
    });

    test('closed outline returns to start', () {
      final pts = belt.modelOutlinePoints();
      expect(pts.length, greaterThan(20));
      expect((pts.first - pts.last).distance, lessThan(1e-12));
    });

    test('view path uses same centers via MVT', () {
      final mvt = EfacMvt.systems();
      final c1 = mvt.modelToView(belt.wheel1Center);
      final c2 = mvt.modelToView(belt.wheel2Center);
      final path = belt.toViewPath(mvt.modelToView);
      final bounds = path.getBounds();
      expect(bounds.contains(c1), isTrue);
      expect(bounds.contains(c2), isTrue);
      expect(
        mvt.modelToViewDelta(belt.wheel1Radius),
        closeTo(EfacLayoutConstants.rearWheelRadius * mvt.scale, 1e-9),
      );
      expect(
        mvt.modelToViewDelta(belt.wheel2Radius),
        closeTo(EfacLayoutConstants.generatorWheelRadius * mvt.scale, 1e-9),
      );
    });
  });
}
