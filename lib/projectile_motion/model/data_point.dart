import 'dart:ui';

/// PhET `DataPoint.ts`：轨迹上的一个采样点。
/// 单位 mks。字段与源码一一对应（DataPoint.ts:35-44）。
class PmDataPoint {
  const PmDataPoint({
    required this.time,
    required this.position,
    required this.airDensity,
    required this.velocity,
    required this.acceleration,
    required this.dragForce,
    required this.forceGravity,
    this.apex = false,
    this.reachedGround = false,
  });

  /// 自发射累计时间（s）
  final double time;

  /// 位置（m），x = 水平射程，y = 高度
  final Offset position;

  /// 该点处空气密度（kg/m³）
  final double airDensity;

  /// 速度（m/s）
  final Offset velocity;

  /// 加速度（m/s²）
  final Offset acceleration;

  /// 阻力（N）
  final Offset dragForce;

  /// 重力（N，向下为负）
  final double forceGravity;

  final bool apex;
  final bool reachedGround;

  double get x => position.dx;
  double get y => position.dy;
  double get vx => velocity.dx;
  double get vy => velocity.dy;
}
