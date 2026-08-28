import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../common/scenario/lesson_plan.dart';
import '../../common/scenario/success_condition.dart';

/// 可编辑节点（编辑器中间态承载）。
///
/// 与运行时 [LessonNode] 解耦：允许"未配 advance"等中间态（运行时
/// LessonPlan.fromJson 会 fail loud，编辑态允许暂存）。保存前由
/// LessonValidator 强制补齐（方案 §5.2 · R5）。
@immutable
class EditableNode {
  const EditableNode({
    required this.id,
    required this.title,
    this.scenario,
    this.unlock,
    this.advance,
  });

  final String id;
  final String title;

  /// null = 终点节点。
  final LessonScenarioRef? scenario;

  /// null = 无门禁。
  final SuccessCondition? unlock;

  /// null = 课时终点（编辑中间态允许；保存前校验）。
  final LessonAdvance? advance;

  bool get isEnd => scenario == null;

  EditableNode copyWith({
    String? id,
    String? title,
    LessonScenarioRef? scenario,
    SuccessCondition? unlock,
    LessonAdvance? advance,
  }) {
    return EditableNode(
      id: id ?? this.id,
      title: title ?? this.title,
      scenario: scenario ?? this.scenario,
      unlock: unlock ?? this.unlock,
      advance: advance ?? this.advance,
    );
  }
}

/// 画布连线（节点流转的可视化边 · T5/T6）。
///
/// 从 [EditableLessonModel.nodes] 的 advance 推导（单一数据源，不单独存储）。
/// [type] 与运行时 advance.type 对应：next / onCompleted / routes。
///
/// 三型视觉（T6）：
/// - next → 蓝色实线
/// - onCompleted → 蓝色实线 + "完成后" 标签（源节点完成即流转）
/// - routes → 实线 + 条件名标签（[label] = when.description）；兜底路由
///   （when == null）→ 灰色虚线 + "否则" 标签（[isFallback] = true）
@immutable
class LessonEdge {
  const LessonEdge({
    required this.fromId,
    required this.toId,
    required this.type,
    this.label,
    this.isFallback = false,
  });

  final String fromId;
  final String toId;

  /// 'next' | 'onCompleted' | 'routes'。
  final String type;

  /// 连线标签（routes 条件名 / onCompleted 恒为"完成后"；next 无）。
  final String? label;

  /// 兜底路由标记（routes 末项 when == null）。
  final bool isFallback;
}

/// 可编辑剧本模型（编辑器 ↔ LessonPlan JSON 双向映射）。
///
/// [layout] 为 editor-only 节点画布坐标（方案 T3 · 外置 .layout.json，
/// 不进入 lesson.schema.json）。修改一律 copyWith 返回新实例。
@immutable
class EditableLessonModel {
  const EditableLessonModel({
    this.lessonId = '',
    this.name = '',
    this.version = '1.0',
    this.description = '',
    this.entry,
    this.nodes = const [],
    this.layout = const {},
  });

  final String lessonId;
  final String name;
  final String version;
  final String description;

  /// null = 新建态尚未指定 entry。
  final String? entry;

  final List<EditableNode> nodes;

  /// 节点 id → 画布坐标（editor-only · 1:1 屏幕坐标，SceneProjection origin=zero）。
  final Map<String, Offset> layout;

  EditableLessonModel copyWith({
    String? lessonId,
    String? name,
    String? version,
    String? description,
    Object? entry = _unset,
    List<EditableNode>? nodes,
    Map<String, Offset>? layout,
  }) {
    return EditableLessonModel(
      lessonId: lessonId ?? this.lessonId,
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      entry: entry == _unset ? this.entry : entry as String?,
      nodes: nodes ?? this.nodes,
      layout: layout ?? this.layout,
    );
  }

  /// sentinel：区分"未传参数"与"显式传 null（清空 entry）"。
  static const Object _unset = Object();

