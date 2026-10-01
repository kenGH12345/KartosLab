import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/projectile_motion/model/data_point.dart';
import 'package:kratos/projectile_motion/model/projectile_motion_model.dart';
import 'package:kratos/projectile_motion/model/screen_models.dart';
import 'package:kratos/projectile_motion/model/trajectory.dart';
import 'package:kratos/projectile_motion/pm_constants.dart';

/// 用恒定 dt 直接驱动物理（等价 EventTimer 的 stepModelElements 回调）。
PmTrajectory fireAndLand(
  ProjectileMotionModel model, {
  double maxTime = 60,
}) {
  model.fire();
  final trajectory = model.trajectories.last;
  var t = 0.0;
  while (!trajectory.reachedGround && t < maxTime) {
    model.stepModelElements(PmConstants.timePerDataPoint);
    t += PmConstants.timePerDataPoint;
  }
  return trajectory;
}

void main() {
  group('AC-PHY 物理核心', () {
    test('PHY-1 发射点与初速度：v = v0(cosθ, sinθ)，起点 (0, h)', () {
      final model = IntroModel(); // h=10, θ=0, v=15
      model.fire();
      final t = model.trajectories.last;
      expect(t.currentPoint.x, 0);
      expect(t.currentPoint.y, 10);
      expect(t.currentPoint.vx, closeTo(15, 1e-9));
      expect(t.currentPoint.vy, closeTo(0, 1e-9));
    });

    test('PHY-2/9 真空解析锚点：g=9.81, h=0, θ=80°, v=18（1% 容差）', () {
      final model = LabModel(); // h=0, θ=80, v=18, 阻力 off
      final trajectory = fireAndLand(model);

      const v = 18.0, g = 9.81, theta = 80 * math.pi / 180;
      final analyticRange = v * v * math.sin(2 * theta) / g;
      final analyticTime = 2 * v * math.sin(theta) / g;
      final analyticApex = math.pow(v * math.sin(theta), 2) / (2 * g);

      expect(trajectory.horizontalDisplacement,
          closeTo(analyticRange, analyticRange * 0.01));
      expect(trajectory.flightTime, closeTo(analyticTime, analyticTime * 0.01));
      expect(trajectory.maxHeight, closeTo(analyticApex, analyticApex * 0.01));
      // 落地点 y 精确为 0（Trajectory:231-234）
      expect(trajectory.dataPoints.last.y, 0);
      expect(trajectory.dataPoints.last.reachedGround, isTrue);
    });

    test('PHY-3 二次阻力缩短射程且轨迹标记 changedInMidAir 语义', () {
      final vacuum = LabModel();
      final tVacuum = fireAndLand(vacuum);

      final drag = LabModel();
      drag.setAirResistanceOn(true);
      final tDrag = fireAndLand(drag);

      expect(tDrag.horizontalDisplacement,
          lessThan(tVacuum.horizontalDisplacement));
      expect(tDrag.flightTime, lessThan(tVacuum.flightTime));
    });

    test('PHY-4 空气密度 NASA 公式：海平面 ≈ 1.225，off → 0', () {
      expect(calculateAirDensity(0, true), closeTo(1.225, 0.01));
      expect(calculateAirDensity(0, false), 0);
      expect(calculateAirDensity(5000, true),
          lessThan(calculateAirDensity(0, true)));
    });

    test('PHY-5 落地时间精确截断：末点 y=0 且时间非 dt 整数倍', () {
      final model = LabModel();
      final trajectory = fireAndLand(model);
      final last = trajectory.dataPoints.last;
      expect(last.y, 0);
      // 精确截断意味着飞行时间一般不是 0.012 的整数倍
      final steps = last.time / PmConstants.timePerDataPoint;
      expect(steps - steps.floorToDouble(), isNot(closeTo(0, 1e-9)));
    });

    test('PHY-10 抛体当前位置始终等于轨迹最新点', () {
      final model = LabModel();
      model.fire();
      final trajectory = model.trajectories.last;
      for (var i = 0; i < 40; i++) {
        model.stepModelElements(PmConstants.timePerDataPoint);
        expect(trajectory.currentPoint, same(trajectory.dataPoints.last));
        expect(trajectory.currentPoint.position,
            trajectory.dataPoints.last.position);
      }
    });

    test('CANNON 高度 <4 时抬升角度下限', () {
      final model = LabModel();
      model.setCannonAngle(-90);
      model.setCannonHeight(0);
      expect(model.cannonAngle, 5);
      model.setCannonAngle(-90);
      model.setCannonHeight(3);
      expect(model.cannonAngle, -40);
    });
    test('PHY-7 apex 插值：vy=0 且位置高于相邻点', () {
      final model = LabModel();
      final trajectory = fireAndLand(model);
      final apex = trajectory.apexPoint;
      expect(apex, isNotNull);
      expect(apex!.vy, 0);
      expect(apex.apex, isTrue);
      expect(apex.y, closeTo(trajectory.maxHeight, 0.01));
    });

    test('PHY-6 vx 反号保护：极大阻力下 vx 不为负', () {
      final model = LabModel();
      model.setAirResistanceOn(true);
      model.setSelectedObjectType(
          model.objectTypes.firstWhere((t) => t.benchmark == 'custom'));
      model.setProjectileMass(0.01); // 极轻
      model.setProjectileDragCoefficient(1.2);
      model.setProjectileDiameter(3);
      model.setCannonAngle(0);
      model.setInitialSpeed(30);
      model.fire();
      final trajectory = model.trajectories.last;
      var t = 0.0;
      while (!trajectory.reachedGround && t < 60) {
        model.stepModelElements(PmConstants.timePerDataPoint);
        t += PmConstants.timePerDataPoint;
      }
      for (final PmDataPoint p in trajectory.dataPoints) {
        expect(p.vx, greaterThanOrEqualTo(0));
      }
      expect(trajectory.reachedGround, isTrue);
    });

    test('PHY-8 目标命中星级：|Δx|≤0.5→3, ≤1.0→2, ≤1.5→1', () {
      final model = LabModel(); // targetX=15
      final stars = <int>[];
      model.target.onScored = stars.add;
      expect(model.target.checkIfHitTarget(15.4), isTrue);
      expect(model.target.checkIfHitTarget(14.2), isTrue);
      expect(model.target.checkIfHitTarget(16.4), isTrue);
      expect(model.target.checkIfHitTarget(17.0), isFalse);
      expect(stars, [3, 2, 1]);
    });
  });

  group('AC-SEM 参数变化语义', () {
    test('SEM-1 改 angle/speed 不影响空中抛体', () {
      final model = LabModel();
      model.fire();
      final trajectory = model.trajectories.last;
      model.setCannonAngle(30);
      model.setInitialSpeed(5);
      model.stepModelElements(PmConstants.timePerDataPoint);
      // 轨迹仍按 80°/18m/s 的锁定初速演化（真空 vx 恒定）
      expect(trajectory.initialAngle, 80);
      expect(trajectory.initialSpeed, 18);
      expect(trajectory.currentPoint.vx,
          closeTo(18 * math.cos(80 * math.pi / 180), 1e-6));
      // 新发射使用新参数
      model.setCannonHeight(0);
      model.fire();
      expect(model.trajectories.last.initialAngle, 30);
      expect(model.trajectories.last.initialSpeed, 5);
    });

    test('SEM-2 改 gravity 立即影响空中抛体', () {
      final model = LabModel();
      model.fire();
      model.stepModelElements(PmConstants.timePerDataPoint);
      final trajectory = model.trajectories.last;
      model.setGravity(20);
      expect(trajectory.changedInMidAir, isTrue);
      // 下一步加速度用新 g
      model.stepModelElements(PmConstants.timePerDataPoint);
      expect(trajectory.currentPoint.acceleration.dy, closeTo(-20, 0.5));
    });

    test('SEM-3 切换物体类型同步 mass/diameter/Cd', () {
      final model = IntroModel();
      model.setSelectedObjectType(model.objectTypes[0]); // cannonball
      expect(model.projectileMass, PmConstants.cannonballMass);
      expect(model.projectileDiameter, PmConstants.cannonballDiameter);
      expect(model.projectileDragCoefficient,
          PmConstants.cannonballDragCoefficient);
    });
  });

  group('AC-FIRE 发射/擦除/复位', () {
    test('FIRE-1 fireEnabled：空中 ≥10 发时禁用', () {
      final model = LabModel();
      model.setCannonAngle(89.9);
      model.setInitialSpeed(30);
      model.setGravity(1); // 长飞行时间
      for (var i = 0; i < 10; i++) {
        expect(model.fireEnabled, isTrue);
        model.fire();
      }
      expect(model.fireEnabled, isFalse);
      expect(model.numberOfMovingProjectiles, 10);
    });

    test('FIRE-2 超过 10 条轨迹时优先移除最老已落地轨迹', () {
      final model = LabModel();
      // 11 发全部落地
      for (var i = 0; i < 11; i++) {
        fireAndLand(model);
      }
      expect(model.trajectories.length, PmConstants.maxNumberOfTrajectories);
      // rank 单调：最新为 0
      expect(model.trajectories.last.rank, 0);
      expect(model.trajectories.first.rank,
          model.trajectories.length - 1);
    });

    test('FIRE-4 ResetAll 全量复位', () {
      final model = LabModel();
      model.setCannonAngle(33);
      model.setInitialSpeed(7);
      model.setGravity(5);
      model.setAltitude(2000);
      model.setAirResistanceOn(true);
      model.setPlaying(false);
      model.setSlowMotion(true);
      model.setZoom(2);
      model.target.x = 8;
      model.measuringTape.isActive = true;
      model.dataProbe.isActive = true;
      fireAndLand(model);

      model.reset();

      expect(model.trajectories, isEmpty);
      expect(model.cannonAngle, 80);
      expect(model.initialSpeed, 18);
      expect(model.cannonHeight, 0);
      expect(model.gravity, PmConstants.gravityOnEarth);
      expect(model.altitude, 0);
      expect(model.airResistanceOn, isFalse);
      expect(model.isPlaying, isTrue);
      expect(model.slowMotion, isFalse);
      expect(model.zoom, 1);
      expect(model.target.x, PmConstants.targetXDefault);
      expect(model.measuringTape.isActive, isFalse);
      expect(model.dataProbe.isActive, isFalse);
      expect(model.numberOfMovingProjectiles, 0);
      expect(model.projectileMass, PmConstants.cannonballMass);
    });

    test('各屏默认值（Intro/Vectors/Drag/Lab）', () {
      final intro = IntroModel();
      expect(intro.cannonHeight, 10);
      expect(intro.cannonAngle, 0);
      expect(intro.initialSpeed, 15);
      expect(intro.airResistanceOn, isFalse);
      expect(intro.selectedObjectType.benchmark, 'pumpkin');

      final vectors = VectorsModel();
      expect(vectors.cannonHeight, 0);
      expect(vectors.cannonAngle, 80);
      expect(vectors.initialSpeed, 18);
      expect(vectors.airResistanceOn, isTrue);

      final drag = DragModel();
      expect(drag.airResistanceOn, isTrue);

      final lab = LabModel();
      expect(lab.cannonAngle, 80);
      expect(lab.airResistanceOn, isFalse);
      expect(lab.selectedObjectType.benchmark, 'cannonball');
    });
  });

  group('时钟 accumulator', () {
    test('墙钟累积按 0.012s 定额切片，慢放 ×0.33', () {
      final model = LabModel();
      model.fire();
      // 正常速度：1 秒墙钟 ≈ 83 步
      model.step(1.0);
      final normalSteps = model.trajectories.last.dataPoints.length;
      expect(normalSteps, greaterThan(80));
      expect(normalSteps, lessThan(86));

      final slow = LabModel();
      slow.setSlowMotion(true);
      slow.fire();
      slow.step(1.0);
      final slowSteps = slow.trajectories.last.dataPoints.length;
      // 慢放 1 秒墙钟 ≈ 27-28 步
      expect(slowSteps, greaterThan(25));
      expect(slowSteps, lessThan(31));
    });

    test('暂停时不步进', () {
      final model = LabModel();
      model.fire();
      model.setPlaying(false);
      model.step(1.0);
      expect(model.trajectories.last.dataPoints.length, 1);
    });
  });
}
