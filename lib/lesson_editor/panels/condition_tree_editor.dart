import 'package:flutter/material.dart';

import '../../common/controls/kratos_combo_box.dart';
import '../../common/controls/kratos_number_field.dart';
import '../../common/scenario/success_condition.dart';

/// 条件树编辑器（T12 · F7 · AC-8）。
///
/// 递归渲染 [SuccessCondition]：
/// - 叶子：类型下拉（nodeCompleted / predictionScore / scenarioSuccess）
///   + 参数表单（nodeId 下拉 / metric+operator+threshold）
/// - 组合：all（全部满足）/ any（任一满足）/ not（取反）+ 子条件列表
/// - 深度上限 [SuccessCondition.maxParseDepth]（4 层）
///
/// [nodeIds] 为画布节点（叶子 nodeId 下拉候选）；[onChanged] 回写树根
/// （null = 删除整棵条件树）。
///
/// [nodeSims]（节点 id → 所属 sim）+ [ownerSim]（本条件树所属节点的 sim）：
/// 用于叶子 nodeId 跨 sim 引用时渲染 ⚠ 提示（M2 · 代码评审 dataFlow 类冲突
/// 在条件树内的可视化补充；不传则不做跨 sim 判断，保持向后兼容）。
class ConditionTreeEditor extends StatelessWidget {
  const ConditionTreeEditor({
    super.key,
    required this.value,
    required this.nodeIds,
    required this.onChanged,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final SuccessCondition? value;
  final List<String> nodeIds;
  final ValueChanged<SuccessCondition?> onChanged;
  final Map<String, String> nodeSims;
  final String? ownerSim;

  static const _leafTypes = [
    'nodeCompleted',
    'predictionScore',
    'scenarioSuccess',
  ];
  static const _leafLabels = ['节点完成', '预测分', '场景成功'];
  static const _operators = ['>=', '>', '<=', '<'];
  static const _metrics = ['ratio', 'count'];

  @override
  Widget build(BuildContext context) {
    final cond = value;
    if (cond == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('添加条件',
              style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _AddButton(
                label: '+ 条件',
                onPressed: () => onChanged(
                  const LeafCondition(
                    id: 'c0',
                    type: 'nodeCompleted',
                    description: '',
                    params: {},
                  ),
                ),
              ),
              _AddButton(
                label: '+ 全部满足',
                onPressed: () => onChanged(const AllCondition(children: [])),
              ),
              _AddButton(
                label: '+ 任一满足',
                onPressed: () => onChanged(const AnyCondition(children: [])),
              ),
              _AddButton(
                label: '+ 取反',
                onPressed: () => onChanged(
                  const NotCondition(
                    child: LeafCondition(
                      id: 'c0',
                      type: 'nodeCompleted',
                      description: '',
                      params: {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return _ConditionNode(
      cond: cond,
      nodeIds: nodeIds,
      depth: 1,
      onChanged: onChanged,
      onRemove: () => onChanged(null),
      nodeSims: nodeSims,
      ownerSim: ownerSim,
    );
  }
}

/// 单个条件节点编辑器（递归）。
class _ConditionNode extends StatelessWidget {
  const _ConditionNode({
    required this.cond,
    required this.nodeIds,
    required this.depth,
    required this.onChanged,
    required this.onRemove,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final SuccessCondition cond;
  final List<String> nodeIds;
  final int depth;
  final ValueChanged<SuccessCondition?> onChanged;
  final VoidCallback onRemove;
  final Map<String, String> nodeSims;
  final String? ownerSim;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeBadge(cond),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close,
                    size: 14, color: Color(0xFF94A3B8)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 4),
          switch (cond) {
            LeafCondition(:final type, :final description, :final params) =>
              _LeafEditor(
                type: type,
                description: description,
                params: params,
                nodeIds: nodeIds,
                onChanged: (leaf) => onChanged(leaf),
                nodeSims: nodeSims,
                ownerSim: ownerSim,
              ),
            AllCondition(:final children) => _ComboEditor(
                label: '全部满足',
                children: children,
                nodeIds: nodeIds,
                depth: depth,
                onChanged: (list) =>
                    onChanged(list == null ? null : AllCondition(children: list)),
                nodeSims: nodeSims,
                ownerSim: ownerSim,
              ),
            AnyCondition(:final children) => _ComboEditor(
                label: '任一满足',
                children: children,
                nodeIds: nodeIds,
                depth: depth,
                onChanged: (list) =>
                    onChanged(list == null ? null : AnyCondition(children: list)),
                nodeSims: nodeSims,
                ownerSim: ownerSim,
              ),
            NotCondition(:final child) => _NotEditor(
                child: child,
                nodeIds: nodeIds,
                depth: depth,
                onChanged: (c) => onChanged(c == null ? null : NotCondition(child: c)),
                nodeSims: nodeSims,
                ownerSim: ownerSim,
              ),
          },
        ],
      ),
    );
  }
}

/// 节点类型徽标。
class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.cond);

  final SuccessCondition cond;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (cond) {
      LeafCondition(:final type) => (
          _leafLabel(type),
          const Color(0xFF1177AA),
        ),
      AllCondition() => ('全部满足', const Color(0xFF0F766E)),
      AnyCondition() => ('任一满足', const Color(0xFFB45309)),
      NotCondition() => ('取反', const Color(0xFF7C3AED)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  static String _leafLabel(String type) {
    final i = ConditionTreeEditor._leafTypes.indexOf(type);
    return i >= 0 ? ConditionTreeEditor._leafLabels[i] : type;
  }
}

/// 叶子编辑器：类型下拉 + 参数表单。
class _LeafEditor extends StatelessWidget {
  const _LeafEditor({
    required this.type,
    required this.description,
    required this.params,
    required this.nodeIds,
    required this.onChanged,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final String type;
  final String description;
  final Map<String, dynamic> params;
  final List<String> nodeIds;
  final ValueChanged<LeafCondition> onChanged;
  final Map<String, String> nodeSims;
  final String? ownerSim;

  LeafCondition _with({String? type, String? description, Map<String, dynamic>? params}) {
    return LeafCondition(
      id: 'c0',
      type: type ?? this.type,
      description: description ?? this.description,
      params: params ?? this.params,
    );
  }

  /// M2（代码评审）：nodeId 引用的节点是否属于另一个 sim（两者 sim 均非空
  /// 且不同）——跨 sim 引用意味着条件依赖另一个模拟的运行结果，属于
  /// dataFlow 类冲突（`ConflictChecker` 已在保存前拦截，这里补画面内提示）。
  bool _isCrossSim(String? nodeId) {
    if (nodeId == null || nodeId.isEmpty) return false;
    final ownerS = ownerSim;
    if (ownerS == null || ownerS.isEmpty) return false;
    final targetSim = nodeSims[nodeId];
    if (targetSim == null || targetSim.isEmpty) return false;
    return targetSim != ownerS;
  }

  @override
  Widget build(BuildContext context) {
    final refNodeId = params['nodeId'] as String?;
    final crossSim = (type == 'nodeCompleted' ||
            type == 'scenarioSuccess' ||
            type == 'predictionScore') &&
        _isCrossSim(refNodeId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KratosComboBox<String>(
          label: '条件类型',
          items: ConditionTreeEditor._leafTypes,
          itemLabels: ConditionTreeEditor._leafLabels,
          value: type,
          width: double.infinity,
          onChanged: (v) => onChanged(_with(type: v)),
        ),
        const SizedBox(height: 6),
        switch (type) {
          'nodeCompleted' => _nodeField('已完成的节点', 'nodeId', value: params['nodeId'] as String?),
          'scenarioSuccess' => _nodeField('成功判定的节点（可选）', 'nodeId',
              value: params['nodeId'] as String?, optional: true),
          'predictionScore' => _predictionScoreFields(),
          _ => const SizedBox.shrink(),
        },
        if (crossSim)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              key: const ValueKey('condition-cross-sim-warning'),
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFB45309)),
                SizedBox(width: 4),
                Text('跨 sim 引用（数据传递冲突，见保存前提示）',
                    style: TextStyle(fontSize: 10, color: Color(0xFFB45309))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _nodeField(String label, String key, {String? value, bool optional = false}) {
    return KratosComboBox<String>(
      label: label,
      items: optional ? <String>['', ...nodeIds] : nodeIds,
      itemLabels: optional ? const ['（当前节点）'] : null,
      value: value ?? (optional ? '' : (nodeIds.isNotEmpty ? nodeIds.first : '')),
      width: double.infinity,
      onChanged: (v) => onChanged(_with(params: {...params, key: v.isEmpty ? null : v})),
    );
  }

  Widget _predictionScoreFields() {
    final nodeId = params['nodeId'] as String?;
    final metric = params['metric'] as String? ?? 'ratio';
    final operator = params['operator'] as String? ?? '>=';
    final threshold = params['threshold'] as num? ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KratosComboBox<String>(
          label: '预测节点',
          items: nodeIds,
          value: nodeId ?? (nodeIds.isNotEmpty ? nodeIds.first : ''),
          width: double.infinity,
          onChanged: (v) => onChanged(_with(params: {...params, 'nodeId': v})),
        ),
        const SizedBox(height: 6),
        KratosComboBox<String>(
          label: '指标',
          items: ConditionTreeEditor._metrics,
          value: metric,
          width: double.infinity,
          onChanged: (v) => onChanged(_with(params: {...params, 'metric': v})),
        ),
        const SizedBox(height: 6),
        KratosComboBox<String>(
          label: '比较符',
          items: ConditionTreeEditor._operators,
          value: operator,
          width: double.infinity,
          onChanged: (v) => onChanged(_with(params: {...params, 'operator': v})),
        ),
        const SizedBox(height: 6),
        KratosNumberField(
          label: '阈值',
          value: threshold.toDouble(),
          format: '0.0',
          min: 0,
          onChanged: (v) => onChanged(_with(params: {...params, 'threshold': v})),
        ),
      ],
    );
  }
}

/// 组合（all/any）编辑器：子条件列表 + 添加。
class _ComboEditor extends StatelessWidget {
  const _ComboEditor({
    required this.label,
    required this.children,
    required this.nodeIds,
    required this.depth,
    required this.onChanged,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final String label;
  final List<SuccessCondition> children;
  final List<String> nodeIds;
  final int depth;
  final ValueChanged<List<SuccessCondition>?> onChanged;
  final Map<String, String> nodeSims;
  final String? ownerSim;

  @override
  Widget build(BuildContext context) {
    final canAdd = depth < SuccessCondition.maxParseDepth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (children.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('（空 · 至少添加一个子条件）',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ),
        for (var i = 0; i < children.length; i++)
          _ConditionNode(
            cond: children[i],
            nodeIds: nodeIds,
            depth: depth + 1,
            onChanged: (c) => onChanged(c == null
                ? ([...children]..removeAt(i))
                : ([for (var j = 0; j < children.length; j++) j == i ? c : children[j]])),
            onRemove: () => onChanged([...children]..removeAt(i)),
            nodeSims: nodeSims,
            ownerSim: ownerSim,
          ),
        if (canAdd) ...[
          const SizedBox(height: 2),
          TextButton.icon(
            onPressed: () => onChanged([
              ...children,
              const LeafCondition(id: 'c0', type: 'nodeCompleted', description: '', params: {}),
            ]),
            icon: const Icon(Icons.add, size: 14),
            label: const Text('添加子条件', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: const Size(0, 26),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('已达最大嵌套深度（4）',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ),
      ],
    );
  }
}

/// not 编辑器：子条件 + 替换。
class _NotEditor extends StatelessWidget {
  const _NotEditor({
    required this.child,
    required this.nodeIds,
    required this.depth,
    required this.onChanged,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final SuccessCondition child;
  final List<String> nodeIds;
  final int depth;
  final ValueChanged<SuccessCondition?> onChanged;
  final Map<String, String> nodeSims;
  final String? ownerSim;

  @override
  Widget build(BuildContext context) {
    if (depth >= SuccessCondition.maxParseDepth) {
      return const Text('已达最大嵌套深度（4）',
          style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)));
    }
    return _ConditionNode(
      cond: child,
      nodeIds: nodeIds,
      depth: depth + 1,
      onChanged: onChanged,
      onRemove: () => onChanged(null),
      nodeSims: nodeSims,
      ownerSim: ownerSim,
    );
  }
}

/// 小号添加按钮。
class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 28),
        textStyle: const TextStyle(fontSize: 11),
        side: const BorderSide(color: Color(0xFF94A3B8)),
      ),
      child: Text(label),
    );
  }
}
