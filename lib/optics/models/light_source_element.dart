import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../physics/optics_math.dart';
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

  // 发射光线（由 Solver 调用）：多条光线覆盖透镜口径，折射后汇聚于像点
  List<Ray> emitRays({Offset? lensCenter, double lensDiameter = 10}) {
    final halfHeight = objectHeight / 2;
    final top = Offset(x, y - halfHeight); // 物体顶端
    switch (sourceType) {
      case SourceType.object:
        // 5条光线覆盖透镜口径，折射后全部汇聚于同一像点
        final halfLens = lensDiameter / 2;
        final step = halfLens * 2 / 4; // 4个间隔
        final colors = const [
          Color(0xFFFFD700), // 金（平行光）
          Color(0xFF22C55E), // 绿（中心光）
          Color(0xFF22C55E), // 绿
          Color(0xFF22C55E), // 绿
          Color(0xFF22C55E), // 绿
        ];
        return List.generate(5, (i) {
          final lensY = -halfLens + i * step;
          final direction = i == 0
              ? const Offset(1, 0) // 第0条：平行光
              : OpticsMath.directionTo(top, Offset(lensCenter?.dx ?? 0, (lensCenter?.dy ?? 0) + lensY));
          return Ray(origin: top, direction: direction, intensity: 1.0, color: colors[i]);
        });
      case SourceType.point:
        return _emitManyRays(7);
      case SourceType.parallel:
        return _emitParallelRays();
    }
  }

  // 发射平行光线
  List<Ray> _emitParallelRays() {
    final halfHeight = objectHeight / 2;
    final step = objectHeight / 4;
    return List.generate(5, (i) {
      final y = -halfHeight + i * step;
      return _createRay(y);
    });
  }

  // 发射边缘光线
  List<Ray> _emitEdgeRays() {
    final halfHeight = objectHeight / 2;
    return [
      _createRay(-halfHeight),
      _createRay(0),
      _createRay(halfHeight),
    ];
  }

  // 发射主要光线
  List<Ray> _emitPrincipalRays() {
    final halfHeight = height / 2;
    return [
      _createRay(-halfHeight * 0.72),
      _createRay(0),
      _createRay(halfHeight * 0.72),
    ];
  }

  // 发射多条光线
  List<Ray> _emitManyRays(int count) {
    final halfHeight = height / 2;
    final step = height / (count - 1);
    return List.generate(count, (i) {
      final y = -halfHeight + i * step;
      return _createRay(y);
    });
  }

  // 创建单条光线
  Ray _createRay(double offsetY) {
    return Ray(
      origin: Offset(x, y + offsetY),
      direction: const Offset(1, 0),
      intensity: 1.0,
      color: const Color(0xFFFFE4B5),
    );
  }

  @override
  void paint(Canvas canvas, Paint paint, OpticsWorld world) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );

    // 绘制光源主体
    paint.color = Colors.yellow.withOpacity(0.5);
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
