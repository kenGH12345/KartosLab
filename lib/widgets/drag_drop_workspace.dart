import 'package:flutter/material.dart';

class DragItem<T extends Object> {
  final T data;
  final String label;
  final IconData icon;
  final Color color;
  final Widget Function()? customFeedback;

  const DragItem({required this.data, required this.label, required this.icon, required this.color, this.customFeedback});
}

enum DragDropLayout { sideTray, bottomTray }

class CanvasProjection {
  final Size canvasSize; final double scale;
  CanvasProjection({required this.canvasSize, this.scale = 1.0});
  Offset get origin => Offset(canvasSize.width / 2, canvasSize.height * 0.55);
  Offset toScreen(Offset w) => Offset(origin.dx + w.dx * scale, origin.dy + w.dy * scale);
  Offset toWorld(Offset s) => Offset((s.dx - origin.dx) / scale, (s.dy - origin.dy) / scale);
}

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
  final Widget Function(BuildContext, CanvasProjection) canvasBuilder;
  final void Function(T, Offset) onItemDropped;
  final double traySize;
  final double scale;
  final Widget? rightPanel;
  final Widget? bottomPanel;

  @override
  Widget build(BuildContext context) {
    final tray = _tray(context);
    final canvas = Expanded(child: _DropCanvas<T>(canvasBuilder: canvasBuilder, onItemDropped: onItemDropped, scale: scale));
    return switch (layout) {
      DragDropLayout.sideTray => Row(children: [tray, canvas, if (rightPanel != null) rightPanel!]),
      DragDropLayout.bottomTray => rightPanel == null
          ? Column(children: [canvas, if (bottomPanel != null) bottomPanel!, tray])
          : Row(children: [
              Expanded(child: Column(children: [canvas, if (bottomPanel != null) bottomPanel!, tray])),
              rightPanel!,
            ]),
    };
  }

  Widget _tray(BuildContext ctx) {
    final isSide = layout == DragDropLayout.sideTray;
    final pad = isSide ? const EdgeInsets.all(12) : const EdgeInsets.all(6);
    final isz = isSide ? 24.0 : 20.0;
    final fsz = isSide ? 14.0 : 11.0;

    final list = isSide
        ? ListView.builder(physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(8), itemCount: items.length,
            itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8),
                child: _Card<T>(item: items[i], pad: pad, isz: isz, fsz: fsz)))
        : ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 4), itemCount: items.length,
            itemBuilder: (_, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _Card<T>(item: items[i], pad: pad, isz: isz, fsz: fsz)));

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
      return SizedBox(height: traySize,
          child: Container(decoration: const BoxDecoration(color: Color(0xFF0B2B3D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))), child: list));
    }
  }
}

class _Card<T extends Object> extends StatelessWidget {
  final DragItem<T> item; final EdgeInsets pad; final double isz; final double fsz;
  const _Card({required this.item, required this.pad, required this.isz, required this.fsz});

  @override
  Widget build(BuildContext context) {
    Widget card() => item.customFeedback?.call() ?? Card(margin: EdgeInsets.zero,
        color: item.color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: item.color.withValues(alpha: 0.3))),
        child: Padding(padding: pad,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(item.icon, color: item.color, size: isz),
              SizedBox(width: fsz >= 14 ? 12 : 6),
              Text(item.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: fsz)),
            ])));
    return Draggable<T>(data: item.data, feedback: card(), childWhenDragging: Opacity(opacity: 0.4, child: card()), child: card());
  }
}

class _DropCanvas<T extends Object> extends StatelessWidget {
  final Widget Function(BuildContext, CanvasProjection) canvasBuilder;
  final void Function(T, Offset) onItemDropped;
  final double scale;
  const _DropCanvas({required this.canvasBuilder, required this.onItemDropped, this.scale = 1.0});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, c) {
    final sz = Size(c.maxWidth, c.maxHeight);
    final proj = CanvasProjection(canvasSize: sz, scale: scale);
    final content = canvasBuilder(context, proj);
    return DragTarget<T>(onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (d) {
          final box = ctx.findRenderObject() as RenderBox;
          onItemDropped(d.data, proj.toWorld(box.globalToLocal(d.offset)));
        },
        builder: (_, cand, __) => Stack(children: [
          content,
          if (cand.isNotEmpty) Positioned.fill(child: Container(color: Colors.blue.withValues(alpha: 0.08),
              child: const Center(child: Text('释放以放置元件', style: TextStyle(color: Colors.blue, fontSize: 16))))),
        ]));
  });
}
