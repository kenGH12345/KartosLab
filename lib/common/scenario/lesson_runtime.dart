import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'lesson_plan.dart';
import 'success_condition.dart';

/// 预测题结果快照（PredictionPanel.onResultChanged 数据）。
@immutable
class PredictionResult {
  const PredictionResult({required this.verified, required this.correct});

  final int verified;
  final int correct;
}

/// sim screen 事件钩子容器。由 LessonScreen 构造、经 simHostBuilder
/// 透传给 sim screen 可选参数（依赖倒置：sim screen 只见回调不见 runtime）。
@immutable
class LessonHooks {
  const LessonHooks({this.onScenarioSuccess, this.onPredictionResult});

  /// 场景 successCriteria 全满足。
  final VoidCallback? onScenarioSuccess;

  /// 预测题结果（verified, correct）。
  final void Function(int verified, int correct)? onPredictionResult;
}

/// 剧本运行状态机（四步契约：load → enterNode → advanceFrom →
/// onScenarioSuccess）。UI 经 ChangeNotifier 监听重建（D2）。
///
/// C5 声明：本类零场景加载逻辑——`loadScenario` 由 sim screen 内部调用
/// （方案 §1.2 D3），剧本层任何文件不得出现场景加载代码（AC-12 守卫断言）。
class LessonRuntime extends ChangeNotifier {
  LessonRuntime();

  LessonPlan? _plan;
  String? _current;
  final Set<String> _completed = {};
  final Set<String> _scenarioSuccess = {};
  final Map<String, PredictionResult> _predictions = {};

  /// 本轮已完成并已流转的源节点（Major-3 · 重玩语义）。
  /// 自动流转路径：完成 → 记入 → 幂等；jumpTo 回到该节点 → 移除 →
  /// 重玩完成可再次流转（completed 保留，进度不倒退）。
  final Set<String> _flowedFrom = {};
  bool _isLessonCompleted = false;

  // ---------- 状态暴露 ----------

  /// null = 未加载。
  LessonPlan? get plan => _plan;

  /// 当前节点 id。
  String? get current => _current;

  LessonNode? get currentNode =>
      _plan == null || _current == null ? null : _plan!.find(_current!);

  /// 已完成节点 id（只读视图）。
  Set<String> get completed => Set.unmodifiable(_completed);

  /// completedRequired / totalRequiredNodes（0~1）。
  double get progress {
    final total = _plan?.totalRequiredNodes ?? 0;
    if (total == 0) return 0;
    final done =
        _completed.where((id) => _plan!.find(id)?.scenario != null).length;
    return done / total;
  }

  /// 进入终点节点（D5：课时完成 = 进入终点节点）。
  bool get isLessonCompleted => _isLessonCompleted;

  /// 指定节点是否解锁（unlock == null → 恒 true；否则条件树求值）。
  /// 幂等纯函数，进度 UI 每帧可调（AC-34~36）。
  bool isUnlocked(String nodeId) {
    final node = _plan?.find(nodeId);
    final unlock = node?.unlock;
    if (unlock == null) return true;
    return _evaluateCondition(unlock);
  }

  /// 条件树求值（T-P2-01 · AC-27）：复用 SuccessCondition.evaluate(leafEvaluator)
  /// 注入模式——组合算子 all/any/not 语义由通用实现（短路），叶子语义剧本私有。
  bool _evaluateCondition(SuccessCondition cond) => cond.evaluate(_lessonLeaf);

  /// 剧本级叶子求值器（方案 §4 语义表）。未知 type / 缺参 / 无记录一律
  /// false 不抛（AC-31/AC-33 fail-safe）。
  bool _lessonLeaf(String type, Map<String, dynamic> params) {
    switch (type) {
      case 'nodeCompleted': // AC-28
        final nodeId = params['nodeId'];
        if (nodeId is! String) return false;
        return _completed.contains(nodeId);
      case 'predictionScore': // AC-29/AC-33
        return _evaluatePredictionScore(params);
      case 'scenarioSuccess': // AC-30
        final nodeId = params['nodeId'];
        if (nodeId == null) {
          final cur = _current;
          if (cur == null) return false;
          return _scenarioSuccess.contains(cur);
        }
        if (nodeId is! String) return false;
        return _scenarioSuccess.contains(nodeId);
      default:
        return false; // 未知 type（AC-31）
    }
  }

  /// predictionScore 求值：无记录 / verified==0 / 未知 metric·operator /
  /// threshold 非数值 → false（AC-33）。
  bool _evaluatePredictionScore(Map<String, dynamic> params) {
    final nodeId = params['nodeId'];
    final metric = params['metric'];
    final operator = params['operator'];
    final threshold = params['threshold'];
    if (nodeId is! String || metric is! String || operator is! String) {
      return false;
    }
    if (threshold is! num) return false;
    final rec = _predictions[nodeId];
    if (rec == null || rec.verified == 0) return false;
    final value = metric == 'ratio'
        ? rec.correct / rec.verified
        : metric == 'count'
            ? rec.correct.toDouble()
            : double.nan; // 未知 metric → 后续比较恒 false
    return switch (operator) {
      'gte' => value >= threshold,
      'lte' => value <= threshold,
      'gt' => value > threshold,
      'lt' => value < threshold,
      'eq' => value == threshold,
      _ => false, // 未知 operator
    };
  }

