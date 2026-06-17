import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/circuit_state.dart';
import '../models/circuit_solver.dart';
import '../models/circuit_history.dart';
import '../services/sound_effects.dart';
import '../widgets/circuit_canvas.dart';
import '../widgets/component_tray.dart';
import '../widgets/circuit_controls.dart';

class CircuitScreen extends StatefulWidget {
  const CircuitScreen({super.key});
  @override State<CircuitScreen> createState() => _CircuitScreenState();
}

class _CircuitScreenState extends State<CircuitScreen> {
  CircuitState _state = const CircuitState();
  SolvedCircuit _solved = SolvedCircuit.empty;
  final CircuitHistory _history = CircuitHistory();
  SoundEffects? _sfx;
  int _nextId = 0;
  final FocusNode _focusNode = FocusNode();

  // [Bug1Fix] 工具箱拖拽进行中标志 — 防止 GestureDetector.onScaleEnd 错误创建导线
  // 根因：DragTarget.onAccept 和 GestureDetector.onScaleEnd 竞争，后者先执行会用残留状态创建多余导线
  // 方案：_onComponentDrop 入口设置此标志，_onDragEnd 入口检查并跳过
  bool _isToolboxDropActive = false;

  // [Fix3] 开关双击检测：记录上次点击时间和元件ID
  DateTime? _lastTapTime;
  String? _lastTapId;
  Timer? _tapTimer; // 单击延迟定时器（双击时取消）

  String _vid() => 'v${_nextId++}';
  String _cid() => 'c${_nextId++}';
  String _wid() => 'w${_nextId++}';

  @override void initState() { super.initState(); _sfx = SoundEffects(); }
  @override void dispose() { _tapTimer?.cancel(); _sfx?.dispose(); _focusNode.dispose(); super.dispose(); }

  void _update(CircuitState next, {bool sound=false}) {
    _history.push(_state);
    setState(() { _state = next; _solved = CircuitSolver.solve(next); });
    if (sound) _sfx?.tap();
  }

  // ─── 从工具箱拖出元件放置 ────────────────────────
  void _onComponentDrop(ComponentType type, Offset worldPos) {
    // [Bug1Fix] 设置工具箱拖拽标志，阻止 _onDragEnd 用残留状态创建多余导线
    _isToolboxDropActive = true;

    try {
    if (type == ComponentType.wire) {
      // 创建导线：两个顶点 + WireSegment
      final vid1 = _vid(); final vid2 = _vid();
      final verts = [
        Vertex(id: vid1, x: worldPos.dx - 50, y: worldPos.dy),
        Vertex(id: vid2, x: worldPos.dx + 50, y: worldPos.dy),
      ];
      final wire = WireSegment(
        id: _wid(),
        startVertexId: vid1,
        endVertexId: vid2,
      );
      // [T-1] 同时添加新导线 + 清理所有画布拖拽中间状态（防止手势冲突）
      _update(_state.copyWith(
        wires: [..._state.wires, wire],
        vertices: [..._state.vertices, ...verts],
        creatingWireStartVertexId: null,
        wireDragIdx: null,
        dragSide: null,
        draggingVertexId: null,
        dragVertexNewPos: null,
        draggingControlPointWireId: null,
        draggingControlPointIndex: null,
        dragPos: null,
      ), sound: true);
    } else {
      // 创建元件：两个端点顶点 + CircuitComponent
      final vid1 = _vid(); final vid2 = _vid();
      final verts = [
        Vertex(id: vid1, x: worldPos.dx - 60, y: worldPos.dy, isTerminal: true),
        Vertex(id: vid2, x: worldPos.dx + 60, y: worldPos.dy, isTerminal: true),
      ];
      final comp = CircuitComponent(
        id: _cid(), type: type, x: worldPos.dx, y: worldPos.dy,
        value: type.defaultValue, startVertexId: vid1, endVertexId: vid2,
      );
      // [T-1] 同时添加新元件 + 清理所有画布拖拽中间状态
      _update(_state.copyWith(
        components: [..._state.components, comp],
        vertices: [..._state.vertices, ...verts],
        creatingWireStartVertexId: null,
        wireDragIdx: null,
        dragSide: null,
        draggingVertexId: null,
        dragVertexNewPos: null,
        draggingControlPointWireId: null,
        draggingControlPointIndex: null,
        dragPos: null,
      ), sound: true);
    }
    } finally {
      // [Bug1Fix] 确保工具箱拖拽标志被清除（即使异常也清除）
      _isToolboxDropActive = false;
    }
  }

