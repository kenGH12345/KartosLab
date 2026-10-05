import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../pm_constants.dart';
import 'data_probe.dart';
import 'measuring_tape.dart';
import 'projectile_object_type.dart';
import 'target.dart';
import 'trajectory.dart';

/// PhET `ProjectileMotionModel.ts` 的 Flutter 等价（公共 model 基类）。
///
/// 时钟架构（Model:244-247, 314-317）：
/// 墙钟 dt →（isPlaying）→ 慢放缩放 → accumulator → 恒定 0.012s 切片
/// → stepModelElements(0.012) → 每条未落地 Trajectory.step
class ProjectileMotionModel extends ChangeNotifier {
  ProjectileMotionModel({
    required PmProjectileObjectType defaultObjectType,
    required bool defaultAirResistanceOn,
    required this.objectTypes,
    this.maxProjectiles = PmConstants.maxNumberOfTrajectories,
    double defaultCannonHeight = 0,
    double defaultCannonAngle = 80,
    double defaultInitialSpeed = 18,
    double targetX = PmConstants.targetXDefault,
  })  : _defaultCannonHeight = defaultCannonHeight,
        _defaultCannonAngle = defaultCannonAngle,
        _defaultInitialSpeed = defaultInitialSpeed,
        _defaultAirResistanceOn = defaultAirResistanceOn,
        _defaultObjectType = defaultObjectType,
        target = PmTarget(initialX: targetX),
        selectedObjectType = defaultObjectType {
    cannonHeight = defaultCannonHeight;
    cannonAngle = defaultCannonAngle;
    initialSpeed = defaultInitialSpeed;
    projectileMass = defaultObjectType.mass;
    projectileDiameter = defaultObjectType.diameter;
    projectileDragCoefficient = defaultObjectType.dragCoefficient;
    airResistanceOn = defaultAirResistanceOn;
    dataProbe = PmDataProbe(
      trajectories: () => trajectories,
      zoom: () => zoom,
    );
  }

  // ── 配置 ──────────────────────────────────────────────────────────────
  final int maxProjectiles;
  final List<PmProjectileObjectType> objectTypes;
  final double _defaultCannonHeight;
  final double _defaultCannonAngle;
  final double _defaultInitialSpeed;
  final bool _defaultAirResistanceOn;
  final PmProjectileObjectType _defaultObjectType;

  /// Lab 屏：编辑 mass/diameter/Cd 时写回当前类型（LabModel.ts:53-62）
  bool syncEditsToObjectType = false;

  // ── 发射参数（仅影响下一次发射）──────────────────────────────────────
  late double cannonHeight;
  late double cannonAngle;
  late double initialSpeed;
  late double projectileMass;
  late double projectileDiameter;
  late double projectileDragCoefficient;
  PmProjectileObjectType selectedObjectType;

  // ── 环境（立即影响空中抛体）─────────────────────────────────────────
  double gravity = PmConstants.gravityOnEarth;
  double altitude = 0;
  late bool airResistanceOn;

  // ── 时钟状态 ──────────────────────────────────────────────────────────
  bool slowMotion = false;
  bool isPlaying = true;
  double zoom = PmConstants.defaultZoom;

  // ── 工具与目标 ────────────────────────────────────────────────────────
  final PmTarget target;
  final PmMeasuringTape measuringTape = PmMeasuringTape();
  late final PmDataProbe dataProbe;

  // ── 轨迹 ──────────────────────────────────────────────────────────────
  final List<PmTrajectory> trajectories = [];
  int numberOfMovingProjectiles = 0;

  /// 炮口火焰年龄（秒）；null = 未激活（muzzleFlashStepper 等价）
  double? muzzleFlashAge;

  /// 落地事件（view 用于星星动画等）
  void Function(PmTrajectory trajectory)? onTrajectoryLanded;

  double _accumulator = 0;

  // ── 派生 ──────────────────────────────────────────────────────────────

  /// Model:406-437 — NASA 标准大气
  double get airDensity =>
      calculateAirDensity(altitude, airResistanceOn);

  /// Model:234-239（Stats 的 rapidFire 不迁移）
  bool get fireEnabled => numberOfMovingProjectiles < maxProjectiles;

  // ── Setters（带语义）─────────────────────────────────────────────────

