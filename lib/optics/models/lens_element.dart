import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../physics/optics_math.dart';
import 'optical_element.dart';
import 'optics_world.dart';

// 透镜元件类
class LensElement extends OpticalElement {
  const LensElement({
    required super.id,
    super.type = OpticalElementType.lens,
    required this.lensKind,
    this.focalLength = 10.0,
    this.diameter = 5.0,
    required super.x,
    required super.y,
    super.rotation = 0,
    super.width = 4,   // 匹配视觉 40×130px 透镜图标
    super.height = 14, // ≈ 2×7 世界单位，加容错
  });

  final LensType lensKind;
  final double focalLength;
  final double diameter;

  // 工厂方法：从场景配置创建
  static LensElement create({
    required String id,
    Offset? position,
    LensType? lensType,
    double? focalLength,
    double? diameter,
  }) {
    return LensElement(
      id: id,
      lensKind: lensType ?? LensType.convex,
      focalLength: focalLength ?? 10.0,
      diameter: diameter ?? 5.0,
      x: position?.dx ?? 0,
      y: position?.dy ?? 0,
    );
  }

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
    final f = lensKind == LensType.convex ? focalLength.abs() : -focalLength.abs();
    if (f.abs() < 1e-6) return const InteractionResult(outRays: []);

    // 用透镜公式计算像点 → 所有光线折射后汇聚于同一点
    final u = x - ray.origin.dx;
    if (u.abs() < 0.001) return const InteractionResult(outRays: []);
    final v = OpticsMath.imageDistance(u, f);
    final mag = -v / u;
    final imagePoint = Offset(x + v, y + (ray.origin.dy - y) * mag);
    final isVirt = v < 0;

    // 真实像：折射光线指向像点；虚像：折射光线背离像点
    final visibleDirection = isVirt
        ? OpticsMath.directionTo(imagePoint, hit.point)
        : OpticsMath.directionTo(hit.point, imagePoint);

    final outRay = Ray(
      origin: hit.point,
      direction: visibleDirection,
      intensity: ray.intensity * 0.95,
      color: ray.color,
    );

    final virtualRays = <Ray>[];
    if (isVirt) {
      virtualRays.add(Ray(
        origin: hit.point,
        direction: OpticsMath.directionTo(hit.point, imagePoint),
        intensity: ray.intensity * 0.5,
        color: ray.color.withValues(alpha: 0.5),
      ));
    }

    return InteractionResult(outRays: [outRay], virtualRays: virtualRays);
  }

  @override
  void paint(Canvas canvas, Paint paint, OpticsWorld world) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );

    // 绘制透镜主体
    paint.color = lensKind == LensType.convex
        ? Colors.blue.withOpacity(0.3)
        : Colors.red.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // 绘制边框
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(rect, paint);

    // 绘制焦距标记
    if (world.showFocalPoints) {
      final focalX = x + focalLength;
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
    LensType? lensKind,
    double? focalLength,
    double? diameter,
    double? x,
    double? y,
    double? rotation,
    double? width,
    double? height,
  }) {
    return LensElement(
      id: id ?? this.id,
      lensKind: lensKind ?? this.lensKind,
      focalLength: focalLength ?? this.focalLength,
      diameter: diameter ?? this.diameter,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