  // ─── 画布点击 ──────────────────────────────────────
  void _onCanvasTap(Offset worldPos) {
    // [Bug1Fix] 清除所有拖拽中间状态（防止点击空白区域后残留状态导致多余导线）
    _update(_state.copyWith(
      selectedId: null,
      creatingWireStartVertexId: null,
      wireDragIdx: null,
      dragSide: null,
      draggingVertexId: null,
      dragVertexNewPos: null,
      draggingControlPointWireId: null,
      draggingControlPointIndex: null,
      dragPos: null,
    ));
  }

  // ─── 元件交互 ─────────────────────────────────────────
  void _onComponentTap(String compId) {
    final now = DateTime.now();

    // [Fix3] 开关双击检测：300ms内连续点击同一个开关 = 双击
    if (_lastTapId == compId &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // 双击 → 如果是开关，切换状态（不改变选中状态）
      final comp = _state.components.where((c) => c.id == compId).toList();
      if (comp.isNotEmpty && comp.first.type == ComponentType.switch_) {
        _tapTimer?.cancel();
        _lastTapTime = null;
        _lastTapId = null;
        _toggleSwitch();
        return;
      }
    }

    // [Fix6b] 立即设置选中状态（不在Timer里，确保拖拽能立即生效）
    setState(() {
      if (_state.selectedId == compId) {
        _state = _state.copyWith(selectedId: null); // 再次点击同一元件 → 取消选中
      } else {
        _state = _state.copyWith(selectedId: compId); // 点击新元件 → 选中
      }
    });

    // 记录这次点击（用于双击检测）
    _lastTapTime = now;
    _lastTapId = compId;

    // 取消之前的定时器（如果有）
    _tapTimer?.cancel();
    _tapTimer = null;
  }

  void _onWireTap(int idx) {
    // 选择导线（而不是删除）
    if (idx < _state.wires.length) {
      final wire = _state.wires[idx];
      _update(_state.copyWith(selectedId: wire.id));
    }
  }

  // ─── 拖拽 ─────────────────────────────────────────────
  // [Fix7] 拖拽开始：检测拖拽目标（不立即移动）
  Offset? _dragStartMousePos; // 拖拽开始时的鼠标位置
  Offset? _dragStartCompPos;  // 拖拽开始时的元件位置

