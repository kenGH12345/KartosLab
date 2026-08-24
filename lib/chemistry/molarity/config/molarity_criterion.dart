import 'package:flutter/foundation.dart';

import '../model/molarity_state.dart';

/// 成功标准判定（叶子求值器 · 对应 scenario JSON `successCriteria` 段）。
///
/// 组合算子（`all`/`any`/`not` · 可嵌套）见
/// `lib/common/scenario/success_condition.dart`——本类只负责叶子 `type`
/// 的判定语义，作为叶子求值回调注入条件树。
@immutable
class MolarityCriterion {
  const MolarityCriterion({
    required this.id,
    required this.type,
    required this.description,
    this.params = const {},
  });

  final String id;
  final String type;
  final String description;
  final Map<String, dynamic> params;

  factory MolarityCriterion.fromJson(Map<String, dynamic> json) =>
      MolarityCriterion(
        id: json['id'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
        params: (json['params'] as Map<String, dynamic>?) ?? {},
      );

  /// 判定当前 [state] 是否达成该标准。
  bool check(MolarityState state) => evaluateLeaf(type, params, state);

  /// 叶子求值器（供 `SuccessCondition.evaluate` 回调注入）。
  ///
  /// 未知 type 一律 false（不 crash · 防御 AI 生成臆造枚举值）。
  static bool evaluateLeaf(
    String type,
    Map<String, dynamic> params,
    MolarityState state,
  ) {
    final s = state.solution;
    switch (type) {
      case 'solutionSaturated':
        return s.isSaturated;
      case 'concentrationReached':
        final target = (params['targetConcentration'] as num?)?.toDouble();
        if (target == null) return false;
        final tolerance = (params['tolerance'] as num?)?.toDouble() ?? 0.01;
        return (s.concentration - target).abs() <= tolerance;
      case 'precipitateVisible':
        return s.numberOfParticles > 0;
      case 'soluteChanged':
        final targetName = params['targetSolute'] as String?;
        return targetName != null && s.solute.name == targetName;
      default:
        return false;
    }
  }
}
