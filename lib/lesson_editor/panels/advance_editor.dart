import 'package:flutter/material.dart';

import '../../common/controls/kratos_combo_box.dart';
import '../../common/controls/kratos_radio_group.dart';
import '../../common/scenario/lesson_plan.dart';
import '../../common/scenario/success_condition.dart';
import 'condition_tree_editor.dart';

/// M3（代码评审）· 保持"末项 when 必须为 null"的不变量（D7 兜底路由规则）。
///
/// 删除路由后，原倒数第二项可能"晋升"为新末项，但其 [LessonRoute.when]
/// 字段可能残留旧条件——若不清空会导致保存校验失败（见
/// `lesson_validator.dart` 规则 6），且末项在 UI 上隐藏条件编辑器，
/// 用户无法自行修复。故每次结构变更（删除）后强制清空新末项的 when。
List<LessonRoute> _withFallbackInvariant(List<LessonRoute> routes) {
  if (routes.isEmpty) return routes;
  final lastIndex = routes.length - 1;
  if (routes[lastIndex].when == null) return routes;
  final fixed = [...routes];
  fixed[lastIndex] = LessonRoute(to: fixed[lastIndex].to, when: null);
  return fixed;
}

/// advance 三型编辑（T9 · F4/F6 · AC-6/AC-7）。
///
/// - RadioGroup 切换 next / onCompleted / routes
/// - next：提示"顺序流转到下一节点"（无参数）
/// - onCompleted：目标节点下拉（只列画布已有节点，不含自身）
/// - routes：路由列表编辑（每行 = 条件名 + 目标节点下拉 + 删除）；
///   末项自动标"兜底路由"（when=null 强制 · AC-7），非末项要求条件名
/// - 无 advance（终点节点）：显示"本节点为课时终点，无流转指令"
class AdvanceEditor extends StatelessWidget {
  const AdvanceEditor({
    super.key,
    required this.advance,
    required this.nodeIds,
    required this.selfId,
    required this.isEndNode,
    required this.onChanged,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final LessonAdvance? advance;

  /// 画布所有节点 id（目标下拉候选，含自身）。
  final List<String> nodeIds;

  /// 当前编辑节点 id（目标候选排除自身）。
  final String selfId;

  /// 是否为终点节点（终点不可有 advance · 二元绑定）。
  final bool isEndNode;

  /// 修改回调（null = 清空 advance，即转为终点节点）。
  final ValueChanged<LessonAdvance?> onChanged;

  /// M2（代码评审）· 节点 id → 所属 sim，供 routes.when 条件树跨 sim 引用判断。
  final Map<String, String> nodeSims;

  /// M2（代码评审）· 本节点（selfId）所属 sim。
  final String? ownerSim;

  @override
  Widget build(BuildContext context) {
    if (isEndNode) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          '本节点为课时终点，无流转指令',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      );
    }
    final type = advance?.type ?? 'next';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KratosRadioGroup<String>(
          label: '流转方式',
          items: const ['next', 'onCompleted', 'routes'],
          itemLabels: const ['顺序流转', '完成后跳转', '条件路由'],
          value: type,
          onChanged: (v) => onChanged(_advanceForType(v)),
        ),
        const SizedBox(height: 8),
        ..._fieldsFor(type),
      ],
    );
  }

  LessonAdvance? _advanceForType(String type) {
    switch (type) {
      case 'onCompleted':
        // 默认目标：候选里第一个（排除自身）
        final first = nodeIds.where((id) => id != selfId).firstOrNull;
        return LessonAdvance(type: 'onCompleted', to: first);
      case 'routes':
        return const LessonAdvance(type: 'routes', routes: []);
      default:
        return LessonAdvance(type: 'next');
    }
  }

  List<Widget> _fieldsFor(String type) {
    switch (type) {
      case 'onCompleted':
        final to = advance?.to;
        final candidates = nodeIds.where((id) => id != selfId).toList();
        return [
          KratosComboBox<String>(
            label: '完成本节点后跳转',
            items: candidates,
            value: to ?? '',
            width: double.infinity,
            onChanged: (v) => onChanged(LessonAdvance(type: 'onCompleted', to: v)),
          ),
        ];
      case 'routes':
        return [_buildRoutesEditor()];
      default:
        return const [
          Text(
            '按节点顺序流转到下一节点',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ];
    }
  }

  Widget _buildRoutesEditor() {
    final routes = advance?.routes ?? const <LessonRoute>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('路由（末项为兜底 · 无条件）',
            style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        for (var i = 0; i < routes.length; i++)
          _RouteRow(
            key: ObjectKey('$selfId:$i:${routes[i].to}'),
            route: routes[i],
            index: i,
            isLast: i == routes.length - 1,
            candidates: nodeIds.where((id) => id != selfId).toList(),
            nodeIds: nodeIds,
            nodeSims: nodeSims,
            ownerSim: ownerSim,
            onChanged: (updated) => onChanged(
              LessonAdvance(
                type: 'routes',
                routes: [
                  for (var j = 0; j < routes.length; j++)
                    j == i ? updated : routes[j],
                ],
              ),
            ),
            onRemove: () => onChanged(
              LessonAdvance(
                type: 'routes',
                routes: _withFallbackInvariant(
                  [...routes]..removeAt(i),
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () {
            // 新增路由默认指向第一个候选节点（避免 to='' 无匹配项）
            final first = nodeIds.where((id) => id != selfId).firstOrNull;
            onChanged(
              LessonAdvance(
                type: 'routes',
                routes: [...routes, LessonRoute(to: first ?? '')],
              ),
            );
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('添加路由', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            minimumSize: const Size(0, 28),
          ),
        ),
      ],
    );
  }
}

/// 单条路由编辑行（T12 · 条件改为 ConditionTreeEditor 层级化构建）。
class _RouteRow extends StatelessWidget {
  const _RouteRow({
    super.key,
    required this.route,
    required this.index,
    required this.isLast,
    required this.candidates,
    required this.nodeIds,
    required this.onChanged,
    required this.onRemove,
    this.nodeSims = const {},
    this.ownerSim,
  });

  final LessonRoute route;
  final int index;
  final bool isLast;

  /// 目标节点候选（排除自身）。
  final List<String> candidates;

  /// 画布全部节点（条件树叶子 nodeId 候选）。
  final List<String> nodeIds;

  final ValueChanged<LessonRoute> onChanged;
  final VoidCallback onRemove;
  final Map<String, String> nodeSims;
  final String? ownerSim;

  void _updateRoute({String? to, SuccessCondition? when}) {
    final route = this.route;
    onChanged(
      LessonRoute(to: to ?? route.to, when: when ?? route.when),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLast ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isLast ? '兜底路由' : '路由 ${index + 1}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLast
                          ? const Color(0xFF64748B)
                          : const Color(0xFF0F766E))),
              const Spacer(),
              IconButton(
                key: ValueKey('route-remove-$index'),
                onPressed: onRemove,
                icon: const Icon(Icons.close,
                    size: 14, color: Color(0xFF94A3B8)),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 4),
            const Text('条件',
                style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
            const SizedBox(height: 2),
            ConditionTreeEditor(
              value: route.when,
              nodeIds: nodeIds,
              onChanged: (c) => _updateRoute(when: c),
              nodeSims: nodeSims,
              ownerSim: ownerSim,
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('无条件 · 其余情况走此路由',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ),
          const SizedBox(height: 4),
          KratosComboBox<String>(
            label: '目标节点',
            items: candidates,
            value: route.to,
            width: double.infinity,
            onChanged: (v) => _updateRoute(to: v),
          ),
        ],
      ),
    );
  }
}
