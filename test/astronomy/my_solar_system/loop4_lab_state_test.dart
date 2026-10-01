import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario_manager.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/model/time_speed.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MssScenario> catalog;

  setUpAll(() async {
    final manager = MssScenarioManager();
    await manager.loadScenarios();
    catalog = manager.scenarios;
  });

  MssScenario mustFind(String id) {
    for (final s in catalog) {
      if (s.scenarioId == id) return s;
    }
    fail('missing scenario $id');
  }

  group('Preset numerical regression', () {
    test('11 visible presets + custom in combo', () {
      final visible =
          catalog.where((s) => s.comboVisible).map((s) => s.scenarioId).toList();
      expect(
        visible,
        [
          'sun_planet',
          'sun_planet_moon',
          'sun_planet_comet',
          'trojan_asteroids',
          'ellipses',
          'hyperbolic',
          'slingshot',
          'double_slingshot',
          'binary_star_planet',
          'four_star_ballet',
          'double_double',
          'custom',
        ],
      );
    });

    test('OS1-4 retained and comboVisible false', () {
      for (var i = 1; i <= 4; i++) {
        final s = mustFind('orbital_system_$i');
        expect(s.comboVisible, isFalse);
        expect(s.bodies, hasLength(4));
        expect(s.bodies[0].mass, 100);
      }
    });

    for (final id in [
      'sun_planet',
      'sun_planet_moon',
      'sun_planet_comet',
      'trojan_asteroids',
      'ellipses',
      'hyperbolic',
      'slingshot',
      'double_slingshot',
      'binary_star_planet',
      'four_star_ballet',
      'double_double',
      'orbital_system_1',
      'orbital_system_2',
      'orbital_system_3',
      'orbital_system_4',
    ]) {
      test('load $id matches JSON', () {
        final file = File('assets/scenarios/my-solar-system/$id.json');
        final scenario = MssScenario.fromJson(
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
        );
        final c = MySolarSystemController(
          isLab: true,
          catalog: catalog,
          initialScenario: mustFind('sun_planet'),
        );
        c.setGridVisible(true);
        c.setZoomLevel(5);
        c.loadScenario(scenario);

        expect(c.currentScenarioId, id);
        expect(c.timeYears, 0);
        expect(c.isPlaying, isFalse);
        final expectedActive =
            scenario.bodies.where((b) => b.isActive).length;
        expect(c.numberOfActiveBodies, expectedActive);
        for (var i = 0; i < scenario.bodies.length; i++) {
          final expected = scenario.bodies[i];
          final body = c.bodies[i];
          expect(body.isActive, expected.isActive);
          if (!expected.isActive) continue;
          expect(body.mass, expected.mass);
          expect(body.position.x, closeTo(expected.position.x, 1e-9));
          expect(body.position.y, closeTo(expected.position.y, 1e-9));
        }
        // Preset switch must NOT reset zoom / visibility
        expect(c.zoomLevel, 5);
        expect(c.gridVisible, isTrue);

        if (id == 'four_star_ballet') {
          expect(
            c.gravityForceScalePower,
            MySolarSystemConstants.fourStarBalletGravityScalePower,
          );
          expect(
            c.gravityArrowScale,
            closeTo(MySolarSystemConstants.gravityArrowScale(-1.1), 1e-12),
          );
        } else if (!id.startsWith('orbital_system_')) {
          expect(c.gravityForceScalePower, 0);
        }
        for (final b in c.activeBodies) {
          expect(b.pathPoints, isEmpty);
        }
      });
    }
  });

  group('State transitions → CUSTOM', () {
    MySolarSystemController lab() => MySolarSystemController(
          isLab: true,
          catalog: catalog,
          initialScenario: mustFind('sun_planet'),
        );

    test('mass → Custom, does not pause', () {
      final c = lab();
      c.play();
      c.setBodyMass(1, 40);
      expect(c.isPlaying, isTrue);
      expect(c.currentScenarioId, 'custom');
    });

    test('position drag begin → Custom + pause', () {
      final c = lab();
      c.play();
      c.beginBodyPositionDrag(1);
      expect(c.isPlaying, isFalse);
      expect(c.currentScenarioId, 'custom');
      c.endBodyDrag();
    });

    test('velocity drag begin → Custom + pause', () {
      final c = lab();
      c.play();
      c.beginBodyVelocityDrag(1);
      expect(c.isPlaying, isFalse);
      expect(c.currentScenarioId, 'custom');
      c.endBodyDrag();
    });

    test('body count → Custom + pause', () {
      final c = lab();
      c.play();
      expect(c.numberOfActiveBodies, 2);
      c.setNumberOfActiveBodies(3);
      expect(c.numberOfActiveBodies, 3);
      expect(c.isPlaying, isFalse);
      expect(c.currentScenarioId, 'custom');
      expect(c.bodies[2].mass, 0.1);
    });

    test('selecting another preset leaves Custom', () {
      final c = lab();
      c.setBodyMass(1, 40);
      expect(c.currentScenarioId, 'custom');
      c.selectOrbitalSystem(mustFind('slingshot'));
      expect(c.currentScenarioId, 'slingshot');
      expect(c.numberOfActiveBodies, 3);
    });
  });

  group('Reset semantics distinct', () {
    test('Clear only clears time + paths', () {
      final c = MySolarSystemController(
        isLab: true,
        catalog: catalog,
        initialScenario: mustFind('sun_planet'),
      );
      c.stepOnce(1 / 8);
      final mass = c.bodies[1].mass;
      final id = c.currentScenarioId;
      final zoom = c.zoomLevel;
      expect(c.timeYears, greaterThan(0));
      c.clearSimulation();
      expect(c.timeYears, 0);
      expect(c.bodies[1].mass, mass);
      expect(c.currentScenarioId, id);
      expect(c.zoomLevel, zoom);
    });

    test('Return Bodies == restart starting state', () {
      final c = MySolarSystemController(
        isLab: true,
        catalog: catalog,
        initialScenario: mustFind('sun_planet'),
      );
      final x0 = c.bodies[1].position.x;
      c.stepOnce(1 / 8);
      expect(c.bodies[1].position.x, isNot(closeTo(x0, 1e-9)));
      c.returnBodies();
      expect(c.timeYears, 0);
      expect(c.bodies[1].position.x, closeTo(x0, 1e-9));
      expect(c.isPlaying, isFalse);
    });

    test('Reset All restores default preset + UI defaults', () {
      final c = MySolarSystemController(
        isLab: true,
        catalog: catalog,
        initialScenario: mustFind('sun_planet'),
      );
      c.selectOrbitalSystem(mustFind('four_star_ballet'));
      c.setZoomLevel(6);
      c.setGridVisible(true);
      c.setGravityVisible(true);
      c.setTimeSpeed(TimeSpeed.fast);
      c.setBodyMass(0, 200);
      expect(c.currentScenarioId, 'custom');
      c.resetAll();
      expect(c.currentScenarioId, 'sun_planet');
      expect(c.zoomLevel, MySolarSystemConstants.zoomLevelDefault);
      expect(c.gridVisible, isFalse);
      expect(c.gravityVisible, isFalse);
      expect(c.timeSpeed, TimeSpeed.normal);
      expect(c.gravityForceScalePower, 0);
      expect(c.numberOfActiveBodies, 2);
      expect(c.bodies[0].mass, 250);
    });
  });

  test('offscale when gravity visible and force tiny relative to scale', () {
    final c = MySolarSystemController(
      isLab: true,
      catalog: catalog,
      initialScenario: mustFind('sun_planet'),
    );
    c.setGravityVisible(true);
    // Move bodies far + tiny mass so |F| is small → offscale at default scale.
    c.setBodyMass(0, 0.1);
    c.setBodyMass(1, 0.1);
    c.setBodyPositionComponent(1, x: 14, y: 0);
    c.engine.updateForces();
    expect(c.isAnyGravityForceOffscale, isTrue);
    expect(c.showOffscaleMessage, isTrue);
    c.setGravityVisible(false);
    expect(c.showOffscaleMessage, isFalse);
  });
}
