import 'package:flutter/foundation.dart';

import '../models/optical_element.dart';
import '../models/optics_world.dart';
import '../solvers/optics_solver.dart';

// 教学目标类型枚举
enum ObjectiveType {
  guided,
  freeExplore,
  challenge,
}

// 成功标准类型枚举
enum CriterionType {
  imageProperties,
  elementPosition,
  rayPath,
}

// 教学目标类
@immutable
class LearningObjective {
  const LearningObjective({
    required this.type,
    required this.description,
    required this.successCriteria,
    required this.hints,
    required this.validation,
  });

  final ObjectiveType type;
  final String description;
  final List<SuccessCriterion> successCriteria;
  final List<Hint> hints;
  final ValidationConfig validation;

  // 检查是否达成教学目标
  bool checkAchieved(OpticsWorld world, SolvedOptics solved) {
    return successCriteria.every((c) => c.check(world, solved));
  }

  // 获取适用的提示
  List<Hint> getApplicableHints(OpticsWorld world) {
    // 简化实现：返回所有提示
    return hints;
  }

  // 从 JSON 加载
  factory LearningObjective.fromJson(Map<String, dynamic> json) {
    return LearningObjective(
      type: _parseType(json['type'] as String),
      description: json['description'] as String,
      successCriteria: (json['successCriteria'] as List<dynamic>)
          .map((e) => SuccessCriterion.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => Hint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      validation: ValidationConfig.fromJson(
          json['validation'] as Map<String, dynamic>),
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
      'successCriteria': successCriteria.map((e) => e.toJson()).toList(),
      'hints': hints.map((e) => e.toJson()).toList(),
      'validation': validation.toJson(),
    };
  }

  static ObjectiveType _parseType(String type) {
    return switch (type) {
      'guided' => ObjectiveType.guided,
      'freeExplore' => ObjectiveType.freeExplore,
      'challenge' => ObjectiveType.challenge,
      _ => ObjectiveType.guided,
    };
  }
}

// 成功标准类
@immutable
class SuccessCriterion {
  const SuccessCriterion({
    required this.id,
    required this.type,
    required this.description,
    required this.params,
  });

  final String id;
  final CriterionType type;
  final String description;
  final Map<String, dynamic> params;

  // 检查是否满足成功标准
  bool check(OpticsWorld world, SolvedOptics solved) {
    switch (type) {
      case CriterionType.imageProperties:
        return _checkImageProperties(solved);
      case CriterionType.elementPosition:
        return _checkElementPosition(world);
      case CriterionType.rayPath:
        return _checkRayPath(solved);
    }
  }

  // 检查图像属性
  bool _checkImageProperties(SolvedOptics solved) {
    final imageInfo = solved.imageInfo;
    if (imageInfo == null) return false;

    // 如果 params 中有期望值，进行实际验证
    final expectedVirtual = params['expectedVirtual'] as bool?;
    final expectedMagnification = params['expectedMagnification'] as num?;

    if (expectedVirtual != null && imageInfo.isVirtual != expectedVirtual) {
      return false;
    }
    if (expectedMagnification != null) {
      final tolerance = 0.5; // 放大率容差
      if ((imageInfo.magnification - expectedMagnification).abs() > tolerance) {
        return false;
      }
    }
    return true;
  }

  // 检查元件位置
  bool _checkElementPosition(OpticsWorld world) {
    // 检查是否至少有一个非光源元件在光轴上
    return world.elements.any((e) =>
      e.type != OpticalElementType.lightSource &&
      (e.x != 0 || e.y != 0)); // 元件被放置过
  }

  // 检查光线路径
  bool _checkRayPath(SolvedOptics solved) {
    // 至少有 1 条光线且有 2+ 个路径点（表示光线经过了元件交互）
    return solved.rays.any((r) => r.points.length >= 2);
  }

  // 从 JSON 加载
  factory SuccessCriterion.fromJson(Map<String, dynamic> json) {
    return SuccessCriterion(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      description: json['description'] as String,
      params: json['params'] as Map<String, dynamic>,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'params': params,
    };
  }

  static CriterionType _parseType(String type) {
    return switch (type) {
      'imageProperties' => CriterionType.imageProperties,
      'elementPosition' => CriterionType.elementPosition,
      'rayPath' => CriterionType.rayPath,
      _ => CriterionType.imageProperties,
    };
  }
}

// 提示类
@immutable
class Hint {
  const Hint({
    required this.trigger,
    required this.message,
  });

  final String trigger;
  final String message;

  // 从 JSON 加载
  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      trigger: json['trigger'] as String,
      message: json['message'] as String,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'message': message,
    };
  }
}

// 验证配置类
@immutable
class ValidationConfig {
  const ValidationConfig({
    required this.autoCheck,
    required this.showFeedback,
  });

  final bool autoCheck;
  final bool showFeedback;

  // 从 JSON 加载
  factory ValidationConfig.fromJson(Map<String, dynamic> json) {
    return ValidationConfig(
      autoCheck: json['autoCheck'] as bool,
      showFeedback: json['showFeedback'] as bool,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'autoCheck': autoCheck,
      'showFeedback': showFeedback,
    };
  }
}
