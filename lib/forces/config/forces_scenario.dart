import 'package:flutter/material.dart';

import '../../common/scenario/success_condition.dart';
import '../../common/widgets/inquiry_models.dart';

enum ForcesMode { netForce, motion, friction, acceleration }

ForcesMode _parseMode(String s) {
  switch (s) {
    case 'netForce': return ForcesMode.netForce;
    case 'motion': return ForcesMode.motion;
    case 'friction': return ForcesMode.friction;
    case 'acceleration': return ForcesMode.acceleration;
    default: throw ArgumentError('Unknown ForcesMode: $s');
  }
}

class PullerConfig {
  final String id;
  final double force;
  final bool side;
  final int colorValue;
  const PullerConfig({required this.id, required this.force, required this.side, required this.colorValue});
  factory PullerConfig.fromJson(Map<String, dynamic> json) => PullerConfig(
    id: json['id'] as String,
    force: (json['force'] as num).toDouble(),
    side: json['side'] as String == 'right',
    colorValue: int.parse(json['color'] as String, radix: 16));
  Color get color => Color(colorValue);
}

class ObjectConfig {
  final String id, label, icon;
  final double mass;
  const ObjectConfig({required this.id, required this.label, required this.mass, required this.icon});
  factory ObjectConfig.fromJson(Map<String, dynamic> json) => ObjectConfig(
    id: json['id'] as String, label: json['label'] as String,
    mass: (json['mass'] as num).toDouble(), icon: json['icon'] as String);
}

class ForcesConstraintConfig {
  final String id, type, description;
  final Map<String, dynamic> params;
  const ForcesConstraintConfig({required this.id, required this.type, required this.description, this.params = const {}});
  factory ForcesConstraintConfig.fromJson(Map<String, dynamic> json) => ForcesConstraintConfig(
    id: json['id'] as String, type: json['type'] as String,
    description: json['description'] as String, params: (json['params'] as Map<String, dynamic>?) ?? {});
}

class ForcesHintConfig {
  final String trigger, message;
  const ForcesHintConfig({required this.trigger, required this.message});
  factory ForcesHintConfig.fromJson(Map<String, dynamic> json) => ForcesHintConfig(
    trigger: json['trigger'] as String, message: json['message'] as String);
}

class ForcesScenario {
  final String scenarioId, name, description, version;
  final ForcesMode mode;
  final double mass, position, velocity, appliedForce, frictionCoeff;
  final double gameLength, cartStep;
  final List<PullerConfig> pullers;
  final List<ObjectConfig> objects;
  final bool showAccelerometer;
  final List<ForcesConstraintConfig> constraints;
  final List<SuccessCondition> successCriteria;
  final List<ForcesHintConfig> hints;
  final InquiryTask? inquiryTask;

  const ForcesScenario({
    required this.scenarioId, required this.name, required this.mode,
    this.description = '', this.version = '1.0',
    this.mass = 50, this.position = 0, this.velocity = 0,
    this.appliedForce = 0, this.frictionCoeff = 0,
    this.gameLength = 400, this.cartStep = 0.003,
    this.pullers = const [], this.objects = const [],
    this.showAccelerometer = false,
    this.constraints = const [], this.successCriteria = const [], this.hints = const [],
    this.inquiryTask,
  });

  factory ForcesScenario.fromJson(Map<String, dynamic> json) {
    final mode = _parseMode(json['mode'] as String);
    final ip = json['initialParams'] as Map<String, dynamic>?;
    final gr = json['gameRules'] as Map<String, dynamic>?;
    return ForcesScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      mode: mode,
      mass: (ip?['mass'] as num?)?.toDouble() ?? 50,
      position: (ip?['position'] as num?)?.toDouble() ?? 0,
      velocity: (ip?['velocity'] as num?)?.toDouble() ?? 0,
      appliedForce: (ip?['appliedForce'] as num?)?.toDouble() ?? 0,
      frictionCoeff: (ip?['frictionCoeff'] as num?)?.toDouble() ?? 0,
      gameLength: (gr?['gameLength'] as num?)?.toDouble() ?? 400,
      cartStep: (gr?['cartStep'] as num?)?.toDouble() ?? 0.003,
      pullers: (json['pullers'] as List<dynamic>?)?.map((e) => PullerConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      objects: (json['objects'] as List<dynamic>?)?.map((e) => ObjectConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      showAccelerometer: (ip?['showAccelerometer'] as bool?) ?? false,
      constraints: (json['constraints'] as List<dynamic>?)?.map((e) => ForcesConstraintConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      successCriteria: (json['successCriteria'] as List<dynamic>?)?.map((e) => SuccessCondition.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      hints: (json['hints'] as List<dynamic>?)?.map((e) => ForcesHintConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      inquiryTask: json['inquiryTask'] != null
          ? InquiryTask.fromJson(json['inquiryTask'] as Map<String, dynamic>)
          : null,
    );
  }
}