  void setCannonHeight(double v, {bool notify = true}) {
    final next = v.clamp(
        PmConstants.cannonHeightMin, PmConstants.cannonHeightMax);
    var changed = (next - cannonHeight).abs() >= 1e-9;
    cannonHeight = next;
    // CannonNode.ts:414-416 — height<4 时抬高角度下限
    if (cannonHeight < 4) {
      final idx =
          cannonHeight.floor().clamp(0, PmConstants.angleRangeMins.length - 1);
      final minAngle = PmConstants.angleRangeMins[idx];
      if (cannonAngle < minAngle) {
        cannonAngle = minAngle.toDouble();
        changed = true;
      }
    }
    if (changed && notify) notifyListeners();
  }

  void setCannonAngle(double v) {
    cannonAngle =
        v.clamp(PmConstants.cannonAngleMin, PmConstants.cannonAngleMax);
    notifyListeners();
  }

  void setInitialSpeed(double v) {
    initialSpeed = v.clamp(
        PmConstants.launchVelocityMin, PmConstants.launchVelocityMax);
    notifyListeners();
  }

  void setProjectileMass(double v) {
    projectileMass = v.clamp(
        PmConstants.projectileMassMin, PmConstants.projectileMassMax);
    if (syncEditsToObjectType) selectedObjectType.mass = projectileMass;
    notifyListeners();
  }

  void setProjectileDiameter(double v) {
    projectileDiameter = v.clamp(
        PmConstants.projectileDiameterMin, PmConstants.projectileDiameterMax);
    if (syncEditsToObjectType) {
      selectedObjectType.diameter = projectileDiameter;
    }
    notifyListeners();
  }

  void setProjectileDragCoefficient(double v) {
    projectileDragCoefficient = v.clamp(
        PmConstants.dragCoefficientMin, PmConstants.dragCoefficientMax);
    if (syncEditsToObjectType) {
      selectedObjectType.dragCoefficient = projectileDragCoefficient;
    }
    notifyListeners();
  }

  /// Model:278-284 — 切换类型立即同步 mass/diameter/Cd
  void setSelectedObjectType(PmProjectileObjectType type) {
    selectedObjectType = type;
    projectileMass = type.mass;
    projectileDiameter = type.diameter;
    projectileDragCoefficient = type.dragCoefficient;
    notifyListeners();
  }

  void setGravity(double v) {
    gravity = v.clamp(PmConstants.gravityMin, PmConstants.gravityMax);
    _markMovingTrajectoriesChangedMidAir();
    notifyListeners();
  }

  void setAltitude(double v) {
    altitude = v.clamp(PmConstants.altitudeMin, PmConstants.altitudeMax);
    _markMovingTrajectoriesChangedMidAir();
    notifyListeners();
  }

  void setAirResistanceOn(bool v) {
    airResistanceOn = v;
    _markMovingTrajectoriesChangedMidAir();
    notifyListeners();
  }

  void setSlowMotion(bool v) {
    slowMotion = v;
    notifyListeners();
  }

  /// 外部（view/gesture）直接改字段后通知刷新。
  void refresh() => notifyListeners();

  void setPlaying(bool v) {
    isPlaying = v;
    notifyListeners();
  }

  void setZoom(double v) {
    zoom = v.clamp(PmConstants.minZoom, PmConstants.maxZoom);
    notifyListeners();
  }

  void zoomIn() => setZoom(zoom * 2);
  void zoomOut() => setZoom(zoom / 2);

  // ── 时钟 ──────────────────────────────────────────────────────────────

  /// Model:314-317 — 墙钟入口
  void step(double wallDt) {
    if (!isPlaying) return;
    _accumulator +=
        (slowMotion ? PmConstants.slowMotionFactor : 1.0) * wallDt;
    var stepped = false;
    while (_accumulator >= PmConstants.timePerDataPoint) {
      _accumulator -= PmConstants.timePerDataPoint;
      stepModelElements(PmConstants.timePerDataPoint);
      stepped = true;
    }
    if (stepped) notifyListeners();
  }

  /// Model:322-329 — 恒定 dt 物理步进（Step 按钮也走这里）
  void stepModelElements(double dt) {
    for (final trajectory in List.of(trajectories)) {
      if (!trajectory.reachedGround) {
        trajectory.step(dt);
      }
    }
    // muzzleFlashStepper.emit(dt)
    final flashAge = muzzleFlashAge;
    if (flashAge != null) {
      final next = flashAge + dt;
      muzzleFlashAge =
          next >= PmConstants.muzzleFlashDuration ? null : next;
    }
  }

  // ── 发射 ──────────────────────────────────────────────────────────────

