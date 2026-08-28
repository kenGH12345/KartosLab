import 'package:flutter/material.dart';

/// 画布节点卡片（T4 · 可拖/可选/角标 + T5 连线手柄）。
///
/// - 拖动手势：onPanUpdate 实时更新位置（由 Screen 更新 layout）
/// - 选中：onTap 回调，选中态蓝色描边
/// - 连线手柄：右下角小圆点，拖拽发起连线（T5 · onEdgeDragStart/Update/End）
/// - 终点节点：灰色 + 旗帜图标；普通节点：sim 主色 + 科学图标
/// - 冲突角标：左上角 ⚠（M2 代码评审 · dataFlow 类冲突涉及节点）
class LessonNodeCard extends StatelessWidget {
  const LessonNodeCard({
    super.key,
    required this.title,
    required this.isEnd,
    required this.isSelected,
    required this.onTap,
    required this.onDragDelta,
    required this.onEdgeDragStart,
    required this.onEdgeDragUpdate,
    required this.onEdgeDragEnd,
    this.isConflict = false,
  });

  final String title;
  final bool isEnd;
  final bool isSelected;

  /// M2（代码评审）· 本节点是否涉及 dataFlow 类冲突（条件树叶子跨 sim 引用），
  /// 涉及时在左上角渲染 ⚠ 角标（semantic 类冲突已由 `LessonEdgePainter`
  /// 的连线黄虚线覆盖，本角标专门补 dataFlow 类"不对应一条边"的缺口）。
  final bool isConflict;
  final VoidCallback onTap;
  final void Function(Offset delta) onDragDelta;

  /// 连线手柄拖拽（T5）：Start/Update/End 传给 Screen 做连线。
  final void Function() onEdgeDragStart;
  final void Function(Offset globalPos) onEdgeDragUpdate;
  final void Function(Offset globalPos) onEdgeDragEnd;

  static const double width = 160;

  @override
  Widget build(BuildContext context) {
    final color = isEnd ? const Color(0xFF64748B) : const Color(0xFF1177AA);
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (d) => onDragDelta(d.delta),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.35),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Icon(
                  isEnd ? Icons.flag_rounded : Icons.science_rounded,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            // 冲突角标：左上角 ⚠（M2 · dataFlow 类冲突涉及节点）
            if (isConflict)
              Positioned(
                left: -6,
                top: -6,
                child: Tooltip(
                  message: '此节点涉及跨 sim 数据传递冲突，详见保存前冲突提示',
                  child: Container(
                    key: const ValueKey('node-conflict-badge'),
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // 连线手柄：右下角小圆点（T5）
            Positioned(
              right: -4,
              bottom: -4,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => onEdgeDragStart(),
                onPanUpdate: (d) => onEdgeDragUpdate(d.globalPosition),
                onPanEnd: (d) => onEdgeDragEnd(d.globalPosition),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
