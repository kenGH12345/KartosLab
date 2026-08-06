import 'package:flutter/material.dart';

import '../../common/scenario/scenario_manager_base.dart';
import '../models/circuit_state.dart';
import 'circuit_scenario.dart';
import 'circuit_learning_objective.dart';

/// Circuit scenario manager.
///
/// Extends [ScenarioManagerBase] -- manifest loading, findById, and scenario
/// caching are handled by the base class. This class provides circuit-specific
/// state construction from layout and constraint/objective checking.
class CircuitScenarioManager
    extends ScenarioManagerBase<CircuitScenario, CircuitState> {
  CircuitScenarioManager();

  CircuitScenario? _currentScenario;

  CircuitScenario? get currentScenario => _currentScenario;

  // ---------------------------------------------------------------------------
  // ScenarioManagerBase required overrides
  // ---------------------------------------------------------------------------

  @override
  String get manifestPath => 'assets/scenarios/circuit/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/circuit/$entryKey.json';

  @override
  CircuitScenario Function(Map<String, dynamic>) get fromJson =>
      CircuitScenario.fromJson;

  @override
  String Function(CircuitScenario) get scenarioId => (s) => s.scenarioId;

  @override
  CircuitState Function(CircuitScenario) get buildInitialState => _build;

  CircuitState _build(CircuitScenario scenario) {
    _currentScenario = scenario;
    return _buildCircuitState(scenario.initialLayout);
  }

  // ---------------------------------------------------------------------------
  // Domain: layout -> CircuitState
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Constraints & objectives
  // ---------------------------------------------------------------------------

  @override
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

  @override
  bool checkObjectives(CircuitState state) {
    final scenario = _currentScenario;
    if (scenario == null || scenario.objectives == null) return true;
    return scenario.objectives!.checkAchieved(state);
  }

  List<CircuitHint> getHints(CircuitState state) {
    final scenario = _currentScenario;
    if (scenario == null || scenario.objectives == null) return [];
    return scenario.objectives!.getApplicableHints(state);
  }
}
