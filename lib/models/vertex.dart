/// 电路顶点（连接点）
///
/// 对应 PhET CCK 的 Vertex.js
library;

import 'dart:math';
import 'package:flutter/material.dart';

/// 顶点类型
enum VertexType {
  /// 元件端子
  terminal,

  /// 导线连接点
  junction,

  /// 接地点
  ground,
}

/// 电路顶点类
///
/// 顶点是电路中的连接点，多个元件或导线可以连接到同一个顶点。
/// 对应 PhET CCK 的 Vertex.js
class Vertex {
  /// 唯一标识符
  final String id;

  /// X 坐标（世界坐标）
  final double x;

  /// Y 坐标（世界坐标）
  final double y;

  /// 顶点类型
  final VertexType type;

  /// 是否选中
  bool isSelected;

  /// 是否高亮
  bool isHighlighted;

  /// 连接的元件 ID 列表
  final List<String> connectedElementIds;

  /// 构造器
  Vertex({
    required this.id,
    required this.x,
    required this.y,
    this.type = VertexType.terminal,
    this.isSelected = false,
    this.isHighlighted = false,
    this.connectedElementIds = const [],
  });

  /// 获取位置（对应 PhET: getPosition）
  Offset get position => Offset(x, y);

  /// 距离计算（对应 PhET: distanceTo）
  double distanceTo(Vertex other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// 距离计算（Offset 版本）
  double distanceToOffset(Offset other) {
    final dx = x - other.dx;
    final dy = y - other.dy;
    return sqrt(dx * dx + dy * dy);
  }

  /// 是否等于另一个顶点
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vertex && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 创建副本
  Vertex copyWith({
    String? id,
    double? x,
    double? y,
    VertexType? type,
    bool? isSelected,
    bool? isHighlighted,
    List<String>? connectedElementIds,
  }) {
    return Vertex(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      connectedElementIds: connectedElementIds ?? this.connectedElementIds,
    );
  }

  /// 添加到连接列表
  Vertex addConnection(String elementId) {
    if (connectedElementIds.contains(elementId)) return this;
    return copyWith(
      connectedElementIds: [...connectedElementIds, elementId],
    );
  }

  /// 从连接列表移除
  Vertex removeConnection(String elementId) {
    return copyWith(
      connectedElementIds:
          connectedElementIds.where((id) => id != elementId).toList(),
    );
  }
}