  /// 画布连线列表：从 nodes 的 advance 推导（T5/T6 · 单一数据源）。
  ///
  /// - next → nodes 数组后继（advance.to 为空，运行时语义为数组顺延）
  /// - onCompleted → advance.to（label = "完成后"）
  /// - routes → 全部路由的 to（label = when.description；末项 when==null
  ///   标 isFallback = true，即运行时兜底路由）
  List<LessonEdge> get edges {
    final result = <LessonEdge>[];
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final adv = n.advance;
      if (adv == null) continue;
      switch (adv.type) {
        case 'next':
          if (i < nodes.length - 1) {
            result.add(
              LessonEdge(fromId: n.id, toId: nodes[i + 1].id, type: 'next'),
            );
          }
        case 'onCompleted':
          if (adv.to != null) {
            result.add(
              LessonEdge(
                fromId: n.id,
                toId: adv.to!,
                type: 'onCompleted',
                label: '完成后',
              ),
            );
          }
        case 'routes':
          final routes = adv.routes ?? const <LessonRoute>[];
          for (var ri = 0; ri < routes.length; ri++) {
            final r = routes[ri];
            final isFallback = ri == routes.length - 1 && r.when == null;
            result.add(
              LessonEdge(
                fromId: n.id,
                toId: r.to,
                type: 'routes',
                label: isFallback ? '否则' : conditionLabel(r.when),
                isFallback: isFallback,
              ),
            );
          }
        default:
          break;
      }
    }
    return result;
  }

  /// 更新指定节点（copyWith 到 nodes 列表）。
  EditableLessonModel updateNode(String id, EditableNode Function(EditableNode) fn) {
    return copyWith(
      nodes: [
        for (final n in nodes) n.id == id ? fn(n) : n,
      ],
    );
  }

  /// 序列化为 lesson.schema.json 契约（保存/导出用）。
  ///
  /// 仅含运行时字段（lessonId/name/version/description/entry/nodes），
  /// layout 不进入（T3）。与运行时 cross-sim-explore.json 同构（方案 §5.2）。
  Map<String, dynamic> toLessonPlanJson() {
    return {
      'lessonId': lessonId,
      'name': name,
      'version': version,
      'description': description,
      'entry': entry,
      'nodes': [
        for (final n in nodes)
          {
            'id': n.id,
            'title': n.title,
            if (n.scenario != null)
              'scenario': {
                'sim': n.scenario!.sim,
                'scenarioId': n.scenario!.scenarioId,
              }
            else
              'scenario': null,
            if (n.unlock != null) 'unlock': n.unlock!.toJson() else 'unlock': null,
            if (n.advance != null) 'advance': _advanceToJson(n.advance!)
            else
              'advance': null,
          },
      ],
    };
  }

  static Map<String, dynamic> _advanceToJson(LessonAdvance adv) {
    return {
      'type': adv.type,
      if (adv.to != null) 'to': adv.to,
      if (adv.routes != null)
        'routes': [
          for (final r in adv.routes!)
            {
              'to': r.to,
              if (r.when != null) 'when': r.when!.toJson() else 'when': null,
            },
        ],
    };
  }

  /// 从运行时 LessonPlan JSON 解析为可编辑模型（导入用）。
  ///
  /// [scenarioPlayable] 用于复用运行时校验；解析失败抛 [FormatException]
  /// （与 LessonPlan.fromJson 同契约 · fail loud）。[layout] 由调用方
  /// 从 .layout.json 注入（T3 · 缺失则自动布局兜底）。
  factory EditableLessonModel.fromLessonPlanJson(
    Map<String, dynamic> json, {
    Map<String, Offset> layout = const {},
  }) {
    // 复用运行时完整校验（9 图校验 + scenarioPlayable），保证导入即合法
    // （校验失败抛 FormatException，由调用方降级处理）。
    final plan = LessonPlan.fromJson(
      json,
      scenarioPlayable: (sim, id) => true, // 仅结构校验，可玩性由导入方注入
    );
    return EditableLessonModel(
      lessonId: plan.lessonId,
      name: plan.name,
      version: plan.version,
      description: plan.description,
      entry: plan.entry,
      nodes: [
        for (final n in plan.nodes)
          EditableNode(
            id: n.id,
            title: n.title,
            scenario: n.scenario,
            unlock: n.unlock,
            advance: n.advance,
          ),
      ],
      layout: layout,
    );
  }
}

/// 提取条件节点的可读标签（连线/T6 与条件树 UI 共用）。
///
/// [SuccessCondition] 为 sealed 类：叶子必填 description；组合节点
/// description 可选（缺省用类型名概括）。
String? conditionLabel(SuccessCondition? cond) {
  switch (cond) {
    case null:
      return null;
    case LeafCondition(:final description):
      return description.isEmpty ? '条件' : description;
    case AllCondition(:final description):
      return (description != null && description.isNotEmpty)
          ? description
          : '全部满足';
    case AnyCondition(:final description):
      return (description != null && description.isNotEmpty)
          ? description
          : '任一满足';
    case NotCondition(:final description):
      return (description != null && description.isNotEmpty)
          ? description
          : '取反';
  }
}
