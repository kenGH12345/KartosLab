import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/optical_element.dart';
import '../models/lens_element.dart';
import '../models/mirror_element.dart';
import '../models/light_source_element.dart';
import '../models/screen_element.dart';
import '../models/optics_world.dart';
import '../solvers/optics_solver.dart';
import 'lab_scenario.dart';
import 'constraint.dart';

// 场景管理器类
class ScenarioManager {
  final List<LabScenario> _scenarios = [];
  LabScenario? _currentScenario;

  // 加载所有场景配置
  Future<void> loadScenarios() async {
    try {
      final manifestStr =
          await rootBundle.loadString('assets/scenarios/manifest.json');
      final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
      final scenarioIds =
          (manifest['scenarios'] as List<dynamic>).cast<Map<String, dynamic>>();

      _scenarios.clear();
      for (final scenarioData in scenarioIds) {
        final id = scenarioData['id'] as String;
        try {
          final jsonStr =
              await rootBundle.loadString('assets/scenarios/$id.json');
          final scenario =
              LabScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
          _scenarios.add(scenario);
        } catch (e) {
          print('Failed to load scenario $id: $e');
        }
      }
    } catch (e) {
      print('Failed to load scenarios manifest: $e');
    }
  }

  // 获取所有场景
  List<LabScenario> get scenarios => List.unmodifiable(_scenarios);

  // domain → 中文标签映射
  static const Map<String, String> domainLabels = {
    'optics-lens': '透镜实验',
    'optics-mirror': '镜子实验',
    'optics-combo': '组合实验',
  };

  // 按 domain 分组
  Map<String, List<LabScenario>> getScenariosByDomain() {
    final groups = <String, List<LabScenario>>{};
    for (final domain in domainLabels.keys) {
      groups[domain] = [];
    }
    groups['other'] = [];

    for (final scenario in _scenarios) {
      final domain = scenario.domain;
      if (groups.containsKey(domain)) {
        groups[domain]!.add(scenario);
      } else {
        groups['other']!.add(scenario);
      }
    }

    // 移除空组
    groups.removeWhere((k, v) => v.isEmpty);
    return groups;
  }

  // 获取当前场景
  LabScenario? get currentScenario => _currentScenario;

  // 切换到指定场景
  OpticsWorld loadScenario(String scenarioId) {
    final scenario = _scenarios.firstWhere(
      (s) => s.scenarioId == scenarioId,
      orElse: () => throw Exception('Scenario not found: $scenarioId'),
    );

    _currentScenario = scenario;

    // 根据 initialLayout 创建初始世界
    final elements = scenario.initialLayout
        .map((placement) => _createElementFromPlacement(placement))
        .toList();

    return OpticsWorld(
      elements: elements,
      showFocalPoints: scenario.ui.showFocalPoints,
    );
  }

  // 从放置配置创建元件
  OpticalElement _createElementFromPlacement(ElementPlacement placement) {
    // 合并 inventory 中的 defaultParams（placement params 优先）
    final spec = _currentScenario?.inventory.availableComponents[placement.type];
    final merged = <String, dynamic>{};
    if (spec != null) {
      merged.addAll(spec.defaultParams);
    }
    merged.addAll(placement.params);
    final params = Map<String, dynamic>.unmodifiable(merged);

    switch (placement.type) {
      case OpticalElementType.lens:
        return LensElement.create(
          id: placement.id,
          position: Offset(placement.x, placement.y),
          lensType: _parseLensType(params['lensType']),
          focalLength: (params['focalLength'] as num?)?.toDouble(),
          diameter: (params['diameter'] as num?)?.toDouble(),
        );
      case OpticalElementType.mirror:
        return MirrorElement.create(
          id: placement.id,
          position: Offset(placement.x, placement.y),
          mirrorType: _parseMirrorType(params['mirrorType']),
          diameter: (params['diameter'] as num?)?.toDouble(),
        );
      case OpticalElementType.lightSource:
        return LightSourceElement.create(
          id: placement.id,
          position: Offset(placement.x, placement.y),
          sourceType: _parseSourceType(params['sourceType']),
          objectHeight: (params['objectHeight'] as num?)?.toDouble(),
        );
      case OpticalElementType.screen:
        return ScreenElement.create(
          id: placement.id,
          position: Offset(placement.x, placement.y),
        );
      default:
        throw Exception('Unknown element type: ${placement.type}');
    }
  }

  static LensType _parseLensType(dynamic type) {
    if (type is! String) return LensType.convex;
    return switch (type) {
      'convex' => LensType.convex,
      'concave' => LensType.concave,
      _ => LensType.convex,
    };
  }

  static MirrorType _parseMirrorType(dynamic type) {
    if (type is! String) return MirrorType.plane;
    return switch (type) {
      'concave' => MirrorType.concave,
      'convex' => MirrorType.convex,
      _ => MirrorType.plane,
    };
  }

  static SourceType _parseSourceType(dynamic type) {
    if (type is! String) return SourceType.object;
    return switch (type) {
      'point' => SourceType.point,
      'parallel' => SourceType.parallel,
      _ => SourceType.object,
    };
  }

  // 验证当前世界是否满足约束
  List<ConstraintViolation> validateConstraints(OpticsWorld world) {
    if (_currentScenario == null) return [];

    final violations = <ConstraintViolation>[];
    for (final constraint in _currentScenario!.constraints) {
      if (constraint.enforced && !constraint.validate(world)) {
        violations.add(ConstraintViolation(constraint: constraint));
      }
    }

    return violations;
  }

  // 检查教学目标是否达成
  bool checkObjectives(OpticsWorld world, SolvedOptics solved) {
    if (_currentScenario == null) return true;
    final objectives = _currentScenario!.objectives;
    if (objectives == null) return true;

    return objectives.checkAchieved(world, solved);
  }
}
