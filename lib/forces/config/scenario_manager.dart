import '../../common/scenario/scenario_manager_base.dart';
import 'forces_scenario.dart';

/// Forces scenario manager.
///
/// Extends [ScenarioManagerBase]. Forces has no separate state type
/// (TState = ForcesScenario) and no constraint/objective methods.
/// Overrides [entryKey] because the forces manifest uses `file`
/// instead of `id` as the entry key.
class ForcesScenarioManager
    extends ScenarioManagerBase<ForcesScenario, ForcesScenario> {
  ForcesScenarioManager();

  // ---------------------------------------------------------------------------
  // ScenarioManagerBase required overrides
  // ---------------------------------------------------------------------------

  @override
  String get manifestPath => 'assets/scenarios/forces/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/forces/$entryKey';

  @override
  ForcesScenario Function(Map<String, dynamic>) get fromJson =>
      ForcesScenario.fromJson;

  @override
  String Function(ForcesScenario) get scenarioId => (s) => s.scenarioId;

  @override
  ForcesScenario Function(ForcesScenario) get buildInitialState => (s) => s;

  /// Forces manifest uses `file` key instead of `id`.
  @override
  String entryKey(Map<String, dynamic> entry) => entry['file'] as String;

  /// Try to load a scenario by id, returning null if not found.
  /// Thin wrapper around [findById].
  ForcesScenario? tryLoad(String scenarioId) => findById(scenarioId);
}
