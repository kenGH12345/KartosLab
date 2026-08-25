import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../geometry/projection.dart';

class DragItem<T extends Object> {
  final T data;
  final String label;
  final IconData icon;
  final Color color;
  final Widget Function()? customFeedback;

  const DragItem({required this.data, required this.label, required this.icon, required this.color, this.customFeedback});
}

enum DragDropLayout { sideTray, bottomTray }

/// 拖拽元件卡片（Draggable · 供托盘 / 任意容器复用）。
class DragItemCard<T extends Object> extends StatelessWidget {
  const DragItemCard({super.key, required this.item, required this.pad, required this.iconSize, required this.fontSize, this.minWidth = 0});

  final DragItem<T> item;
  final EdgeInsets pad;
  final double iconSize;
  final double fontSize;
  /// 卡片最小宽度（0=自然宽）· 用于确保 label 文字不被父约束压缩成"电"竖线
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    Widget card() => Card(margin: EdgeInsets.zero,
        color: item.color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: item.color.withValues(alpha: 0.3))),
        child: Padding(padding: pad,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(item.icon, color: item.color, size: iconSize),
              SizedBox(width: fontSize >= 14 ? 12 : 6),
              Text(item.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize)),
            ])));
    // 拖拽反馈：优先用 customFeedback（渲染画布上的最终形态预览），否则用 tray 卡片
    // 用 Material 包一层，避免 customFeedback 缺 Material 上下文时抛异常（如 Icon/Text）
    final feedback = item.customFeedback != null
        ? Material(color: Colors.transparent, child: item.customFeedback!())
        : card();
    // minWidth>0 时仅 wrap child（ListView 静态槽位）· feedback 拖拽时反复渲染需保持轻量
    final childWidget = minWidth > 0
        ? ConstrainedBox(constraints: BoxConstraints(minWidth: minWidth), child: card())
        : card();
    return Draggable<T>(data: item.data, feedback: feedback, childWhenDragging: Opacity(opacity: 0.4, child: childWidget), child: childWidget);
  }
}

/// 元件托盘（原 DragDropWorkspace._tray · 供 NineGridLayout 边格单独使用）。
class DragTray<T extends Object> extends StatelessWidget {
  const DragTray({super.key, required this.layout, required this.trayTitle, required this.items, this.traySize = 200, this.itemMinWidth = 0});

  final DragDropLayout layout;
  final String trayTitle;
  final List<DragItem<T>> items;
  final double traySize;
  /// 每个拖盘 item 最小宽度（0=自然宽）· 防止父约束压缩 label 为"电"竖线
  final double itemMinWidth;

  @override
  Widget build(BuildContext ctx) {
    final isSide = layout == DragDropLayout.sideTray;
    final pad = isSide ? const EdgeInsets.all(12) : const EdgeInsets.all(6);
    final isz = isSide ? 24.0 : 20.0;
    final fsz = isSide ? 14.0 : 11.0;

    final list = isSide
        ? ListView.builder(physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(8), itemCount: items.length,
            itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8),
                child: DragItemCard<T>(item: items[i], pad: pad, iconSize: isz, fontSize: fsz)))
        : ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 4), itemCount: items.length,
            itemBuilder: (_, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DragItemCard<T>(item: items[i], pad: pad, iconSize: isz, fontSize: fsz, minWidth: itemMinWidth)));

    if (isSide) {
      return SizedBox(width: traySize, child: Container(color: const Color(0xFFF0F4F8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(12), color: const Color(0xFF062A3A),
                child: Row(children: [const Icon(Icons.category_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8), Text(trayTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: const Color(0xFFFEF3C7),
                child: const Text('拖动到画布', style: TextStyle(fontSize: 11, color: Color(0xFF92400E)))),
            Expanded(child: list),
          ])));
    } else {
      // 高度自适应：不超过 traySize，也不超过父约束（矮视口 bottom 行 < traySize 时收缩，
      // 避免 SizedBox 固定高溢出）。
      return LayoutBuilder(
        builder: (_, c) {
          final h = c.maxHeight.isFinite
              ? math.min(traySize, c.maxHeight)
              : traySize;
          return SizedBox(
            height: h,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B2B3D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: list,
            ),
          );
        },
      );
    }
  }
}

