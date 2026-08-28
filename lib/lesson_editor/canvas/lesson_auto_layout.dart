import 'dart:ui';

import '../../common/scenario/lesson_plan.dart';

/// 自动布局兜底（T3 · L1 第 1/3 用户）。
///
/// 场景：导入剧本时 `.layout.json` 缺失/损坏（如 AI 生成的 lesson JSON 天然
/// 没有配套布局文件），画布需要一个"不重叠堆叠"的默认坐标——按方案 §3.3，
/// 从 [LessonPlan.entry] 起 BFS 分层，每层节点横向等距排布。
///
/// 与手工/已保存布局的关系：本类只产出"缺失节点"的兜底坐标，调用方
/// （[lesson_importer.dart]）负责与已读取的部分/全量 `.layout.json` 合并
/// （已有坐标优先，缺失的才用本类结果填充）。
abstract final class LessonAutoLayout {
  static const double _colSpacing = 200;
  static const double _rowSpacing = 100;
  static const double _originX = 40;
  static const double _originY = 40;

  /// 计算 [plan] 全部节点的兜底画布坐标（entry 层级 0，逐层递增）。
  ///
  /// 分层规则：BFS 自 [LessonPlan.entry] 沿 next/onCompleted/routes 后继边
  /// 扩展，每个节点取首次被访问到的层级（最短路径层）；[LessonPlan.fromJson]
  /// 已保证图全可达（规则 9），但仍做防御式兜底——理论上不会触发的孤立节点
  /// 追加到末层之后，保证不遗漏任何节点。
  static Map<String, Offset> layout(LessonPlan plan) {
    final byId = {for (final n in plan.nodes) n.id: n};
    final layers = <String, int>{plan.entry: 0};
    final queue = <String>[plan.entry];
    var head = 0;
    while (head < queue.length) {
      final curId = queue[head++];
      final cur = byId[curId];
      if (cur == null) continue;
      final level = layers[curId]!;
      for (final nextId in _successors(cur, plan.nodes)) {
        if (!layers.containsKey(nextId)) {
          layers[nextId] = level + 1;
          queue.add(nextId);
        }
      }
    }
    // 防御式兜底：图校验保证全可达，理论上不会触发，但避免遗漏导致渲染缺位。
    var maxLevel =
        layers.values.isEmpty ? -1 : layers.values.reduce((a, b) => a > b ? a : b);
    for (final n in plan.nodes) {
      layers.putIfAbsent(n.id, () => ++maxLevel);
    }

    final byLevel = <int, List<String>>{};
    for (final n in plan.nodes) {
      byLevel.putIfAbsent(layers[n.id]!, () => []).add(n.id);
    }

    final result = <String, Offset>{};
    for (final e in byLevel.entries) {
      final ids = e.value;
      for (var i = 0; i < ids.length; i++) {
        result[ids[i]] = Offset(
          _originX + i * _colSpacing,
          _originY + e.key * _rowSpacing,
        );
      }
    }
    return result;
  }

  /// 后继集合：next → nodes 数组后继；onCompleted → to；routes → 全部 to；
  /// 终点节点（advance == null）→ 无。与 [LessonPlan] 内部同名私有逻辑同构
  /// （Dart 库私有作用域无法跨文件复用，此处按公开字段重新实现）。
  static Iterable<String> _successors(LessonNode node, List<LessonNode> nodes) sync* {
    final adv = node.advance;
    if (adv == null) return;
    switch (adv.type) {
      case 'next':
        for (var i = 0; i < nodes.length - 1; i++) {
          if (nodes[i].id == node.id) {
            yield nodes[i + 1].id;
            return;
          }
        }
      case 'onCompleted':
        final to = adv.to;
        if (to != null) yield to;
      case 'routes':
        for (final r in adv.routes ?? const <LessonRoute>[]) {
          yield r.to;
        }
    }
  }
}
