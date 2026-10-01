import 'dart:math' as math;
import 'dart:ui';

import 'data_point.dart';
import 'projectile_object_type.dart';

/// PhET `Trajectory.ts` 的 Flutter 等价（1.1.0-dev.41 逐行对照）。
///
/// 物理核心（Trajectory.ts:229-269, 437-455）：
/// - 恒定 dt = 0.012s 由调用方（model）保证
/// - 积分：p' = p + v·t + ½a·t²（a 取上一点）；v' = v + a·t
/// - 阻力：Fd = ½ρ(πD²/4)Cd|v|v（二次），用新速度重算下一步 a
/// - 落地：y≤0 时按二次方程精确截断本步时间
/// - vx 反号保护：截断至 vx = 0
class PmTrajectory {
  PmTrajectory({
    required this.projectileObjectType,
    required this.mass,
    required this.diameter,
    required this.dragCoefficient,
    required this.initialSpeed,
    required this.initialHeight,
    required this.initialAngle,
    required double Function() gravity,
    required double Function() airDensity,
    required bool Function(double projectileX) checkIfHitTarget,
    required void Function() onMovingCountChanged,
    void Function(PmTrajectory trajectory)? onLanded,
    void Function(PmDataPoint point)? onDataPointAdded,
  })  : _gravity = gravity,
        _airDensity = airDensity,
        _checkIfHitTarget = checkIfHitTarget,
        _onMovingCountChanged = onMovingCountChanged,
        _onLanded = onLanded,
        _onDataPointAdded = onDataPointAdded {
    _onMovingCountChanged(); // numberOfMovingProjectiles++

    // Trajectory.ts:163-168 — 发射点 (0, initialHeight)，v = v0(cosθ, sinθ)
    final velocity = Offset.fromDirection(
      initialAngle * math.pi / 180,
      initialSpeed,
    );
    final dragForce = _dragForceForVelocity(velocity);
    final acceleration = _accelerationForDragForce(dragForce);
    final initialPoint = PmDataPoint(
      time: 0,
      position: Offset(0, initialHeight),
      airDensity: _airDensity(),
      velocity: velocity,
      acceleration: acceleration,
      dragForce: dragForce,
      forceGravity: _gravityForce(),
    );
    _addDataPoint(initialPoint);
    currentPoint = initialPoint;
  }

  final PmProjectileObjectType projectileObjectType;
  final double mass;
  final double diameter;
  final double dragCoefficient;
  final double initialSpeed;
  final double initialHeight;
  final double initialAngle;

  final double Function() _gravity;
  final double Function() _airDensity;
  final bool Function(double projectileX) _checkIfHitTarget;
  final void Function() _onMovingCountChanged;
  final void Function(PmTrajectory trajectory)? _onLanded;
  final void Function(PmDataPoint point)? _onDataPointAdded;

  final List<PmDataPoint> dataPoints = [];
  late PmDataPoint currentPoint;

  PmDataPoint? apexPoint;
  bool reachedGround = false;
  bool changedInMidAir = false;
  int rank = 0;

  double maxHeight = 0;
  double horizontalDisplacement = 0;
  double flightTime = 0;
  bool hasHitTarget = false;

  double _gravityForce() => -_gravity() * mass;

  /// Trajectory.ts:209-210
  Offset _accelerationForDragForce(Offset dragForce) => Offset(
        -dragForce.dx / mass,
        -_gravity() - dragForce.dy / mass,
      );

  /// Trajectory.ts:216-221 — 二次阻力 Fd = ½ρACd|v|v
  Offset _dragForceForVelocity(Offset velocity) {
    final area = math.pi * diameter * diameter / 4;
    return velocity *
        (0.5 * _airDensity() * area * dragCoefficient * velocity.distance);
  }

  /// Trajectory.ts:437-439 — 常加速度运动学
  static double _nextPosition(
          double position, double velocity, double acceleration, double time) =>
      position + velocity * time + 0.5 * acceleration * time * time;

  /// Trajectory.ts:441-455 — 精确落地时间
  static double _timeToGround(PmDataPoint previousPoint) {
    final ay = previousPoint.acceleration.dy;
    final vy = previousPoint.velocity.dy;
    final y = previousPoint.position.dy;
    if (ay == 0) {
      return -y / vy;
    }
    final squareRoot = -math.sqrt(vy * vy - 2 * ay * y);
    return (squareRoot - vy) / ay;
  }

