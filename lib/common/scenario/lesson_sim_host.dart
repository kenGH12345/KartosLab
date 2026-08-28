import 'package:flutter/widgets.dart';

import '../../circuit/config/scenario_manager.dart';
import '../../circuit/screens/circuit_screen.dart';
import '../../color_vision/config/color_vision_scenario.dart';
import '../../color_vision/config/color_vision_scenario_manager.dart';
import '../../color_vision/screens/rgb_bulbs_screen.dart';
import 'lesson_plan.dart';
import 'lesson_runtime.dart';
import 'success_condition.dart';

/// 节点 → sim screen widget 构建器签名。
typedef LessonSimHostBuilder =
    Widget Function(BuildContext context, LessonNode node, LessonHooks hooks);

/// sim 宿主注册中心：试点 2 sim（C-R6）。每个 host 惰性缓存 manager 实例。
///
/// 生命周期约定（方案 §7 加载时序）：
/// 1. 入口初始化先 `await LessonSimHosts.ensureManagersLoaded()`（幂等）
/// 2. 再 `loader.loadAll(scenarioPlayable: LessonSimHosts.scenarioPlayable())`
/// 3. LessonScreen 的 simHostBuilder 实参固定为 `LessonSimHosts.dispatch()`（D9）
class LessonSimHosts {
  LessonSimHosts._();

  static CircuitScenarioManager? _circuitMgr;
  static ColorVisionScenarioManager? _cvMgr;
  static Future<void>? _loading;

  /// 各 sim 已实现求值叶子集（D10 · 方案 §2.4）：
  /// - circuit：`circuit_learning_objective.dart` evaluateLeaf 已实现 4 类
  /// - color_vision：仅 colorMatch（filterPassed/intensityReached 未实现 →
  ///   引用其的场景被本闭包拦截；singleBulb 场景由此统一排除，R5 并入）
  static const Set<String> _circuitLeafTypes = {
    'circuitClosed',
    'componentPowered',
    'bulbBrightness',
    'componentCount',
  };
  static const Set<String> _cvLeafTypes = {'colorMatch'};

  /// 惰性加载全部已注册 sim manager（幂等 + 并发去重）。
  /// 46 场景全量 manifest 读取 <1s，一次会话内复用。
  static Future<void> ensureManagersLoaded() {
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    final circuit = CircuitScenarioManager();
    await circuit.loadScenarios();
    final cv = ColorVisionScenarioManager();
    await cv.loadScenarios();
    _circuitMgr = circuit;
    _cvMgr = cv;
  }

  /// 跨 sim 分派构建器（D9 · Blocker-2）：按 node.scenario.sim 分发到对应
  /// 宿主构建器，使混合 sim 剧本逐节点进入正确宿主。
  /// LessonScreen 的 simHostBuilder 实参固定为本方法。
  static LessonSimHostBuilder dispatch() {
    final builders = <String, LessonSimHostBuilder>{
      'circuit': circuit(),
      'color_vision': colorVision(),
    };
    return (context, node, hooks) {
      final b = builders[node.scenario?.sim];
      if (b == null) {
        // 防御：正常不发生——解析期 scenarioPlayable 已拦截
        debugPrint('LessonSimHosts: 未注册 sim ${node.scenario?.sim}');
        return const SizedBox.shrink();
      }
      return b(context, node, hooks);
    };
  }

  /// circuit：单屏 sim。CircuitScreen 经 initialScenarioId 加载指定场景
  /// （内部仍走 manager.loadScenario · C5）；剧本模式 showScenarioMenu:
  /// false 隐藏 AppBar 场景下拉（D11 · Major-3 防节点内逃逸编排）。
  static LessonSimHostBuilder circuit() {
    return (context, node, hooks) {
      return CircuitScreen(
        initialScenarioId: node.scenario!.scenarioId,
        showScenarioMenu: false,
        onScenarioSuccess: hooks.onScenarioSuccess,
        onPredictionResult: hooks.onPredictionResult,
      );
    };
  }

  /// color_vision：试点仅 rgb 屏场景（§0.1 排除证据）。
  /// scenarioList 传空列表：自带场景菜单「非空即显示」→ 空列表菜单自隐，
  /// 剧本模式禁用场景切换零新参数（D11）；场景本体由 scenario 参数直接驱动。
  static LessonSimHostBuilder colorVision() {
    return (context, node, hooks) {
      final mgr = _cvMgr;
      final scenarioId = node.scenario?.scenarioId;
      if (mgr == null || scenarioId == null) {
        debugPrint('LessonSimHosts: color_vision manager 未加载或节点缺场景');
        return const SizedBox.shrink();
      }
      final s = mgr.findById(scenarioId);
      if (s == null) {
        // 防御：正常不发生——解析期 scenarioPlayable 已校验存在性
        debugPrint('LessonSimHosts: color_vision 场景不存在 $scenarioId');
        return const SizedBox.shrink();
      }
      return MagicLabScreen(
        scenario: s,
        scenarioList: const [],
        manager: mgr,
        onScenarioSuccess: hooks.onScenarioSuccess,
        onPredictionResult: hooks.onPredictionResult,
      );
    };
  }

