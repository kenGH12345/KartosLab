import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/model/celestial_body.dart';
import 'package:kratos/astronomy/my_solar_system/model/mss_vec.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_constants.dart';
import 'package:kratos/astronomy/my_solar_system/solver/numerical_engine.dart';

void main() {
  test('G is Kepler secondary 4.45669 not model.md 4.4567e-3', () {
    expect(MySolarSystemConstants.G, 4.45669);
    expect(MySolarSystemConstants.engineTimeScale, 0.05);
    expect(MySolarSystemConstants.pefrlXi, 0.1786178958448091);
    expect(MySolarSystemConstants.pefrlLambda, -0.2123418310626054);
    expect(MySolarSystemConstants.pefrlChi, -0.06626458266981849);
  });

  test('SUN_PLANET JSON matches OrbitalSystem.ts', () {
    final file = File('assets/scenarios/my-solar-system/sun_planet.json');
    final scenario = MssScenario.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
    expect(scenario.comboVisible, isTrue);
    expect(scenario.bodies, hasLength(2));
    expect(scenario.bodies[0].mass, 250);
    expect(scenario.bodies[1].mass, 25);
    expect(scenario.bodies[1].position.x, 2);
    expect(scenario.bodies[1].velocity.y, 23.4457);
  });

  test('OS1-4 JSON exists and comboVisible is false', () {
    for (var i = 1; i <= 4; i++) {
      final scenario = MssScenario.fromJson(
        jsonDecode(
          File('assets/scenarios/my-solar-system/orbital_system_$i.json')
              .readAsStringSync(),
        ) as Map<String, dynamic>,
      );
      expect(scenario.comboVisible, isFalse, reason: scenario.scenarioId);
      expect(scenario.bodies, hasLength(4));
    }
  });

  test('pairwise gravity on body1 is G m1 m2 r / r^3', () {
    final a = CelestialBody(
      index: 1,
      mass: 1,
      position: MssVec(0, 0),
      velocity: MssVec.zero(),
      color: const Color(0xFFFFFF00),
    );
    final b = CelestialBody(
      index: 2,
      mass: 2,
      position: MssVec(2, 0),
      velocity: MssVec.zero(),
      color: const Color(0xFFFF00FF),
    );
    final engine = NumericalEngine([a, b]);
    final f = engine.getGravityForce(a, b);
    final expected = MySolarSystemConstants.G * 1 * 2 * 2 / 8;
    expect(f.x, closeTo(expected, 1e-12));
    expect(f.y, closeTo(0, 1e-12));
  });

  test('collision deactivates smaller and transfers momentum, not mass', () {
    final big = CelestialBody(
      index: 1,
      mass: 10,
      position: MssVec(0, 0),
      velocity: MssVec(0, 0),
      color: const Color(0xFFFFFF00),
    );
    final small = CelestialBody(
      index: 2,
      mass: 2,
      position: MssVec(0.01, 0),
      velocity: MssVec(5, 0),
      color: const Color(0xFFFF00FF),
    );
    final engine = NumericalEngine([big, small]);
    engine.checkCollisions();
    expect(small.isActive, isFalse);
    expect(big.isActive, isTrue);
    expect(big.mass, 10);
    expect(big.velocity.x, closeTo(5 * 2 / 10, 1e-12));
  });

  test('PEFRL stepOnce keeps SUN_PLANET finite', () {
    final c = MySolarSystemController(isLab: false);
    expect(c.activeBodies, hasLength(2));
    c.stepOnce(1 / 8);
    for (final b in c.activeBodies) {
      expect(b.position.x.isFinite, isTrue);
      expect(b.position.y.isFinite, isTrue);
      expect(b.velocity.x.isFinite, isTrue);
    }
    expect(c.timeYears, greaterThan(0));
  });

  test('restart restores starting bodies, resetAll restores default', () {
    final c = MySolarSystemController(isLab: false);
    final x0 = c.bodies[1].position.x;
    c.stepOnce(1 / 8);
    expect(c.bodies[1].position.x, isNot(x0));
    c.restart();
    expect(c.bodies[1].position.x, closeTo(x0, 1e-12));
    expect(c.timeYears, 0);
    c.stepOnce(1 / 8);
    c.resetAll();
    expect(c.bodies[0].mass, 250);
    expect(c.bodies[1].mass, 25);
    expect(c.isPlaying, isFalse);
  });
}
