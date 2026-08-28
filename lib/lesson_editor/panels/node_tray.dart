import 'package:flutter/material.dart';

import '../../common/widgets/drag_drop_workspace.dart';

/// 托盘可拖节点类型。
enum LessonNodeType { scene, end }

/// 节点库托盘（T3 · midLeft 格）。
///
/// 复用 [DragTray]/[DragItem]/[DragItemCard]（L0 · 禁平行实现）。
/// scene = 普通场景节点；end = 终点节点。
class NodeTray extends StatelessWidget {
  const NodeTray({super.key});

  static List<DragItem<LessonNodeType>> get items => const [
        DragItem(
          data: LessonNodeType.scene,
          label: '场景节点',
          icon: Icons.science_rounded,
          color: Color(0xFF1177AA),
        ),
        DragItem(
          data: LessonNodeType.end,
          label: '终点节点',
          icon: Icons.flag_rounded,
          color: Color(0xFF64748B),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return DragTray<LessonNodeType>(
      layout: DragDropLayout.sideTray,
      trayTitle: '节点库',
      items: items,
      traySize: 180,
    );
  }
}
