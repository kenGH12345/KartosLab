import '../config/molarity_scenario_manager.dart';
import '../model/molarity_state.dart';

/// Molarity 控制器：编排场景加载与交互回写（无 UI · 对齐 MVC）。
class MolarityController {
  MolarityController({required this.manager});

  final MolarityScenarioManager manager;

  /// 当前状态（由 [init] 构建 · 场景切换时重建）。
  MolarityState? currentState;

  MolarityState get state {
    final s = currentState;
    if (s == null) {
      throw StateError('MolarityController not initialized — call init() first');
    }
    return s;
  }

  /// §C1 启动路径：加载场景池 → 构建指定场景状态。
  ///
  /// manager 已预加载（注入/测试）时跳过 loadScenarios（同步构建 · 无异步窗口）。
  Future<void> init({String? scenarioId}) async {
    if (manager.scenarios.isEmpty) {
      await manager.loadScenarios();
    }
    currentState = _load(scenarioId);
  }

  MolarityState _load(String? scenarioId) {
    final id = scenarioId ?? (manager.scenarios.isNotEmpty ? manager.scenarios.first.scenarioId : 'default');
    try {
      return manager.loadScenario(id);
    } catch (_) {
      // 降级：找不到场景时不 crash（AC-3.5）
      if (manager.scenarios.isNotEmpty) {
        return manager.loadScenario(manager.scenarios.first.scenarioId);
      }
      rethrow;
    }
  }

  /// 切换场景（重建状态）。
  MolarityState loadScenario(String scenarioId) {
    currentState = _load(scenarioId);
    return state;
  }

  void selectSolute(int index) {
    final solutes = state.solutes;
    if (index < 0 || index >= solutes.length) return;
    state.solution.setSolute(solutes[index]);
  }

  /// 写入前 clamp 到物理范围（对齐蓝本常量 · 防 JSON paramRanges 外值）。
  void setSoluteAmount(double v) {
    state.solution.setSoluteAmount(v.clamp(0.0, 1.0));
  }

  void setVolume(double v) {
    state.solution.setVolume(v.clamp(0.2, 1.0));
  }

  void toggleValues(bool v) {
    state.valuesVisible = v;
  }

  void reset() {
    state.reset();
  }
}
