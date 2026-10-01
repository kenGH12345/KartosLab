import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/gravity_and_orbits/gao_constants.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/body_type.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/gao_model.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/mode_config.dart';
import 'package:kratos/astronomy/gravity_and_orbits/physics/physics_engine.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/gao_body.dart';

void main() {
  group('ModeConfig.center', () {
    test('total momentum near zero after center', () {
      final configs = buildSceneConfigs(isModelScreen: false);
      for (final scene in configs) {
        var px = 0.0;
        var py = 0.0;
        for (final b in scene.bodies) {
          px += b.vx * b.mass;
          py += b.vy * b.mass;
        }
        expect(px.abs() / scene.bodies.first.mass, lessThan(1e-6),
            reason: '${scene.id} px');
        expect(py.abs() / scene.bodies.first.mass, lessThan(1e-6),
            reason: '${scene.id} py');
      }
    });
  });

  group('Clock substeps', () {
    test('DEFAULT_DT and smallest step', () {
      expect(GaoConstants.defaultDt, closeTo(36000, 1e-9));
      expect(GaoConstants.defaultDt * GaoConstants.smallestTimeStepFactor,
          closeTo(4725, 1e-9));
    });

    test('NORMAL advances 4× smallest step per frame', () {
      final model = GaoModel(isModelScreen: true);
      model.setPlaying(true);
      model.setTimeSpeed(GaoTimeSpeed.normal);
      final t0 = model.scene.engine.simulationTime;
      model.scene.stepModel();
      final elapsed = model.scene.engine.simulationTime - t0;
      expect(elapsed, closeTo(4725 * 4, 1e-6));
    });

    test('SLOW / FAST substep ratios', () {
      final model = GaoModel(isModelScreen: true);
      model.setTimeSpeed(GaoTimeSpeed.slow);
      model.scene.engine.simulationTime = 0;
      model.scene.stepModel();
      final slow = model.scene.engine.simulationTime;

      model.setTimeSpeed(GaoTimeSpeed.fast);
      model.scene.engine.simulationTime = 0;
      model.scene.stepModel();
      final fast = model.scene.engine.simulationTime;

      expect(slow, closeTo(4725, 1e-6));
      expect(fast, closeTo(4725 * 7, 1e-6));
    });
  });

  group('Physics PEFRL Sun-Earth', () {
    test('planet remains bound over short run (Model screen)', () {
      final model = GaoModel(isModelScreen: true);
      final planet =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      final r0 = planet.position.magnitude;

      for (var i = 0; i < 120; i++) {
        model.scene.stepModel(); // ~ NORMAL frames
      }
      final r1 = planet.position.magnitude;
      // Should not escape to >> perihelion scale
      expect(r1 / r0, lessThan(3));
      expect(r1 / r0, greaterThan(0.3));
      expect(planet.isCollided, isFalse);
    });

    test('gravity off → coast at constant velocity', () {
      final model = GaoModel(isModelScreen: true);
      model.setGravityEnabled(false);
      final planet =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      final v0 = planet.velocity.copy();
      model.scene.stepModel();
      expect(planet.velocity.x, closeTo(v0.x, 1e-6));
      expect(planet.velocity.y, closeTo(v0.y, 1e-6));
      expect(planet.force.magnitude, closeTo(0, 1e-6));
    });

    test('updateForceVectors at t=0 yields non-zero force', () {
      final model = GaoModel(isModelScreen: true);
      final planet =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.planet);
      expect(planet.force.magnitude, greaterThan(0));
    });
  });

  group('Reset / rewind', () {
    test('resetAll restores scene 0 and defaults', () {
      final model = GaoModel(isModelScreen: true);
      model.selectScene(2);
      model.showPath = true;
      model.setPlaying(true);
      model.setTimeSpeed(GaoTimeSpeed.fast);
      model.scene.stepModel();
      model.resetAll();
      expect(model.sceneIndex, 0);
      expect(model.showPath, isFalse);
      expect(model.isPlaying, isFalse);
      expect(model.timeSpeed, GaoTimeSpeed.normal);
      expect(model.scene.engine.simulationTime, 0);
    });

    test('path grows when show path sampling via modelStepped', () {
      final configs = buildSceneConfigs(isModelScreen: true);
      final engine = GaoPhysicsEngine(
        baseDtValue: configs.first.dt,
        adjustMoonOrbit: false,
      );
      final body = GaoBody.fromConfig(configs.first.bodies[1]);
      engine.addBody(GaoBody.fromConfig(configs.first.bodies[0]));
      engine.addBody(body);
      engine.timeSpeed = GaoTimeSpeed.normal;
      engine.stepModel();
      expect(body.path.length, greaterThan(0));
    });
  });

  group('Model vs ToScale factory flags', () {
    test('Model sun not movable; ToScale sun movable', () {
      final model = GaoModel(isModelScreen: true);
      final toScale = GaoModel(isModelScreen: false);
      final modelSun =
          model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.star);
      final scaleSun =
          toScale.scene.bodies.firstWhere((b) => b.type == GaoBodyType.star);
      expect(modelSun.isMovable, isFalse);
      expect(scaleSun.isMovable, isTrue);
      expect(model.showMeasuringTape, isFalse);
      expect(toScale.showMeasuringTape, isTrue);
    });

    test('Model starPlanetMoon has adjustMoonOrbit', () {
      final model = GaoModel(isModelScreen: true);
      model.selectSceneById(GaoSceneId.starPlanetMoon);
      expect(model.scene.engine.adjustMoonOrbit, isTrue);
    });
  });
}
