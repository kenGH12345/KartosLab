import 'dart:ui';

import '../../common/scenario/scenario_manager_base.dart';
import '../models/optical_element.dart';
import '../models/lens_element.dart';
import '../models/mirror_element.dart';
import '../models/light_source_element.dart';
import '../models/screen_element.dart';
import '../models/optics_world.dart';
import '../solvers/optics_solver.dart';
import 'lab_scenario.dart';
import 'constraint.dart';

/// Optics scenario manager.
///
/// Extends [ScenarioManagerBase] -- manifest loading, findById, and scenario
/// caching are handled by the base class. This class provides optics-specific
/// element construction, constraint validation, and objective checking.
class ScenarioManager extends ScenarioManagerBase<LabScenario, OpticsWorld> {
  LabScenario? _currentScenario;

  /// The currently active scenario (set by [buildInitialState]).
  LabScenario? get currentScenario => _currentScenario;

  // ---------------------------------------------------------------------------
  // ScenarioManagerBase required overrides
  // ---------------------------------------------------------------------------

  @override
  String get manifestPath => 'assets/scenarios/manifest.json';

  @override
  String scenarioPath(String entryKey) => 'assets/scenarios/$entryKey.json';

  @override
  LabScenario Function(Map<String, dynamic>) get fromJson => LabScenario.fromJson;

  @override
  String Function(LabScenario) get scenarioId => (s) => s.scenarioId;

  @override
  OpticsWorld Function(LabScenario) get buildInitialState => _build;

  OpticsWorld _build(LabScenario scenario) {
    _currentScenario = scenario;
    final elements = scenario.initialLayout
        .map((placement) => _createElementFromPlacement(placement))
        .toList();
    return OpticsWorld(
      elements: elements,
      showFocalPoints: scenario.ui.showFocalPoints,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain-specific: element construction
  // ---------------------------------------------------------------------------

  OpticalElement _createElementFromPlacement(ElementPlacement placement) {
    final scenario = _requireScenario('_createElementFromPlacement');
    final spec = scenario.inventory.availableComponents[placement.type];
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

  LabScenario _requireScenario(String caller) {
    final s = _currentScenario;
    if (s == null) throw StateError('$caller: no current scenario loaded');
    return s;
  }

  // ---------------------------------------------------------------------------
  // Constraints & objectives
  // ---------------------------------------------------------------------------

  @override
  List<ConstraintViolation> validateConstraints(OpticsWorld state) {
    if (_currentScenario == null) return [];
    final violations = <ConstraintViolation>[];
    for (final constraint in _currentScenario!.constraints) {
      if (constraint.enforced && !constraint.validate(state)) {
        violations.add(ConstraintViolation(constraint: constraint));
      }
    }
    return violations;
  }

  @override
  bool checkObjectives(OpticsWorld state, [dynamic extra]) {
    if (_currentScenario == null) return true;
    final objectives = _currentScenario!.objectives;
    if (objectives == null) return true;
    final solved = extra as SolvedOptics?;
    if (solved == null) return true;
    return objectives.checkAchieved(state, solved);
  }

  // ---------------------------------------------------------------------------
  // Domain helpers
  // ---------------------------------------------------------------------------

  static const Map<String, String> domainLabels = {
    'optics-lens': '\u900f\u955c\u5b9e\u9a8c',
    'optics-mirror': '\u955c\u5b50\u5b9e\u9a8c',
    'optics-combo': '\u7ec4\u5408\u5b9e\u9a8c',
  };

  Map<String, List<LabScenario>> getScenariosByDomain() {
    final groups = <String, List<LabScenario>>{};
    for (final domain in domainLabels.keys) {
      groups[domain] = [];
    }
    groups['other'] = [];
    for (final scenario in scenarios) {
      final domain = scenario.domain;
      if (groups.containsKey(domain)) {
        groups[domain]!.add(scenario);
      } else {
        groups['other']!.add(scenario);
      }
    }
    groups.removeWhere((k, v) => v.isEmpty);
    return groups;
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
}
