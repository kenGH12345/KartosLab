import 'package:flutter/foundation.dart';

import '../model/molarity_state.dart';

/// 成功标准判定配置（对应 scenario JSON `successCriteria` 段）。
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
  bool check(MolarityState state) {
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
