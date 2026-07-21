import 'package:flutter/foundation.dart';

import '../models/circuit_state.dart';
import '../models/circuit_solver.dart';

enum CircuitObjectiveType {
  guided,
  freeExplore,
  challenge,
}

enum CircuitCriterionType {
  circuitClosed,
  componentPowered,
  bulbBrightness,
  componentCount,
}

@immutable
class CircuitLearningObjective {
  const CircuitLearningObjective({
    required this.type,
    required this.description,
    required this.successCriteria,
    required this.hints,
    required this.validation,
  });

  final CircuitObjectiveType type;
  final String description;
  final List<CircuitSuccessCriterion> successCriteria;
  final List<CircuitHint> hints;
  final CircuitValidationConfig validation;

  bool checkAchieved(CircuitState state) {
    final solved = CircuitSolver.solve(state);
    return successCriteria.every((c) => c.check(state, solved));
  }

  List<CircuitHint> getApplicableHints(CircuitState state) {
    return hints;
  }

  factory CircuitLearningObjective.fromJson(Map<String, dynamic> json) {
    return CircuitLearningObjective(
      type: _parseType(json['type'] as String),
      description: json['description'] as String,
      successCriteria: (json['successCriteria'] as List<dynamic>)
          .map((e) => CircuitSuccessCriterion.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => CircuitHint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      validation: CircuitValidationConfig.fromJson(
          json['validation'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
      'successCriteria': successCriteria.map((e) => e.toJson()).toList(),
      'hints': hints.map((e) => e.toJson()).toList(),
      'validation': validation.toJson(),
    };
  }

  static CircuitObjectiveType _parseType(String type) {
    return switch (type) {
      'guided' => CircuitObjectiveType.guided,
      'freeExplore' => CircuitObjectiveType.freeExplore,
      'challenge' => CircuitObjectiveType.challenge,
      _ => CircuitObjectiveType.guided,
    };
  }
}

@immutable
class CircuitSuccessCriterion {
  const CircuitSuccessCriterion({
    required this.id,
    required this.type,
    required this.description,
    required this.params,
  });

  final String id;
  final CircuitCriterionType type;
  final String description;
  final Map<String, dynamic> params;

  bool check(CircuitState state, SolvedCircuit solved) {
    switch (type) {
      case CircuitCriterionType.circuitClosed:
        return _checkCircuitClosed(solved);
      case CircuitCriterionType.componentPowered:
        return _checkComponentPowered(state, solved);
      case CircuitCriterionType.bulbBrightness:
        return _checkBulbBrightness(solved);
      case CircuitCriterionType.componentCount:
        return _checkComponentCount(state);
    }
  }

  bool _checkCircuitClosed(SolvedCircuit solved) {
    return solved.openNodes.isEmpty &&
        solved.componentStates.values.any((v) => v);
  }

  bool _checkComponentPowered(CircuitState state, SolvedCircuit solved) {
    final targetType = params['componentType'] as String?;
    if (targetType != null) {
      final targetComps = state.components
          .where((c) => c.type.name == targetType)
          .toList();
      if (targetComps.isEmpty) return false;
      return targetComps.any((c) => solved.isPowered(c.id));
    }
    return solved.componentStates.values.any((v) => v);
  }

  bool _checkBulbBrightness(SolvedCircuit solved) {
    if (solved.bulbBrightness.isEmpty) return false;
    final minBrightness = (params['minBrightness'] as num?)?.toDouble() ?? 0.1;
    return solved.bulbBrightness.values.any((b) => b >= minBrightness);
  }

  bool _checkComponentCount(CircuitState state) {
    final typeName = params['componentType'] as String;
    final expected = (params['expectedCount'] as int?) ?? 1;
    final actual = state.components
        .where((c) => c.type.name == typeName)
        .length;
    return actual >= expected;
  }

  factory CircuitSuccessCriterion.fromJson(Map<String, dynamic> json) {
    return CircuitSuccessCriterion(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      description: json['description'] as String,
      params: json['params'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'params': params,
    };
  }

  static CircuitCriterionType _parseType(String type) {
    return switch (type) {
      'circuitClosed' => CircuitCriterionType.circuitClosed,
      'componentPowered' => CircuitCriterionType.componentPowered,
      'bulbBrightness' => CircuitCriterionType.bulbBrightness,
      'componentCount' => CircuitCriterionType.componentCount,
      _ => CircuitCriterionType.circuitClosed,
    };
  }
}

@immutable
class CircuitHint {
  const CircuitHint({
    required this.trigger,
    required this.message,
  });

  final String trigger;
  final String message;

  factory CircuitHint.fromJson(Map<String, dynamic> json) {
    return CircuitHint(
      trigger: json['trigger'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'message': message,
    };
  }
}

@immutable
class CircuitValidationConfig {
  const CircuitValidationConfig({
    required this.autoCheck,
    required this.showFeedback,
  });

  final bool autoCheck;
  final bool showFeedback;

  factory CircuitValidationConfig.fromJson(Map<String, dynamic> json) {
    return CircuitValidationConfig(
      autoCheck: json['autoCheck'] as bool,
      showFeedback: json['showFeedback'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoCheck': autoCheck,
      'showFeedback': showFeedback,
    };
  }
}