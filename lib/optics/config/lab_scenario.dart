import 'package:flutter/material.dart';

import '../models/optical_element.dart';
import 'component_inventory.dart';
import 'constraint.dart';
import 'learning_objective.dart';
import 'game_rules.dart';

// 场景难度级别
enum ScenarioLevel {
  beginner,
  intermediate,
  advanced,
}

// 实验场景类
@immutable
class LabScenario {
  const LabScenario({
    required this.scenarioId,
    required this.name,
    required this.description,
    required this.version,
    required this.level,
    required this.domain,
    required this.inventory,
    required this.initialLayout,
    required this.constraints,
    this.objectives,
    this.gameRules,
    required this.ui,
  });

  final String scenarioId;
  final String name;
  final String description;
  final String version;
  final ScenarioLevel level;
  final String domain;

  final ComponentInventory inventory;
  final List<ElementPlacement> initialLayout;
  final List<Constraint> constraints;
  final LearningObjective? objectives;
  final GameRules? gameRules;
  final ScenarioUIConfig ui;

  // 从 JSON 加载
  factory LabScenario.fromJson(Map<String, dynamic> json) {
    return LabScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      level: _parseLevel(json['level'] as String),
      domain: json['domain'] as String,
      inventory: ComponentInventory.fromJson(json['inventory'] as Map<String, dynamic>),
      initialLayout: (json['initialLayout'] as List<dynamic>)
          .map((e) => ElementPlacement.fromJson(e as Map<String, dynamic>))
          .toList(),
      constraints: (json['constraints'] as List<dynamic>)
          .map((e) => Constraint.fromJson(e as Map<String, dynamic>))
          .toList(),
      objectives: json['objectives'] != null
          ? LearningObjective.fromJson(json['objectives'] as Map<String, dynamic>)
          : null,
      gameRules: json['gameRules'] != null
          ? GameRules.fromJson(json['gameRules'] as Map<String, dynamic>)
          : null,
      ui: ScenarioUIConfig.fromJson(json['ui'] as Map<String, dynamic>),
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'name': name,
      'description': description,
      'version': version,
      'level': level.name,
      'domain': domain,
      'inventory': inventory.toJson(),
      'initialLayout': initialLayout.map((e) => e.toJson()).toList(),
      'constraints': constraints.map((e) => e.toJson()).toList(),
      if (objectives != null) 'objectives': objectives!.toJson(),
      if (gameRules != null) 'gameRules': gameRules!.toJson(),
      'ui': ui.toJson(),
    };
  }

  static ScenarioLevel _parseLevel(String level) {
    return switch (level) {
      'beginner' => ScenarioLevel.beginner,
      'intermediate' => ScenarioLevel.intermediate,
      'advanced' => ScenarioLevel.advanced,
      _ => ScenarioLevel.beginner,
    };
  }
}

// 元件放置类
@immutable
class ElementPlacement {
  const ElementPlacement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.rotation = 0,
    this.locked = false,
    this.params = const {},
  });

  final String id;
  final OpticalElementType type;
  final double x;
  final double y;
  final double rotation;
  final bool locked;
  final Map<String, dynamic> params;

  factory ElementPlacement.fromJson(Map<String, dynamic> json) {
    return ElementPlacement(
      id: json['id'] as String,
      type: OpticalElementType.parseType(json['type'] as String),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      locked: json['locked'] as bool? ?? false,
      params: json['params'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'rotation': rotation,
      'locked': locked,
      'params': params,
    };
  }
}

// 场景 UI 配置类
@immutable
class ScenarioUIConfig {
  const ScenarioUIConfig({
    required this.showGrid,
    required this.showRuler,
    required this.showFocalPoints,
    required this.allowAddComponent,
    required this.allowRemoveComponent,
    required this.allowMoveComponent,
  });

  final bool showGrid;
  final bool showRuler;
  final bool showFocalPoints;
  final bool allowAddComponent;
  final bool allowRemoveComponent;
  final bool allowMoveComponent;

  factory ScenarioUIConfig.fromJson(Map<String, dynamic> json) {
    return ScenarioUIConfig(
      showGrid: json['showGrid'] as bool? ?? true,
      showRuler: json['showRuler'] as bool? ?? true,
      showFocalPoints: json['showFocalPoints'] as bool? ?? true,
      allowAddComponent: json['allowAddComponent'] as bool? ?? true,
      allowRemoveComponent: json['allowRemoveComponent'] as bool? ?? true,
      allowMoveComponent: json['allowMoveComponent'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showGrid': showGrid,
      'showRuler': showRuler,
      'showFocalPoints': showFocalPoints,
      'allowAddComponent': allowAddComponent,
      'allowRemoveComponent': allowRemoveComponent,
      'allowMoveComponent': allowMoveComponent,
    };
  }
}