  void step(double dt) {
    assert(!reachedGround, 'Trajectories should not step after reaching ground');

    final previousPoint = dataPoints.last;

    var newY = _nextPosition(previousPoint.y, previousPoint.vy,
        previousPoint.acceleration.dy, dt);
    if (newY <= 0) {
      newY = 0;
      reachedGround = true;
    }

    final cappedDeltaTime = reachedGround ? _timeToGround(previousPoint) : dt;

    var newX = _nextPosition(previousPoint.x, previousPoint.vx,
        previousPoint.acceleration.dx, cappedDeltaTime);
    var newVx =
        previousPoint.vx + previousPoint.acceleration.dx * cappedDeltaTime;
    final newVy =
        previousPoint.vy + previousPoint.acceleration.dy * cappedDeltaTime;

    // Trajectory.ts:242-248 — vx 反号保护
    if (_sign(newVx) != _sign(previousPoint.vx)) {
      final dtForLargeDragX =
          -previousPoint.vx / previousPoint.acceleration.dx;
      newX = _nextPosition(previousPoint.x, previousPoint.vx,
          previousPoint.acceleration.dx, dtForLargeDragX);
      newVx = 0;
    }

    final newPosition = Offset(newX, newY);
    final newVelocity = Offset(newVx, newVy);
    final newDragForce = _dragForceForVelocity(newVelocity);
    final newAcceleration = _accelerationForDragForce(newDragForce);

    // Trajectory.ts:257-259 — apex 检测
    if (previousPoint.vy > 0 && newVelocity.dy < 0) {
      _handleApex(previousPoint);
    }

    final newPoint = PmDataPoint(
      time: previousPoint.time + cappedDeltaTime,
      position: newPosition,
      airDensity: _airDensity(),
      velocity: newVelocity,
      acceleration: newAcceleration,
      dragForce: newDragForce,
      forceGravity: _gravityForce(),
      reachedGround: reachedGround,
    );

    _addDataPoint(newPoint);
    currentPoint = newPoint;

    if (reachedGround) {
      _handleLanded();
    }
  }

  void _handleLanded() {
    // Trajectory.ts:272-278
    _onMovingCountChanged(); // numberOfMovingProjectiles--
    hasHitTarget = _checkIfHitTarget(currentPoint.x);
    _onLanded?.call(this);
  }

  /// Trajectory.ts:280-302 — apex 插值点
  void _handleApex(PmDataPoint previousPoint) {
    final dtToApex =
        (previousPoint.vy / previousPoint.acceleration.dy).abs();
    final apexX = _nextPosition(previousPoint.x, previousPoint.vx,
        previousPoint.acceleration.dx, dtToApex);
    final apexY = _nextPosition(previousPoint.y, previousPoint.vy,
        previousPoint.acceleration.dy, dtToApex);
    final apexVelocity = Offset(
      previousPoint.vx + previousPoint.acceleration.dx * dtToApex,
      0,
    );
    final apexDragForce = _dragForceForVelocity(apexVelocity);
    final apexAcceleration = _accelerationForDragForce(apexDragForce);

    apexPoint = PmDataPoint(
      time: previousPoint.time + dtToApex,
      position: Offset(apexX, apexY),
      airDensity: _airDensity(),
      velocity: apexVelocity,
      acceleration: apexAcceleration,
      dragForce: apexDragForce,
      forceGravity: _gravityForce(),
      apex: true,
    );
    _addDataPoint(apexPoint!);
  }

  void _addDataPoint(PmDataPoint dataPoint) {
    dataPoints.add(dataPoint);
    // Trajectory.ts:183-190
    if (dataPoint.y > maxHeight) maxHeight = dataPoint.y;
    horizontalDisplacement = dataPoint.x;
    flightTime = dataPoint.time;
    // Trajectory.ts:306-309 — DataProbe 增量更新
    _onDataPointAdded?.call(dataPoint);
  }

  /// Trajectory.ts:317-338 — 最近点（距离相等取时间更大者）
  PmDataPoint? getNearestPoint(double x, double y) {
    if (dataPoints.isEmpty) return null;
    var nearest = dataPoints.first;
    var minDistance = (nearest.position - Offset(x, y)).distance;
    for (final point in dataPoints) {
      final d = (point.position - Offset(x, y)).distance;
      if (d <= minDistance) {
        nearest = point;
        minDistance = d;
      }
    }
    return nearest;
  }

  static int _sign(double v) => v == 0 ? 0 : (v > 0 ? 1 : -1);
}
