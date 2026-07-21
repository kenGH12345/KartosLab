import 'package:flutter/foundation.dart';

import '../models/circuit_state.dart';
import '../models/circuit_solver.dart';

enum CircuitConstraintType {
  topology,
  componentCount,
  componentPresent,
}

@immutable
class CircuitConstraint {
  const CircuitConstraint({
    required this.id,
    required this.type,
    required this.description,
    required this.params,
    required this.enforced,
  });

  final String id;
  final CircuitConstraintType type;
  final String description;
  final Map<String, dynamic> params;
  final bool enforced;

  bool validate(CircuitState state) {
    switch (type) {
      case CircuitConstraintType.topology:
        return _validateTopology(state);
      case CircuitConstraintType.componentCount:
        return _validateComponentCount(state);
      case CircuitConstraintType.componentPresent:
        return _validateComponentPresent(state);
    }
  }

  bool _validateTopology(CircuitState state) {
    final solved = CircuitSolver.solve(state);
    final maxOpen = (params['maxOpenNodes'] as int?) ?? 0;
    final requireClosed = params['requireClosed'] as bool? ?? false;
    if (requireClosed && solved.openNodes.isNotEmpty) return false;
    if (solved.openNodes.length > maxOpen) return false;
    return true;
  }

  bool _validateComponentCount(CircuitState state) {
    final typeName = params['componentType'] as String;
    final componentType = _parseComponentType(typeName);
    final minCount = (params['minCount'] as int?) ?? 0;
    final maxCount = (params['maxCount'] as int?) ?? 999;
    final count = state.components.where((c) => c.type == componentType).length;
    return count >= minCount && count <= maxCount;
  }

  bool _validateComponentPresent(CircuitState state) {
    final typeName = params['componentType'] as String;
    final componentType = _parseComponentType(typeName);
    return state.components.any((c) => c.type == componentType);
  }

  static ComponentType _parseComponentType(String type) {
    for (final t in ComponentType.values) {
      if (t.name == type) return t;
    }
    throw ArgumentError('Unknown ComponentType: $type');
  }

  String? buildViolationMessage(CircuitState state) {
    if (validate(state)) return null;
    switch (type) {
      case CircuitConstraintType.topology:
        return '$description (topology check failed)';
      case CircuitConstraintType.componentCount:
        final typeName = params['componentType'] as String;
        final minCount = (params['minCount'] as int?) ?? 0;
        final maxCount = (params['maxCount'] as int?) ?? 999;
        return '$description (need $minCount~$maxCount x $typeName)';
      case CircuitConstraintType.componentPresent:
        final typeName = params['componentType'] as String;
        return '$description (missing $typeName)';
    }
  }

  factory CircuitConstraint.fromJson(Map<String, dynamic> json) {
    return CircuitConstraint(
      id: json['id'] as String? ?? 'unknown',
      type: _parseType(json['type'] as String? ?? 'topology'),
      description: json['description'] as String? ?? '',
      params: json['params'] as Map<String, dynamic>? ?? {},
      enforced: json['enforced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'params': params,
      'enforced': enforced,
    };
  }

  static CircuitConstraintType _parseType(String type) {
    return switch (type) {
      'topology' => CircuitConstraintType.topology,
      'componentCount' => CircuitConstraintType.componentCount,
      'componentPresent' => CircuitConstraintType.componentPresent,
      _ => CircuitConstraintType.topology,
    };
  }
}
