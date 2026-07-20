import 'package:flutter/foundation.dart';

import '../models/optical_element.dart';
import '../models/optics_world.dart';

// 约束类型枚举
enum ConstraintType {
  alignment,
  distance,
  order,
}

// 约束类
@immutable
class Constraint {
  const Constraint({
    required this.id,
    required this.type,
    required this.description,
    required this.params,
    required this.enforced,
  });

  final String id;
  final ConstraintType type;
  final String description;
  final Map<String, dynamic> params;
  final bool enforced;

  // 验证约束是否满足
  bool validate(OpticsWorld world) {
    switch (type) {
      case ConstraintType.alignment:
        return _validateAlignment(world);
      case ConstraintType.distance:
        return _validateDistance(world);
      case ConstraintType.order:
        return _validateOrder(world);
    }
  }

  // 验证对齐约束
  bool _validateAlignment(OpticsWorld world) {
    final elementIds = params['elementIds'] as List<dynamic>;
    final axis = params['axis'] as String;
    final tolerance = (params['tolerance'] as num).toDouble();

    final elements = elementIds
        .map((id) => world.getElementById(id as String))
        .whereType<OpticalElement>()
        .toList();

    if (elements.isEmpty) return true;

    final first = elements.first;
    final reference = axis == 'y' ? first.y : first.x;

    return elements.every((e) {
      final value = axis == 'y' ? e.y : e.x;
      return (value - reference).abs() <= tolerance;
    });
  }

  // 验证距离约束
  bool _validateDistance(OpticsWorld world) {
    final fromId = params['fromElementId'] as String;
    final toId = params['toElementId'] as String;
    final minDist = (params['minDistance'] as num?)?.toDouble();
    final maxDist = (params['maxDistance'] as num?)?.toDouble();

    final from = world.getElementById(fromId);
    final to = world.getElementById(toId);
    if (from == null || to == null) return true;

    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final distance = (dx * dx + dy * dy);
    if (minDist != null && distance < minDist * minDist) return false;
    if (maxDist != null && distance > maxDist * maxDist) return false;

    return true;
  }

  // 验证顺序约束
  bool _validateOrder(OpticsWorld world) {
    final elementIds = params['elementIds'] as List<dynamic>;
    final elements = elementIds
        .map((id) => world.getElementById(id as String))
        .whereType<OpticalElement>()
        .toList();

    if (elements.length < 2) return true;

    // 检查 x 坐标是否递增
    for (int i = 1; i < elements.length; i++) {
      if (elements[i].x < elements[i - 1].x) return false;
    }

    return true;
  }

  // 从 JSON 加载
  factory Constraint.fromJson(Map<String, dynamic> json) {
    try {
      return Constraint(
        id: json['id'] as String? ?? 'unknown',
        type: _parseType(json['type'] as String? ?? 'alignment'),
        description: json['description'] as String? ?? '',
        params: json['params'] as Map<String, dynamic>? ?? {},
        enforced: json['enforced'] as bool? ?? false,
      );
    } catch (e) {
      throw FormatException('Failed to parse Constraint: $e');
    }
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'params': params,
      'enforced': enforced,
    };
  }

  static ConstraintType _parseType(String type) {
    return switch (type) {
      'alignment' => ConstraintType.alignment,
      'distance' => ConstraintType.distance,
      'order' => ConstraintType.order,
      _ => ConstraintType.alignment,
    };
  }
}

// 约束违反类
class ConstraintViolation {
  const ConstraintViolation({
    required this.constraint,
    this.message,
  });

  final Constraint constraint;
  final String? message;
}
