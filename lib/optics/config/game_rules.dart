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
    this.baseScore = 100,
    this.timePenaltyPerSecond = 0.5,
    this.violationPenalty = 10,
  });

  final bool enabled;
  final int? timeLimit;
  final String? scoreFormula;
  final List<Penalty> penalties;

  /// 基础分（默认 100 · 原 calculateScore 硬编码值）。
  final int baseScore;

  /// 每秒耗时扣分（默认 0.5 · 原硬编码值）。
  final double timePenaltyPerSecond;

  /// 每个违规扣分（默认 10 · 原硬编码值）。
  final int violationPenalty;

  // 计算得分
  int calculateScore(
    OpticsWorld world,
    SolvedOptics solved,
    int timeSpent,
    int violationCount,
  ) {
    if (!enabled) return 0;

    final timePenalty = (timeSpent * timePenaltyPerSecond).toInt();
    final violationPenaltyTotal = violationCount * violationPenalty;
    return (baseScore - timePenalty - violationPenaltyTotal)
        .clamp(0, baseScore);
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
      baseScore: (json['baseScore'] as num?)?.toInt() ?? 100,
      timePenaltyPerSecond:
          (json['timePenaltyPerSecond'] as num?)?.toDouble() ?? 0.5,
      violationPenalty: (json['violationPenalty'] as num?)?.toInt() ?? 10,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      if (timeLimit != null) 'timeLimit': timeLimit,
      if (scoreFormula != null) 'scoreFormula': scoreFormula,
      'penalties': penalties.map((e) => e.toJson()).toList(),
      'baseScore': baseScore,
      'timePenaltyPerSecond': timePenaltyPerSecond,
      'violationPenalty': violationPenalty,
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
