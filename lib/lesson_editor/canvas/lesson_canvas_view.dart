import 'package:flutter/material.dart';

import '../../common/geometry/projection.dart';
import '../../common/widgets/drag_drop_workspace.dart';
import '../models/editable_lesson_model.dart';
import '../panels/node_tray.dart';
import 'lesson_edge_painter.dart';
import 'lesson_node_card.dart';

/// 编排画布（T4 + T5 · center 格）。
///
/// 复用 [DropCanvas] 的"拖入落点"机制承载"从节点库拖入新节点"
/// （F2/AC-2）：projectionFactory 注入 `SceneProjection(origin: Offset.zero)`
/// 以 1:1 屏幕坐标承载节点布局（技术方案 §3.1）。
///
/// 节点用 Positioned 按 [layout] 定位（Stack 语义），拖动通过
/// [LessonNodeCard.onDragDelta] 增量更新。
/// 连线（T5）：节点卡片右下角手柄拖拽 → 临时边（[tempEdge]）→ 松开由
/// Screen 做目标命中判定并回写 advance。边渲染走 [LessonEdgePainter]。
class LessonCanvasView extends StatelessWidget {
  const LessonCanvasView({
    super.key,
    required this.nodes,
    required this.layout,
    required this.edges,
    required this.selectedNodeId,
    required this.onNodeDrop,
    required this.onNodeMoved,
    required this.onNodeSelected,
    required this.onEdgeDragStart,
    required this.onEdgeDragUpdate,
    required this.onEdgeDragEnd,
    this.conflictEdgeKeys = const {},
    this.conflictNodeIds = const {},
    this.tempEdge,
  });

  final List<EditableNode> nodes;

  /// 节点 id → 画布坐标（1:1 屏幕坐标）。
  final Map<String, Offset> layout;

  /// 画布连线（由 Screen 从 model.edges 传入）。
  final List<LessonEdge> edges;

  /// 冲突边集合（"fromId:toId" · T21）。
  final Set<String> conflictEdgeKeys;

  /// dataFlow 类冲突涉及节点 id 集合（M2 · 代码评审）：条件树叶子跨 sim
  /// 引用不对应画布上的一条边，无法用 [conflictEdgeKeys] 表达，改为节点角标。
  final Set<String> conflictNodeIds;

  /// 选中节点 id（null = 无选中）。
  final String? selectedNodeId;

  /// 拖拽中的临时边（源节点 id + 指针位置 · Screen 状态）。
  final TempLessonEdge? tempEdge;

  final void Function(LessonNodeType type, Offset pos) onNodeDrop;
  final void Function(String id, Offset delta) onNodeMoved;
  final void Function(String id) onNodeSelected;
  final void Function(String fromId) onEdgeDragStart;
  final void Function(Offset globalPos) onEdgeDragUpdate;
  final void Function(Offset globalPos) onEdgeDragEnd;

  @override
  Widget build(BuildContext context) {
    // 画布自身 context 用于 globalToLocal 转换：连线拖拽回调拿到的
    // globalPosition 需转成画布局部坐标（与 layout 坐标系一致）。
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = context.findRenderObject() as RenderBox?;
        Offset toLocal(Offset global) =>
            box == null ? global : box.globalToLocal(global);
        return Stack(
          children: [
            Positioned.fill(
              child: DropCanvas<LessonNodeType>(
                projectionFactory: (sz) =>
                    const SceneProjection(origin: Offset.zero),
                onItemDropped: (type, worldPos) => onNodeDrop(type, worldPos),
                canvasBuilder: (ctx, proj, sz) => CustomPaint(
                  size: Size(sz.width, sz.height),
                  painter: _GridPainter(),
                ),
              ),
            ),
            // 连线层（T5）：固定边 + 临时边（tempEdge.pointer 已由
            // onEdgeDragUpdate 转为画布局部坐标，直接透传）
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: LessonEdgePainter(
                    edges: edges,
                    layout: layout,
                    conflictEdgeKeys: conflictEdgeKeys,
                    tempEdge: tempEdge,
                  ),
                ),
              ),
            ),
            for (final node in nodes)
              Positioned(
                left: layout[node.id]?.dx ?? 40,
                top: layout[node.id]?.dy ?? 40,
                child: LessonNodeCard(
                  title: node.title.isEmpty ? '(未命名)' : node.title,
                  isEnd: node.isEnd,
                  isSelected: node.id == selectedNodeId,
                  isConflict: conflictNodeIds.contains(node.id),
                  onTap: () => onNodeSelected(node.id),
                  onDragDelta: (delta) => onNodeMoved(node.id, delta),
                  onEdgeDragStart: () => onEdgeDragStart(node.id),
                  onEdgeDragUpdate: (g) => onEdgeDragUpdate(toLocal(g)),
                  onEdgeDragEnd: (g) => onEdgeDragEnd(toLocal(g)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 画布背景：浅色网格（帮助定位节点）。
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const step = 40.0;
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