  // ---------- 四步契约 ----------

  /// 步骤 1 · 剧本加载：注入已解析 plan，重置运行态，current = plan.entry。
  ///
  /// entry 即终点节点 → 直接进入完成态（AC-11 边界）。
  /// 场景加载不在此发生——enterNode 的实际渲染由 LessonScreen 经
  /// simHostBuilder 完成（sim screen 内部 loadScenario，C5）。
  void load(LessonPlan plan) {
    _plan = plan;
    _completed.clear();
    _scenarioSuccess.clear();
    _predictions.clear();
    _flowedFrom.clear();
    _isLessonCompleted = false;
    _current = plan.entry;
    if (plan.entryNode.isEnd) {
      _isLessonCompleted = true;
    }
    notifyListeners();
  }

  /// 步骤 3+4 内部联动 · 场景完成事件（sim screen 钩子回调入口）：
  /// 标记 current 节点 completed + scenarioSuccess → advanceFrom(current)。
  ///
  /// 幂等（Major-3）：同一节点「本轮」只流转一次（_flowedFrom 门控）；
  /// jumpTo 回已完成节点重玩 → 再次完成 → 允许再次流转（completed 保留）。
  void onScenarioSuccess() {
    final plan = _plan;
    final cur = _current;
    if (plan == null || cur == null || _isLessonCompleted) return;
    if (_flowedFrom.contains(cur)) return; // 本轮已流转（幂等）

    _completed.add(cur);
    _scenarioSuccess.add(cur);
    _flowedFrom.add(cur);
    _advanceFrom(cur);
    notifyListeners();
  }

  /// 手动跳转（T-P2-03 · 进度 chips 点击）：未解锁 → 拒绝（返回 false，
  /// 由调用方给提示）；已解锁 → current 切换 + notifyListeners。
  /// completed 保留（节点可重玩）；预测/场景成功记录不跨节点保留语义。
  /// 终点节点不可跳入（jumpTo 仅用于场景节点）。
  bool jumpTo(String nodeId) {
    final plan = _plan;
    if (plan == null) return false;
    final node = plan.find(nodeId);
    if (node == null || node.isEnd) return false;
    if (!isUnlocked(nodeId)) return false;
    // Major-3：重玩新一轮——清除该节点"本轮已流转"标记，完成可再次流转；
    // 若当前处于完成态（终点）→ 恢复进行中（jumpTo 只跳场景节点·终点不可跳入，
    // 但可从终点状态跳回已解锁场景节点——必须清除完成态，否则 onScenarioSuccess
    // 被 _isLessonCompleted 短路，重玩永远无法流转）
    _isLessonCompleted = false;
    _flowedFrom.remove(nodeId);
    _current = nodeId;
    notifyListeners();
    return true;
  }

  /// 预测题结果事件（InquiryDrawer 转发 → sim screen 钩子 → 此处）：
  /// 记录到 _predictions[current]，供 predictionScore 叶子求值（AC-42）。
  void onPredictionResult(int verified, int correct) {
    final cur = _current;
    if (cur == null) return;
    _predictions[cur] =
        PredictionResult(verified: verified, correct: correct);
    // 不 notifyListeners——预测结果仅作为后续 routes 求值输入，
    // 不直接驱动 UI 重建（进度条等不依赖它）。
  }

  // ---------- 私有：步骤 3 流转 ----------

  /// advance.type 分派：
  /// - next → plan.nextInOrder(nodeId)
  /// - onCompleted → advance.to
  /// - routes → P2 实现（T-P2-04，依赖 T-P2-01 条件求值器）
  ///
  /// advance == null 不会发生——终点节点不挂场景、无完成事件（二元绑定）。
  void _advanceFrom(String nodeId) {
    final plan = _plan!;
    final node = plan.find(nodeId);
    final advance = node?.advance;
    if (node == null || advance == null) return;

    String? nextId;
    switch (advance.type) {
      case 'next':
        nextId = plan.nextInOrder(nodeId)?.id;
      case 'onCompleted':
        nextId = advance.to;
      case 'routes':
        // T-P2-04（AC-37/38）：按数组序求值 when（null 项跳过求值·兜底），
        // 首个 true 的 to 生效；全部 false → 末项兜底 to（解析期已保证末项存在）
        final routes = advance.routes;
        if (routes == null || routes.isEmpty) return;
        for (final r in routes) {
          final when = r.when;
          if (when == null) break; // 兜底路由（仅末项可能为 null · D7）
          if (_evaluateCondition(when)) {
            nextId = r.to;
            break;
          }
        }
        nextId ??= routes.last.to;
      default:
        return;
    }
    if (nextId == null) return;

    _current = nextId;
    if (plan.find(nextId)!.isEnd) {
      _isLessonCompleted = true;
    }
  }
}
