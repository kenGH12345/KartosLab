import 'package:flutter/material.dart';

import 'optical_element.dart';

// 光学世界状态管理类（不可变）
@immutable
class OpticsWorld {
  const OpticsWorld({
    required this.elements,
    this.selectedId,
    this.zoom = 1.0,
    this.showVirtualImage = true,
    this.showFocalPoints = true,
    this.showLabels = false,
  });

  // 空世界
  static OpticsWorld empty() => const OpticsWorld(elements: []);

  // 从场景配置创建（暂时注释掉，等待配置系统完成）
  // factory OpticsWorld.fromScenario(LabScenario scenario) {
  //   ...
  // }

  final List<OpticalElement> elements;
  final String? selectedId;
  final double zoom;
  final bool showVirtualImage;
  final bool showFocalPoints;
  final bool showLabels;

  // 游戏相关字段（未来扩展）
  // final GameState? gameState;

  OpticsWorld copyWith({
    List<OpticalElement>? elements,
    String? selectedId,
    double? zoom,
    bool? showVirtualImage,
    bool? showFocalPoints,
    bool? showLabels,
  }) {
    return OpticsWorld(
      elements: elements ?? this.elements,
      selectedId: selectedId ?? this.selectedId,
      zoom: zoom ?? this.zoom,
      showVirtualImage: showVirtualImage ?? this.showVirtualImage,
      showFocalPoints: showFocalPoints ?? this.showFocalPoints,
      showLabels: showLabels ?? this.showLabels,
    );
  }

  // 辅助方法：按 x 坐标排序元件（光线传播顺序）
  List<OpticalElement> get sortedElements =>
      [...elements]..sort((a, b) => a.x.compareTo(b.x));

  // 根据 ID 获取元件
  OpticalElement? getElementById(String id) {
    final idx = elements.indexWhere((e) => e.id == id);
    return idx >= 0 ? elements[idx] : null;
  }

  // 获取选中的元件
  OpticalElement? get selectedElement =>
      selectedId != null ? getElementById(selectedId!) : null;

  // 添加元件
  OpticsWorld addElement(OpticalElement element) {
    return copyWith(elements: [...elements, element]);
  }

  // 删除元件
  OpticsWorld removeElement(String id) {
    return copyWith(
      elements: elements.where((e) => e.id != id).toList(),
      selectedId: selectedId == id ? null : selectedId,
    );
  }

  // 更新元件
  OpticsWorld updateElement(OpticalElement element) {
    final index = elements.indexWhere((e) => e.id == element.id);
    if (index == -1) return this;

    final newElements = [...elements];
    newElements[index] = element;
    return copyWith(elements: newElements);
  }

  // 选择元件
  OpticsWorld selectElement(String? id) {
    return copyWith(selectedId: id);
  }

  // 移动元件
  OpticsWorld moveElement(String id, Offset newPosition) {
    final element = getElementById(id);
    if (element == null) return this;

    final moved = element.copyWith(x: newPosition.dx, y: newPosition.dy);
    return updateElement(moved);
  }
}
