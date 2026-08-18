import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/scenario_manager.dart';
import '../models/circuit_state.dart';
import '../models/circuit_solver.dart';
import '../models/circuit_history.dart';
import '../services/sound_effects.dart';
import '../widgets/component_icon.dart';
import '../widgets/circuit_controls.dart';
import '../../common/widgets/drag_drop_workspace.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../../common/widgets/inquiry_models.dart';
import '../../common/widgets/inquiry_drawer.dart';
import '../../common/widgets/experiment_logger.dart';
import '../../common/widgets/experiment_intro_panel.dart';
import '../../common/controls/kratos_combo_box.dart';

/// AC-4 feature flag · true = 从 JSON scenario 加载初始状态 · false = 保留原空拓扑硬编码
///
/// 加载失败时静默降级为 `const CircuitState()`（不阻塞电路屏渲染）。
/// 详见 `req-kratos-circuit-config-json` Loop 3。
const bool useScenarioLoader = true;

/// AC-4 默认场景 id · 空拓扑 · 复刻 `const CircuitState()` 事实。
const String _defaultScenarioId = 'default';

class CircuitScreen extends StatefulWidget {
  const CircuitScreen({super.key});
  @override
  State<CircuitScreen> createState() => _CircuitScreenState();
}

class _CircuitScreenState extends State<CircuitScreen> {
  CircuitState _state = const CircuitState();
  SolvedCircuit _solved = SolvedCircuit.empty;
  final CircuitHistory _history = CircuitHistory();
  SoundEffects? _sfx;
  int _nextId = 0;
  CircuitScenarioManager? _scenarioManager;
  String _currentScenarioId = _defaultScenarioId;
  final FocusNode _focusNode = FocusNode();

  bool _isToolboxDropActive = false;
  DateTime? _lastTapTime;
  String? _lastTapId;
  Timer? _tapTimer;
  Offset? _doubleTapWorld;
  bool _objectiveMetNotified = false;
  bool _inquiryOpen = true; // 预测阶段默认展开：进入即见预测题（置顶），可手动收起
  Size? _canvasSize; // DropCanvas 画布尺寸（拖放投影转换用）

  String _vid() => 'v${_nextId++}';
  String _cid() => 'c${_nextId++}';
  String _wid() => 'w${_nextId++}';

  @override
  void initState() {
    super.initState();
    _sfx = SoundEffects();
    if (useScenarioLoader) {
      _loadDefaultScenario();
    }
  }

  /// AC-4 · 从 `assets/scenarios/circuit/default.json` 异步加载初始状态。
  ///
  /// 失败时静默降级：`_state` 保持构造时的 `const CircuitState()`。
  Future<void> _loadDefaultScenario() async {
    try {
      final manager = CircuitScenarioManager();
      await manager.loadScenarios();
      if (!mounted) return;
      _scenarioManager = manager;
      final next = manager.loadScenario(_defaultScenarioId);
      setState(() {
        _state = next;
        _solved = CircuitSolver.solve(next);
        _nextId = _computeNextId(next);
        _currentScenarioId = _defaultScenarioId;
      });
    } catch (e) {
      debugPrint('Failed to load default circuit scenario: $e');
    }
  }

  void _switchScenario(String scenarioId) {
    final mgr = _scenarioManager;
    if (mgr == null) return;
    try {
      final next = mgr.loadScenario(scenarioId);
      _history.clear();
      setState(() {
        _state = next;
        _solved = CircuitSolver.solve(next);
        _nextId = _computeNextId(next);
        _currentScenarioId = scenarioId;
      });
      _objectiveMetNotified = false;
    } catch (e) {
      debugPrint('Failed to switch circuit scenario to $scenarioId: $e');
    }
  }

  /// 扫描 scenario 中所有 id 的数字后缀，返回 max+1；避免手工新建元件时与 scenario id 撞车。
  ///
  /// 支持任意前缀 + 数字尾格式（如 `v0` / `bat_1` / `wire_junction_2`）。
  /// 无数字后缀的 id 视为 -1；空场景返回 0。
  static int _computeNextId(CircuitState state) {
    final re = RegExp(r'(\d+)$');
    int mx = -1;
    for (final id in [
      ...state.components.map((c) => c.id),
      ...state.vertices.map((v) => v.id),
      ...state.wires.map((w) => w.id),
    ]) {
      final m = re.firstMatch(id);
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? -1;
        if (n > mx) mx = n;
      }
    }
    return mx + 1;
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _sfx?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _update(CircuitState next, {bool sound = false}) {
    _history.push(_state);
    setState(() {
      _state = next;
      _solved = CircuitSolver.solve(next);
    });
    if (sound) _sfx?.tap();
    _maybeNotifyObjectiveMet();
  }

