import '../../../common/scenario/scenario_manager_base.dart';
import '../model/molarity_state.dart';
import '../model/solution.dart';
import '../model/solute.dart';
import '../model/solvent.dart';
import 'molarity_scenario.dart';

/// Molarity 场景管理器：继承公共 ScenarioManagerBase（§C1 启动路径）。
class MolarityScenarioManager
    extends ScenarioManagerBase<MolarityScenario, MolarityState> {
  @override
  String get manifestPath => 'assets/scenarios/molarity/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/molarity/$entryKey.json';

  @override
  MolarityScenario Function(Map<String, dynamic>) get fromJson =>
      MolarityScenario.fromJson;

  @override
  String Function(MolarityScenario) get scenarioId => (s) => s.scenarioId;

  @override
  MolarityState Function(MolarityScenario) get buildInitialState => _build;

  MolarityState _build(MolarityScenario scenario) {
    final solutes = scenario.solutes;
    final initialIndex = solutes.isEmpty
        ? 0
        : scenario.initialSoluteIndex.clamp(0, solutes.length - 1);
    final solution = Solution(
      solvent: const Solvent(),
      solute: solutes.isEmpty ? _fallbackSolute() : solutes[initialIndex],
      soluteAmount: scenario.initialSoluteAmount,
      volume: scenario.initialVolume,
    );
    return MolarityState(
      scenarioId: scenario.scenarioId,
      solutes: solutes,
      solution: solution,
      initialSoluteIndex: initialIndex,
      initialSoluteAmount: scenario.initialSoluteAmount,
      initialVolume: scenario.initialVolume,
      initialValuesVisible: scenario.initialValuesVisible,
    );
  }

  /// 极端的空溶质列表兜底（配置缺失不 crash · 对齐降级策略）。
  static Solute _fallbackSolute() =>
      MolarityScenario.fromJson(const {
        'scenarioId': 'fallback',
        'name': 'Fallback',
        'initialParams': {'soluteIndex': 0, 'soluteAmount': 0.5, 'volume': 0.5},
        'solutes': [
          {
            'name': '饮料粉',
            'formula': 'Drink mix',
            'saturatedConcentration': 5.95,
            'solutionColorMin': '#FFE1E1',
            'solutionColorMax': '#FF0000',
            'particleColor': '#FF0000',
          },
        ],
      }).solutes.first;

  @override
  bool checkObjectives(MolarityState state) {
    final scenario = findById(state.scenarioId);
    if (scenario == null || scenario.successCriteria.isEmpty) return true;
    return scenario.successCriteria.every((c) => c.check(state));
  }
}
