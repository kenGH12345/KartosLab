import 'solute.dart';
import 'solution.dart';

/// 组装后的摩尔浓度状态：solutes 列表 + 当前 solution + 视图开关。
///
/// 初始值由场景构建（config 层 `buildInitialState`）· [reset] 恢复场景初始参数。
class MolarityState {
  MolarityState({
    required this.scenarioId,
    required this.solutes,
    required this.solution,
    required this.initialSoluteIndex,
    required this.initialSoluteAmount,
    required this.initialVolume,
    required this.initialValuesVisible,
    bool? valuesVisible,
  }) : valuesVisible = valuesVisible ?? initialValuesVisible;

  /// 当前场景 id（checkObjectives 定位 successCriteria 用）。
  final String scenarioId;

  final List<Solute> solutes;
  final Solution solution;

  /// 场景初始参数（reset 目标）。
  final int initialSoluteIndex;
  final double initialSoluteAmount;
  final double initialVolume;
  final bool initialValuesVisible;

  /// 是否显示数值（Show Values 开关）。
  bool valuesVisible;

  void reset() {
    solution.setSolute(solutes[initialSoluteIndex]);
    solution.setSoluteAmount(initialSoluteAmount);
    solution.setVolume(initialVolume);
    valuesVisible = initialValuesVisible;
  }
}
