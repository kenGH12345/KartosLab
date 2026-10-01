/// Loop 6: long-run stability, collision safety, performance, audits.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario_manager.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/model/celestial_body.dart';
import 'package:kratos/astronomy/my_solar_system/model/mss_vec.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_constants.dart';
import 'package:kratos/astronomy/my_solar_system/render/constrain_drag_point.dart';
import 'package:kratos/astronomy/my_solar_system/render/mss_mvt.dart';
import 'package:kratos/astronomy/my_solar_system/solver/numerical_engine.dart';

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
    fail('missing $id');
  }

  MySolarSystemController lab({String preset = 'sun_planet'}) =>
      MySolarSystemController(
        isLab: true,
        catalog: catalog,
        initialScenario: mustFind(preset),
      );

  void assertAllFinite(MySolarSystemController c) {
    expect(c.numberOfActiveBodies, greaterThan(0));
    for (final b in c.activeBodies) {
      expect(b.position.x.isFinite, isTrue, reason: 'position.x NaN/Inf');
      expect(b.position.y.isFinite, isTrue);
      expect(b.velocity.x.isFinite, isTrue);
      expect(b.velocity.y.isFinite, isTrue);
      expect(b.acceleration.x.isFinite, isTrue);
      expect(b.gravityForce.x.isFinite, isTrue);
    }
  }

  group('Preset long-run stability (200 steps)', () {
    for (final id in [
      'sun_planet',
      'sun_planet_moon',
      'trojan_asteroids',
      'ellipses',
      'hyperbolic',
      'binary_star_planet',
      'four_star_ballet',
      'double_double',
    ]) {
      test('$id stays finite', () {
        final c = lab(preset: id);
        final initialCount = c.numberOfActiveBodies;
        for (var i = 0; i < 200; i++) {
          c.stepOnce(1 / 60);
        }
        assertAllFinite(c);
        expect(c.numberOfActiveBodies, initialCount);
        for (final b in c.activeBodies) {
          expect(b.pathPoints.length, lessThanOrEqualTo(MySolarSystemConstants.maxPathPoints));
        }
      });
    }
  });

  group('Collision safety [TEMPORARY overlap]', () {
    test('small hits large: no NaN, smaller deactivated', () {
      final big = CelestialBody(
        index: 1,
        mass: 100,
        position: MssVec(0, 0),
        velocity: MssVec.zero(),
        color: const Color(0xFFFFFF00),
      );
      final small = CelestialBody(
        index: 2,
        mass: 5,
        position: MssVec(0.02, 0),
        velocity: MssVec(10, 0),
        color: const Color(0xFFFF00FF),
      );
      final engine = NumericalEngine([big, small]);
      engine.checkCollisions();
      expect(small.isActive, isFalse);
      expect(big.velocity.x.isFinite, isTrue);
      expect(big.velocity.x, closeTo(0.5, 1e-9));
    });

    test('large hits small: symmetric outcome', () {
      final big = CelestialBody(
        index: 1,
        mass: 100,
        position: MssVec(0, 0),
        velocity: MssVec(0, 0),
        color: const Color(0xFFFFFF00),
      );
      final small = CelestialBody(
        index: 2,
        mass: 5,
        position: MssVec(0.02, 0),
        velocity: MssVec(-10, 0),
        color: const Color(0xFFFF00FF),
      );
      final engine = NumericalEngine([big, small]);
      engine.checkCollisions();
      expect(small.isActive, isFalse);
      expect(big.velocity.x.isFinite, isTrue);
    });

    test('d=0 gravity returns zero force', () {
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
        position: MssVec(0, 0),
        velocity: MssVec.zero(),
        color: const Color(0xFFFF00FF),
      );
      final engine = NumericalEngine([a, b]);
      final f = engine.getGravityForce(a, b);
      expect(f.x, 0);
      expect(f.y, 0);
    });

    test('post-collision stepOnce remains finite', () {
      final c = lab();
      c.bodies[1].position.x = c.bodies[0].position.x + 0.01;
      c.engine.update(c.activeBodies);
      c.engine.checkCollisions();
      c.stepOnce(1 / 8);
      assertAllFinite(c);
    });
  });

  group('Path cap [TEMPORARY maxPathPoints]', () {
    test('path points never exceed maxPathPoints', () {
      final c = lab();
      c.setPathVisible(true);
      for (var i = 0; i < 500; i++) {
        c.stepOnce(1 / 8);
      }
      for (final b in c.activeBodies) {
        expect(b.pathPoints.length, lessThanOrEqualTo(MySolarSystemConstants.maxPathPoints));
      }
    });
  });

  group('Solver performance (Stopwatch, not CI benchmark)', () {
    Future<double> avgStepMs(MySolarSystemController c, {int n = 20}) async {
      final sw = Stopwatch()..start();
      for (var i = 0; i < n; i++) {
        c.stepOnce(1 / 60);
      }
      sw.stop();
      return sw.elapsedMicroseconds / n / 1000.0;
    }

    test('2 bodies stepOnce < 200ms (desktop headroom for 60fps)', () async {
      final ms = await avgStepMs(MySolarSystemController(isLab: false));
      expect(ms, lessThan(200));
    });

    test('3 bodies Lab stepOnce < 250ms', () async {
      final c = lab();
      c.setNumberOfActiveBodies(3);
      final ms = await avgStepMs(c);
      expect(ms, lessThan(250));
    });

    test('4 bodies Lab stepOnce < 300ms', () async {
      final c = lab();
      c.setNumberOfActiveBodies(4);
      final ms = await avgStepMs(c);
      expect(ms, lessThan(300));
    });

    test('Four Star Ballet stepOnce < 300ms', () async {
      final c = lab(preset: 'four_star_ballet');
      final ms = await avgStepMs(c);
      expect(ms, lessThan(300));
    });
  });

  group('Render pipeline audit — physics once', () {
    test('painters do not import NumericalEngine', () {
      final dir = Directory('lib/astronomy/my_solar_system/painters');
      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final text = f.readAsStringSync();
        expect(
          text.contains('numerical_engine'),
          isFalse,
          reason: '${f.path} must not run solver',
        );
        expect(text.contains('updateForces'), isFalse);
      }
    });

    test('screen builds RenderData from controller state only', () {
      final screenFile = File(
        'lib/astronomy/my_solar_system/screens/my_solar_system_screen.dart',
      );
      final text = screenFile.readAsStringSync();
      expect(text.contains('engine.run'), isFalse);
      expect(text.contains('_renderData'), isTrue);
    });
  });

  group('Offscreen audit [TEMPORARY |r|>50]', () {
    test('offscreen body still active and in engine', () {
      final c = lab();
      c.bodies[1].position.x = 60;
      expect(c.bodies[1].isOffscreen, isTrue);
      expect(c.bodies[1].isActive, isTrue);
      expect(c.bodiesAreReturnable, isTrue);
      c.stepOnce(1 / 8);
      expect(c.bodies[1].isActive, isTrue);
      assertAllFinite(c);
    });

    test('isOffscreen does not remove body from activeBodies', () {
      final c = lab();
      c.bodies[1].position.x = 100;
      expect(c.activeBodies, hasLength(2));
      expect(c.bodies[1].isActive, isTrue);
    });
  });

  group('Drag boundary [TEMPORARY AABB]', () {
    test('constrainDragPoint stays inside model rect', () {
      const size = Size(400, 300);
      final mvt = MssMvt(center: Offset(200, 150), scale: 85);
      final out = constrainDragPoint(
        modelPoint: MssVec(999, -999),
        canvasSize: size,
        mvt: mvt,
        bodyRadiusView: 10,
      );
      final a = mvt.toModel(const Offset(10, 10));
      final b = mvt.toModel(Offset(size.width - 10, size.height - 10));
      final minX = math.min(a.x, b.x);
      final maxX = math.max(a.x, b.x);
      final minY = math.min(a.y, b.y);
      final maxY = math.max(a.y, b.y);
      expect(out.x, inInclusiveRange(minX, maxX));
      expect(out.y, inInclusiveRange(minY, maxY));
    });

    test('zoom change keeps constrained point finite', () {
      for (final scale in [25.0, 85.0, 125.0]) {
        final mvt = MssMvt(center: const Offset(512, 384), scale: scale);
        final p = constrainDragPoint(
          modelPoint: MssVec(50, 50),
          canvasSize: const Size(1024, 768),
          mvt: mvt,
        );
        expect(p.x.isFinite, isTrue);
        expect(p.y.isFinite, isTrue);
      }
    });
  });

  group('Reset / preset numerical consistency', () {
    for (final id in ['sun_planet', 'slingshot', 'four_star_ballet']) {
      test('$id: 100 steps → restart restores snapshot', () {
        final c = lab(preset: id);
        final snap = [
          for (final b in c.bodies)
            (
              b.mass,
              b.position.x,
              b.position.y,
              b.velocity.x,
              b.velocity.y,
              b.isActive,
            ),
        ];
        for (var i = 0; i < 100; i++) {
          c.stepOnce(1 / 8);
        }
        expect(c.timeYears, greaterThan(0));
        c.restart();
        expect(c.timeYears, 0);
        for (var i = 0; i < c.bodies.length; i++) {
          expect(c.bodies[i].mass, snap[i].$1);
          expect(c.bodies[i].position.x, closeTo(snap[i].$2, 1e-9));
          expect(c.bodies[i].position.y, closeTo(snap[i].$3, 1e-9));
          expect(c.bodies[i].velocity.x, closeTo(snap[i].$4, 1e-9));
          expect(c.bodies[i].velocity.y, closeTo(snap[i].$5, 1e-9));
          expect(c.bodies[i].isActive, snap[i].$6);
          expect(c.bodies[i].pathPoints, isEmpty);
        }
      });
    }

    test('clear retains body state after step', () {
      final c = lab();
      for (var i = 0; i < 50; i++) {
        c.stepOnce(1 / 8);
      }
      final x = c.bodies[1].position.x;
      final t = c.timeYears;
      c.clearSimulation();
      expect(c.timeYears, 0);
      expect(c.bodies[1].position.x, x);
      expect(c.bodies[1].pathPoints, isEmpty);
      expect(t, greaterThan(0));
    });
  });

  group('centerOrbitOffset [BLOCKED — not applied in Flutter]', () {
    test('MVT documents offset ignored', () {
      final mvtFile = File('lib/astronomy/my_solar_system/render/mss_mvt.dart');
      expect(mvtFile.readAsStringSync(), contains('centerOrbitOffset'));
      expect(mvtFile.readAsStringSync(), contains('忽略'));
    });

    test('constants retained for future common port', () {
      expect(MySolarSystemConstants.centerOrbitOffsetX, 100);
      expect(MySolarSystemConstants.centerOrbitOffsetY, 100);
    });
  });
}
