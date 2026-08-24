import 'package:flutter/material.dart';

import '../../common/scenario/success_condition.dart';
import '../../common/widgets/inquiry_models.dart';
import '../model/color_vision_state.dart';
import '../solver/color_model.dart';

/// Color vision screen type.
enum CVScreen { rgb, singleBulb }

CVScreen _parseScreen(String s) {
  switch (s) {
    case 'rgb': return CVScreen.rgb;
    case 'singleBulb': return CVScreen.singleBulb;
    default: throw ArgumentError('Unknown CVScreen: $s');
  }
}

/// Color vision rendering mode.
enum CVBeamMode { photons, wave }

CVBeamMode _parseBeamMode(String s) {
  switch (s) {
    case 'photons': return CVBeamMode.photons;
    case 'wave': return CVBeamMode.wave;
    default: return CVBeamMode.photons;
  }
}

/// Success criterion for a color-vision scenario.
class CVCriterionConfig {
  final String id, type, description;
  final Map<String, dynamic> params;
  const CVCriterionConfig({required this.id, required this.type, required this.description, this.params = const {}});
  factory CVCriterionConfig.fromJson(Map<String, dynamic> json) => CVCriterionConfig(
    id: json['id'] as String, type: json['type'] as String,
    description: json['description'] as String, params: (json['params'] as Map<String, dynamic>?) ?? {});

  /// 判定当前 [state] 是否达成该成功标准。
  bool check(ColorVisionState state) => evaluateLeaf(type, params, state);

  /// 叶子求值器（供 `SuccessCondition.evaluate` 回调注入）。
  ///
  /// 当前仅实现 `colorMatch`（按 targetColor 命名色匹配 · tolerance 默认 30）。
  /// 未知 type 一律 false（不 crash）。
  static bool evaluateLeaf(
      String type, Map<String, dynamic> params, ColorVisionState state) {
    switch (type) {
      case 'colorMatch':
        final target = params['targetColor'] as String?;
        if (target == null) return false;
        final tolerance = (params['tolerance'] as num?)?.toInt() ?? 30;
        return ColorModel.colorMatches(state.mixedColor, target, tolerance: tolerance);
      default:
        return false;
    }
  }
}

/// Hint message with trigger condition.
class CVHintConfig {
  final String trigger, message;
  const CVHintConfig({required this.trigger, required this.message});
  factory CVHintConfig.fromJson(Map<String, dynamic> json) => CVHintConfig(
    trigger: json['trigger'] as String, message: json['message'] as String);
}

/// 挑战模式配置（对应 scenario JSON `challenge` 顶层字段 · 替代硬编码）。
@immutable
class CVChallengeConfig {
  final bool enabled;
  final String mode;            // 当前仅 'colorMatch'
  final String difficulty;      // 'easy' | 'medium' | 'hard'
  final int timeLimit;          // 基础倒计时秒数
  final int timeBonusPerLevel;  // 每过一关额外秒数
  final double accuracyThreshold; // 匹配精度阈值 0-100
  final List<CVTargetColor> targets;    // 预设目标色（按序出题）
  final CVRandomTargets? randomTargets; // 随机目标配置

  const CVChallengeConfig({
    this.enabled = true,
    this.mode = 'colorMatch',
    this.difficulty = 'easy',
    this.timeLimit = 30,
    this.timeBonusPerLevel = 5,
    this.accuracyThreshold = 95.0,
    this.targets = const [],
    this.randomTargets,
  });

  factory CVChallengeConfig.fromJson(Map<String, dynamic> json) =>
      CVChallengeConfig(
        enabled: json['enabled'] as bool? ?? true,
        mode: json['mode'] as String? ?? 'colorMatch',
        difficulty: json['difficulty'] as String? ?? 'easy',
        timeLimit: (json['timeLimit'] as num?)?.toInt() ?? 30,
        timeBonusPerLevel: (json['timeBonusPerLevel'] as num?)?.toInt() ?? 5,
        accuracyThreshold: (json['accuracyThreshold'] as num?)?.toDouble() ?? 95.0,
        targets: (json['targets'] as List<dynamic>? ?? const [])
            .map((e) => CVTargetColor.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        randomTargets: json['randomTargets'] != null
            ? CVRandomTargets.fromJson(json['randomTargets'] as Map<String, dynamic>)
            : null,
      );
}

/// 预设目标色。
@immutable
class CVTargetColor {
  final String color; // 形如 "#FFFF00"
  final String label; // 如 "黄色（红+绿）"

