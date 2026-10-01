import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';

void main() {
  group('Position track / constraints', () {
    test('snap 0.1 m', () {
      expect(GravityForceConstants.snapToGrid(1.04), 1.0);
      expect(GravityForceConstants.snapToGrid(1.05), 1.1);
      expect(GravityForceConstants.snapToGrid(-1.05), -1.1);
    });

    test('keyboard step constants', () {
      expect(GravityForceConstants.positionStepSize, 0.5);
      expect(GravityForceConstants.positionSnap, 0.1);
    });

    test('positions clamped to ±5', () {
      final m = GravityForceLabModel();
      m.beginDrag(1);
      m.setPositionWhileDragging(1, -999);
      m.endDrag(1);
      expect(m.mass1.positionX, greaterThanOrEqualTo(-5));

      m.beginDrag(2);
      m.setPositionWhileDragging(2, 999);
      m.endDrag(2);
      expect(m.mass2.positionX, lessThanOrEqualTo(5));
    });

    test('cannot cross — min center separation', () {
      final m = GravityForceLabModel();
      m.beginDrag(1);
      m.setPositionWhileDragging(1, 5);
      m.endDrag(1);
      final minCenters = m.getSumRadiusWithSeparation();
      expect(m.distance + 1e-9, greaterThanOrEqualTo(minCenters));
      expect(m.mass1.positionX, lessThan(m.mass2.positionX));
    });

    test('distance is center-to-center', () {
      final m = GravityForceLabModel();
      expect(m.distance, (m.mass2.positionX - m.mass1.positionX).abs());
      expect(m.distance, isNot(m.distance - m.radius1 - m.radius2));
    });
  });

  group('Push-on-radius', () {
    test('growing mass1 radius pushes mass2 when close', () {
      final m = GravityForceLabModel();
      // Place spheres near each other at min masses (small radii).
      m.setMassValue(1, 10);
      m.setMassValue(2, 10);
      m.setPosition(1, -0.5);
      m.setPosition(2, 0.5);
      final p2Before = m.mass2.positionX;
      final sepBefore = m.distance;

      // Grow mass1 → larger radius → step pushes other sphere.
      m.setMassValue(1, 1000);
      final minCenters = m.getSumRadiusWithSeparation(); // snapped (ISLC)
      expect(m.distance + 1e-9, greaterThanOrEqualTo(minCenters));
      expect(m.mass2.positionX, greaterThan(p2Before));
      expect(m.distance, greaterThan(sepBefore));
    });
  });
}