/// 可拖放画布（原 DragDropWorkspace._DropCanvas · DragTarget 接收托盘元件）。
class DropCanvas<T extends Object> extends StatelessWidget {
  const DropCanvas({super.key, required this.canvasBuilder, required this.onItemDropped, this.scale = 1.0, this.projectionFactory});

  /// 画布内容构建器。第三参数 canvasSize 供 SizedBox/CustomPaint 定尺寸
  /// （替代原 CanvasProjection.canvasSize 的消费场景）。
  final Widget Function(BuildContext, SceneProjection, Size) canvasBuilder;

  /// 落点回调（world 坐标 · 与 canvasBuilder 收到的投影同实例产出）。
  final void Function(T, Offset) onItemDropped;

  /// 世界单位→屏幕像素换算（仅默认工厂使用；提供 projectionFactory 时被忽略）。
  final double scale;

  /// 画布投影工厂。null = 默认工厂（origin=(w/2, h*0.55)，即旧 CanvasProjection 语义，
  /// optics 光轴行为依赖此值）。sim 渲染/hitTest 与拖放落点共用同一投影实例时必传
  /// （如 circuit: origin=(w/2,h/2)+zoom），可整体删除坐标转换 workaround。
  final SceneProjection Function(Size canvasSize)? projectionFactory;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, c) {
    final sz = Size(c.maxWidth, c.maxHeight);
    final proj = projectionFactory?.call(sz) ??
        SceneProjection(origin: Offset(sz.width / 2, sz.height * 0.55), scale: scale);
    final content = canvasBuilder(context, proj, sz);
    return DragTarget<T>(onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (d) {
          final box = ctx.findRenderObject() as RenderBox;
          onItemDropped(d.data, proj.toWorld(box.globalToLocal(d.offset)));
        },
        builder: (_, cand, _) => Stack(children: [
          content,
          if (cand.isNotEmpty) Positioned.fill(child: Container(color: Colors.blue.withValues(alpha: 0.08),
              child: const Center(child: Text('释放以放置元件', style: TextStyle(color: Colors.blue, fontSize: 16))))),
        ]));
  });
}

/// 工作区（画布 + 托盘 + 可选面板的组合容器 · 9宫格适配下请拆分为 DragTray/DropCanvas 放入边格/中间格）。
class DragDropWorkspace<T extends Object> extends StatelessWidget {
  const DragDropWorkspace({
    super.key,
    required this.items,
    required this.canvasBuilder,
    required this.onItemDropped,
    this.layout = DragDropLayout.sideTray,
    this.trayTitle = '元件库',
    this.traySize = 200,
    this.scale = 1.0,
    this.rightPanel,
    this.bottomPanel,
  });

  final DragDropLayout layout;
  final String trayTitle;
  final List<DragItem<T>> items;
  final Widget Function(BuildContext, SceneProjection, Size) canvasBuilder;
  final void Function(T, Offset) onItemDropped;
  final double traySize;
  final double scale;
  final Widget? rightPanel;
  final Widget? bottomPanel;

  @override
  Widget build(BuildContext context) {
    final tray = DragTray<T>(layout: layout, trayTitle: trayTitle, items: items, traySize: traySize);
    final canvas = Expanded(child: DropCanvas<T>(canvasBuilder: canvasBuilder, onItemDropped: onItemDropped, scale: scale));
    return switch (layout) {
      DragDropLayout.sideTray => Row(children: [tray, canvas, ?rightPanel]),
      DragDropLayout.bottomTray => rightPanel == null
          ? Column(children: [canvas, ?bottomPanel, tray])
          : Row(children: [
              Expanded(child: Column(children: [canvas, ?bottomPanel, tray])),
              rightPanel!,
            ]),
    };
  }
}