  const CVTargetColor({required this.color, required this.label});

  factory CVTargetColor.fromJson(Map<String, dynamic> json) => CVTargetColor(
        color: json['color'] as String,
        label: json['label'] as String? ?? '',
      );

  /// 解析 "#RRGGBB" → Flutter Color；无法解析时返回黑色并告警。
  Color toColor() {
    final hex = color.replaceFirst('#', '');
    final v = int.tryParse(hex, radix: 16);
    if (v == null || hex.length != 6) {
      debugPrint('Invalid target color hex: $color');
      return const Color(0xFF000000);
    }
    return Color(0xFF000000 | v);
  }
}

/// 随机目标色配置（targets 用尽后使用）。
@immutable
class CVRandomTargets {
  final bool enabled;
  final int count;
  final bool excludeGrayscale;

  const CVRandomTargets({
    this.enabled = true,
    this.count = 5,
    this.excludeGrayscale = true,
  });

  factory CVRandomTargets.fromJson(Map<String, dynamic> json) => CVRandomTargets(
        enabled: json['enabled'] as bool? ?? true,
        count: (json['count'] as num?)?.toInt() ?? 5,
        excludeGrayscale: json['excludeGrayscale'] as bool? ?? true,
      );
}

/// Color-vision scenario data model.
///
/// Parsed from JSON scenario files. Carries initialParameters for
/// both screens; the screen type determines which subset is active.
@immutable
class ColorVisionScenario {
  final String scenarioId, name, description, version;
  final CVScreen screen;
  final CVBeamMode beamMode;
  final double redIntensity, greenIntensity, blueIntensity;
  final String filterType; // none, red, green, blue, custom
  final double customFilterR, customFilterG, customFilterB;
  final bool showPhotonView, showBeamView;
  final double personPosition;
  final List<SuccessCondition> successCriteria;
  final List<CVHintConfig> hints;
  final InquiryTask? inquiryTask;
  final CVChallengeConfig? challenge;

  const ColorVisionScenario({
    required this.scenarioId,
    required this.name,
    required this.screen,
    this.description = '',
    this.version = '1.0',
    this.beamMode = CVBeamMode.photons,
    this.redIntensity = 100,
    this.greenIntensity = 100,
    this.blueIntensity = 100,
    this.filterType = 'none',
    this.customFilterR = 1.0,
    this.customFilterG = 1.0,
    this.customFilterB = 1.0,
    this.showPhotonView = true,
    this.showBeamView = false,
    this.personPosition = 300,
    this.successCriteria = const [],
    this.hints = const [],
    this.inquiryTask,
    this.challenge,
  });

  factory ColorVisionScenario.fromJson(Map<String, dynamic> json) {
    final ip = json['initialParams'] as Map<String, dynamic>?;
    final cf = ip?['customFilter'] as Map<String, dynamic>?;
    return ColorVisionScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      screen: _parseScreen(json['screen'] as String),
      beamMode: json['beamMode'] != null ? _parseBeamMode(json['beamMode'] as String) : CVBeamMode.photons,
      redIntensity: (ip?['redIntensity'] as num?)?.toDouble() ?? 100,
      greenIntensity: (ip?['greenIntensity'] as num?)?.toDouble() ?? 100,
      blueIntensity: (ip?['blueIntensity'] as num?)?.toDouble() ?? 100,
      filterType: (ip?['filterType'] as String?) ?? 'none',
      customFilterR: (cf?['redPass'] as num?)?.toDouble() ?? 1.0,
      customFilterG: (cf?['greenPass'] as num?)?.toDouble() ?? 1.0,
      customFilterB: (cf?['bluePass'] as num?)?.toDouble() ?? 1.0,
      showPhotonView: (ip?['showPhotonView'] as bool?) ?? true,
      showBeamView: (ip?['showBeamView'] as bool?) ?? false,
      personPosition: (ip?['personPosition'] as num?)?.toDouble() ?? 300,
      successCriteria: (json['successCriteria'] as List<dynamic>?)?.map((e) => SuccessCondition.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      hints: (json['hints'] as List<dynamic>?)?.map((e) => CVHintConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      inquiryTask: json['inquiryTask'] != null
          ? InquiryTask.fromJson(json['inquiryTask'] as Map<String, dynamic>)
          : null,
      challenge: json['challenge'] != null
          ? CVChallengeConfig.fromJson(json['challenge'] as Map<String, dynamic>)
          : null,
    );
  }
}
