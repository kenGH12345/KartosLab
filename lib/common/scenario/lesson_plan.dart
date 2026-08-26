import 'package:flutter/foundation.dart';

import 'success_condition.dart';

/// 剧本节点引用的既有场景（引用式资产，不复制场景数据）。
@immutable
class LessonScenarioRef {
  const LessonScenarioRef({required this.sim, required this.scenarioId});

  /// 'circuit' | 'color_vision'（试点封闭，见方案 D8）。
  final String sim;

  /// 须在该 sim manifest 中存在且可完成（解析期校验，D10）。
  final String scenarioId;
}

/// 条件路由项。末项 [when] == null 为兜底路由（仅末项允许，解析期强制，D7）。
@immutable
class LessonRoute {
  const LessonRoute({required this.to, this.when});

  /// 目标节点 id（解析期校验存在）。
  final String to;

  /// null = 兜底路由。
  final SuccessCondition? when;
}

/// 节点流转指令。
@immutable
class LessonAdvance {
  const LessonAdvance({required this.type, this.to, this.routes});

  /// 'next' | 'onCompleted' | 'routes'。
  final String type;

  /// onCompleted 时必填（解析期校验）。
  final String? to;

  /// routes 时必填非空（解析期校验）。
  final List<LessonRoute>? routes;
}

