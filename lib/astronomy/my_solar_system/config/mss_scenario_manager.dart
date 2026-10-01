/// Scenario manager. [Kratos] `ScenarioManagerBase` + `assets/scenarios/my-solar-system/`.
library;

import '../../../common/scenario/scenario_manager_base.dart';
import '../model/body_info.dart';
import '../model/mss_vec.dart';
import 'mss_scenario.dart';

class MssScenarioManager
    extends ScenarioManagerBase<MssScenario, List<BodyInfo>> {
  @override
  String get manifestPath =>
      'assets/scenarios/my-solar-system/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/my-solar-system/$entryKey.json';

  @override
  MssScenario Function(Map<String, dynamic>) get fromJson =>
      MssScenario.fromJson;

  @override
  String Function(MssScenario) get scenarioId => (s) => s.scenarioId;

  @override
  List<BodyInfo> Function(MssScenario) get buildInitialState =>
      (s) => s.bodies;

  /// [MSS] Intro / Lab 默认 SUN_PLANET。JSON 失败时降级，不 crash。
  static MssScenario sunPlanetFallback() {
    return MssScenario(
      scenarioId: 'sun_planet',
      name: 'Sun, Planet',
      comboVisible: true,
      bodies: [
        BodyInfo(
          mass: 250,
          position: MssVec(0, 0),
          velocity: MssVec(0, -2.3446),
        ),
        BodyInfo(
          mass: 25,
          position: MssVec(2, 0),
          velocity: MssVec(0, 23.4457),
        ),
      ],
    );
  }

  static List<BodyInfo> labInactiveSlots() => [
        BodyInfo(
          mass: 0.1,
          position: MssVec(3, 0),
          velocity: MssVec(0, 10),
          isActive: false,
        ),
        BodyInfo(
          mass: 0.1,
          position: MssVec(-3, 0),
          velocity: MssVec(0, -10),
          isActive: false,
        ),
      ];
}