  void _onDragStart(Offset worldPos) {
    // 0. 清除残留状态（Bug1Fix）
    if (_state.creatingWireStartVertexId != null) {
      setState(() => _state = _state.copyWith(
        creatingWireStartVertexId: null,
        dragPos: null,
      ));
    }

    // [Fix7] 优先级调整：顶点 > 控制点 > 元件（避免焦点乱跳）
    // 原因：顶点是精确拖拽目标，元件是选择目标。如果顶点和元件重叠，顶点优先。

    // 1. [Fix2] 优先检查选中导线的端点（修复：选中a拖拽时不会命中b）
    // [Fix5] 保留 selectedId（拖拽端点后导线仍然被选中，符合用户预期）
    if (_state.selectedId != null) {
      final selectedWire = _state.wires.where((w) => w.id == _state.selectedId).toList();
      if (selectedWire.isNotEmpty) {
        final wire = selectedWire.first;
        final va = _state.findVertex(wire.startVertexId);
        final vb = _state.findVertex(wire.endVertexId);
        
        if (va != null && (va.pos - worldPos).distance < 30) {
          setState(() => _state = _state.copyWith(
            draggingVertexId: va.id,
            dragVertexNewPos: worldPos,
            // 不清除 selectedId — 端点拖拽后导线应保持选中
          ));
          return;
        }
        if (vb != null && (vb.pos - worldPos).distance < 30) {
          setState(() => _state = _state.copyWith(
            draggingVertexId: vb.id,
            dragVertexNewPos: worldPos,
            // 不清除 selectedId — 端点拖拽后导线应保持选中
          ));
          return;
        }
      }
    }

    // 2. 检查是否按在顶点上（统一逻辑：所有顶点都可拖拽）— 优先级高于元件
    final vertex = _state.vertexAt(worldPos);
    if (vertex != null) {
      // [Fix7] 顶点拖拽时，如果顶点属于某个元件的端子，不清除 selectedId
      // 这样可以在拖拽端子顶点的同时，保持元件选中状态
      final isTerminalVertex = _state.components.any((c) => c.startVertexId == vertex.id || c.endVertexId == vertex.id);
      
      // [Fix8] 重置拖拽偏移变量（防止后续元件拖拽时使用过期数据）
      if (!isTerminalVertex) {
        _dragStartMousePos = null;
        _dragStartCompPos = null;
      }
      
      setState(() => _state = _state.copyWith(
        selectedId: isTerminalVertex ? _state.selectedId : null, // 端子顶点不清除选中
        draggingVertexId: vertex.id,
        dragVertexNewPos: worldPos,
      ));
      return;
    }

    // 3. 检查是否按在控制点上（开始拖拽控制点）— 优先级高于元件
    if (_state.selectedId != null) {
      final selectedWire = _state.wires.where((w) => w.id == _state.selectedId).toList();
      if (selectedWire.isNotEmpty) {
        final wire = selectedWire.first;
        for (var i = 0; i < wire.controlPoints.length; i++) {
          final cp = wire.controlPoints[i];
          if ((cp - worldPos).distance < 15) {
            setState(() => _state = _state.copyWith(
              draggingControlPointWireId: wire.id,
              draggingControlPointIndex: i,
              dragPos: worldPos,
            ));
            return;
          }
        }
      }
    }

    // 4. 检查是否按在元件上（选择/取消选择）
    final hitComponent = _state.components.where((c) => c.hitTest(worldPos)).toList();
    if (hitComponent.isNotEmpty) {
      // [Fix6b] 立即选中该元件
      setState(() {
        if (_state.selectedId == hitComponent.first.id) {
          _state = _state.copyWith(selectedId: null); // 再次点击同一元件 → 取消选中
        } else {
          _state = _state.copyWith(selectedId: hitComponent.first.id); // 点击新元件 → 选中
        }
      });
      // [Fix7] 记录拖拽开始位置和元件位置（用于相对偏移计算）
      final comp = hitComponent.first;
      _dragStartMousePos = worldPos;
      _dragStartCompPos = Offset(comp.x, comp.y);
      return;
    }

    // 5. 如果点击空白区域且有选中元件，不立即移动（避免跳转到点击位置）
    //    等待 _onDragMove 处理（使用相对偏移）
    if (_state.selectedId != null) {
      final comp = _state.selected;
      if (comp != null) {
        _dragStartMousePos = worldPos;
        _dragStartCompPos = Offset(comp.x, comp.y);
      }
    }
  }

  void _onDragMove(Offset worldPos) {
    // 1. 如果正在拖拽控制点，更新控制点位置
    if (_state.draggingControlPointWireId != null) {
      setState(() => _state = _state.copyWith(dragPos: worldPos));
      return;
    }

    // 2. 如果正在拖动顶点，更新顶点位置
    if (_state.draggingVertexId != null) {
      setState(() => _state = _state.copyWith(dragVertexNewPos: worldPos));
      return;
    }

    // 3. [Fix7] 移动选中的元件（使用相对偏移，避免跳转到鼠标位置）
    if (_state.selectedId != null && _dragStartMousePos != null && _dragStartCompPos != null) {
      final dx = worldPos.dx - _dragStartMousePos!.dx;
      final dy = worldPos.dy - _dragStartMousePos!.dy;
      final newCompX = _dragStartCompPos!.dx + dx;
      final newCompY = _dragStartCompPos!.dy + dy;
      
      final comp = _state.selected;
      if (comp != null) {
        final newComps = _state.components.map((c) {
          if (c.id != comp.id) return c;
          return c.copyWith(x: newCompX, y: newCompY);
        }).toList();
        final newVerts = _state.vertices.map((v) {
          if (v.id == comp.startVertexId) return v.copyWith(x: v.x + dx, y: v.y + dy);
          if (v.id == comp.endVertexId) return v.copyWith(x: v.x + dx, y: v.y + dy);
          return v;
        }).toList();
        setState(() => _state = _state.copyWith(components: newComps, vertices: newVerts));
      }
    }
  }

