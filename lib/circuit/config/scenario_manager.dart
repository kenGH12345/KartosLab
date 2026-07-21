import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/circuit_state.dart';
import '../models/circuit_solver.dart';
import 'circuit_scenario.dart';
import 'circuit_constraint.dart';
import 'circuit_learning_objective.dart';

/// 电路场景管理器（Step 1a · §C1 落地）
///
/// 对应光学 `ScenarioManager`（`lib/optics/config/scenario_manager.dart`），
/// 按 `req-phet-circuit-config-json` Step 1a 边界收窄：
/// - 不含 constraints / objectives / gameRules 校验（Step 1c）
/// - 不含 inventory / defaultParams 合并（Step 1b）
/// - `loadScenario` 直接从 `CircuitScenario.initialLayout` 构造 `CircuitState`
///
/// 加载策略与光学同款：
/// - `loadScenarios()` 是 `Future<void>` · 读 manifest.json · 遍历 id 加载
/// - 单个场景加载失败不抛异常（catch + debugPrint · 静默降级）
/// - `loadScenario(id)` 是**同步**方法（依赖 `_scenarios` 缓存）
class CircuitScenarioManager {
  CircuitScenarioManager();

  static const String _manifestPath = 'assets/scenarios/circuit/manifest.json';
  static String _scenarioPath(String id) => 'assets/scenarios/circuit/$id.json';

  final List<CircuitScenario> _scenarios = [];
  CircuitScenario? _currentScenario;

  /// 加载所有电路场景配置。
  ///
  /// 从 `assets/scenarios/circuit/manifest.json` 读取场景 id 列表，
  /// 逐个加载 `{id}.json`；任一场景加载失败仅打印警告，其余继续。
  Future<void> loadScenarios() async {
    try {
      final manifestStr = await rootBundle.loadString(_manifestPath);
      final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
      final scenarioEntries =
          (manifest['scenarios'] as List<dynamic>).cast<Map<String, dynamic>>();

      _scenarios.clear();
      for (final entry in scenarioEntries) {
        final id = entry['id'] as String;
        try {
          final jsonStr = await rootBundle.loadString(_scenarioPath(id));
          final scenario = CircuitScenario.fromJson(
            jsonDecode(jsonStr) as Map<String, dynamic>,
          );
          _scenarios.add(scenario);
        } catch (e) {
          debugPrint('Failed to load circuit scenario $id: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to load circuit scenarios manifest: $e');
    }
  }

  /// 获取所有已加载场景（不可变视图）。
  List<CircuitScenario> get scenarios => List.unmodifiable(_scenarios);

  /// 当前激活场景（`loadScenario` 后设置）。
  CircuitScenario? get currentScenario => _currentScenario;

  /// 按 id 切换到指定场景并构造初始 `CircuitState`。
  ///
  /// 与光学 `loadScenario` 同签名：找不到抛异常。
  /// 电路无 constraint/objectives · 本方法**只做**拓扑→State 的映射。
  CircuitState loadScenario(String scenarioId) {
    final scenario = _scenarios.firstWhere(
      (s) => s.scenarioId == scenarioId,
      orElse: () => throw Exception('Circuit scenario not found: $scenarioId'),
    );

    _currentScenario = scenario;
    return _buildCircuitState(scenario.initialLayout);
  }

  /// 拓扑三元组 → `CircuitState` 构造。
  ///
  /// - `VertexPlacement` → `Vertex`（一一对应字段）
  /// - `ComponentPlacement` → `CircuitComponent`（type 已在 Loop 1 解析）
  /// - `WirePlacement` → `WireSegment`（controlPoints 从 `[{x,y}]` → `List<Offset>`）
  CircuitState _buildCircuitState(CircuitLayout layout) {
    final vertices = layout.vertices
        .map((v) => Vertex(
              id: v.id,
              x: v.x,
              y: v.y,
              isJunction: v.isJunction,
              isTerminal: v.isTerminal,
            ))
        .toList(growable: false);

    final components = layout.components
        .map((c) => CircuitComponent(
              id: c.id,
              type: c.type,
              x: c.x,
              y: c.y,
              rotation: c.rotation,
              value: c.value,
              isClosed: c.isClosed,
              startVertexId: c.startVertexId,
              endVertexId: c.endVertexId,
            ))
        .toList(growable: false);

    final wires = layout.wires
        .map((w) => WireSegment(
              id: w.id,
              startVertexId: w.startVertexId,
              endVertexId: w.endVertexId,
              controlPoints: w.controlPoints
                  .map((p) => Offset(p['x'] ?? 0.0, p['y'] ?? 0.0))
                  .toList(growable: false),
            ))
        .toList(growable: false);

    return CircuitState(
      components: components,
      wires: wires,
      vertices: vertices,
    );
  }

  /// Validate all constraints (enforced only) against current [CircuitState].
  ///
  /// Returns list of violation messages; empty list = all passed.
  /// Non-enforced constraints are always skipped.
  List<String> validateConstraints(CircuitState state) {
    final scenario = _currentScenario;
    if (scenario == null) return [];

    final violations = <String>[];
    for (final c in scenario.constraints) {
      if (!c.enforced) continue;
      final msg = c.buildViolationMessage(state);
      if (msg != null) violations.add(msg);
    }
    return violations;
  }

  /// Check if current scenario objectives are achieved.
  ///
  /// Returns true if no objectives are defined or all criteria are met.
  bool checkObjectives(CircuitState state) {
    final scenario = _currentScenario;
    if (scenario == null || scenario.objectives == null) return true;
    return scenario.objectives!.checkAchieved(state);
  }

  /// Get applicable hints for current state from scenario objectives.
  List<CircuitHint> getHints(CircuitState state) {
    final scenario = _currentScenario;
    if (scenario == null || scenario.objectives == null) return [];
    return scenario.objectives!.getApplicableHints(state);
  }
}
