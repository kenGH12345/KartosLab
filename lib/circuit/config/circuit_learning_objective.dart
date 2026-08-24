import 'package:flutter/foundation.dart';

import '../../common/scenario/success_condition.dart';
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
  final List<SuccessCondition> successCriteria;
  final List<CircuitHint> hints;
  final CircuitValidationConfig validation;

  bool checkAchieved(CircuitState state) {
    final solved = CircuitSolver.solve(state);
    return SuccessCondition.allSatisfied(
      successCriteria,
      (type, params) =>
          CircuitSuccessCriterion.evaluateLeaf(type, params, state, solved),
    );
  }

  /// 按 hint.trigger 表达式过滤，仅返回当前 state 下应显示的 hints。
  ///
  /// 支持的 trigger 语法（简化版 · 覆盖当前 few-shot 场景足够）：
  /// - 空字符串 或 `always` → 永远触发
  /// - `openNodes <op> <N>`：例如 `openNodes > 0`
  /// - `componentCount <op> <N>`：全体元件数
  /// - `componentCount(<type>) <op> <N>`：指定类型元件数，如 `componentCount(switch_) == 0`
  /// - `<op>` ∈ `>`, `>=`, `<`, `<=`, `==`, `!=`
  ///
  /// 解析失败的 trigger 视为永远触发（保守策略，保证 hint 不因 typo 消失）。
  List<CircuitHint> getApplicableHints(CircuitState state) {
    final solved = CircuitSolver.solve(state);
    return hints.where((h) => _evalTrigger(h.trigger, state, solved)).toList();
  }

  static bool _evalTrigger(String trigger, CircuitState state, SolvedCircuit solved) {
    final t = trigger.trim();
    if (t.isEmpty || t == 'always') return true;
    final m = RegExp(r'^(openNodes|componentCount(?:\(([a-zA-Z_]+)\))?)\s*(==|!=|>=|<=|>|<)\s*(\d+)$').firstMatch(t);
    if (m == null) return true;
    final metric = m.group(1)!;
    final typeArg = m.group(2);
    final op = m.group(3)!;
    final n = int.parse(m.group(4)!);
    final int lhs;
    if (metric.startsWith('openNodes')) {
      lhs = solved.openNodes.length;
    } else {
      lhs = typeArg == null
          ? state.components.length
          : state.components.where((c) => c.type.name == typeArg).length;
    }
    return switch (op) {
      '==' => lhs == n,
      '!=' => lhs != n,
      '>=' => lhs >= n,
      '<=' => lhs <= n,
      '>'  => lhs >  n,
      '<'  => lhs <  n,
      _    => true,
    };
  }

  factory CircuitLearningObjective.fromJson(Map<String, dynamic> json) {
    return CircuitLearningObjective(
      type: _parseType(json['type'] as String),
      description: json['description'] as String,
      successCriteria: (json['successCriteria'] as List<dynamic>)
          .map((e) => SuccessCondition.fromJson(e as Map<String, dynamic>))
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

  bool check(CircuitState state, SolvedCircuit solved) =>
      evaluateLeaf(type.name, params, state, solved);

  /// 叶子求值器（type 字符串 → 枚举 → 判定 · 供条件树回调注入）。
  /// 未知 type 解析为 circuitClosed（与既有 fromJson 行为一致）。
  static bool evaluateLeaf(String type, Map<String, dynamic> params,
      CircuitState state, SolvedCircuit solved) {
    switch (_parseType(type)) {
      case CircuitCriterionType.circuitClosed:
        return _checkCircuitClosed(solved);
      case CircuitCriterionType.componentPowered:
        return _checkComponentPowered(params, state, solved);
      case CircuitCriterionType.bulbBrightness:
        return _checkBulbBrightness(params, solved);
      case CircuitCriterionType.componentCount:
        return _checkComponentCount(params, state);
    }
  }

  static bool _checkCircuitClosed(SolvedCircuit solved) {
    return solved.openNodes.isEmpty &&
        solved.componentStates.values.any((v) => v);
  }

  static bool _checkComponentPowered(Map<String, dynamic> params,
      CircuitState state, SolvedCircuit solved) {
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

  static bool _checkBulbBrightness(
      Map<String, dynamic> params, SolvedCircuit solved) {
    if (solved.bulbBrightness.isEmpty) return false;
    final minBrightness = (params['minBrightness'] as num?)?.toDouble() ?? 0.1;
    return solved.bulbBrightness.values.any((b) => b >= minBrightness);
  }

  static bool _checkComponentCount(
      Map<String, dynamic> params, CircuitState state) {
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