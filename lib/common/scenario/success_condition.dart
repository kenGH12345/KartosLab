import 'package:flutter/foundation.dart';

/// 可组合成功条件树（L0 · 全 sim 通用）。
///
/// 由 8 个 sim 的平铺 CriterionConfig 上抽（3-Time Rule：第 8 个使用者触发强制上抽）。
/// 树结构与组合语义通用；叶子 `type` 的枚举语义由各 sim 注入的求值器解释。
///
/// ## JSON 契约（向后兼容——存量场景的平铺格式零改动可加载）
///
/// 叶子（= 现有平铺格式）：
/// ```json
/// {"id": "c1", "type": "concentrationReached", "description": "…", "params": {…}}
/// ```
///
/// 组合算子（三选一，可嵌套，深度 ≤ [maxParseDepth]）：
/// ```json
/// {"id": "g1", "all": [子条件, …]}   // 全部满足
/// {"id": "g1", "any": [子条件, …]}   // 任一满足
/// {"id": "g1", "not": 子条件}        // 取反
/// ```
///
/// 组合节点的 `id`/`description` 可选（供 UI 定位与提示）。
///
/// ## 容错语义
///
/// 非法输入（type 与组合键并存 / 组合键互斥并存 / 两者皆缺 / not 值非对象 /
/// all/any 空数组 / 超深度）一律抛 [FormatException]——由
/// `ScenarioManagerBase.loadScenarios` 的单场景降级捕获跳过，不会 crash。
@immutable
sealed class SuccessCondition {
  const SuccessCondition();

  /// 解析嵌套深度上限，防 AI 生成过深嵌套。
  static const int maxParseDepth = 4;

  /// 解析一个条件节点 JSON。
  factory SuccessCondition.fromJson(Map<String, dynamic> json) =>
      _parse(json, 1);

  static SuccessCondition _parse(Map<String, dynamic> json, int depth) {
    if (depth > maxParseDepth) {
      throw FormatException(
          'SuccessCondition 嵌套深度超过 $maxParseDepth 层（AI 生成场景应保持 ≤ 4 层）');
    }
    final hasType = json.containsKey('type');
    final comboKeys = ['all', 'any', 'not']
        .where((k) => json.containsKey(k))
        .toList();
    if (hasType && comboKeys.isNotEmpty) {
      throw FormatException(
          'SuccessCondition 不能同时含 type 与组合键 $comboKeys（叶子与组合互斥）');
    }
    if (comboKeys.length > 1) {
      throw FormatException('SuccessCondition 组合键互斥，却同时出现 $comboKeys');
    }
    if (hasType) return LeafCondition.fromJson(json);
    if (comboKeys.isEmpty) {
      throw FormatException('SuccessCondition 缺少 type 或组合键 all/any/not');
    }

    final key = comboKeys.single;
    if (key == 'not') {
      final child = json['not'];
      if (child is! Map<String, dynamic>) {
        throw FormatException('not 的值必须是条件对象，实际为 ${child.runtimeType}');
      }
      return NotCondition(
        id: json['id'] as String?,
        description: json['description'] as String?,
        child: _parse(child, depth + 1),
      );
    }

    final rawList = json[key];
    if (rawList is! List<dynamic>) {
      throw FormatException('$key 的值必须是数组，实际为 ${rawList.runtimeType}');
    }
    if (rawList.isEmpty) {
      throw FormatException('$key 的值必须是非空数组（空数组语义无意义）');
    }
    final children = <SuccessCondition>[];
    for (final e in rawList) {
      if (e is! Map<String, dynamic>) {
        throw FormatException('$key 数组元素必须是条件对象，实际为 ${e.runtimeType}');
      }
      children.add(_parse(e, depth + 1));
    }
    return key == 'all'
        ? AllCondition(
            id: json['id'] as String?,
            description: json['description'] as String?,
            children: children,
          )
        : AnyCondition(
            id: json['id'] as String?,
            description: json['description'] as String?,
            children: children,
          );
  }

  /// 递归求值。叶子判定由 [leafEvaluator] 注入（各 sim 用自己的
  /// Criterion 求值逻辑闭包），组合语义（且/或/非）在本层通用实现。
  ///
  /// `all` 遇 false 短路、`any` 遇 true 短路。
  bool evaluate(
      bool Function(String type, Map<String, dynamic> params) leafEvaluator);

  /// 按树序收集全部叶子（UI 逐条展示判定进度 / description 用）。
  List<LeafCondition> collectLeaves();

  Map<String, dynamic> toJson();

  /// 顶层 `successCriteria` 数组的判定语义：全部满足（与改造前
  /// `successCriteria.every((c) => c.check(state))` 行为一致；空列表 = true）。
  static bool allSatisfied(
    List<SuccessCondition> conditions,
    bool Function(String type, Map<String, dynamic> params) leafEvaluator,
  ) =>
      conditions.every((c) => c.evaluate(leafEvaluator));
}

/// 叶子条件——平铺格式的原样承载，`type` 语义由各 sim 求值器解释。
@immutable
final class LeafCondition extends SuccessCondition {
  const LeafCondition({
    required this.id,
    required this.type,
    required this.description,
    this.params = const {},
  });

  final String id;
  final String type;
  final String description;
  final Map<String, dynamic> params;

  factory LeafCondition.fromJson(Map<String, dynamic> json) {
    return LeafCondition(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      params: (json['params'] as Map<String, dynamic>?) ?? const {},
    );
  }

  @override
  bool evaluate(
      bool Function(String type, Map<String, dynamic> params)
          leafEvaluator) {
    return leafEvaluator(type, params);
  }

  @override
  List<LeafCondition> collectLeaves() => [this];

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'params': params,
      };
}

/// `all` 组合——全部子条件满足。
@immutable
final class AllCondition extends SuccessCondition {
  const AllCondition({this.id, this.description, required this.children});

  final String? id;
  final String? description;
  final List<SuccessCondition> children;

  @override
  bool evaluate(
      bool Function(String type, Map<String, dynamic> params)
          leafEvaluator) {
    return children.every((c) => c.evaluate(leafEvaluator));
  }

  @override
  List<LeafCondition> collectLeaves() => [
        for (final c in children) ...c.collectLeaves(),
      ];

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (description != null) 'description': description,
        'all': children.map((e) => e.toJson()).toList(),
      };
}

/// `any` 组合——任一子条件满足。
@immutable
final class AnyCondition extends SuccessCondition {
  const AnyCondition({this.id, this.description, required this.children});

  final String? id;
  final String? description;
  final List<SuccessCondition> children;

  @override
  bool evaluate(
      bool Function(String type, Map<String, dynamic> params)
          leafEvaluator) {
    return children.any((c) => c.evaluate(leafEvaluator));
  }

  @override
  List<LeafCondition> collectLeaves() => [
        for (final c in children) ...c.collectLeaves(),
      ];

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (description != null) 'description': description,
        'any': children.map((e) => e.toJson()).toList(),
      };
}

/// `not` 组合——子条件取反。
@immutable
final class NotCondition extends SuccessCondition {
  const NotCondition({this.id, this.description, required this.child});

  final String? id;
  final String? description;
  final SuccessCondition child;

  @override
  bool evaluate(
      bool Function(String type, Map<String, dynamic> params)
          leafEvaluator) {
    return !child.evaluate(leafEvaluator);
  }

  @override
  List<LeafCondition> collectLeaves() => child.collectLeaves();

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (description != null) 'description': description,
        'not': child.toJson(),
      };
}
