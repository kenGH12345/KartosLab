import 'dart:ui';

import '../../common/scenario/scenario_manager_base.dart';
import '../../common/scenario/success_condition.dart';
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

  ColorVisionScenario? _currentScenario;

  /// 当前生效场景（checkObjectives 判定依据 · AC-4.4）。
  ColorVisionScenario? get currentScenario => _currentScenario;

  /// 记录当前生效场景（checkObjectives 判定依据 · AC-4.4）。
  ///
  /// screen 自行构造 state（不经过 buildInitialState）时必须显式同步，
  /// 否则 `_currentScenario` 恒为 null、checkObjectives 恒 false。
  void setCurrentScenario(ColorVisionScenario s) => _currentScenario = s;

  @override
  ColorVisionState Function(ColorVisionScenario) get buildInitialState {
    return (s) {
      _currentScenario = s;
      return _build(s);
    };
  }

  /// 判定全部 successCriteria 是否达成（AC-4.4 · 挑战完成触发）。
  @override
  bool checkObjectives(ColorVisionState state) {
    final s = _currentScenario;
    if (s == null || s.successCriteria.isEmpty) return false;
    return SuccessCondition.allSatisfied(
      s.successCriteria,
      (type, params) => CVCriterionConfig.evaluateLeaf(type, params, state),
    );
  }

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
