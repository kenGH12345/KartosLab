import 'dart:ui';

import '../../common/scenario/scenario_manager_base.dart';
import '../model/color_vision_state.dart';
import '../solver/photon_beam.dart';
import 'color_vision_scenario.dart';

/// Color-vision scenario manager.
///
/// Extends [ScenarioManagerBase]. Loads scenario JSON from
/// `assets/scenarios/color-vision/`, constructs [ColorVisionState]
/// with the appropriate PhotonBeam configuration.
class ColorVisionScenarioManager
    extends ScenarioManagerBase<ColorVisionScenario, ColorVisionState> {

  @override
  String get manifestPath => 'assets/scenarios/color-vision/manifest.json';

  @override
  String scenarioPath(String entryKey) =>
      'assets/scenarios/color-vision/$entryKey.json';

  @override
  ColorVisionScenario Function(Map<String, dynamic>) get fromJson =>
      ColorVisionScenario.fromJson;

  @override
  String Function(ColorVisionScenario) get scenarioId => (s) => s.scenarioId;

  @override
  ColorVisionState Function(ColorVisionScenario) get buildInitialState => _build;

  ColorVisionState _build(ColorVisionScenario s) {
    final beams = <PhotonBeam>[
      PhotonBeam(
        color: const Color(0xFFFF0000),
        originX: 50, originY: 120,
        maxDistance: 400,
      ),
      PhotonBeam(
        color: const Color(0xFF00FF00),
        originX: 50, originY: 190,
        maxDistance: 400,
      ),
      PhotonBeam(
        color: const Color(0xFF0000FF),
        originX: 50, originY: 260,
        maxDistance: 400,
      ),
    ];

    final state = ColorVisionState(
      beams: beams,
      redIntensity: s.redIntensity,
      greenIntensity: s.greenIntensity,
      blueIntensity: s.blueIntensity,
      personPosition: s.personPosition,
    );

    beams[0].setIntensity(s.redIntensity);
    beams[1].setIntensity(s.greenIntensity);
    beams[2].setIntensity(s.blueIntensity);

    return state;
  }
}
