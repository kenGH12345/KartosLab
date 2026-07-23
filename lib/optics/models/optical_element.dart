import 'package:flutter/material.dart';
import 'optics_world.dart';

// 光学元件类型枚举
enum OpticalElementType {
  lens,
  mirror,
  lightSource,
  screen,
  candle,
  prism;

  /// 类型名称 → 枚举值解析
  static OpticalElementType parseType(String type) {
    switch (type) {
      case 'lens':
        return OpticalElementType.lens;
      case 'mirror':
        return OpticalElementType.mirror;
      case 'lightSource':
      case 'light_source':
        return OpticalElementType.lightSource;
      case 'screen':
        return OpticalElementType.screen;
      case 'candle':
        return OpticalElementType.candle;
      case 'prism':
        return OpticalElementType.prism;
      default:
        throw FormatException('Unknown optical element type: $type');
    }
  }
}

// 透镜类型
enum LensType {
  convex,
  concave,
}

// 镜子类型
enum MirrorType {
  concave,
  convex,
  plane,
}

// 光线模式
enum RayMode {
  edge,
  principal,
  many,
  none,
}

// 光源类型
enum SourceType {
  object,
  point,
  parallel,
}

// 光线类
class Ray {
  const Ray({
    required this.origin,
    required this.direction,
    this.intensity = 1.0,
    this.color = const Color(0xFFFFFFFF),
  });

  final Offset origin;
  final Offset direction;
  final double intensity;
  final Color color;

  Ray copyWith({
    Offset? origin,
    Offset? direction,
    double? intensity,
    Color? color,
  }) {
    return Ray(
      origin: origin ?? this.origin,
      direction: direction ?? this.direction,
      intensity: intensity ?? this.intensity,
      color: color ?? this.color,
    );
  }
}

// 元件交互结果
class InteractionResult {
  const InteractionResult({
    required this.outRays,
    this.virtualRays = const [],
    this.isAbsorbed = false,
  });

  final List<Ray> outRays;
  final List<Ray> virtualRays;
  final bool isAbsorbed;
}

// 光学元件抽象基类
@immutable
abstract class OpticalElement {
  const OpticalElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.rotation = 0,
    required this.width,
    required this.height,
  });

  final String id;
  final OpticalElementType type;
  final double x;
  final double y;
  final double rotation;
  final double width;
  final double height;

  // 核心方法：光线与元件交互
  InteractionResult interact(List<Ray> incomingRays, OpticsWorld world);

  // 光线命中检测：默认不参与光线追踪
  OpticalHit? intersect(Ray ray) => null;

  // 单条光线在指定命中点交互：默认复用批量 interact
  InteractionResult interactAt(Ray ray, OpticalHit hit, OpticsWorld world) {
    return interact([ray], world);
  }

  // 命中检测
  bool hitTest(Offset position) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );
    return rect.contains(position);
  }

  // 渲染
  void paint(Canvas canvas, Paint paint, OpticsWorld world);

  // 不可变拷贝
  OpticalElement copyWith({
    String? id,
    OpticalElementType? type,
    double? x,
    double? y,
    double? rotation,
    double? width,
    double? height,
  });
}

class OpticalHit {
  const OpticalHit({required this.point, required this.distance});

  final Offset point;
  final double distance;
}
