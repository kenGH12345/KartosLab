import 'dart:ui';

import 'package:flutter/foundation.dart';

/// 位置元件基类：跨 sim 元件公共底座（id / 类型 / 位置 / 旋转 / 尺寸 / 命中检测）。
///
/// 源自 shared-abstraction-plan 候选 1（2026-08-07 上抽）。当前用户：
/// - optics 的 [OpticalElement]（4 子类：透镜 / 平面镜 / 光源 / 屏）
/// - circuit 的 [CircuitComponent]（电池 / 电阻 / 灯泡 / 开关等）
///
/// 域特化行为（光线交互 / 电路物理 / 渲染 / 物理值）由子类各自实现，不上抽
/// （shared-abstraction-plan §三 L2）。
///
/// [width]/[height] 用抽象 getter：子类既可用 final 字段（如光学元件），
/// 也可按类型计算（如电路元件），两边自由度最大化。
@immutable
abstract class PositionElement<TType> {
  const PositionElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.rotation = 0,
  });

  final String id;
  final TType type;
  final double x;
  final double y;
  final double rotation;

  /// 元件尺寸（子类提供：字段或按类型计算的 getter）
  double get width;
  double get height;

  /// 命中检测：默认按中心矩形；子类可 override（如电路元件的磁吸 padding）
  bool hitTest(Offset position) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );
    return rect.contains(position);
  }
}
