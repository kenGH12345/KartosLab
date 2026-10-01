import 'package:flutter/material.dart';
import '../models/circuit_state.dart';
import 'component_icon.dart';

class SceneProjection {
  final double scale; final Offset origin; final double zoom;
  const SceneProjection({required this.scale, required this.origin, this.zoom = 1.0});
  Offset toScreen(Offset world) => Offset(world.dx*scale*zoom+origin.dx, world.dy*scale*zoom+origin.dy);
  Offset toWorld(Offset screen) => Offset((screen.dx-origin.dx)/(scale*zoom), (screen.dy-origin.dy)/(scale*zoom));
  double toScreenLength(double w) => w*scale*zoom;
}

class CircuitCanvas extends StatelessWidget {
  final CircuitState state; final SolvedCircuit solved; final double zoom;
  final void Function(Offset) onTap, onDragStart, onDragUpdate;
  final VoidCallback onDragEnd;
  final void Function(String) onComponentTap;
  final void Function(int) onWireTap;
  final void Function(double) onScaleUpdate;
  final void Function(ComponentType, Offset)? onComponentDrop; // 新增：接收从工具箱拖出的元件

  const CircuitCanvas({super.key, required this.state, required this.solved, required this.zoom,
    required this.onTap, required this.onDragStart, required this.onDragUpdate, required this.onDragEnd,
    required this.onComponentTap, required this.onWireTap, required this.onScaleUpdate,
    this.onComponentDrop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final proj = SceneProjection(scale:1, origin:Offset(c.maxWidth/2, c.maxHeight/2), zoom:zoom);

      // 1. 现有的 CustomPaint（底层）
      final canvas = GestureDetector(
        onTapUp: (d) {
          final w = proj.toWorld(d.localPosition);
          // 导线优先命中（8px 内）：解决"元件矩形吞点击"导致贴近元件的导线选不中的问题
          final closeWire = _hitTestWire(w, proj, threshold: 8);
          if (closeWire != null) { onWireTap(closeWire); return; }
          // 元件本体命中
          final hit = _hitTest(w);
          if (hit != null) { onComponentTap(hit.id); return; }
          // 兜底：15px 内的导线仍可命中（远离元件的导线段保持原体验）
          final farWire = _hitTestWire(w, proj, threshold: 15);
          if (farWire != null) { onWireTap(farWire); return; }
          onTap(w);
        },
        onScaleStart: (d) {
          if (d.pointerCount >= 2) return;
          onDragStart(proj.toWorld(d.localFocalPoint));
        },
        onScaleUpdate: (d) {
          if (d.pointerCount >= 2) {
            onScaleUpdate(d.horizontalScale);
          } else {
            onDragUpdate(proj.toWorld(d.localFocalPoint));
          }
        },
        onScaleEnd: (d) {
          if (d.pointerCount >= 2) return;
          onDragEnd();
        },
        child: CustomPaint(
          size: Size(c.maxWidth, c.maxHeight),
          painter: CircuitPainter(state:state, solved:solved, projection:proj),
        ),
      );

      // 2. 为每个元件添加 Positioned widget（图标样式覆盖层）
      final overlays = <Widget>[];
      for (final comp in state.components) {
        final screenPos = proj.toScreen(Offset(comp.x, comp.y));
        final screenWidth = proj.toScreenLength(comp.width);
        final screenHeight = proj.toScreenLength(comp.height);

        overlays.add(
          Positioned(
            key: Key('component_${comp.id}'),
            left: screenPos.dx - screenWidth/2,
            top: screenPos.dy - screenHeight/2,
            width: screenWidth,
            height: screenHeight,
            child: IgnorePointer(
              child: Center(
                child: ComponentIconWidget(
                  type: comp.type,
                  iconSize: (screenWidth * 0.45).clamp(16, 32),
                  fontSize: (screenHeight * 0.18).clamp(8, 14),
                  showLabel: screenHeight > 30,
                  fixedWidth: screenWidth * 0.8,
                  fixedHeight: screenHeight * 0.7,
                ),
              ),
            ),
          ),
        );
      }

      // 3. 包裹 DragTarget，支持接收从工具箱拖出的元件
      return DragTarget<ComponentType>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          final renderBox = ctx.findRenderObject() as RenderBox;
          final localOffset = renderBox.globalToLocal(details.offset);
          final worldPos = proj.toWorld(localOffset);
          onComponentDrop?.call(details.data, worldPos);
        },
        onMove: (details) {},
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Stack(
            children: [
              canvas,
              ...overlays,
              if (isHovering)
                Positioned.fill(
                  child: Container(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: const Center(
                      child: Text('释放以放置元件', style: TextStyle(color: Colors.blue, fontSize: 16)),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }

  CircuitComponent? _hitTest(Offset w) {
    for (final c in state.components.reversed) { if (c.hitTest(w)) return c; }
    return null;
  }

  int? _hitTestWire(Offset wp, SceneProjection proj, {double threshold = 15}) {
    final sp = proj.toScreen(wp); // 点击位置（屏幕坐标）

    for (var i = 0; i < state.wires.length; i++) {
      final seg = state.wires[i];
      final startVertex = state.findVertex(seg.startVertexId);
      final endVertex = state.findVertex(seg.endVertexId);
      if (startVertex == null || endVertex == null) continue;

      // 获取所有点（屏幕坐标）
      final allPoints = <Offset>[proj.toScreen(startVertex.pos)];
      for (final cp in seg.controlPoints) {
        allPoints.add(proj.toScreen(cp));
      }
      allPoints.add(proj.toScreen(endVertex.pos));

      // 计算点击位置到导线的最小距离
      var minDist = double.infinity;

      for (var j = 0; j < allPoints.length - 1; j++) {
        final a = allPoints[j];
        final b = allPoints[j + 1];
        final dist = _pointToSegmentDistance(sp, a, b);
        if (dist < minDist) minDist = dist;
      }

      if (minDist < threshold) return i;
    }
    return null;
  }

  /// 计算点到线段的距离（辅助方法）
  double _pointToSegmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;

    final abLenSq = ab.distanceSquared;
    if (abLenSq == 0) return ap.distance; // a 和 b 重合

    final t = (ap.dx * ab.dx + ap.dy * ab.dy) / abLenSq;
    final tClamped = t.clamp(0.0, 1.0);

    final projection = a + ab * tClamped;
    return (p - projection).distance;
  }
}

class CircuitPainter extends CustomPainter {
  final CircuitState state; final SolvedCircuit solved; final SceneProjection projection;
  CircuitPainter({required this.state, required this.solved, required this.projection});

  @override void paint(Canvas canvas, Size size) { _grid(canvas,size); _wires(canvas); _components(canvas); }
  @override bool shouldRepaint(covariant CircuitPainter old) {
    // [Fix6a] 改用引用比较（.length 无法检测位置变化）
    return state.selectedId != old.state.selectedId ||
          state.wires != old.state.wires ||
          state.vertices != old.state.vertices ||
          state.components != old.state.components ||
          state.dragPos != old.state.dragPos ||
          state.draggingVertexId != old.state.draggingVertexId ||
          state.dragVertexNewPos != old.state.dragVertexNewPos;
  }

  void _grid(Canvas canvas, Size size) {
    final p = Paint()..color=const Color(0xFFE8ECF0)..strokeWidth=0.5..style=PaintingStyle.stroke;
    final g = 40*projection.scale*projection.zoom;
    for (double x=0;x<size.width;x+=g) { canvas.drawLine(Offset(x,0),Offset(x,size.height),p); }
    for (double y=0;y<size.height;y+=g) { canvas.drawLine(Offset(0,y),Offset(size.width,y),p); }
  }

  void _wires(Canvas canvas) {
    // 1. 绘制所有导线（支持控制点）
    for (final seg in state.wires) {
      final isSelected = state.selectedId == seg.id;
      final isDraggingControlPoint = state.draggingControlPointWireId == seg.id;

      // 构建路径（屏幕坐标）
      final path = Path();
      final startVertex = state.findVertex(seg.startVertexId);
      final endVertex = state.findVertex(seg.endVertexId);
      if (startVertex == null || endVertex == null) continue;

      // 如果顶点正在被拖动，使用 dragVertexNewPos
      final startPos = state.draggingVertexId == startVertex.id && state.dragVertexNewPos != null
          ? state.dragVertexNewPos!
          : startVertex.pos;
      final endPos = state.draggingVertexId == endVertex.id && state.dragVertexNewPos != null
          ? state.dragVertexNewPos!
          : endVertex.pos;

      var currentPoint = projection.toScreen(startPos);
      path.moveTo(currentPoint.dx, currentPoint.dy);

      // 添加控制点（如果正在拖拽控制点，使用 dragPos 替换）
      for (var i = 0; i < seg.controlPoints.length; i++) {
        final cp = isDraggingControlPoint && state.draggingControlPointIndex == i
            ? state.dragPos!
            : seg.controlPoints[i];
        currentPoint = projection.toScreen(cp);
        path.lineTo(currentPoint.dx, currentPoint.dy);
      }

      // 添加到终点
      currentPoint = projection.toScreen(endPos);
      path.lineTo(currentPoint.dx, currentPoint.dy);

      // 绘制导线主体
      final paint = Paint()
        ..color = isSelected ? const Color(0xFF3B82F6) : const Color(0xFF334155)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, paint);

      // 绘制端点
      _drawVertex(canvas, startVertex);
      _drawVertex(canvas, endVertex);

      // 如果选中，绘制控制点
      if (isSelected) {
        _drawControlPoints(canvas, seg);
      }

      // 如果正在拖拽控制点，绘制控制点预览
      if (isDraggingControlPoint) {
        final cp = state.dragPos!;
        final screenPos = projection.toScreen(cp);
        canvas.drawCircle(screenPos, 8, Paint()..color = const Color(0xFF3B82F6));
        canvas.drawCircle(screenPos, 6, Paint()..color = Colors.white);
      }
    }

    // 4. 绘制顶点拖动磁吸指示器（T-8）
    if (state.draggingVertexId != null && state.dragVertexNewPos != null) {
      final snap = state.findSnapTarget(state.dragVertexNewPos!, excludeVertexId: state.draggingVertexId);
      if (snap != null) {
        final snapPos = projection.toScreen(snap.position);
        final draggedV = state.findVertex(state.draggingVertexId!);
        final isTerminalDrag = draggedV != null && draggedV.isTerminal;
        if (isTerminalDrag) {
          // 拖动的是元件端子：拒绝 merge，显示红色禁止图标提示"不能连"
          final red = const Color(0xFFEF4444);
          canvas.drawCircle(snapPos, 14, Paint()
            ..color = red.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
          // 禁止斜杠 "⊘"
          final r = 10.0;
          final dx = r * 0.7071, dy = r * 0.7071;
          canvas.drawLine(
            Offset(snapPos.dx - dx, snapPos.dy - dy),
            Offset(snapPos.dx + dx, snapPos.dy + dy),
            Paint()..color = red..strokeWidth = 2.5..strokeCap = StrokeCap.round,
          );
        } else {
          // 普通顶点拖动：可磁吸合并，显示绿色高亮
          canvas.drawCircle(snapPos, 12, Paint()
            ..color = const Color(0xFF22C55E).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
        }
      }
    }
  }

  /// 绘制顶点（ junction 或普通顶点）
  void _drawVertex(Canvas canvas, Vertex v) {
    final isDragging = state.draggingVertexId == v.id;
    final pos = projection.toScreen(isDragging ? (state.dragVertexNewPos ?? v.pos) : v.pos);
    final radius = isDragging ? 10.0 : (v.isJunction ? 5.0 : 3.0);
    final color = isDragging ? Colors.blue : 
                   v.isJunction ? const Color(0xFF334155) : const Color(0xFF94A3B8);
    
    canvas.drawCircle(pos, radius, Paint()..color = color);
    if (v.isJunction && !isDragging) {
      canvas.drawCircle(pos, 3.5, Paint()..color = const Color(0xFF94A3B8));
    }
  }

  /// 绘制导线控制点（选中时显示）
  void _drawControlPoints(Canvas canvas, WireSegment seg) {
    for (var i = 0; i < seg.controlPoints.length; i++) {
      final cp = seg.controlPoints[i];
      final screenPos = projection.toScreen(cp);

      // 绘制控制点（蓝色圆圈）
      canvas.drawCircle(screenPos, 6, Paint()..color = const Color(0xFF3B82F6));
      canvas.drawCircle(screenPos, 4, Paint()..color = Colors.white);
    }
  }

  void _components(Canvas canvas) {
    for (final comp in state.components) {
      _draw(canvas, comp, comp.id==state.selectedId, solved.isPowered(comp.id));
    }
  }

  void _draw(Canvas canvas, CircuitComponent c, bool sel, bool pw) {
    final pos = projection.toScreen(Offset(c.x,c.y));
    final w = projection.toScreenLength(c.width);
    final h = projection.toScreenLength(c.height);
    final r = Rect.fromCenter(center:pos, width:w, height:h);
    // 元件本体由 ComponentIconWidget overlay 渲染（图标风格）
    // 此处只画端点和选中高亮
    _term(canvas, Offset(r.left,pos.dy));
    _term(canvas, Offset(r.right,pos.dy));
    if (sel) {
      canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(6),const Radius.circular(8)),
        Paint()..color=const Color(0xFF1177AA)..style=PaintingStyle.stroke..strokeWidth=2);
    }
  }

  void _term(Canvas c, Offset o) {
    c.drawCircle(o,5,Paint()..color=const Color(0xFF334155));
    c.drawCircle(o,3.5,Paint()..color=const Color(0xFF94A3B8));
    c.drawCircle(o,2,Paint()..color=Colors.white);
  }
}
