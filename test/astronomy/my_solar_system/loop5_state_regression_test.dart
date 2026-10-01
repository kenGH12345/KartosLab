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

  MySolarSystemController lab({MssScenario? initial}) =>
      MySolarSystemController(
        isLab: true,
        catalog: catalog,
        initialScenario: initial ?? mustFind('sun_planet'),
      );

  group('Flow A — preset play pause drag Custom return', () {
    test('position drag then returnBodies restores saved starting state', () {
      final c = lab();
      c.beginBodyPositionDrag(1);
      c.bodies[1].position.x += 0.5;
      c.endBodyDrag();
      expect(c.currentScenarioId, 'custom');
      final savedX = c.bodies[1].position.x;
      c.play();
      c.stepOnce(1 / 8);
      expect(c.isPlaying, isTrue);
      expect(c.bodies[1].position.x, isNot(closeTo(savedX, 1e-6)));
      c.returnBodies();
      expect(c.timeYears, 0);
      expect(c.bodies[1].position.x, closeTo(savedX, 1e-9));
      expect(c.isPlaying, isFalse);
    });
  });

  group('Flow B — velocity drag Custom clear retains bodies', () {
    test('clear resets time only, retains current body state', () {
      final c = lab();
      c.setBodyVelocityComponent(1, vx: 5);
      expect(c.currentScenarioId, 'custom');
      c.stepOnce(1 / 8);
      expect(c.timeYears, greaterThan(0));
      final mass = c.bodies[1].mass;
      final vx = c.bodies[1].velocity.x;
      final x = c.bodies[1].position.x;
      c.clearSimulation();
      expect(c.timeYears, 0);
      expect(c.bodies[1].mass, mass);
      expect(c.bodies[1].velocity.x, vx);
      expect(c.bodies[1].position.x, x);
      expect(c.currentScenarioId, 'custom');
    });
  });

  group('Flow C — mass bodies Custom resetAll', () {
    test('resetAll returns Sun + Planet defaults', () {
      final c = lab();
      c.setBodyMass(1, 40);
      expect(c.currentScenarioId, 'custom');
      c.setNumberOfActiveBodies(3);
      expect(c.numberOfActiveBodies, 3);
      expect(c.currentScenarioId, 'custom');
      c.resetAll();
      expect(c.currentScenarioId, 'sun_planet');
      expect(c.numberOfActiveBodies, 2);
      expect(c.bodies[0].mass, 250);
      expect(c.zoomLevel, MySolarSystemConstants.zoomLevelDefault);
      expect(c.gridVisible, isFalse);
      expect(c.moreDataVisible, isFalse);
    });
  });

  group('Flow D — Four Star Ballet gravity scale', () {
    test('load sets scalePower -1.1 and arrow scale', () {
      final c = lab();
      c.loadScenario(mustFind('four_star_ballet'));
      expect(c.currentScenarioId, 'four_star_ballet');
      expect(
        c.gravityForceScalePower,
        MySolarSystemConstants.fourStarBalletGravityScalePower,
      );
      c.setGravityVisible(true);
      expect(
        c.gravityArrowScale,
        closeTo(
          MySolarSystemConstants.gravityArrowScale(-1.1),
          1e-12,
        ),
      );
    });
  });

  group('Flow E — toggles then resetAll', () {
    test('resetAll restores zoom grid com tape speed gravity scale', () {
      final c = lab();
      c.selectOrbitalSystem(mustFind('slingshot'));
      c.setZoomLevel(6);
      c.setGridVisible(true);
      c.setCenterOfMassVisible(true);
      c.setMeasuringTapeVisible(true);
      c.setGravityVisible(true);
      c.setTimeSpeed(TimeSpeed.fast);
      c.setGravityForceScalePower(3);
      final tip = c.tapeTip.copy();
      tip.x += 2;
      c.setTapeTip(tip);
      c.resetAll();
      expect(c.currentScenarioId, 'sun_planet');
      expect(c.zoomLevel, MySolarSystemConstants.zoomLevelDefault);
      expect(c.gridVisible, isFalse);
      expect(c.centerOfMassVisible, isFalse);
      expect(c.measuringTapeVisible, isFalse);
      expect(c.gravityVisible, isFalse);
      expect(c.velocityVisible, isTrue);
      expect(c.pathVisible, isTrue);
      expect(c.timeSpeed, TimeSpeed.normal);
      expect(c.gravityForceScalePower, 0);
      expect(c.tapeBase.x, MySolarSystemConstants.tapeDefaultBaseX);
      expect(c.tapeTip.x, MySolarSystemConstants.tapeDefaultTipX);
    });

    test('preset switch does NOT reset zoom or visibility', () {
      final c = lab();
      c.setZoomLevel(6);
      c.setGridVisible(true);
      c.loadScenario(mustFind('trojan_asteroids'));
      expect(c.zoomLevel, 6);
      expect(c.gridVisible, isTrue);
      expect(c.currentScenarioId, 'trojan_asteroids');
    });
  });

  group('Visible preset play pause restart', () {
    final visibleIds = [
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
    ];

    for (final id in visibleIds) {
      test('$id load play pause restart', () {
        final scenario = mustFind(id);
        final c = lab(initial: mustFind('sun_planet'));
        c.loadScenario(scenario);
        expect(c.currentScenarioId, id);
        expect(c.timeYears, 0);
        final expectedActive =
            scenario.bodies.where((b) => b.isActive).length;
        expect(c.numberOfActiveBodies, expectedActive);
        for (final b in c.activeBodies) {
          expect(b.pathPoints, isEmpty);
        }
        if (id == 'four_star_ballet') {
          expect(
            c.gravityForceScalePower,
            MySolarSystemConstants.fourStarBalletGravityScalePower,
          );
        } else {
          expect(c.gravityForceScalePower, 0);
        }
        final startX = c.bodies[1].position.x;
        c.play();
        c.stepOnce(1 / 8);
        expect(c.bodies[1].position.x, isNot(closeTo(startX, 1e-6)));
        c.pause();
        c.restart();
        expect(c.timeYears, 0);
        expect(c.bodies[1].position.x, closeTo(startX, 1e-9));
        for (final b in c.activeBodies) {
          expect(b.pathPoints, isEmpty);
        }
      });
    }
  });
}