  /// 探究目标达成检测（轻量 · 一次成功只提示一次）。
  void _maybeNotifyObjectiveMet() {
    final mgr = _scenarioManager;
    if (mgr == null || _inquiryTask == null || _objectiveMetNotified) return;
    final met = mgr.checkObjectives(_state);
    if (!met) return;
    _objectiveMetNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 探究目标已达成！去「我的发现」写下你的结论吧',
              style: TextStyle(fontSize: 13),
            ),
            duration: Duration(seconds: 3),
          ),
        );
    });
  }

  void _onComponentDrop(ComponentType type, Offset worldPos) {
    _isToolboxDropActive = true;
    try {
      // DropCanvas 放置坐标基于 CanvasProjection（origin=(W/2, H*0.55)）→
      // 转换到 SceneProjection（origin=(W/2, H/2)）坐标系，保证渲染与 hitTest 一致。
      // （否则拖放后元件渲染位置偏移、点击无法选中——既有 bug，测试暴露）
      final size = _canvasSize;
      if (size != null) {
        final canvasProj = CanvasProjection(canvasSize: size, scale: 1.0);
        final screenLocal = canvasProj.toScreen(worldPos);
        final sceneProj = SceneProjection(
          scale: 1,
          origin: Offset(size.width / 2, size.height / 2),
          // 用当前 zoom（Major-1 评审修复）：渲染/hitTest 用 _state.zoom，缩放后拖放坐标一致
          zoom: _state.zoom,
        );
        worldPos = sceneProj.toWorld(screenLocal);
      }
      _addComponent(type, worldPos);
    } finally {
      _isToolboxDropActive = false;
    }
  }

  void _addComponent(ComponentType type, Offset wp) {
    if (type == ComponentType.wire) {
      final v1 = _vid(), v2 = _vid();
      _update(
        _state.copyWith(
          wires: [
            ..._state.wires,
            WireSegment(id: _wid(), startVertexId: v1, endVertexId: v2),
          ],
          vertices: [
            ..._state.vertices,
            Vertex(id: v1, x: wp.dx - 50, y: wp.dy),
            Vertex(id: v2, x: wp.dx + 50, y: wp.dy),
          ],
          creatingWireStartVertexId: null,
          wireDragIdx: null,
          dragSide: null,
          draggingVertexId: null,
          dragVertexNewPos: null,
          draggingControlPointWireId: null,
          draggingControlPointIndex: null,
          dragPos: null,
        ),
        sound: true,
      );
    } else {
      final v1 = _vid(), v2 = _vid();
      _update(
        _state.copyWith(
          components: [
            ..._state.components,
            CircuitComponent(
              id: _cid(),
              type: type,
              x: wp.dx,
              y: wp.dy,
              value: type.defaultValue,
              startVertexId: v1,
              endVertexId: v2,
            ),
          ],
          vertices: [
            ..._state.vertices,
            Vertex(id: v1, x: wp.dx - 60, y: wp.dy, isTerminal: true),
            Vertex(id: v2, x: wp.dx + 60, y: wp.dy, isTerminal: true),
          ],
          creatingWireStartVertexId: null,
          wireDragIdx: null,
          dragSide: null,
          draggingVertexId: null,
          dragVertexNewPos: null,
          draggingControlPointWireId: null,
          draggingControlPointIndex: null,
          dragPos: null,
        ),
        sound: true,
      );
    }
  }

  void _onCanvasTap(Offset w) => _update(_state.copyWith(selectedId: null));

  void _onComponentTap(String id) {
    final now = DateTime.now();
    if (_lastTapId == id &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      final comp = _state.components.where((c) => c.id == id).toList();
      if (comp.isNotEmpty && comp.first.type == ComponentType.switch_) {
        _tapTimer?.cancel();
        _lastTapTime = null;
        _lastTapId = null;
        _toggleSwitch();
        return;
      }
    }
    setState(
      () => _state = _state.copyWith(
        selectedId: _state.selectedId == id ? null : id,
      ),
    );
    _lastTapTime = now;
    _lastTapId = id;
    _tapTimer?.cancel();
  }

  void _onWireTap(int idx) {
    if (idx < _state.wires.length)
      _update(_state.copyWith(selectedId: _state.wires[idx].id));
  }

  Offset? _dragStartMousePos, _dragStartCompPos;

  void _onDragStart(Offset w) {
    if (_state.creatingWireStartVertexId != null)
      setState(
        () => _state = _state.copyWith(
          creatingWireStartVertexId: null,
          dragPos: null,
        ),
      );
    final sel = _state.selected;
    if (sel != null && !_state.wires.any((wr) => wr.id == _state.selectedId)) {
      if (_state.draggingVertexId != null)
        setState(
          () => _state = _state.copyWith(
            draggingVertexId: null,
            dragVertexNewPos: null,
          ),
        );
      _dragStartMousePos = w;
      _dragStartCompPos = Offset(sel.x, sel.y);
      return;
    }
    // 选中的是导线：优先命中导线端点（15px），进入顶点拖动模式（用于断连/挪端点）
    final selWire = _state.selectedId != null
        ? _state.wires.where((wr) => wr.id == _state.selectedId).toList()
        : const <WireSegment>[];
    if (selWire.isNotEmpty) {
      final wr = selWire.first;
      for (final vid in [wr.startVertexId, wr.endVertexId]) {
        final v = _state.findVertex(vid);
        if (v != null && (v.pos - w).distance < 15) {
          setState(
            () => _state = _state.copyWith(
              draggingVertexId: v.id,
              dragVertexNewPos: w,
            ),
          );
          return;
        }
      }
    }
    final hit = _state.components.where((c) => c.hitTest(w)).toList();
    if (hit.isNotEmpty) {
      setState(
        () => _state = _state.copyWith(
          selectedId: _state.selectedId == hit.first.id ? null : hit.first.id,
        ),
      );
      _dragStartMousePos = w;
      _dragStartCompPos = Offset(hit.first.x, hit.first.y);
      return;
    }
    final v = _state.vertexAt(w);
    if (v != null) {
      setState(
        () => _state = _state.copyWith(
          draggingVertexId: v.id,
          dragVertexNewPos: w,
        ),
      );
      return;
    }
    if (_state.selectedId != null && _state.selected != null) {
      _dragStartMousePos = w;
      _dragStartCompPos = Offset(_state.selected!.x, _state.selected!.y);
    }
  }

  void _onDragMove(Offset w) {
    if (_state.draggingControlPointWireId != null) {
      setState(() => _state = _state.copyWith(dragPos: w));
      return;
    }
    if (_state.draggingVertexId != null) {
      setState(() => _state = _state.copyWith(dragVertexNewPos: w));
      return;
    }
    if (_state.selectedId != null &&
        _dragStartMousePos != null &&
        _dragStartCompPos != null) {
      final nc = _state.selected;
      if (nc != null) {
        final nx = _dragStartCompPos!.dx + w.dx - _dragStartMousePos!.dx;
        final ny = _dragStartCompPos!.dy + w.dy - _dragStartMousePos!.dy;
        final incX = nx - nc.x, incY = ny - nc.y;
        setState(
          () => _state = _state.copyWith(
            components: _state.components
                .map((c) => c.id == nc.id ? c.copyWith(x: nx, y: ny) : c)
                .toList(),
            vertices: _state.vertices.map((v) {
              if (v.id == nc.startVertexId)
                return v.copyWith(x: v.x + incX, y: v.y + incY);
              if (v.id == nc.endVertexId)
                return v.copyWith(x: v.x + incX, y: v.y + incY);
              return v;
            }).toList(),
          ),
        );
      }
    }
  }

  void _onDragEnd() {
    if (_isToolboxDropActive) return;
    if (_state.draggingControlPointWireId != null) {
      final wr = _state.wires.firstWhere(
        (w) => w.id == _state.draggingControlPointWireId,
      );
      _update(
        _state.copyWith(
          wires: _state.wires
              .map(
                (w) => w.id == wr.id
                    ? wr.moveControlPoint(
                        _state.draggingControlPointIndex!,
                        _state.dragPos!,
                      )
                    : w,
              )
              .toList(),
          draggingControlPointWireId: null,
          draggingControlPointIndex: null,
          dragPos: null,
        ),
        sound: true,
      );
    } else if (_state.draggingVertexId != null) {
      final vId = _state.draggingVertexId!;
      final np = _state.dragVertexNewPos ?? _state.findVertex(vId)!.pos;
      final snap = _state.findSnapTarget(np, excludeVertexId: vId);
      if (snap != null) {
        // 保护：不允许把元件 terminal merge 到别的顶点（会导致元件被硬拉到目标位置）
        final draggedV = _state.findVertex(vId);
        if (draggedV != null && draggedV.isTerminal) {
          _update(
            _state.copyWith(draggingVertexId: null, dragVertexNewPos: null),
          );
        } else {
          _mergeVertices(vId, snap.vertexId!);
        }
      } else {
        // 断连分支：若被拖顶点是某元件的 terminal 且无磁吸目标，则新建自由 vertex 承接 wire 端，原 terminal 留在元件上
        final draggedV = _state.findVertex(vId);
        final ownerComp = _state.components
            .where((c) => c.startVertexId == vId || c.endVertexId == vId)
            .toList();
        if (draggedV != null && draggedV.isTerminal && ownerComp.isNotEmpty) {
          final wiresOnTerminal = _state.wires
              .where((wr) => wr.startVertexId == vId || wr.endVertexId == vId)
              .toList();
          if (wiresOnTerminal.isNotEmpty) {
            final newV = Vertex(id: _vid(), x: np.dx, y: np.dy);
            final newWires = _state.wires.map((wr) {
              if (wr.startVertexId == vId)
                return wr.copyWith(startVertexId: newV.id);
              if (wr.endVertexId == vId)
                return wr.copyWith(endVertexId: newV.id);
              return wr;
            }).toList();
            _update(
              _state.copyWith(
                vertices: [..._state.vertices, newV],
                wires: newWires,
                draggingVertexId: null,
                dragVertexNewPos: null,
              ),
              sound: true,
            );
            _dragStartMousePos = null;
            _dragStartCompPos = null;
            return;
          }
        }
        _update(
          _state.copyWith(
            vertices: _state.vertices
                .map((v) => v.id == vId ? v.copyWith(x: np.dx, y: np.dy) : v)
                .toList(),
            draggingVertexId: null,
            dragVertexNewPos: null,
          ),
          sound: true,
        );
      }
    }
    _dragStartMousePos = null;
    _dragStartCompPos = null;
  }

  void _mergeVertices(String old, String nw) => _update(
    _state.copyWith(
      wires: _state.wires.map((w) {
        if (w.startVertexId == old)
          return WireSegment(
            id: w.id,
            startVertexId: nw,
            endVertexId: w.endVertexId,
          );
        if (w.endVertexId == old)
          return WireSegment(
            id: w.id,
            startVertexId: w.startVertexId,
            endVertexId: nw,
          );
        return w;
      }).toList(),
      components: _state.components.map((c) {
        if (c.startVertexId == old) return c.copyWith(startVertexId: nw);
        if (c.endVertexId == old) return c.copyWith(endVertexId: nw);
        return c;
      }).toList(),
      vertices: _state.vertices.where((v) => v.id != old).toList(),
      draggingVertexId: null,
      dragVertexNewPos: null,
    ),
    sound: true,
  );

  void _deleteSelected() {
    if (_state.selectedId == null) return;
    final id = _state.selectedId!;
    final wi = _state.wires.indexWhere((w) => w.id == id);
    if (wi != -1)
      _update(
        _state.copyWith(
          wires: List<WireSegment>.from(_state.wires)..removeAt(wi),
          selectedId: null,
        ),
        sound: true,
      );
    else
      _update(_state.removeComponent(id));
  }

  void _toggleSwitch() {
    final s = _state.selected;
    if (s?.type != ComponentType.switch_) return;
    _update(
      _state.copyWith(
        components: _state.components
            .map((c) => c.id == s!.id ? c.copyWith(isClosed: !c.isClosed) : c)
            .toList(),
      ),
      sound: true,
    );
  }

  void _adjustValue(double v) {
    final s = _state.selected;
    if (s == null) return;
    _update(
      _state.copyWith(
        components: _state.components
            .map(
              (c) => c.id == s.id
                  ? c.copyWith(value: v.clamp(s.type.valueMin, s.type.valueMax))
                  : c,
            )
            .toList(),
      ),
    );
  }

  void _setZoom(double z) {
    _update(_state.copyWith(zoom: z.clamp(0.6, 2.0)));
  }

  void _rotateSelected() {
    final s = _state.selected;
    if (s == null) return;
    _update(
      _state.copyWith(
        components: _state.components
            .map(
              (c) => c.id == s.id
                  ? c.copyWith(rotation: (c.rotation + 90) % 360)
                  : c,
            )
            .toList(),
      ),
    );
  }

  void _undo() {
    final p = _history.undo(_state);
    if (p != null)
      setState(() {
        _state = p;
        _solved = CircuitSolver.solve(p);
      });
  }

  void _redo() {
    final n = _history.redo(_state);
    if (n != null)
      setState(() {
        _state = n;
        _solved = CircuitSolver.solve(n);
      });
  }

  void _clear() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('清空电路'),
      content: const Text('确定清空所有元件和连线吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            _update(const CircuitState());
            _history.clear();
            _nextId = 0;
          },
          child: const Text('确定', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  // 每项都带 customFeedback：拖拽跟随手指的浮起视觉与画布上落定的最终形态一致（迷你版）。
  // 参见 lib/widgets/drag_drop_workspace.dart 的 DragItem.customFeedback。
  static final _trayItems = <DragItem<ComponentType>>[
    DragItem(
      data: ComponentType.battery,
      label: '电池',
      icon: Icons.battery_5_bar,
      color: const Color(0xFFEF4444),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.battery),
    ),
    DragItem(
      data: ComponentType.resistor,
      label: '电阻',
      icon: Icons.waves,
      color: const Color(0xFFF59E0B),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.resistor),
    ),
    DragItem(
      data: ComponentType.lightBulb,
      label: '灯泡',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFF22C55E),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.lightBulb),
    ),
    DragItem(
      data: ComponentType.switch_,
      label: '开关',
      icon: Icons.toggle_off_outlined,
      color: const Color(0xFF6366F1),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.switch_),
    ),
    DragItem(
      data: ComponentType.fuse,
      label: '保险丝',
      icon: Icons.flash_on_rounded,
      color: const Color(0xFFF97316),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.fuse),
    ),
    DragItem(
      data: ComponentType.ground,
      label: '接地',
      icon: Icons.vertical_align_bottom_rounded,
      color: const Color(0xFF6B7280),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.ground),
    ),
    DragItem(
      data: ComponentType.wire,
      label: '导线',
      icon: Icons.horizontal_rule_rounded,
      color: const Color(0xFF334155),
      customFeedback: () =>
          ComponentIconWidget.dragFeedback(ComponentType.wire),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sel = _state.selected;
    final hasSelection = _state.selectedId != null;
    final isWireSelected = hasSelection && sel == null;
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.delete)
            _deleteSelected();
          else if (event.logicalKey == LogicalKeyboardKey.keyR)
            _rotateSelected();
          else if (event.logicalKey == LogicalKeyboardKey.escape)
            _update(_state.copyWith(selectedId: null));
          else if (event.logicalKey == LogicalKeyboardKey.keyZ &&
              HardwareKeyboard.instance.isControlPressed)
            HardwareKeyboard.instance.isShiftPressed ? _redo() : _undo();
          else if (event.logicalKey == LogicalKeyboardKey.keyY &&
              HardwareKeyboard.instance.isControlPressed)
            _redo();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFC),
        appBar: AppBar(
          title: Text(
            isWireSelected
                ? '电路搭建 - 导线'
                : sel != null
                ? '电路搭建 - ${sel.type.label}'
                : '电路搭建',
          ),
          backgroundColor: const Color(0xFF0B2B3D),
          foregroundColor: Colors.white,
          // FittedBox 缩放：320 窄视口 AppBar 按钮过多（21px 溢出）时整体缩放
          actions: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: '知识点',
              onPressed: _showKnowledgeDialog,
            ),
            // 320 窄视口隐藏场景下拉（140px 最占空间 · AppBar 21px 溢出修复）
            if (_scenarioManager != null &&
                MediaQuery.sizeOf(context).width >= 600)
              SizedBox(
                width: 140,
                child: KratosComboBox<String>(
                  items: _scenarioManager!.scenarios
                      .map((s) => s.scenarioId)
                      .toList(),
                  itemLabels: _scenarioManager!.scenarios
                      .map((s) => s.name)
                      .toList(),
                  value: _currentScenarioId,
                  onChanged: _switchScenario,
                ),
              ),
            const SizedBox(width: 8),
            if (sel != null && sel.type == ComponentType.switch_)
              IconButton(
                icon: Icon(
                  sel.isClosed ? Icons.toggle_on : Icons.toggle_off,
                  color: const Color(0xFF22C55E),
                ),
                tooltip: '切换',
                onPressed: _toggleSwitch,
              ),
            if (sel != null)
              IconButton(
                icon: const Icon(Icons.rotate_right, color: Color(0xFFCBD5E1)),
                tooltip: '旋转(R)',
                onPressed: _rotateSelected,
              ),
            if (hasSelection)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                ),
                tooltip: '删除',
                onPressed: _deleteSelected,
              ),
            IconButton(
              icon: const Icon(Icons.undo, size: 20),
              tooltip: '撤销',
              onPressed: _history.canUndo ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo, size: 20),
              tooltip: '重做',
              onPressed: _history.canRedo ? _redo : null,
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out, size: 20),
              tooltip: '缩小',
              onPressed: () => _setZoom(_state.zoom - 0.1),
            ),
            Text(
              '${(_state.zoom * 100).toInt()}%',
              style: const TextStyle(fontSize: 11),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in, size: 20),
              tooltip: '放大',
              onPressed: () => _setZoom(_state.zoom + 0.1),
            ),
                  IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: '清空',
              onPressed: _clear,
            ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            NineGridLayout(
              // 中间格 = 纯电路画布 · 面积 ≥ 70% 屏 · DragTarget 接收元件
              center: DropCanvas<ComponentType>(
              canvasBuilder: (_, wsProj) {
                _canvasSize = wsProj.canvasSize;
                return _buildCanvas(wsProj.canvasSize);
              },
              onItemDropped: _onComponentDrop,
              scale: 1.0,
            ),
              // 底部中格 = 元件托盘（永久 UI · 贴屏底；临时调节条在画布内跟随选中元件）
              bottomCenter: DragTray<ComponentType>(
                layout: DragDropLayout.bottomTray,
                trayTitle: '元件',
                items: _trayItems,
                traySize: 56,
                itemMinWidth: 80, // 7 items 文字完整（电池/保险丝/接地/导线等不裁成"电"竖线）
              ),
              // 左侧中格 = 探究入口按钮（窄边条放不下三组件 → 抽屉方案）
              midLeft: _buildInquiryEntryButton(),
              // 顶部右格 = 实验说明 + 操作指引（通用引导组件）
              topRight: ExperimentIntroPanel(
                description:
                    _scenarioManager?.currentScenario?.description ?? '',
                task: _inquiryTask,
                color: const Color(0xFF0C4A6E),
                onOpenInquiry: () => setState(() => _inquiryOpen = true),
              ),
            ),
            // 探究工作流抽屉（Offstage 保持记录/结论 State · 无 inquiryTask 不渲染）
            InquiryDrawer(
              task: _inquiryTask,
              columns: _inquiryTask != null
                  ? _inquiryColumns(_inquiryTask!)
                  : const [],
              snapshotProvider: _circuitSnapshot,
              open: _inquiryOpen,
            ),
          ],
        ),
      ),
    );
  }

  /// 探究抽屉入口按钮（仅在有 inquiryTask 的 scenario 显示）。
  Widget _buildInquiryEntryButton() {
    final task = _inquiryTask;
    if (task == null) return const SizedBox.shrink();
    return Center(
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.science_outlined, size: 20),
        tooltip: '探究任务',
        onPressed: () => setState(() => _inquiryOpen = !_inquiryOpen),
      ),
    );
  }

  /// 当前 scenario 的探究任务（无 inquiryTask 时为 null → 三组件不渲染）。
  InquiryTask? get _inquiryTask =>
      _scenarioManager?.currentScenario?.inquiryTask;

  /// circuit 快照：从 _state（元件 value）+ _solved（currentFor/voltageFor/brightnessFor）读取。
  ///
  /// key 与 simple-series.json inquiryTask.snapshotColumns 的 key 一致（AC-2.4）。
  Map<String, dynamic> _circuitSnapshot() {
    final res = _state.findComp('res_1');
    return {
      'resistance': res?.value,
      'voltage': _solved.voltageFor('res_1'),
      'current': _solved.currentFor('res_1'),
      'brightness': _solved.brightnessFor('bulb_1'),
    };
  }

  List<ColumnDef> _inquiryColumns(InquiryTask task) {
    if (task.snapshotColumns.isEmpty) {
      return const [
        ColumnDef(key: 'resistance', label: '电阻(Ω)', isParam: true),
        ColumnDef(key: 'current', label: '电流(A)'),
        ColumnDef(key: 'brightness', label: '灯泡亮度'),
      ];
    }
    return task.snapshotColumns
        .map(
          (c) => ColumnDef(
            key: c.key,
            label: c.label,
            isParam: c.source == 'param',
          ),
        )
        .toList(growable: false);
  }

  /// 知识点卡 → 弹窗（9 宫格边条容纳不下长文本知识卡）
  void _showKnowledgeDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: _buildKnowledgePanel(),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(Size sz) {
    final pw = _solved;
    final proj = SceneProjection(
      scale: 1,
      origin: Offset(sz.width / 2, sz.height / 2),
      zoom: _state.zoom,
    );
    final isWire = _state.selected != null
        ? false
        : _state.selectedId != null &&
              _state.wires.any((w) => w.id == _state.selectedId);

    return Stack(
      children: [
        GestureDetector(
          onTapUp: (d) {
            final w = proj.toWorld(d.localPosition);
            final hit = _state.components.reversed
                .cast<CircuitComponent?>()
                .firstWhere((c) => c!.hitTest(w), orElse: () => null);
            if (hit != null) {
              _onComponentTap(hit.id);
              return;
            }
            final wi = _hitTestWire(w, proj);
            if (wi != null) {
              _onWireTap(wi);
              return;
            }
            _onCanvasTap(w);
          },
          onDoubleTapDown: (d) {
            _doubleTapWorld = proj.toWorld(d.localPosition);
          },
          onDoubleTap: () {
            final w = _doubleTapWorld;
            if (w != null) _onDoubleTap(w, proj);
            _doubleTapWorld = null;
          },
          onScaleStart: (d) {
            if (d.pointerCount < 2)
              _onDragStart(proj.toWorld(d.localFocalPoint));
          },
          onScaleUpdate: (d) => d.pointerCount >= 2
              ? _setZoom(_state.zoom * d.horizontalScale)
              : _onDragMove(proj.toWorld(d.localFocalPoint)),
          onScaleEnd: (d) {
            if (d.pointerCount < 2) _onDragEnd();
          },
          child: CustomPaint(
            size: sz,
            painter: CircuitPainter(
              state: _state,
              solved: pw,
              projection: proj,
              wireSelected: isWire,
            ),
          ),
        ),
        ..._state.components.map((comp) {
          final sp = proj.toScreen(Offset(comp.x, comp.y));
          final sw = proj.toScreenLength(comp.width),
              sh = proj.toScreenLength(comp.height);
          return Positioned(
            key: Key('component_${comp.id}_${pw.hashCode}'),
            left: sp.dx - sw / 2,
            top: sp.dy - sh / 2,
            width: sw,
            height: sh,
            child: IgnorePointer(
              child: Center(
                child: ComponentIconWidget(
                  type: comp.type,
                  iconSize: (sw * 0.45).clamp(16, 32),
                  fontSize: (sh * 0.18).clamp(8, 14),
                  showLabel: sh > 30,
                  fixedWidth: sw * 0.8,
                  fixedHeight: sh * 0.7,
                  isPowered: pw.isPowered(comp.id),
                  isClosed: comp.type == ComponentType.switch_
                      ? comp.isClosed
                      : true,
                ),
              ),
            ),
          );
        }),
        // 临时 UI：选中元件的参数调节条悬浮在元件正上方（动态投影坐标 · 非硬编码，
        // 80-checklist L0-1 允许浮层；不占用底部永久位置 → 元件库始终贴底）
        if (_state.selected != null) _buildSelectedControls(sz, proj),
      ],
    );
  }

  /// 选中元件的参数调节条：悬浮在元件正上方（画布内 · 动态投影坐标）。
  ///
  /// 宽度 = `min(320, 画布宽×0.5)`，靠近画布边缘时 clamp 防溢出。
  Widget _buildSelectedControls(Size sz, SceneProjection proj) {
    final comp = _state.selected;
    if (comp == null) return const SizedBox.shrink();
    final sp = proj.toScreen(Offset(comp.x, comp.y));
    final barW = math.min(320.0, sz.width * 0.5);
    const barH = 52.0;
    final maxLeft = math.max(0.0, sz.width - barW);
    final maxTop = math.max(0.0, sz.height - barH);
    final left = (sp.dx - barW / 2).clamp(0.0, maxLeft).toDouble();
    final top = (sp.dy - barH - 10).clamp(0.0, maxTop).toDouble();
    return Positioned(
      left: left,
      top: top,
      width: barW,
      // 不固定 height：让 CircuitControls 用 natural height（≈50px：Slider 48+border 1），
      // 避免窄画布被 tight 52 压崩（实测 integration_test 默认视口下画布 26px → Slider 溢出 22px）
      child: CircuitControls(
        state: _state,
        solved: _solved,
        onValueChanged: _adjustValue,
      ),
    );
  }

  /// 双击导线：命中已有控制点 → 删除；命中导线非控制点位置 → 添加拐点。
  ///
  /// 屏幕距离阈值 12px（控制点手柄）/ 15px（导线），与 `_hitTestWire` 保持一致。
  void _onDoubleTap(Offset wp, SceneProjection proj) {
    final sp = proj.toScreen(wp);
    // 1) 先查是否命中某导线的某个控制点（优先删）
    for (var i = 0; i < _state.wires.length; i++) {
      final seg = _state.wires[i];
      for (var j = 0; j < seg.controlPoints.length; j++) {
        if ((proj.toScreen(seg.controlPoints[j]) - sp).distance < 12) {
          final next = seg.removeControlPoint(j);
          _update(
            _state.copyWith(
              wires: _state.wires
                  .map((w) => w.id == seg.id ? next : w)
                  .toList(),
            ),
          );
          return;
        }
      }
    }
    // 2) 命中导线（非控制点位置） → 在最近线段插入控制点
    final wi = _hitTestWire(wp, proj);
    if (wi != null) {
      final wireId = _state.wires[wi].id;
      _update(_state.addControlPointToWire(wireId, wp));
    }
  }

  int? _hitTestWire(Offset wp, SceneProjection proj) {
    final sp = proj.toScreen(wp);
    for (var i = 0; i < _state.wires.length; i++) {
      final seg = _state.wires[i];
      final sv = _state.findVertex(seg.startVertexId),
          ev = _state.findVertex(seg.endVertexId);
      if (sv == null || ev == null) continue;
      final pts = [
        proj.toScreen(sv.pos),
        ...seg.controlPoints.map(proj.toScreen),
        proj.toScreen(ev.pos),
      ];
      var md = double.infinity;
      for (var j = 0; j < pts.length - 1; j++) {
        final ab = pts[j + 1] - pts[j], ap = sp - pts[j];
        final ls = ab.distanceSquared,
            t = ls == 0 ? 0 : (ap.dx * ab.dx + ap.dy * ab.dy) / ls;
        md = math.min(
          md,
          (sp - (pts[j] + ab * (t.clamp(0.0, 1.0) as double))).distance,
        );
      }
      if (md < 15) return i;
    }
    return null;
  }

  // ---- 电路知识点 ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '电路基础知识',
      titleIcon: '⚡',
      titleColor: const Color(0xFFF59E0B),
      maxHeight: 200,
      sections: [
        KnowledgeSection.grid(
          items: const [
            KnowledgeItem(
              dot: Color(0xFFEF4444),
              title: '串联电路',
              titleColor: Color(0xFFEF4444),
              desc: '元件首尾相连。电流处处相等I=I₁=I₂,总电压=各段之和U=U₁+U₂。一个断开全断。',
            ),
            KnowledgeItem(
              dot: Color(0xFF22C55E),
              title: '并联电路',
              titleColor: Color(0xFF22C55E),
              desc: '元件并列连接。各支路电压相等U=U₁=U₂,干路电流=各支路之和I=I₁+I₂。互不影响。',
            ),
            KnowledgeItem(
              dot: Color(0xFFF97316),
              title: '欧姆定律',
              titleColor: Color(0xFFF97316),
              desc: 'U = I × R。电压=电流×电阻。已知任意两个量可求第三个——电路分析最基础的公式。',
            ),
            KnowledgeItem(
              dot: Color(0xFF6366F1),
              title: '短路与断路',
              titleColor: Color(0xFF6366F1),
              desc: '短路：导线直接连接电源两极,电流极大,危险!断路：电路某处断开,无电流。保险丝防短路。',
            ),
          ],
        ),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '🔌',
              title: '电流的本质 · 电子流 vs 常规电流',
              titleColor: Color(0xFFF59E0B),
              desc:
                  '实际是带负电的电子从负极流向正极（电子流）。但工程上约定"常规电流"从正极流向负极——'
                  '这是历史原因,所有电路图符号都按常规电流标方向,不影响计算结果。',
            ),
            KnowledgeItem(
              icon: '📊',
              title: '基尔霍夫定律 · 电路分析基石',
              titleColor: Color(0xFF22C55E),
              desc:
                  'KCL(电流定律): 流入节点的电流=流出节点的电流。KVL(电压定律): 闭合回路总电压降=0。'
                  '这两条定律是分析任意复杂电路的核心工具——比欧姆定律更通用。',
            ),
            KnowledgeItem(
              icon: '💡',
              title: '安全用电 · 生活常识',
              titleColor: Color(0xFF8B5CF6),
              desc:
                  '保险丝/空气开关=短路保护(电流过大自动断开)。接地线=漏电时把电流导入大地保护人身安全。'
                  '人体安全电压≤36V,家用220V足以致命——所以千万别用湿手碰开关。',
            ),
          ],
        ),
      ],
    );
  }
}