  /// 场景「存在 + 可完成」闭包（D10 · LessonManifestLoader.loadAll /
  /// LessonPlan.fromJson 注入用）。
  ///
  /// 全部满足才 true：sim ∈ 已注册 host 且 manager.findById != null 且
  /// objectives/successCriteria 非空 且全部叶子 type ∈ 该 sim 已实现集。
  /// 未注册 sim / 不存在 / 不可完成一律 false → AC-3 解析期 fail loud。
  static bool Function(String sim, String scenarioId) scenarioPlayable() {
    return (sim, scenarioId) {
      switch (sim) {
        case 'circuit':
          final mgr = _circuitMgr;
          if (mgr == null) {
            debugPrint('LessonSimHosts.scenarioPlayable: circuit manager 未加载'
                '（应先 ensureManagersLoaded）');
            return false;
          }
          final s = mgr.findById(scenarioId);
          final criteria = s?.objectives?.successCriteria;
          if (s == null || criteria == null || criteria.isEmpty) return false;
          return _allLeavesImplemented(criteria, _circuitLeafTypes);
        case 'color_vision':
          final mgr = _cvMgr;
          if (mgr == null) {
            debugPrint('LessonSimHosts.scenarioPlayable: color_vision manager '
                '未加载（应先 ensureManagersLoaded）');
            return false;
          }
          final s = mgr.findById(scenarioId);
          if (s == null || s.successCriteria.isEmpty) return false;
          // 试点仅 rgb 屏（singleBulb 显式排除 · D10/§0.1）
          if (s.screen != CVScreen.rgb) return false;
          if (!_allLeavesImplemented(s.successCriteria, _cvLeafTypes)) {
            return false;
          }
          // D10 强化（代码评审 Blocker-2 · 2026-08-25）：colorMatch 单场景只允许
          // 1 个 colorMatch 叶子——判定链为"同一瞬时态 allSatisfied"，多目标
          // （先后状态，如"先黄后白"）必然互斥不可满足（rgb-yellow-only /
          // rgb-cyan-challenge 曾中招）。静态零成本拦截，防止 UNSAT 场景再进剧本。
          var colorMatchCount = 0;
          for (final cond in s.successCriteria) {
            for (final leaf in cond.collectLeaves()) {
              if (leaf.type == 'colorMatch') colorMatchCount++;
            }
          }
          return colorMatchCount <= 1;
        default:
          return false; // 未注册 sim（D8 封闭集）
      }
    };
  }

  /// 全部叶子 type ∈ 已实现集（组合节点递归展开）。
  static bool _allLeavesImplemented(
      List<SuccessCondition> criteria, Set<String> implemented) {
    for (final cond in criteria) {
      for (final leaf in cond.collectLeaves()) {
        if (!implemented.contains(leaf.type)) return false;
      }
    }
    return true;
  }

  /// 场景目录（T10 · 编辑器场景选择器数据源 · 只读访问器）。
  ///
  /// 返回 已注册 sim → 该 sim「存在 + 可完成」的 scenarioId 列表（复用
  /// [scenarioPlayable] 过滤）。新增 sim 接线后自动出现在目录中（T2 拍板：
  /// 注册表驱动 + 动态刷新，进入编辑器/手动刷新按钮时重新调用本方法）。
  ///
  /// 设计意图（方案 §T2）：编辑器只"读到什么显示什么"，不硬编码 enum；
  /// 未注册 sim 不出现在目录（scenarioPlayable 返回 false 的 sim 被排除）。
  static Future<Map<String, List<String>>> loadSceneCatalog() async {
    await ensureManagersLoaded();
    final playable = scenarioPlayable();
    final result = <String, List<String>>{};
    final circuit = _circuitMgr;
    if (circuit != null) {
      result['circuit'] = [
        for (final s in circuit.scenarios)
          if (playable('circuit', circuit.scenarioId(s))) circuit.scenarioId(s),
      ];
    }
    final cv = _cvMgr;
    if (cv != null) {
      result['color_vision'] = [
        for (final s in cv.scenarios)
          if (playable('color_vision', cv.scenarioId(s))) cv.scenarioId(s),
      ];
    }
    return result;
  }
}
