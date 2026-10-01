import 'package:flutter/material.dart';

import '../controller/projectile_motion_controller.dart';
import '../model/data_point.dart';
import '../model/trajectory.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';
import '../transform/pm_transform.dart';
import '../view/pm_image_cache.dart';
import '../view/projectile_view_factory.dart';

/// TrajectoryNode.ts + ProjectileNode.ts 的 Flutter 等价。
///
/// - 折线连接 DataPoint，宽 2px；阻力开洋红 / 关蓝
/// - 时间点：每 1000ms 大点 r=3.3，每 100ms 小点 r=1.65
/// - apex 绿点；rank 透明度衰减
/// - 抛体 = 轨迹最新点（同一数据，禁止双轨）
class PmTrajectoriesPainter extends CustomPainter {
  PmTrajectoriesPainter({
    required this.transform,
    required this.images,
    required this.trajectories,
    required this.viewProperties,
  });

  final PmTransform transform;
  final PmImageCache images;
  final List<PmTrajectory> trajectories;
  final PmViewProperties viewProperties;

  @override
  void paint(Canvas canvas, Size size) {
    for (final trajectory in trajectories) {
      _paintTrajectory(canvas, trajectory);
    }
  }

  void _paintTrajectory(Canvas canvas, PmTrajectory trajectory) {
    final points = trajectory.dataPoints;
    if (points.isEmpty) return;

    final pathOpacity = PmConstants.pathOpacityForRank(trajectory.rank);
    final dotsOpacity = PmConstants.dotsOpacityForRank(trajectory.rank);

    // ── 轨迹线（段级着色：该点空气密度>0 → 洋红）────────────────────────
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final hasDrag = prev.airDensity > 0;
      final paint = Paint()
        ..color = (hasDrag
                ? PmConstants.airResistanceOnPathColor
                : PmConstants.airResistanceOffPathColor)
            .withValues(alpha: pathOpacity)
        ..strokeWidth = PmConstants.pathWidth
        ..style = PaintingStyle.stroke;
      canvas.drawLine(transform.modelToView(prev.position),
          transform.modelToView(curr.position), paint);
    }

    // ── 时间点（TrajectoryNode:114-120）─────────────────────────────────
    for (final point in points) {
      final ms = (point.time * 1000).round();
      double? radius;
      if (ms % 1000 == 0) {
        radius = PmConstants.largeDotRadius;
      } else if (ms % 100 == 0) {
        radius = PmConstants.smallDotRadius;
      }
      if (radius != null) {
        canvas.drawCircle(
            transform.modelToView(point.position),
            radius,
            Paint()
              ..color = Colors.black.withValues(alpha: dotsOpacity));
      }
    }

    // ── apex 绿点（TrajectoryNode:124-132）──────────────────────────────
    final apex = trajectory.apexPoint;
    if (apex != null) {
      canvas.drawCircle(
          transform.modelToView(apex.position),
          PmConstants.smallDotRadius,
          Paint()
            ..color = PmColors.apexDot.withValues(alpha: pathOpacity));
    }

    // ── 抛体（= 最新 DataPoint，TrajectoryNode:47 不可拖）────────────────
    final current = trajectory.currentPoint;
    final center = transform.modelToView(current.position);
    final viewDiameter = transform.modelToViewDeltaX(trajectory.diameter);
    final visual = PmProjectileViewFactory.create(
        trajectory.projectileObjectType, viewDiameter, trajectory.reachedGround);
    final rotation = trajectory.projectileObjectType.rotates
        ? -current.velocity.direction // 屏坐标 y 翻转
        : 0.0;
    canvas.save();
    canvas.saveLayer(
        Rect.fromCircle(center: center, radius: 1000),
        Paint()..color = Colors.white.withValues(alpha: pathOpacity));
    PmProjectilePainter.draw(canvas, images, visual, center, rotation);
    canvas.restore();
    canvas.restore();

