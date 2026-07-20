import 'package:flutter/material.dart';

import 'optical_element.dart';
import 'optics_world.dart';

class ScreenElement extends OpticalElement {
  const ScreenElement({
    required super.id,
    super.type = OpticalElementType.screen,
    required super.x,
    required super.y,
    super.rotation = 0,
    super.width = 2,    // 匹配视觉 6×80px 光屏图标
    super.height = 6,
  });

  static ScreenElement create({
    required String id,
    Offset? position,
  }) {
    return ScreenElement(
      id: id,
      x: position?.dx ?? 0,
      y: position?.dy ?? 0,
    );
  }

  @override
  InteractionResult interact(List<Ray> incomingRays, OpticsWorld world) {
    final outRays = <Ray>[];
    for (final ray in incomingRays) {
      final hit = intersect(ray);
      if (hit != null) outRays.add(ray.copyWith(origin: hit.point));
    }
    return InteractionResult(outRays: outRays, isAbsorbed: true);
  }

  @override
  OpticalHit? intersect(Ray ray) {
    if (ray.direction.dx.abs() < 0.001) return null;
    final t = (x - ray.origin.dx) / ray.direction.dx;
    if (t <= 0.001) return null;
    final point = ray.origin + ray.direction * t;
    if ((point.dy - y).abs() > height / 2) return null;
    return OpticalHit(point: point, distance: t);
  }

  @override
  void paint(Canvas canvas, Paint paint, OpticsWorld world) {
    final rect = Rect.fromCenter(center: Offset(x, y), width: width, height: height);
    paint.color = Colors.grey.withValues(alpha: 0.4);
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(rect, paint);
  }

  @override
  OpticalElement copyWith({
    String? id, OpticalElementType? type, double? x, double? y,
    double? rotation, double? width, double? height,
  }) {
    return ScreenElement(
      id: id ?? this.id, x: x ?? this.x, y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width, height: height ?? this.height,
    );
  }
}

class ScreenHit {
  const ScreenHit({
    required this.screenId,
    required this.point,
    required this.intensity,
    this.distanceToImage,
  });
  final String screenId;
  final Offset point;
  final double intensity;
  final double? distanceToImage;
}