class SceneProjection {
  final double scale;
  final Offset origin;
  final double zoom;
  const SceneProjection({
    required this.scale,
    required this.origin,
    this.zoom = 1.0,
  });
  Offset toScreen(Offset w) =>
      Offset(w.dx * scale * zoom + origin.dx, w.dy * scale * zoom + origin.dy);
  Offset toWorld(Offset s) => Offset(
    (s.dx - origin.dx) / (scale * zoom),
    (s.dy - origin.dy) / (scale * zoom),
  );
  double toScreenLength(double w) => w * scale * zoom;
}

class CircuitPainter extends CustomPainter {
  final CircuitState state;
  final SolvedCircuit solved;
  final SceneProjection projection;
  final bool wireSelected;
  CircuitPainter({
    required this.state,
    required this.solved,
    required this.projection,
    this.wireSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _grid(canvas, size);
    _wires(canvas);
    _components(canvas);
  }

  @override
  bool shouldRepaint(covariant CircuitPainter old) =>
      solved != old.solved ||
      wireSelected != old.wireSelected ||
      state.selectedId != old.state.selectedId ||
      state.wires != old.state.wires ||
      state.vertices != old.state.vertices ||
      state.components != old.state.components ||
      state.dragPos != old.state.dragPos ||
      state.draggingVertexId != old.state.draggingVertexId ||
      state.dragVertexNewPos != old.state.dragVertexNewPos;

  void _grid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFE8ECF0)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final g = 40 * projection.scale * projection.zoom;
    for (double x = 0; x < size.width; x += g)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += g)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  void _wires(Canvas canvas) {
    for (final seg in state.wires) {
      final sv = state.findVertex(seg.startVertexId),
          ev = state.findVertex(seg.endVertexId);
      if (sv == null || ev == null) continue;
      final sp =
          state.draggingVertexId == sv.id && state.dragVertexNewPos != null
          ? state.dragVertexNewPos!
          : sv.pos;
      final ep =
          state.draggingVertexId == ev.id && state.dragVertexNewPos != null
          ? state.dragVertexNewPos!
          : ev.pos;
      final path = Path()
        ..moveTo(projection.toScreen(sp).dx, projection.toScreen(sp).dy);
      for (final cp in seg.controlPoints) {
        final p = projection.toScreen(cp);
        path.lineTo(p.dx, p.dy);
      }
      final lp = projection.toScreen(ep);
      path.lineTo(lp.dx, lp.dy);
      final sel = state.selectedId == seg.id;
      canvas.drawPath(
        path,
        Paint()
          ..color = sel ? const Color(0xFFEF4444) : const Color(0xFF334155)
          ..strokeWidth = sel ? 5 : 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      _v(canvas, sv);
      _v(canvas, ev);
    }
  }

  void _v(Canvas c, Vertex v) {
    final drag = state.draggingVertexId == v.id;
    final pos = projection.toScreen(
      drag ? (state.dragVertexNewPos ?? v.pos) : v.pos,
    );
    c.drawCircle(
      pos,
      drag ? 10.0 : (v.isJunction ? 5.0 : 3.0),
      Paint()
        ..color = drag
            ? Colors.blue
            : (v.isJunction
                  ? const Color(0xFF334155)
                  : const Color(0xFF94A3B8)),
    );
  }

  void _components(Canvas canvas) {
    for (final comp in state.components)
      _draw(canvas, comp, comp.id == state.selectedId);
  }

  void _draw(Canvas canvas, CircuitComponent c, bool sel) {
    final pos = projection.toScreen(Offset(c.x, c.y));
    final w = projection.toScreenLength(c.width),
        h = projection.toScreenLength(c.height);
    final r = Rect.fromCenter(center: pos, width: w, height: h);
    _t(canvas, Offset(r.left, pos.dy));
    _t(canvas, Offset(r.right, pos.dy));
    if (sel)
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.inflate(6), const Radius.circular(8)),
        Paint()
          ..color = const Color(0xFF1177AA)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  void _t(Canvas c, Offset o) {
    c.drawCircle(o, 5, Paint()..color = const Color(0xFF334155));
    c.drawCircle(o, 3.5, Paint()..color = const Color(0xFF94A3B8));
    c.drawCircle(o, 2, Paint()..color = Colors.white);
  }
}