  void _onDragEnd() {
    // [Bug1Fix] 守卫：如果工具箱拖拽刚完成，跳过处理
    if (_isToolboxDropActive) {
      _isToolboxDropActive = false;
      return;
    }

    // 0. 如果正在拖拽控制点
    if (_state.draggingControlPointWireId != null) {
      final wireId = _state.draggingControlPointWireId!;
      final index = _state.draggingControlPointIndex!;
      final newPos = _state.dragPos!;

      // 更新导线控制点
      final wire = _state.wires.firstWhere((w) => w.id == wireId);
      final updatedWire = wire.moveControlPoint(index, newPos);

      _update(_state.copyWith(
        wires: _state.wires.map((w) => w.id == wireId ? updatedWire : w).toList(),
        draggingControlPointWireId: null,
        draggingControlPointIndex: null,
        dragPos: null,
      ), sound: true);
      return;
    }

    // ✅ 修复：移除"创建导线"和"重新连接"分支

    // 1. 如果正在拖动顶点（添加磁吸合并逻辑）
    if (_state.draggingVertexId != null) {
      final vertexId = _state.draggingVertexId!;
      final newPos = _state.dragVertexNewPos ?? _state.findVertex(vertexId)!.pos;

      // 查找磁吸目标（40px内，排除自己）
      final snap = _state.findSnapTarget(newPos, excludeVertexId: vertexId);

      if (snap != null) {
        // ✅ 新增：合并顶点
        _mergeVertices(vertexId, snap.vertexId!);
      } else {
        // 移动顶点到新位置
        _update(_state.copyWith(
          vertices: _state.vertices.map((v) =>
            v.id == vertexId ? v.copyWith(x: newPos.dx, y: newPos.dy) : v
          ).toList(),
          draggingVertexId: null,
          dragVertexNewPos: null,
        ), sound: true);
      }
      
      // [Fix7] 清除拖拽偏移记录
      _dragStartMousePos = null;
      _dragStartCompPos = null;
      return;
    }

    // 2. [Fix7] 清除拖拽偏移记录（元件拖拽结束）
    _dragStartMousePos = null;
    _dragStartCompPos = null;
  }

  // ✅ 新增：合并两个顶点（磁吸合并）
  void _mergeVertices(String oldVertexId, String newVertexId) {
    // 把所有引用 oldVertexId 的导线/元件，改为引用 newVertexId
    final newWires = _state.wires.map((w) {
      if (w.startVertexId == oldVertexId) {
        return WireSegment(id: w.id, startVertexId: newVertexId, endVertexId: w.endVertexId);
      }
      if (w.endVertexId == oldVertexId) {
        return WireSegment(id: w.id, startVertexId: w.startVertexId, endVertexId: newVertexId);
      }
      return w;
    }).toList();

    final newComps = _state.components.map((c) {
      if (c.startVertexId == oldVertexId) {
        return c.copyWith(startVertexId: newVertexId);
      }
      if (c.endVertexId == oldVertexId) {
        return c.copyWith(endVertexId: newVertexId);
      }
      return c;
    }).toList();

    // 删除 oldVertexId
    final newVertices = _state.vertices.where((v) => v.id != oldVertexId).toList();

    _update(_state.copyWith(
      wires: newWires,
      components: newComps,
      vertices: newVertices,
      draggingVertexId: null,
      dragVertexNewPos: null,
    ), sound: true);
  }

  // ─── 其他操作 ─────────────────────────────────────────
  void _deleteSelected() {
    if (_state.selectedId == null) return;

    final selectedId = _state.selectedId!;

    // 1. 检查是否选中了导线
    final wireIndex = _state.wires.indexWhere((w) => w.id == selectedId);
    if (wireIndex != -1) {
      // 删除导线
      final newWires = List<WireSegment>.from(_state.wires)..removeAt(wireIndex);
      _update(_state.copyWith(wires: newWires, selectedId: null), sound: true);
      return;
    }

    // 2. 否则，删除元件
    _update(_state.removeComponent(selectedId));
  }

  void _toggleSwitch() {
    final sel = _state.selected; if (sel?.type != ComponentType.switch_) return;
    _update(_state.copyWith(components: _state.components.map((c) =>
      c.id == sel!.id ? c.copyWith(isClosed: !c.isClosed) : c).toList()), sound: true);
  }

