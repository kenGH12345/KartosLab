import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/projectile_object_type.dart';
import '../pm_assets.dart';
import 'pm_image_cache.dart';

/// 一个抛体视图的绘制描述。
sealed class PmProjectileVisual {
  const PmProjectileVisual();
}

/// 自绘圆（cannonball 黑 / golfBall 白+灰边）
class PmCircleVisual extends PmProjectileVisual {
  const PmCircleVisual({required this.radius, required this.fill, this.stroke});

  final double radius;
  final Color fill;
  final Color? stroke;
}

/// 图片（已按原版 maxWidth/maxHeight 规则换算出目标像素尺寸）
class PmImageVisual extends PmProjectileVisual {
  const PmImageVisual({
    required this.asset,
    required this.width,
    required this.height,
    this.alignBottom = false,
  });

  final String asset;
  final double width;
  final double height;

  /// human/car 落地时 bottom = centerY（ProjectileNode:158-174）
  final bool alignBottom;
}

/// Custom / COMPANIONLESS 的泪滴-半球自绘（createCustom）
class PmCustomVisual extends PmProjectileVisual {
  const PmCustomVisual({required this.radius, required this.dragCoefficient});

  final double radius;
  final double dragCoefficient;
}

/// PhET `ProjectileObjectViewFactory.ts` 的 Flutter 等价。
/// 输入：view 单位的直径（已乘 MVT scale）。
abstract final class PmProjectileViewFactory {
  static PmProjectileVisual create(
    PmProjectileObjectType type,
    double viewDiameter,
    bool landed,
  ) {
    switch (type.benchmark) {
      case 'cannonball':
        return PmCircleVisual(
            radius: viewDiameter / 2, fill: Colors.black);
      case 'golfBall':
        return PmCircleVisual(
            radius: viewDiameter / 2, fill: Colors.white, stroke: Colors.grey);
      case 'baseball':
        return _image(PmAssets.baseball, width: viewDiameter);
      case 'pumpkin':
        return landed
            ? _image(PmAssets.pumpkinLanded, height: viewDiameter * 0.75)
            : _image(PmAssets.pumpkinFlying, height: viewDiameter * 0.95);
      case 'car':
        return landed
            ? _image(PmAssets.carLanded,
                height: viewDiameter * 1.7, alignBottom: true)
            : _image(PmAssets.carFlying, height: viewDiameter * 0.75);
      case 'football':
        return _image(PmAssets.football, height: viewDiameter);
      case 'human':
        return landed
            ? _image(PmAssets.humanLanded,
                width: viewDiameter * 1.35, alignBottom: true)
            : _image(PmAssets.humanFlying, height: viewDiameter * 1.9);
      case 'piano':
        return landed
            ? _image(PmAssets.pianoLanded, width: viewDiameter * 1.3)
            : _image(PmAssets.pianoFlying, width: viewDiameter * 1.1);
      case 'tankShell':
        return _image(PmAssets.tankShell, height: viewDiameter);
      default: // custom / companionless
        return PmCustomVisual(
            radius: viewDiameter / 2, dragCoefficient: type.dragCoefficient);
    }
  }

  static PmImageVisual _image(String asset,
      {double? width, double? height, bool alignBottom = false}) {
    // 另一维度由 painter 按图片固有宽高比换算
    return PmImageVisual(
        asset: asset,
        width: width ?? 0,
        height: height ?? 0,
        alignBottom: alignBottom);
  }
}

/// 抛体 + 向量绘制共用工具。
abstract final class PmProjectilePainter {
  static void draw(
    Canvas canvas,
    PmImageCache images,
    PmProjectileVisual visual,
    Offset center,
    double rotationRadians,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationRadians);
    switch (visual) {
      case PmCircleVisual v:
        final paint = Paint()..color = v.fill;
        canvas.drawCircle(Offset.zero, v.radius, paint);
        if (v.stroke != null) {
          canvas.drawCircle(
              Offset.zero,
              v.radius,
              Paint()
                ..color = v.stroke!
                ..style = PaintingStyle.stroke);
        }
      case PmImageVisual v:
        final image = images[v.asset];
        if (image != null) {
          final aspect = image.width / image.height;
          final w = v.width > 0 ? v.width : v.height * aspect;
          final h = v.height > 0 ? v.height : v.width / aspect;
          // 默认 center 锚点；alignBottom 时底边对齐 center.y
          final top = v.alignBottom ? -h : -h / 2;
          final dst = Rect.fromLTWH(-w / 2, top, w, h);
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
                0, 0, image.width.toDouble(), image.height.toDouble()),
            dst,
            Paint()
              ..filterQuality = FilterQuality.medium,
          );
        }
      case PmCustomVisual v:
        canvas.drawPath(_customPath(v.radius, v.dragCoefficient),
            Paint()..color = Colors.black);
    }
    canvas.restore();
  }

  /// createCustom（ProjectileObjectViewFactory.ts:103-156）
  static Path _customPath(double radius, double dragCoefficient) {
    if (dragCoefficient <= 0.47) {
      // teardrop→sphere：m ∈ [4,0]
      final m = _linear(0.04, 0.47, 4, 0, dragCoefficient);
      final path = Path()..moveTo(-radius, 0);
      var maxY = 0.0;
      final points = <Offset>[];
      for (var t = math.pi / 24; t < 2 * math.pi; t += math.pi / 24) {
        final x = -math.cos(t) * radius;
        final y = math.sin(t) * math.pow(math.sin(0.5 * t), m) * radius;
        points.add(Offset(x, y));
        if (y.abs() > maxY) maxY = y.abs();
      }
      // 保持截面积（源码按 bounds 缩放）
      final scale = maxY > 0 ? radius / maxY : 1.0;
      for (final p in points) {
        path.lineTo(p.dx * scale, p.dy * scale);
      }
      path.close();
      return path;
    } else {
      // sphere→hemisphere
      final path = Path();
      path.addArc(Rect.fromCircle(center: Offset.zero, radius: radius),
          math.pi / 2, math.pi);
      final angle = _linear(0.47, 1.17, math.pi / 2, 0, dragCoefficient);
      final newRadius = radius / math.sin(angle);
      final newCenterX = -radius / math.tan(angle);
      path.moveTo(0, -radius);
      path.addArc(
          Rect.fromCircle(center: Offset(newCenterX, 0), radius: newRadius),
          -angle, 2 * angle);
      path.close();
      return path;
    }
  }

  static double _linear(
          double a1, double b1, double a2, double b2, double v) =>
      a2 + (b2 - a2) * (v - a1) / (b1 - a1);
}

/// ui.Image 尺寸访问
extension PmImageSize on ui.Image {
  Size get size => Size(width.toDouble(), height.toDouble());
}