    // ── 向量（ProjectileNode + FreeBodyDiagram）─────────────────────────
    if (!trajectory.reachedGround) {
      _paintVectors(canvas, center, current);
    }
  }

  void _paintVectors(Canvas canvas, Offset center, PmDataPoint point) {
    final vp = viewProperties;
    // 速度（绿，标量 15）
    if (vp.showTotalVelocityVector) {
      _drawArrow(canvas, center,
          point.velocity * PmConstants.velocityVectorScalar,
          PmColors.velocityVectorFill);
    }
    if (vp.showVelocityComponentVectors) {
      _drawArrow(canvas, center,
          Offset(point.vx, 0) * PmConstants.velocityVectorScalar,
          PmColors.velocityVectorFill);
      _drawArrow(canvas, center,
          Offset(0, point.vy) * PmConstants.velocityVectorScalar,
          PmColors.velocityVectorFill);
    }
    // 加速度（黄，标量 15）
    if (vp.showTotalAccelerationVector) {
      _drawArrow(canvas, center,
          point.acceleration * PmConstants.accelerationVectorScalar,
          PmColors.accelerationVectorFill);
    }
    if (vp.showAccelerationComponentVectors) {
      _drawArrow(canvas, center,
          Offset(point.acceleration.dx, 0) *
              PmConstants.accelerationVectorScalar,
          PmColors.accelerationVectorFill);
      _drawArrow(canvas, center,
          Offset(0, point.acceleration.dy) *
              PmConstants.accelerationVectorScalar,
          PmColors.accelerationVectorFill);
    }
    // 力（黑，标量 3，FBD 偏移 (-40,-40)）
    if (vp.showTotalForceVector || vp.showForceComponentVectors) {
      final origin = center + const Offset(-40, -40);
      final gravity = Offset(0, point.forceGravity); // model 向量（向下为负）
      final drag = -point.dragForce;
      final total = gravity + drag;
      if (vp.showTotalForceVector) {
        _drawArrow(canvas, origin, total * PmConstants.forceVectorScalar,
            PmColors.forceVectorFill);
        _drawArrow(canvas, origin, gravity * PmConstants.forceVectorScalar,
            PmColors.forceVectorFill);
        if (drag != Offset.zero) {
          _drawArrow(canvas, origin, drag * PmConstants.forceVectorScalar,
              PmColors.forceVectorFill);
        }
      } else {
        _drawArrow(canvas, origin, Offset(total.dx, 0) * 3,
            PmColors.forceVectorFill);
        _drawArrow(canvas, origin, Offset(0, total.dy) * 3,
            PmColors.forceVectorFill);
      }
    }
  }

  /// PhET ArrowNode 风格（tailWidth 4, headWidth 10, headHeight 8）
  static void _drawArrow(Canvas canvas, Offset tail, Offset delta, Color color) {
    // model 向量 → 屏向量：y 翻转（调用方已处理分量符号，此处统一翻 y）
    final tip = tail + Offset(delta.dx, -delta.dy);
    final length = (tip - tail).distance;
    if (length < 4) return;
    final dir = (tip - tail) / length;
    final perp = Offset(-dir.dy, dir.dx);
    final headBase = tip - dir * 8;
    final path = Path()
      ..moveTo(tail.dx + perp.dx * 2, tail.dy + perp.dy * 2)
      ..lineTo(headBase.dx + perp.dx * 2, headBase.dy + perp.dy * 2)
      ..lineTo(headBase.dx + perp.dx * 5, headBase.dy + perp.dy * 5)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(headBase.dx - perp.dx * 5, headBase.dy - perp.dy * 5)
      ..lineTo(headBase.dx - perp.dx * 2, headBase.dy - perp.dy * 2)
      ..lineTo(tail.dx - perp.dx * 2, tail.dy - perp.dy * 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(PmTrajectoriesPainter oldDelegate) => true;
}