  /// Model:359-376（σ=0，getRandomizedValue 即原值）
  void fire() {
    if (!fireEnabled) return;
    final trajectory = PmTrajectory(
      projectileObjectType: selectedObjectType,
      mass: projectileMass,
      diameter: projectileDiameter,
      dragCoefficient: projectileDragCoefficient,
      initialSpeed: initialSpeed,
      initialHeight: cannonHeight,
      initialAngle: cannonAngle,
      gravity: () => gravity,
      airDensity: () => airDensity,
      checkIfHitTarget: target.checkIfHitTarget,
      onMovingCountChanged: _onMovingCountChanged,
      onLanded: (t) => onTrajectoryLanded?.call(t),
      onDataPointAdded: (p) {
        if (dataProbe.isActive) dataProbe.updateDataIfWithinRange(p);
      },
    );
    // updateTrajectoryRanksEmitter：所有已有轨迹 rank++
    for (final t in trajectories) {
      t.rank++;
    }
    trajectories.add(trajectory);
    _onMovingCountChanged(); // 计入新发射的空中抛体
    muzzleFlashAge = 0;
    _limitTrajectories();
    notifyListeners();
  }

  void _onMovingCountChanged() {
    // Trajectory 构造 ++，落地 --；顺序与源码一致
    // 通过比较 trajectories 中未落地数重算，保持单一事实来源
    numberOfMovingProjectiles =
        trajectories.where((t) => !t.reachedGround).length;
  }

  /// Model:332-349 — 超限优先移除最老的已落地轨迹
  void _limitTrajectories() {
    var toRemove = trajectories.length - maxProjectiles;
    if (toRemove <= 0) return;
    final disposeList = <PmTrajectory>[];
    for (final t in trajectories) {
      if (t.reachedGround) {
        disposeList.add(t);
        if (disposeList.length >= toRemove) break;
      }
    }
    for (final t in disposeList) {
      trajectories.remove(t);
    }
    if (dataProbe.isActive) dataProbe.updateData();
  }

  /// Model:351-354 — Eraser
  void eraseTrajectories() {
    trajectories.clear();
    numberOfMovingProjectiles = 0;
    if (dataProbe.isActive) dataProbe.updateData();
    notifyListeners();
  }

  /// Model:379-388
  void _markMovingTrajectoriesChangedMidAir() {
    for (final t in trajectories) {
      if (!t.changedInMidAir && !t.reachedGround) {
        t.changedInMidAir = true;
      }
    }
  }

  // ── Reset（Model:287-312）─────────────────────────────────────────────

  void reset() {
    resetObjectTypes();
    eraseTrajectories();
    target.reset();
    measuringTape.reset();
    dataProbe.reset();
    zoom = PmConstants.defaultZoom;
    cannonHeight = _defaultCannonHeight;
    cannonAngle = _defaultCannonAngle;
    initialSpeed = _defaultInitialSpeed;
    selectedObjectType = _defaultObjectType;
    projectileMass = selectedObjectType.mass;
    projectileDiameter = selectedObjectType.diameter;
    projectileDragCoefficient = selectedObjectType.dragCoefficient;
    gravity = PmConstants.gravityOnEarth;
    altitude = 0;
    airResistanceOn = _defaultAirResistanceOn;
    slowMotion = false;
    isPlaying = true;
    muzzleFlashAge = null;
    _accumulator = 0;
    notifyListeners();
  }

  /// LabModel 覆写：复位所有可编辑类型（LabModel.ts:72-78）
  @protected
  void resetObjectTypes() {}
}

/// Model:406-437 — NASA 标准大气（https://www.grc.nasa.gov/www/k-12/airplane/atmosmet.html）
double calculateAirDensity(double altitude, bool airResistanceOn) {
  if (!airResistanceOn) return 0;
  double temperature;
  double pressure;
  if (altitude < 11000) {
    // troposphere
    temperature = 15.04 - 0.00649 * altitude;
    pressure = 101.29 * math.pow((temperature + 273.1) / 288.08, 5.256);
  } else if (altitude < 25000) {
    // lower stratosphere
    temperature = -56.46;
    pressure = 22.65 * math.exp(1.73 - 0.000157 * altitude);
  } else {
    // upper stratosphere
    temperature = -131.21 + 0.00299 * altitude;
    pressure = 2.488 * math.pow((temperature + 273.1) / 216.6, -11.388);
  }
  return pressure / (0.2869 * (temperature + 273.1));
}
