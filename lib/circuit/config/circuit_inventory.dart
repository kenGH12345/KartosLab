import 'package:flutter/foundation.dart';

import '../models/circuit_state.dart';

/// Component inventory for circuit scenarios.
///
/// Counterpart to optical `ComponentInventory` (`lib/optics/config/component_inventory.dart`).
///
/// Each scenario defines which component types are available, their max count,
/// lock status, and default constructor params.
@immutable
class CircuitComponentInventory {
  const CircuitComponentInventory({
    required this.availableComponents,
  });

  final Map<ComponentType, CircuitComponentSpec> availableComponents;

  /// Check if a component type can be added (respects maxCount).
  bool canAdd(ComponentType type, int currentCount) {
    final spec = availableComponents[type];
    if (spec == null || spec.maxCount == 0) return false;
    return currentCount < spec.maxCount;
  }

  factory CircuitComponentInventory.fromJson(Map<String, dynamic> json) {
    final raw = json['availableComponents'];
    if (raw == null || raw is! Map<String, dynamic>) {
      return const CircuitComponentInventory(availableComponents: {});
    }
    final available = raw as Map<String, dynamic>;
    final map = <ComponentType, CircuitComponentSpec>{};

    for (final entry in available.entries) {
      final type = _parseComponentType(entry.key);
      final spec = CircuitComponentSpec.fromJson(
          entry.value as Map<String, dynamic>);
      map[type] = spec;
    }

    return CircuitComponentInventory(availableComponents: map);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    for (final entry in availableComponents.entries) {
      map[entry.key.name] = entry.value.toJson();
    }
    return {'availableComponents': map};
  }

  static ComponentType _parseComponentType(String type) {
    for (final t in ComponentType.values) {
      if (t.name == type) return t;
    }
    throw FormatException('Invalid component type in inventory: $type');
  }
}

/// Specification for a single component type in the inventory.
@immutable
class CircuitComponentSpec {
  const CircuitComponentSpec({
    required this.maxCount,
    required this.locked,
    required this.defaultParams,
  });

  final int maxCount;
  final bool locked;
  final Map<String, dynamic> defaultParams;

  factory CircuitComponentSpec.fromJson(Map<String, dynamic> json) {
    return CircuitComponentSpec(
      maxCount: json['maxCount'] as int,
      locked: json['locked'] as bool,
      defaultParams: json['defaultParams'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxCount': maxCount,
      'locked': locked,
      'defaultParams': defaultParams,
    };
  }
}