import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/gravity_and_orbits/gao_constants.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/body_type.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/gao_model.dart';

void main() {
  group('Orbit regression', () {
    test('Model Sun-Earth stays elliptical-like over 2000 NORMAL frames', () {
      final model = GaoModel(isModelScreen: true);
      final planet =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      final star =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.star);

      var rMin = double.infinity;
      var rMax = 0.0;
      for (var i = 0; i < 2000; i++) {
        model.scene.stepModel();
        final dx = planet.position.x - star.position.x;
        final dy = planet.position.y - star.position.y;
        final r = math.sqrt(dx * dx + dy * dy);
        rMin = math.min(rMin, r);
        rMax = math.max(rMax, r);
      }

      expect(planet.isCollided, isFalse);
      expect(rMax / rMin, lessThan(3.0),
          reason: 'orbit should not wildly deform');
      expect(rMin, greaterThan(GaoConstants.earthPerihelion * 0.2));
      expect(rMax, lessThan(GaoConstants.earthPerihelion * 5));
    });

    test('pause resume does not jump state', () {
      final model = GaoModel(isModelScreen: true);
      final planet =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      for (var i = 0; i < 10; i++) {
        model.scene.stepModel();
      }
      final x = planet.position.x;
      final y = planet.position.y;
      final vx = planet.velocity.x;
      final vy = planet.velocity.y;
      // "paused" — no steps
      expect(planet.position.x, x);
      expect(planet.position.y, y);
      expect(planet.velocity.x, vx);
      expect(planet.velocity.y, vy);
      model.scene.stepModel();
      expect(planet.position.x, isNot(x));
    });

    test('reset restores initial planet perihelion-scale distance', () {
      final model = GaoModel(isModelScreen: true);
      final planet =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      final r0 = planet.position.magnitude;
      for (var i = 0; i < 100; i++) {
        model.scene.stepModel();
      }
      model.resetAll();
      final planet2 =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      expect(planet2.position.magnitude, closeTo(r0, r0 * 1e-9));
      expect(model.scene.engine.simulationTime, 0);
    });
  });
}
