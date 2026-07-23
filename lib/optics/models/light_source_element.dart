import 'package:flutter/material.dart';

import 'optical_element.dart';
import 'optics_world.dart';

// 光源元件类
class LightSourceElement extends OpticalElement {
  const LightSourceElement({
    required super.id,
    super.type = OpticalElementType.lightSource,
    this.objectHeight = 5.0,
    this.sourceType = SourceType.object,
    required super.x,
    required super.y,
    super.rotation = 0,
    super.width = 4,   // 匹配视觉 pencil.svg 30×50px + 标签
    super.height = 6,  // = 约 2×3 世界单位，加容错
  });

  final double objectHeight;
  final SourceType sourceType;

  // 工厂方法：从场景配置创建
  static LightSourceElement create({
    required String id,
    Offset? position,
    SourceType? sourceType,
    double? objectHeight,
  }) {
    return LightSourceElement(
      id: id,
      sourceType: sourceType ?? SourceType.object,
      objectHeight: objectHeight ?? 5.0,
      x: position?.dx ?? 0,
      y: position?.dy ?? 0,
    );
  }

  @override
  InteractionResult interact(List<Ray> incomingRays, OpticsWorld world) {
    // 光源不"交互"，它产生光线
    return const InteractionResult(outRays: []);
  }

  @override
  void paint(Canvas canvas, Paint paint, OpticsWorld world) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );

    // 绘制光源主体
    paint.color = Colors.yellow.withValues(alpha: 0.5);
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // 绘制边框
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(rect, paint);

    // 绘制光线发射示意
    paint.color = const Color(0xFFFFE4B5);
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(x + width / 2, y),
      Offset(x + width / 2 + 50, y),
      paint,
    );
  }

  @override
  OpticalElement copyWith({
    String? id,
    OpticalElementType? type,
    double? objectHeight,
    SourceType? sourceType,
    double? x,
    double? y,
    double? rotation,
    double? width,
    double? height,
  }) {
    return LightSourceElement(
      id: id ?? this.id,
      objectHeight: objectHeight ?? this.objectHeight,
      sourceType: sourceType ?? this.sourceType,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
