import 'package:flutter/material.dart';

import '../../../common/scenario/success_condition.dart';
import '../../../common/widgets/inquiry_models.dart';
import '../model/color_range.dart';
import '../model/solute.dart';

/// 参数范围（min/max/step/unit）· 对应 JSON `paramRanges` 段。
@immutable
class ParamRange {
  const ParamRange({required this.min, required this.max, this.step, this.unit});

  final double min;
  final double max;
  final double? step;
  final String? unit;

  factory ParamRange.fromJson(Map<String, dynamic> json) => ParamRange(
        min: (json['min'] as num).toDouble(),
        max: (json['max'] as num).toDouble(),
        step: (json['step'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
      );
}

/// 性能参数（每摩尔粒子数 / 粒子尺寸）· 对应 JSON `performance` 段。
@immutable
class PerformanceConfig {
  const PerformanceConfig({this.particlesPerMole = 200, this.particleSize = 5});

  final int particlesPerMole;
  final double particleSize;

  factory PerformanceConfig.fromJson(Map<String, dynamic>? json) =>
      PerformanceConfig(
        particlesPerMole: (json?['particlesPerMole'] as num?)?.toInt() ?? 200,
        particleSize: (json?['particleSize'] as num?)?.toDouble() ?? 5,
      );
}

/// Molarity 场景数据模型（对齐蓝本 · 配置化 §C2）。
@immutable
class MolarityScenario {
  const MolarityScenario({
    required this.scenarioId,
    required this.name,
    required this.initialSoluteIndex,
    required this.initialSoluteAmount,
    required this.initialVolume,
    this.description = '',
    this.version = '1.0',
    this.initialValuesVisible = false,
    this.soluteAmountRange = const ParamRange(min: 0, max: 1, step: 0.01, unit: 'mol'),
    this.volumeRange = const ParamRange(min: 0.2, max: 1, step: 0.01, unit: 'L'),
    this.concentrationMax = 5.0,
    this.solutes = const [],
    this.performance = const PerformanceConfig(),
    this.successCriteria = const [],
    this.hints = const [],
    this.inquiryTask,
  });

  final String scenarioId;
  final String name;
  final String description;
  final String version;
  final int initialSoluteIndex;
  final double initialSoluteAmount;
  final double initialVolume;
  final bool initialValuesVisible;
  final ParamRange soluteAmountRange;
  final ParamRange volumeRange;
  final double concentrationMax;
  final List<Solute> solutes;
  final PerformanceConfig performance;
  final List<SuccessCondition> successCriteria;
  final List<HintConfig> hints;
  final InquiryTask? inquiryTask;

  factory MolarityScenario.fromJson(Map<String, dynamic> json) {
    final ip = json['initialParams'] as Map<String, dynamic>? ?? {};
    final pr = json['paramRanges'] as Map<String, dynamic>? ?? {};
    return MolarityScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      initialSoluteIndex: (ip['soluteIndex'] as num?)?.toInt() ?? 0,
      initialSoluteAmount: (ip['soluteAmount'] as num?)?.toDouble() ?? 0.5,
      initialVolume: (ip['volume'] as num?)?.toDouble() ?? 0.5,
      initialValuesVisible: (ip['valuesVisible'] as bool?) ?? false,
      soluteAmountRange: pr['soluteAmount'] != null
          ? ParamRange.fromJson(pr['soluteAmount'] as Map<String, dynamic>)
          : const ParamRange(min: 0, max: 1, step: 0.01, unit: 'mol'),
      volumeRange: pr['volume'] != null
          ? ParamRange.fromJson(pr['volume'] as Map<String, dynamic>)
          : const ParamRange(min: 0.2, max: 1, step: 0.01, unit: 'L'),
      concentrationMax: (json['concentrationMax'] as num?)?.toDouble() ?? 5.0,
      solutes: (json['solutes'] as List<dynamic>? ?? const [])
          .map((e) => _parseSolute(e as Map<String, dynamic>,
              performance: (json['performance'] as Map<String, dynamic>?)))
          .toList(growable: false),
      performance: PerformanceConfig.fromJson(json['performance'] as Map<String, dynamic>?),
      successCriteria: (json['successCriteria'] as List<dynamic>? ?? const [])
          .map((e) => SuccessCondition.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      hints: (json['hints'] as List<dynamic>? ?? const [])
          .map((e) => HintConfig.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      inquiryTask: json['inquiryTask'] != null
          ? InquiryTask.fromJson(json['inquiryTask'] as Map<String, dynamic>)
          : null,
    );
  }

  static Solute _parseSolute(Map<String, dynamic> json,
      {Map<String, dynamic>? performance}) {
    return Solute(
      name: json['name'] as String,
      formula: json['formula'] as String,
      saturatedConcentration: (json['saturatedConcentration'] as num).toDouble(),
      solutionColor: ColorRange(
        min: _parseHex(json['solutionColorMin'] as String),
        max: _parseHex(json['solutionColorMax'] as String),
      ),
      particleColor: _parseHex(json['particleColor'] as String),
      particleSize: (json['particleSize'] as num?)?.toDouble() ??
          (performance?['particleSize'] as num?)?.toDouble() ??
          5,
      particlesPerMole: (json['particlesPerMole'] as num?)?.toInt() ??
          (performance?['particlesPerMole'] as num?)?.toInt() ??
          200,
    );
  }

  /// 解析 "#RRGGBB" → Color；无法解析时黑色 + debugPrint 告警。
  static Color _parseHex(String hex) {
    final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (v == null || hex.length != 7) {
      debugPrint('Invalid color hex: $hex');
      return const Color(0xFF000000);
    }
    return Color(0xFF000000 | v);
  }
}

/// 提示配置（trigger 条件 + message）· 对应 JSON `hints` 段。
@immutable
class HintConfig {
  const HintConfig({required this.trigger, required this.message});

  final String trigger;
  final String message;

  factory HintConfig.fromJson(Map<String, dynamic> json) => HintConfig(
        trigger: json['trigger'] as String,
        message: json['message'] as String,
      );
}
