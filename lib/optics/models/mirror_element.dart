import 'package:flutter/material.dart';

import '../physics/optics_math.dart';
import 'optical_element.dart';
import 'optics_world.dart';

// 镜子元件类
class MirrorElement extends OpticalElement {
  const MirrorElement({
    required super.id,
    super.type = OpticalElementType.mirror,
    required this.mirrorKind,
    this.diameter = 6.0,
    this.radius = 180, // default matching OpticsState mirror mode
    required super.x,
    required super.y,
    super.rotation = 0,
    super.width = 2,   // 匹配视觉 6×80px 镜面图标
    super.height = 6,
  });

  final MirrorType mirrorKind;
  final double diameter;
  final double radius;

  // 工厂方法：从场景配置创建
  static MirrorElement create({
    required String id,
    Offset? position,
    MirrorType? mirrorType,
    double? diameter,
    double? radius,
  }) {
    return MirrorElement(
      id: id,
      mirrorKind: mirrorType ?? MirrorType.plane,
      diameter: diameter ?? 6.0,
      radius: radius ?? 180,
      x: position?.dx ?? 0,
      y: position?.dy ?? 0,
    );
  }

  // 焦距
  double get focalLength => switch (mirrorKind) {
        MirrorType.concave => radius / 2,
        MirrorType.convex => -radius / 2,
        MirrorType.plane => double.infinity,
      };

  @override
  InteractionResult interact(List<Ray> incomingRays, OpticsWorld world) {
    final outRays = <Ray>[];
    final virtualRays = <Ray>[];
    for (final ray in incomingRays) {
      final hit = intersect(ray);
      if (hit == null) continue;
      final result = interactAt(ray, hit, world);
      outRays.addAll(result.outRays);
      virtualRays.addAll(result.virtualRays);
    }
    return InteractionResult(outRays: outRays, virtualRays: virtualRays);
  }

  @override
  OpticalHit? intersect(Ray ray) {
    if (ray.direction.dx.abs() < 0.001) return null;
    final t = (x - ray.origin.dx) / ray.direction.dx;
    if (t <= 0.001) return null;
    final point = ray.origin + ray.direction * t;
    if ((point.dy - y).abs() > diameter / 2) return null;
    return OpticalHit(point: point, distance: t);
  }

  @override
  InteractionResult interactAt(Ray ray, OpticalHit hit, OpticsWorld world) {
    final Offset reflectedDirection;
    if (mirrorKind == MirrorType.plane || radius.abs() < 1e-6) {
      // 平面镜：x 方向翻转
      reflectedDirection = Offset(-ray.direction.dx, ray.direction.dy);
    } else {
      // 曲面镜球面反射：球心 (x + radius, y)，radius > 0 凹面 / < 0 凸面
      final center = Offset(x + radius, y);
      final normal = OpticsMath.directionTo(center, hit.point);
      final dot = ray.direction.dx * normal.dx + ray.direction.dy * normal.dy;
      reflectedDirection = Offset(
        ray.direction.dx - 2 * dot * normal.dx,
        ray.direction.dy - 2 * dot * normal.dy,
      );
    }
    final reflectedRay = Ray(
      origin: hit.point,
      direction: reflectedDirection,
      intensity: ray.intensity * 0.95,
      color: ray.color,
    );
    final virtualRay = Ray(
      origin: hit.point,
      direction: -reflectedDirection,
      intensity: ray.intensity * 0.5,
      color: ray.color.withValues(alpha: 0.5),
    );
    return InteractionResult(outRays: [reflectedRay], virtualRays: [virtualRay]);
  }

  @override
  void paint(Canvas canvas, Paint paint, OpticsWorld world) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );

    // 绘制镜子主体
    paint.color = switch (mirrorKind) {
      MirrorType.concave => Colors.green.withValues(alpha: 0.3),
      MirrorType.convex => Colors.orange.withValues(alpha: 0.3),
      MirrorType.plane => Colors.grey.withValues(alpha: 0.3),
    };
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // 绘制边框
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(rect, paint);

    // 绘制焦距标记
    if (world.showFocalPoints && !focalLength.isInfinite) {
      final focalX = x - focalLength; // 镜子焦距在镜子前面
      paint.color = Colors.red;
      paint.strokeWidth = 1;
      canvas.drawLine(
        Offset(focalX, y - 10),
        Offset(focalX, y + 10),
        paint,
      );
    }
  }

  @override
  OpticalElement copyWith({
    String? id,
    OpticalElementType? type,
    MirrorType? mirrorKind,
    double? diameter,
    double? radius,
    double? x,
    double? y,
    double? rotation,
    double? width,
    double? height,
  }) {
    return MirrorElement(
      id: id ?? this.id,
      mirrorKind: mirrorKind ?? this.mirrorKind,
      diameter: diameter ?? this.diameter,
      radius: radius ?? this.radius,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
