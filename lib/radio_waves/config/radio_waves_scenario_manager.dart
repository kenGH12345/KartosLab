import '../../common/scenario/scenario_manager_base.dart';
import '../model/radio_state.dart';
import 'radio_waves_scenario.dart';

/// Radio-waves scenario manager.
///
/// Extends [ScenarioManagerBase]. Loads scenario JSON from
/// `assets/scenarios/radio-waves/`, constructs [RadioState] with
/// appropriate frequency, amplitude, and display options.
class RadioWavesScenarioManager
    extends ScenarioManagerBase<RadioWavesScenario, RadioState> {
  @override
  String get manifestPath => 'assets/scenarios/radio-waves/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/radio-waves/$entryKey.json';

  @override
  RadioWavesScenario Function(Map<String, dynamic>) get fromJson =>
      RadioWavesScenario.fromJson;

  @override
  String Function(RadioWavesScenario) get scenarioId => (s) => s.scenarioId;

  @override
  RadioState Function(RadioWavesScenario) get buildInitialState => _build;

  RadioState _build(RadioWavesScenario s) {
    final state = RadioState();
    state.setFrequency(s.frequency);
    state.setAmplitude(s.amplitude);
    state.showCurve = s.showCurve;
    state.showArrows = s.showArrows;
    state.dynamicFieldEnabled = s.dynamicFieldEnabled;
    return state;
  }
}