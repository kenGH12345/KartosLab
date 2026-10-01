/// Sun + Planet reference regression against MSS NumericalEngine semantics.
///
/// Golden values locked from Dart engine (port of `NumericalEngine.ts`).
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario_manager.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/model/celestial_body.dart';
import 'package:kratos/astronomy/my_solar_system/model/mss_vec.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_constants.dart';
import 'package:kratos/astronomy/my_solar_system/render/velocity_vector.dart';

/// Reference SUN_PLANET initial state (OrbitalSystem.ts / sun_planet.json).
CelestialBody sunPlanetSun() => CelestialBody(
      index: 1,
      mass: 250,
      position: MssVec(0, 0),
      velocity: MssVec(0, -2.3446),
      color: const Color(0xFFFFFF00),
    );

CelestialBody sunPlanetPlanet() => CelestialBody(
      index: 2,
      mass: 25,
      position: MssVec(2, 0),
      velocity: MssVec(0, 23.4457),
      color: const Color(0xFFFF00FF),
    );

double totalMechanicalEnergy(List<CelestialBody> bodies) {
  var ke = 0.0;
  var pe = 0.0;
  for (final b in bodies) {
    if (!b.isActive) continue;
    final vm = b.velocity.magnitude;
    ke += 0.5 * b.mass * vm * vm;
  }
  for (var i = 0; i < bodies.length; i++) {
    final b1 = bodies[i];
    if (!b1.isActive) continue;
    for (var j = i + 1; j < bodies.length; j++) {
      final b2 = bodies[j];
      if (!b2.isActive) continue;
      final r = b1.position.distance(b2.position);
      if (r > 0) {
        pe -= MySolarSystemConstants.G * b1.mass * b2.mass / r;
      }
    }
  }
  return ke + pe;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PEFRL source audit [MSS-SOURCE]', () {
    test('coefficients match NumericalEngine.ts', () {
      expect(MySolarSystemConstants.pefrlXi, 0.1786178958448091);
      expect(MySolarSystemConstants.pefrlLambda, -0.2123418310626054);
      expect(MySolarSystemConstants.pefrlChi, -0.06626458266981849);
      expect(MySolarSystemConstants.pefrlIterationBudget, 4000);
      expect(MySolarSystemConstants.engineTimeScale, 0.05);
      expect(MySolarSystemConstants.desiredStepsPerSecond, 30);
    });

    test('iterationCount = 4000 / N for N active bodies', () {
      final n = 2;
      final expectedIterations =
          MySolarSystemConstants.pefrlIterationBudget / n;
      expect(expectedIterations, 2000);
    });

    test('pairwise force count is N(N-1)/2 per PEFRL sub-iteration', () {
      final bodies = [
        sunPlanetSun(),
        sunPlanetPlanet(),
        CelestialBody(
          index: 3,
          mass: 1,
          position: MssVec(3, 0),
          velocity: MssVec.zero(),
          color: const Color(0xFF00FFFF),
        ),
      ];
      final n = bodies.length;
      final iterations = MySolarSystemConstants.pefrlIterationBudget / n;
      final expectedPairsPerIter = n * (n - 1) ~/ 2;
      expect(expectedPairsPerIter, 3);
      expect(iterations * expectedPairsPerIter, closeTo(4000, 1e-9));
    });
  });

  group('Sun + Planet reference regression', () {
    test('one stepOnce(1/8) matches golden snapshot', () {
      final c = MySolarSystemController(isLab: false);
      final e0 = totalMechanicalEnergy(c.activeBodies);
      c.stepOnce(1 / 8);
      final p = c.bodies[1];
      expect(p.position.x, closeTo(1.994563110194916, 1e-9));
      expect(p.position.y, closeTo(0.14638957670111072, 1e-9));
      expect(p.velocity.x, closeTo(-1.7387153917192715, 1e-9));
      expect(p.velocity.y, closeTo(23.37561714989423, 1e-9));
      expect(c.timeYears, closeTo(0.49603174603174605, 1e-9));
      // Closed orbit: energy should not drift wildly in one step.
      final e1 = totalMechanicalEnergy(c.activeBodies);
      expect((e1 - e0).abs() / e0.abs(), lessThan(0.01));
    });

    test('100 stepOnce(1/8) matches golden snapshot', () {
      final c = MySolarSystemController(isLab: false);
      final e0 = totalMechanicalEnergy(c.activeBodies);
      for (var i = 0; i < 100; i++) {
        c.stepOnce(1 / 8);
      }
      final p = c.bodies[1];
      expect(p.position.x, closeTo(1.7318404024812366, 1e-6));
      expect(p.position.y, closeTo(0.9936671331775497, 1e-6));
      expect(c.timeYears, closeTo(49.603174603174686, 1e-6));
      final e100 = totalMechanicalEnergy(c.activeBodies);
      expect(e100.isFinite, isTrue);
      // Closed 2-body orbit: energy drift should stay bounded over 100 steps.
      expect((e100 - e0).abs() / e0.abs(), lessThan(0.05));
      for (final b in c.activeBodies) {
        expect(b.position.x.isFinite, isTrue);
        expect(b.velocity.x.isFinite, isTrue);
      }
    });
  });

  group('Gravity / velocity vector data path', () {
    test('gravity arrow uses force not acceleration', () {
      final c = MySolarSystemController(isLab: false);
      c.setGravityVisible(true);
      c.engine.updateForces();
      final b = c.bodies[1];
      expect(b.gravityForce.magnitude, isNot(closeTo(b.acceleration.magnitude, 1e-6)));
      expect(b.gravityForce.magnitude / b.mass, closeTo(b.acceleration.magnitude, 1e-9));
    });

    test('Four Star Ballet scalePower changes gravityArrowScale', () async {
      final manager = MssScenarioManager();
      await manager.loadScenarios();
      final ballet = manager.scenarios
          .firstWhere((s) => s.scenarioId == 'four_star_ballet');
      final c = MySolarSystemController(
        isLab: true,
        catalog: manager.scenarios,
        initialScenario: ballet,
      );
      final low = c.gravityArrowScale;
      expect(c.gravityForceScalePower, -1.1);
      c.setGravityForceScalePower(0);
      final high = c.gravityArrowScale;
      expect(low, isNot(closeTo(high, 1e-12)));
    });

    test('velocity tip = position + v * VELOCITY_TO_VIEW', () {
      final pos = MssVec(2, 0);
      final vel = MssVec(0, 23.4457);
      final tip = velocityTipModel(pos, vel);
      expect(
        tip.x,
        closeTo(pos.x + vel.x * MySolarSystemConstants.velocityToViewMultiplier, 1e-12),
      );
      expect(
        tip.y,
        closeTo(pos.y + vel.y * MySolarSystemConstants.velocityToViewMultiplier, 1e-12),
      );
    });
  });
}
