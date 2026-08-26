import 'package:flutter/material.dart';

import '../scenario/lesson_plan.dart';
import '../scenario/lesson_runtime.dart';

/// 课时进度指示组件（纯展示 · 消费 LessonRuntime 只读状态）。
///
/// 布局：[当前节点标题 · N/M 计数] 一行 + [节点 chips 列表] 一行（横向滚动）。
/// chips 三态：已完成 ✓绿 / 当前 ▶蓝边 / 未完成淡灰（锁定 🔒 由
/// isUnlocked==false 触发）。
///
/// 点击语义（T-P2-03）：onNodeTap 非空 → 全部 chips 可点；锁定拦截由父层
/// LessonScreen 负责（jumpTo 返回 false → SnackBar '节点未解锁'）。
/// 实时更新：随外层 ListenableBuilder 重建（AC-20）。
/// L0-1/L0-2/L0-3 合规：Row/Wrap 弹性布局 · 无 Positioned · 无固定宽主图。
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({super.key, required this.runtime, this.onNodeTap});

  final LessonRuntime runtime;

  /// 点击回调（T-P2-03 起由 LessonScreen 传入 jumpTo 包装）。null = 不可点。
  final void Function(String nodeId)? onNodeTap;

  @override
  Widget build(BuildContext context) {
    final plan = runtime.plan;
    if (plan == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final current = runtime.currentNode;
    final total = plan.totalRequiredNodes;
    final done = runtime.completed
        .where((id) => plan.find(id)?.scenario != null)
        .length;

    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：当前节点标题 + N/M 计数
            Row(
              children: [
                Expanded(
                  child: Text(
                    current?.title ?? '',
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$done/$total',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 第二行：节点 chips（横向滚动防窄屏溢出）
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final node in plan.nodes) ...[
                    _NodeChip(
                      node: node,
                      state: _chipState(node),
                      onTap: onNodeTap == null
                          ? null
                          : () => onNodeTap!(node.id),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChipState _chipState(LessonNode node) {
    if (runtime.completed.contains(node.id)) return _ChipState.done;
    if (runtime.current == node.id) return _ChipState.current;
    if (!runtime.isUnlocked(node.id)) return _ChipState.locked;
    return _ChipState.todo;
  }
}

enum _ChipState { done, current, todo, locked }

class _NodeChip extends StatelessWidget {
  const _NodeChip({required this.node, required this.state, this.onTap});

  final LessonNode node;
  final _ChipState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (IconData icon, Color fg, Color bg, Border? border) = switch (state) {
      _ChipState.done => (
          Icons.check,
          Colors.white,
          const Color(0xFF22C55E),
          null,
        ),
      _ChipState.current => (
          Icons.play_arrow,
          const Color(0xFF2563EB),
          const Color(0xFFDBEAFE),
          Border.all(color: const Color(0xFF2563EB), width: 1.5),
        ),
      _ChipState.locked => (
          Icons.lock,
          const Color(0xFF94A3B8),
          const Color(0xFFF1F5F9),
          null,
        ),
      _ChipState.todo => (
          Icons.circle_outlined,
          const Color(0xFF64748B),
          const Color(0xFFF8FAFC),
          null,
        ),
    };

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              node.title,
              style: theme.textTheme.labelSmall?.copyWith(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: chip,
    );
  }
}
