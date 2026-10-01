import 'package:flutter/foundation.dart';

import '../models/optics_world.dart';
import '../solvers/optics_solver.dart';
@immutable
class GameRules {
  const GameRules({
    required this.enabled,
    this.timeLimit,
    this.scoreFormula,
    required this.penalties,
  });

  final bool enabled;
  final int? timeLimit;
  final String? scoreFormula;
  final List<Penalty> penalties;

  // 计算得分
  int calculateScore(
    OpticsWorld world,
    SolvedOptics solved,
    int timeSpent,
    int violationCount,
  ) {
    if (!enabled) return 0;

    // 固定公式：基础分 100，每秒扣 0.5 分，每个违规扣 10 分
    final baseScore = 100;
    final timePenalty = (timeSpent * 0.5).toInt();
    final violationPenalty = violationCount * 10;
    return (baseScore - timePenalty - violationPenalty).clamp(0, 100);
  }

  // 从 JSON 加载
  factory GameRules.fromJson(Map<String, dynamic> json) {
    return GameRules(
      enabled: json['enabled'] as bool,
      timeLimit: json['timeLimit'] as int?,
      scoreFormula: json['scoreFormula'] as String?,
      penalties: (json['penalties'] as List<dynamic>?)
              ?.map((e) => Penalty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      if (timeLimit != null) 'timeLimit': timeLimit,
      if (scoreFormula != null) 'scoreFormula': scoreFormula,
      'penalties': penalties.map((e) => e.toJson()).toList(),
    };
  }
}

// 惩罚类
@immutable
class Penalty {
  const Penalty({
    required this.type,
    required this.value,
    required this.condition,
  });

  final String type;
  final int value;
  final String condition;

  // 从 JSON 加载
  factory Penalty.fromJson(Map<String, dynamic> json) {
    return Penalty(
      type: json['type'] as String,
      value: json['value'] as int,
      condition: json['condition'] as String,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'condition': condition,
    };
  }
}
