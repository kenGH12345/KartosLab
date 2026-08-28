import 'package:flutter/foundation.dart';

import '../../common/scenario/success_condition.dart';
import '../models/editable_lesson_model.dart';
import 'conflict_rules.dart';

/// 冲突警告（F14 输出 · AC-19）。
@immutable
class ConflictWarning {
  const ConflictWarning({
    required this.type,
    required this.reason,
    this.fromNodeId,
    this.toNodeId,
  });

  /// 'semantic' = 教学语义冲突（sim→sim 组合）| 'dataFlow' = 数据传递冲突
  /// （条件树叶子跨 sim 引用）。
  final String type;

  final String reason;

  /// 涉及的源节点（semantic 的边起点 / dataFlow 的条件所在节点）。
  final String? fromNodeId;

  /// 涉及的终点（semantic 的边终点 / dataFlow 的跨 sim 引用节点）。
  final String? toNodeId;

  String get label => type == 'semantic' ? '教学语义冲突' : '数据传递冲突';
}

/// 冲突检测器（T20 · F14 · AC-19/AC-20/AC-21）。
///
/// 两类（技术方案 §6）：
/// - **教学语义**：遍历所有有向边（next→数组后继 / onCompleted→to /
///   routes→全部 to），跨 sim 组合查规则表（白名单放行 · 警告表命中报）
/// - **数据传递**：遍历每个节点 unlock / routes when 的条件树叶子
///   （nodeCompleted / predictionScore / scenarioSuccess），叶子 nodeId
///   引用的节点 sim ≠ 当前节点 sim → 记警告（运行时本已 fail-safe，故
///   仅警告级 · C7）
class ConflictChecker {
  const ConflictChecker._();

  /// 检测剧本冲突。 [rules] 为规则表（可降级：降级态仅查数据传递）。
  static List<ConflictWarning> analyze(
    EditableLessonModel model,
    ConflictRuleSet rules,
  ) {
    final warnings = <ConflictWarning>[];
    final nodeById = {for (final n in model.nodes) n.id: n};

    // ---- 第一类 · 教学语义冲突（仅规则表正常时检查） ----
    if (!rules.isDegraded) {
      for (final edge in model.edges) {
        final from = nodeById[edge.fromId];
        final to = nodeById[edge.toId];
        if (from == null || to == null) continue;
        final fromSim = from.scenario?.sim;
        final toSim = to.scenario?.sim;
        if (fromSim == null || toSim == null || fromSim.isEmpty || toSim.isEmpty) {
          continue; // 终点/未绑定场景无边语义
        }
        if (fromSim == toSim) continue; // 同 sim 不查
        if (rules.isAllowed(fromSim, toSim)) continue; // 白名单放行（AC-21）
        final warn = rules.findWarn(fromSim, toSim);
        if (warn != null) {
          warnings.add(
            ConflictWarning(
              type: 'semantic',
              reason: '$fromSim→$toSim: ${warn.reason}',
              fromNodeId: edge.fromId,
              toNodeId: edge.toId,
            ),
          );
        }
        // 未知组合 → 保守放行（交互指南 §4.5）
      }
    }

    // ---- 第二类 · 数据传递冲突（条件树叶子跨 sim 引用） ----
    for (final node in model.nodes) {
      final nodeSim = node.scenario?.sim;
      if (nodeSim == null || nodeSim.isEmpty) continue;
      // unlock 条件树
      if (node.unlock != null) {
        _checkTree(node.unlock!, node, nodeSim, nodeById, warnings);
      }
      // routes 各 when
      final routes = node.advance?.routes;
      if (routes != null) {
        for (final r in routes) {
          if (r.when != null) {
            _checkTree(r.when!, node, nodeSim, nodeById, warnings);
          }
        }
      }
    }

    return warnings;
  }

  static void _checkTree(
    SuccessCondition cond,
    EditableNode owner,
    String ownerSim,
    Map<String, EditableNode> nodeById,
    List<ConflictWarning> warnings,
  ) {
    for (final leaf in cond.collectLeaves()) {
      if (leaf.type != 'nodeCompleted' &&
          leaf.type != 'predictionScore' &&
          leaf.type != 'scenarioSuccess') {
        continue;
      }
      final nodeId = leaf.params['nodeId'];
      if (nodeId is! String || nodeId.isEmpty) continue;
      final ref = nodeById[nodeId];
      if (ref == null) continue; // 悬空引用由 LessonPlan.fromJson 校验兜底
      final refSim = ref.scenario?.sim;
      if (refSim != null && refSim != ownerSim) {
        warnings.add(
          ConflictWarning(
            type: 'dataFlow',
            reason:
                '条件树叶子引用跨 sim 节点（$leaf.type → $nodeId，sim $refSim ≠ 当前 $ownerSim）',
            fromNodeId: owner.id,
            toNodeId: nodeId,
          ),
        );
      }
    }
  }
}
