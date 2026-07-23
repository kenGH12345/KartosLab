import 'package:flutter/foundation.dart';

import '../models/optical_element.dart';

// 元件库存类
@immutable
class ComponentInventory {
  const ComponentInventory({
    required this.availableComponents,
  });

  final Map<OpticalElementType, ComponentSpec> availableComponents;

  // 检查是否可以添加指定类型的元件
  bool canAdd(OpticalElementType type, int currentCount) {
    final spec = availableComponents[type];
    if (spec == null || spec.maxCount == 0) return false;
    return currentCount < spec.maxCount;
  }

  // 从 JSON 加载
  factory ComponentInventory.fromJson(Map<String, dynamic> json) {
    final raw = json['availableComponents'];
    if (raw == null || raw is! Map<String, dynamic>) {
      return const ComponentInventory(availableComponents: {});
    }
    final map = <OpticalElementType, ComponentSpec>{};

    for (final entry in raw.entries) {
      final type = _parseType(entry.key);
      final spec = ComponentSpec.fromJson(entry.value as Map<String, dynamic>);
      map[type] = spec;
    }

    return ComponentInventory(availableComponents: map);
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    for (final entry in availableComponents.entries) {
      map[entry.key.name] = entry.value.toJson();
    }
    return {'availableComponents': map};
  }

  static OpticalElementType _parseType(String type) {
    try {
      return OpticalElementType.parseType(type);
    } catch (e) {
      throw FormatException('Invalid component type in inventory: $type');
    }
  }
}

// 元件规格类
@immutable
class ComponentSpec {
  const ComponentSpec({
    required this.maxCount,
    required this.locked,
    required this.defaultParams,
  });

  final int maxCount;
  final bool locked;
  final Map<String, dynamic> defaultParams;

  // 从 JSON 加载
  factory ComponentSpec.fromJson(Map<String, dynamic> json) {
    return ComponentSpec(
      maxCount: json['maxCount'] as int,
      locked: json['locked'] as bool,
      defaultParams: json['defaultParams'] as Map<String, dynamic>? ?? {},
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'maxCount': maxCount,
      'locked': locked,
      'defaultParams': defaultParams,
    };
  }
}
