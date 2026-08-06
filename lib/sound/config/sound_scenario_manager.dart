import '../../common/scenario/scenario_manager_base.dart';
import '../model/sound_state.dart';
import 'sound_scenario.dart';

/// Sound scenario manager.
///
/// Extends [ScenarioManagerBase]. Loads scenario JSON from
/// `assets/scenarios/sound/`, constructs [SoundState] with the
/// appropriate frequency and amplitude.
class SoundScenarioManager
    extends ScenarioManagerBase<SoundScenario, SoundState> {
  @override
  String get manifestPath => 'assets/scenarios/sound/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/sound/$entryKey.json';

  @override
  SoundScenario Function(Map<String, dynamic>) get fromJson =>
      SoundScenario.fromJson;

  @override
  String Function(SoundScenario) get scenarioId => (s) => s.scenarioId;

  @override
  SoundState Function(SoundScenario) get buildInitialState => _build;

  SoundState _build(SoundScenario s) {
    return SoundState(
      frequency: s.frequency,
      amplitude: s.amplitude,
    );
  }
}