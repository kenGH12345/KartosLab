import '../../common/scenario/scenario_manager_base.dart';
import '../model/wave_engine.dart';
import 'wave_interference_scenario.dart';

/// Wave-interference scenario manager.
class WaveInterferenceScenarioManager
    extends ScenarioManagerBase<WaveInterferenceScenario, WaveEngine> {
  @override
  String get manifestPath => 'assets/scenarios/wave-interference/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/wave-interference/$entryKey.json';

  @override
  WaveInterferenceScenario Function(Map<String, dynamic>) get fromJson =>
      WaveInterferenceScenario.fromJson;

  @override
  String Function(WaveInterferenceScenario) get scenarioId => (s) => s.scenarioId;

  @override
  WaveEngine Function(WaveInterferenceScenario) get buildInitialState => _build;

  WaveEngine _build(WaveInterferenceScenario s) {
    final engine = WaveEngine(width: 80, height: 55);
    if (s.barrierEnabled) {
      engine.setDoubleSlit(35, 2, s.slitSize, s.slitSeparation);
    }
    return engine;
  }
}