  void _adjustValue(double v) {
    final sel = _state.selected; if (sel == null) return;
    final nv = v.clamp(sel.type.valueMin, sel.type.valueMax);
    _update(_state.copyWith(components: _state.components.map((c) =>
      c.id == sel.id ? c.copyWith(value: nv) : c).toList()));
  }

  void _setZoom(double z) { _update(_state.copyWith(zoom: z.clamp(0.6, 2.0))); }
  void _rotateSelected() {
    final sel = _state.selected; if (sel == null) return;
    _update(_state.copyWith(components: _state.components.map((c) =>
      c.id == sel.id ? c.copyWith(rotation: (c.rotation + 90) % 360) : c).toList()));
  }
  void _undo() { final prev = _history.undo(_state); if (prev != null) setState(() { _state = prev; _solved = CircuitSolver.solve(prev); }); }
  void _redo() { final next = _history.redo(_state); if (next != null) setState(() { _state = next; _solved = CircuitSolver.solve(next); }); }

  void _clear() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('清空电路'), content: const Text('确定清空所有元件和连线吗？'),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: (){Navigator.pop(ctx); _update(const CircuitState()); _history.clear(); _nextId=0;},
          child: const Text('确定',style:TextStyle(color:Colors.red))),
      ]));
  }

  @override
  Widget build(BuildContext context) {
    final sel = _state.selected;
    return KeyboardListener(focusNode:_focusNode, autofocus:true, onKeyEvent:(event){
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.delete) {
          _deleteSelected();
        } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
          _rotateSelected();
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          _update(_state.copyWith(selectedId:null));
        } else if (event.logicalKey == LogicalKeyboardKey.keyZ && HardwareKeyboard.instance.isControlPressed) {
          HardwareKeyboard.instance.isShiftPressed ? _redo() : _undo();
        } else if (event.logicalKey == LogicalKeyboardKey.keyY && HardwareKeyboard.instance.isControlPressed) {
          _redo();
        }
      }
    }, child: Scaffold(
      backgroundColor: const Color(0xFFF6FAFC),
      appBar: AppBar(title: const Text('电路搭建'), backgroundColor: const Color(0xFF0B2B3D), foregroundColor: Colors.white, actions: [
        if (sel != null) ...[
          if (sel.type == ComponentType.switch_)
            IconButton(icon: Icon(sel.isClosed?Icons.toggle_on:Icons.toggle_off,color:const Color(0xFF22C55E)), tooltip:'切换', onPressed:_toggleSwitch),
          IconButton(icon: const Icon(Icons.rotate_right,color:Color(0xFFCBD5E1)), tooltip:'旋转(R)', onPressed:_rotateSelected),
          IconButton(icon: const Icon(Icons.delete_outline,color:Color(0xFFEF4444)), tooltip:'删除(Del)', onPressed:_deleteSelected),
        ],
        IconButton(icon: const Icon(Icons.undo,size:20), tooltip:'撤销', onPressed:_history.canUndo?_undo:null),
        IconButton(icon: const Icon(Icons.redo,size:20), tooltip:'重做', onPressed:_history.canRedo?_redo:null),
        IconButton(icon: const Icon(Icons.zoom_out,size:20), tooltip:'缩小', onPressed:()=>_setZoom(_state.zoom-0.1)),
        Text('${(_state.zoom*100).toInt()}%', style: const TextStyle(fontSize:11)),
        IconButton(icon: const Icon(Icons.zoom_in,size:20), tooltip:'放大', onPressed:()=>_setZoom(_state.zoom+0.1)),
        IconButton(icon: const Icon(Icons.restart_alt_rounded), tooltip:'清空', onPressed:_clear),
      ]),
      body: Column(children: [
        Expanded(child: CircuitCanvas(state:_state, solved:_solved, zoom:_state.zoom,
          onTap: _onCanvasTap, onDragStart: _onDragStart, onDragUpdate: _onDragMove, onDragEnd: _onDragEnd,
          onComponentTap: _onComponentTap, onWireTap: _onWireTap,
          onScaleUpdate: (s)=>_setZoom(_state.zoom*s),
          onComponentDrop: _onComponentDrop,
        )),
        CircuitControls(state:_state, solved:_solved, onValueChanged:_adjustValue),
        const ComponentTray(),
      ]),
    ));
  }
}