/// 剧本节点。scenario == null ⇔ advance == null（终点节点二元绑定，D5）。
@immutable
class LessonNode {
  const LessonNode({
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

  /// null = 无门禁（始终可进）。
  final SuccessCondition? unlock;

  /// null = 课时终点。
  final LessonAdvance? advance;

  /// 终点节点判定（D5：课时完成 = 进入终点节点）。
  bool get isEnd => scenario == null;
}

/// 剧本（不可变解析产物）。
///
/// `fromJson` 为 fail loud 解析 + 全量图校验（9 条规则，方案 §2.1），
/// 任何违规抛 [FormatException]，错误信息一律以 `lessonId` 开头（AC-2 族）。
@immutable
class LessonPlan {
  const LessonPlan({
    required this.lessonId,
    required this.name,
    required this.version,
    required this.description,
    required this.entry,
    required this.nodes,
  });

  /// fail loud 解析 + 全量图校验。
  ///
  /// [scenarioPlayable] 由调用方注入（各 sim manager 的「存在 + 可完成」
  /// 组合闭包，D10），使本类不依赖任何具体 sim 类型（依赖倒置）；
  /// 未注册 sim / 不存在场景 / 不可完成场景一律 false（D8/D10）。
  ///
  /// 一切解析异常（含 [SuccessCondition.fromJson] 叶子缺 id/description
  /// 抛出的 TypeError）统一包装为 [FormatException]（lessonId 前缀），
  /// 保证 `loadAll` 的课时级降级能捕获（评审 Minor-4 约定）。
  factory LessonPlan.fromJson(
    Map<String, dynamic> json, {
    required bool Function(String sim, String scenarioId) scenarioPlayable,
  }) {
    // ---- 顶层必填字段（规则 1 前半） ----
    final lessonId = json['lessonId'];
    if (lessonId is! String || lessonId.isEmpty) {
      throw const FormatException('剧本缺少 lessonId 或类型非法');
    }

    Never fail(String reason) =>
        throw FormatException('$lessonId: $reason');

    try {
      final name = json['name'];
      final version = json['version'];
      final description = json['description'];
      final entry = json['entry'];
      final rawNodes = json['nodes'];
      if (name is! String || name.isEmpty) fail('缺少 name 或类型非法');
      if (version is! String || version.isEmpty) fail('缺少 version 或类型非法');
      if (description is! String) fail('缺少 description 或类型非法');
      if (entry is! String || entry.isEmpty) fail('缺少 entry 或类型非法');
      if (rawNodes is! List || rawNodes.isEmpty) {
        fail('nodes 必须是非空数组');
      }

      // ---- 逐节点解析（规则 1 后半 / 4 / 5 / 7） ----
      final nodes = <LessonNode>[];
      for (final raw in rawNodes) {
        if (raw is! Map<String, dynamic>) {
          fail('nodes 数组元素必须是对象，实际为 ${raw.runtimeType}');
        }
        nodes.add(_parseNode(raw, fail, scenarioPlayable));
      }

      // ---- 规则 2：节点 id 全局唯一 ----
      final seen = <String>{};
      for (final n in nodes) {
        if (!seen.add(n.id)) fail('节点 id 重复: "${n.id}"');
      }

      final byId = {for (final n in nodes) n.id: n};

      // ---- 规则 3：entry 指向存在节点 ----
      if (!byId.containsKey(entry)) {
        fail('entry 指向不存在的节点: "$entry"');
      }

      // ---- 规则 6：advance 三型校验 + 引用存在性 ----
      for (var i = 0; i < nodes.length; i++) {
        final n = nodes[i];
        final adv = n.advance;
        if (adv == null) continue; // 终点节点
        switch (adv.type) {
          case 'next':
            if (i == nodes.length - 1) {
              fail('节点 "${n.id}" advance.type=next 但已是 nodes 数组末位，无后继');
            }
          case 'onCompleted':
            final to = adv.to;
            if (to == null || to.isEmpty) {
              fail('节点 "${n.id}" advance.type=onCompleted 缺少 to');
            }
            if (!byId.containsKey(to)) {
              fail('节点 "${n.id}" advance.to 指向不存在的节点: "$to"');
            }
          case 'routes':
            final routes = adv.routes;
            if (routes == null || routes.isEmpty) {
              fail('节点 "${n.id}" advance.type=routes 但 routes 为空');
            }
            for (var j = 0; j < routes.length; j++) {
              final r = routes[j];
              if (!byId.containsKey(r.to)) {
                fail('节点 "${n.id}" routes[$j].to 指向不存在的节点: "${r.to}"');
              }
              if (r.when == null && j != routes.length - 1) {
                fail('节点 "${n.id}" routes[$j].when == null——兜底路由仅允许末项（D7）');
              }
            }
            if (routes.last.when != null) {
              fail('节点 "${n.id}" routes 缺兜底路由（末项 when 必须为 null）');
            }
          default:
            fail('节点 "${n.id}" advance.type 非法: "${adv.type}"（允许 next/onCompleted/routes）');
        }
      }

      // ---- 规则 8：条件树叶子 nodeId 引用存在性（D6） ----
      void checkLeafRefs(SuccessCondition cond, String where) {
        for (final leaf in cond.collectLeaves()) {
          switch (leaf.type) {
            case 'nodeCompleted':
            case 'predictionScore':
              final nodeId = leaf.params['nodeId'];
              if (nodeId is! String || !byId.containsKey(nodeId)) {
                fail('$where 叶子 "${leaf.type}" 的 params.nodeId 悬空: $nodeId');
              }
            case 'scenarioSuccess':
              final nodeId = leaf.params['nodeId'];
              // scenarioSuccess 的 nodeId 可选（缺省 = 当前节点），提供时必须存在
              if (nodeId != null &&
                  (nodeId is! String || !byId.containsKey(nodeId))) {
                fail('$where 叶子 "scenarioSuccess" 的 params.nodeId 悬空: $nodeId');
              }
            default:
              break; // 未知叶子 type 不在解析期拒绝（运行时 fail-safe 求值 false）
          }
        }
      }

      for (final n in nodes) {
        if (n.unlock != null) checkLeafRefs(n.unlock!, '节点 "${n.id}" unlock');
        final routes = n.advance?.routes;
        if (routes != null) {
          for (var j = 0; j < routes.length; j++) {
            final w = routes[j].when;
            if (w != null) checkLeafRefs(w, '节点 "${n.id}" routes[$j]');
          }
        }
      }

      // ---- 规则 9：图可达性（BFS 自 entry） ----
      final reachable = <String>{entry};
      final queue = <String>[entry];
      while (queue.isNotEmpty) {
        final cur = queue.removeLast();
        final node = byId[cur]!;
        for (final nextId in _successors(node, byId, nodes)) {
          if (reachable.add(nextId)) queue.add(nextId);
        }
      }
      for (final n in nodes) {
        if (!reachable.contains(n.id)) {
          fail('节点 "${n.id}" 从 entry "$entry" 出发不可达');
        }
      }

      return LessonPlan(
        lessonId: lessonId,
        name: name,
        version: version,
        description: description,
        entry: entry,
        nodes: List.unmodifiable(nodes),
      );
    } on FormatException catch (e) {
      // 已带 lessonId 前缀的直接重抛；SuccessCondition 嵌套的异常补前缀
      final msg = e.message;
      if (msg.startsWith('$lessonId:')) rethrow;
      throw FormatException('$lessonId: $msg');
    } catch (e) {
      // TypeError（叶子缺 id/description 的 `as String` 断言）等统一包装
      throw FormatException('$lessonId: 解析失败（${e.runtimeType}）: $e');
    }
  }

  final String lessonId;
  final String name;
  final String version;
  final String description;
  final String entry;
  final List<LessonNode> nodes;

  /// id → 节点（O(n) 线性，节点数 ≤10 量级）。
  LessonNode? find(String nodeId) {
    for (final n in nodes) {
      if (n.id == nodeId) return n;
    }
    return null;
  }

  /// 'next' 流转：nodes 数组中该节点的下一个。
  LessonNode? nextInOrder(String nodeId) {
    for (var i = 0; i < nodes.length - 1; i++) {
      if (nodes[i].id == nodeId) return nodes[i + 1];
    }
    return null;
  }

  /// scenario != null 的节点（progress 分母）。
  List<LessonNode> get requiredNodes =>
      [for (final n in nodes) if (n.scenario != null) n];

  int get totalRequiredNodes => requiredNodes.length;

  LessonNode get entryNode => find(entry)!;

  // ---- 内部：单节点解析（规则 1 后半 / 4 / 5 / 7） ----

  static LessonNode _parseNode(
    Map<String, dynamic> raw,
    Never Function(String) fail,
    bool Function(String sim, String scenarioId) scenarioPlayable,
  ) {
    final id = raw['id'];
    final title = raw['title'];
    if (id is! String || id.isEmpty) fail('节点缺少 id 或类型非法');
    if (title is! String || title.isEmpty) {
      fail('节点 "$id" 缺少 title 或类型非法');
    }

    // scenario（规则 5）
    LessonScenarioRef? scenario;
    final rawScenario = raw['scenario'];
    if (rawScenario != null) {
      if (rawScenario is! Map<String, dynamic>) {
        fail('节点 "$id" scenario 必须是对象或 null');
      }
      final sim = rawScenario['sim'];
      final scenarioId = rawScenario['scenarioId'];
      if (sim is! String || sim.isEmpty) {
        fail('节点 "$id" scenario.sim 缺失或类型非法');
      }
      if (scenarioId is! String || scenarioId.isEmpty) {
        fail('节点 "$id" scenario.scenarioId 缺失或类型非法');
      }
      if (!scenarioPlayable(sim, scenarioId)) {
        fail('节点 "$id" 引用场景不可用于剧本: $sim/$scenarioId'
            '（不存在 / 未注册 sim / 无可完成判定）');
      }
      scenario = LessonScenarioRef(sim: sim, scenarioId: scenarioId);
    }

    // unlock（规则 7：SuccessCondition.fromJson 自带深度/组合校验）
    SuccessCondition? unlock;
    final rawUnlock = raw['unlock'];
    if (rawUnlock != null) {
      if (rawUnlock is! Map<String, dynamic>) {
        fail('节点 "$id" unlock 必须是条件对象或 null');
      }
      unlock = SuccessCondition.fromJson(rawUnlock);
    }

    // advance（结构提取；规则 6 的引用存在性在 fromJson 主体校验）
    LessonAdvance? advance;
    final rawAdvance = raw['advance'];
    if (rawAdvance != null) {
      if (rawAdvance is! Map<String, dynamic>) {
        fail('节点 "$id" advance 必须是对象或 null');
      }
      final type = rawAdvance['type'];
      if (type is! String) {
        fail('节点 "$id" advance.type 缺失或类型非法');
      }
      List<LessonRoute>? routes;
      final rawRoutes = rawAdvance['routes'];
      if (rawRoutes != null) {
        if (rawRoutes is! List) {
          fail('节点 "$id" advance.routes 必须是数组');
        }
        routes = [
          for (var j = 0; j < rawRoutes.length; j++)
            _parseRoute(rawRoutes[j], fail, id, j),
        ];
      }
      final to = rawAdvance['to'];
      if (to != null && to is! String) {
        fail('节点 "$id" advance.to 类型非法');
      }
      advance = LessonAdvance(type: type, to: to as String?, routes: routes);
    }

    // 规则 4：终点二元绑定（D5）
    if (scenario == null && advance != null) {
      fail('节点 "$id" scenario == null（终点）但 advance 非 null——'
          '终点节点不允许有流转指令');
    }
    if (scenario != null && advance == null) {
      fail('节点 "$id" scenario 非 null 但 advance == null——'
          '非终点节点必须有流转指令（二元绑定，D5）');
    }
    if (scenario == null && unlock != null) {
      fail('节点 "$id" 是终点节点，unlock 必须为 null');
    }

    return LessonNode(
      id: id,
      title: title,
      scenario: scenario,
      unlock: unlock,
      advance: advance,
    );
  }

  static LessonRoute _parseRoute(
    dynamic raw,
    Never Function(String) fail,
    String nodeId,
    int index,
  ) {
    if (raw is! Map<String, dynamic>) {
      fail('节点 "$nodeId" routes[$index] 必须是对象');
    }
    final to = raw['to'];
    if (to is! String || to.isEmpty) {
      fail('节点 "$nodeId" routes[$index] 缺少 to 或类型非法');
    }
    SuccessCondition? when;
    final rawWhen = raw['when'];
    if (rawWhen != null) {
      if (rawWhen is! Map<String, dynamic>) {
        fail('节点 "$nodeId" routes[$index].when 必须是条件对象或 null');
      }
      when = SuccessCondition.fromJson(rawWhen);
    }
    return LessonRoute(to: to, when: when);
  }

  /// BFS 后继集合：next → 数组后继；onCompleted → to；routes → 全部 to；终点 → 无。
  static Iterable<String> _successors(
    LessonNode node,
    Map<String, LessonNode> byId,
    List<LessonNode> nodes,
  ) sync* {
    final adv = node.advance;
    if (adv == null) return; // 终点
    switch (adv.type) {
      case 'next':
        for (var i = 0; i < nodes.length - 1; i++) {
          if (nodes[i].id == node.id) {
            yield nodes[i + 1].id;
            return;
          }
        }
      case 'onCompleted':
        if (adv.to != null) yield adv.to!;
      case 'routes':
        for (final r in adv.routes ?? const <LessonRoute>[]) {
          yield r.to;
        }
      default:
        break;
    }
  }
}
