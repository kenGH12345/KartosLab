import 'package:flutter/material.dart';

import '../../common/elements/position_element.dart';

enum ComponentType { battery, resistor, lightBulb, switch_, wire, fuse, ground }
enum WireDragSide { from, to }
enum SnapType { terminal, vertex } // 新增：磁吸类型

extension ComponentTypeLabel on ComponentType {
  String get label => switch (this) {
    ComponentType.battery => '电池', ComponentType.resistor => '电阻',
    ComponentType.lightBulb => '灯泡', ComponentType.switch_ => '开关',
    ComponentType.wire => '导线', ComponentType.fuse => '保险丝',
    ComponentType.ground => '接地',
  };
  String get unit => switch (this) {
    ComponentType.battery => 'V', ComponentType.resistor => 'Ω', _ => '',
  };
  double get defaultValue => switch (this) {
    ComponentType.battery => 10.0, ComponentType.resistor => 10.0,
    ComponentType.lightBulb => 10.0, _ => 0.0,
  };
  double get valueMin => switch (this) {
    ComponentType.battery => 1.0, ComponentType.resistor => 1.0, _ => 1.0,
  };
  double get valueMax => switch (this) {
    ComponentType.battery => 100.0, ComponentType.resistor => 1000.0, _ => 100.0,
  };
  double get valueStep => switch (this) {
    ComponentType.battery => 1.0, ComponentType.resistor => 5.0, _ => 1.0,
  };
}

@immutable
class Vertex {
  final String id;
  final double x, y;
  final bool isJunction;
  final bool isTerminal; // 元件端点，不可独立删除

  const Vertex({required this.id, required this.x, required this.y,
    this.isJunction = false, this.isTerminal = false});

  Offset get pos => Offset(x, y);
  Vertex copyWith({String? id, double? x, double? y, bool? isJunction, bool? isTerminal}) =>
    Vertex(id: id??this.id, x: x??this.x, y: y??this.y, isJunction: isJunction??this.isJunction, isTerminal: isTerminal??this.isTerminal);
}

@immutable
class CircuitComponent extends PositionElement<ComponentType> {
  final double value;
  final bool isClosed;
  final String startVertexId, endVertexId;

  const CircuitComponent({
    required super.id, required super.type, required super.x, required super.y,
    super.rotation = 0.0, this.value = 10.0, this.isClosed = true,
    required this.startVertexId, required this.endVertexId,
  });

  @override
  double get width { return type == ComponentType.wire ? 100 : type == ComponentType.fuse ? 80 : type == ComponentType.ground ? 40 : 120; }
  @override
  double get height { return type == ComponentType.wire ? 4 : type == ComponentType.ground ? 30 : 60; }
  String get label {
    if (type == ComponentType.lightBulb || type == ComponentType.wire || type == ComponentType.ground) return '';
    if (type == ComponentType.switch_) return isClosed ? '开' : '关';
    return '${value.toInt()}${type.unit}';
  }
  Rect get hitRect => Rect.fromCenter(center: Offset(x, y), width: width + 40, height: height + 40);
  @override
  bool hitTest(Offset position) => hitRect.contains(position);

  CircuitComponent copyWith({
    String? id, ComponentType? type, double? x, double? y, double? rotation,
    double? value, bool? isClosed, String? startVertexId, String? endVertexId,
  }) => CircuitComponent(
    id: id ?? this.id, type: type ?? this.type, x: x ?? this.x, y: y ?? this.y,
    rotation: rotation ?? this.rotation, value: value ?? this.value,
    isClosed: isClosed ?? this.isClosed,
    startVertexId: startVertexId ?? this.startVertexId,
    endVertexId: endVertexId ?? this.endVertexId,
  );
}

@immutable
class WireSegment {
  final String id;
  final String startVertexId, endVertexId;
  final List<Offset> controlPoints; // 控制点列表（用于导线弯曲）

  const WireSegment({
    required this.id,
    required this.startVertexId,
    required this.endVertexId,
    this.controlPoints = const [], // 默认空列表（直线）
  });

  /// 添加控制点（在最近的两个点之间）
  WireSegment addControlPoint(Offset point, List<Vertex> vertices) {
    // 1. 获取所有点（端点 + 控制点）
    final allPoints = _getAllPoints(vertices);

    // 2. 找到最近的线段
    var minDist = double.infinity;
    var insertIndex = 0;

    for (var i = 0; i < allPoints.length - 1; i++) {
      final dist = _pointToSegmentDistance(point, allPoints[i], allPoints[i + 1]);
      if (dist < minDist) {
        minDist = dist;
        insertIndex = i;
      }
    }

    // 3. 插入控制点
    final newControlPoints = List<Offset>.from(controlPoints);
    newControlPoints.insert(insertIndex, point);

    return copyWith(controlPoints: newControlPoints);
  }

  /// 移动控制点
  WireSegment moveControlPoint(int index, Offset newPosition) {
    if (index < 0 || index >= controlPoints.length) return this;

    final newControlPoints = List<Offset>.from(controlPoints);
    newControlPoints[index] = newPosition;
    return copyWith(controlPoints: newControlPoints);
  }

  /// 删除控制点（拖拽到端点附近）
  WireSegment removeControlPoint(int index) {
    if (index < 0 || index >= controlPoints.length) return this;

    final newControlPoints = List<Offset>.from(controlPoints);
    newControlPoints.removeAt(index);
    return copyWith(controlPoints: newControlPoints);
  }

  /// 获取所有点（端点 + 控制点）
  List<Offset> _getAllPoints(List<Vertex> vertices) {
    final points = <Offset>[];
    final startVertex = vertices.firstWhere((v) => v.id == startVertexId);
    final endVertex = vertices.firstWhere((v) => v.id == endVertexId);

    points.add(startVertex.pos);
    points.addAll(controlPoints);
    points.add(endVertex.pos);

    return points;
  }

  /// 计算点到线段的距离
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

  /// 构建 Path（用于渲染和命中检测）
  Path buildPath(List<Vertex> vertices, {double scale = 1.0, double zoom = 1.0}) {
    final allPoints = _getAllPoints(vertices);
    final path = Path();

    var firstPoint = allPoints.first;
    path.moveTo(firstPoint.dx * scale * zoom, firstPoint.dy * scale * zoom);

    for (final point in allPoints.skip(1)) {
      path.lineTo(point.dx * scale * zoom, point.dy * scale * zoom);
    }

    return path;
  }

  /// copyWith 方法（不可变模式）
  WireSegment copyWith({
    String? id,
    String? startVertexId,
    String? endVertexId,
    List<Offset>? controlPoints,
  }) =>
      WireSegment(
        id: id ?? this.id,
        startVertexId: startVertexId ?? this.startVertexId,
        endVertexId: endVertexId ?? this.endVertexId,
        controlPoints: controlPoints ?? this.controlPoints,
      );
}

@immutable
class SnapTarget {
  final SnapType type;
  final Offset position;
  final String? vertexId;
  final String? componentId;
  final double distance;

  const SnapTarget({required this.type, required this.position, this.vertexId, this.componentId, required this.distance});
}

@immutable
class SolvedCircuit {
  final Map<String, double> bulbBrightness;
  final Map<String, bool> componentStates;
  final Set<String> openNodes, shortedNodes;

  /// MNA 求解结果扩展：每元件电流 (A) 与端电压 (V)。
  /// 供黑盒行为对比等下游使用（向后兼容，未启用时为默认空）。
  final Map<String, double> currents;
  final Map<String, double> voltages;

  const SolvedCircuit({
    this.bulbBrightness = const {},
    this.componentStates = const {},
    this.openNodes = const {},
    this.shortedNodes = const {},
    this.currents = const {},
    this.voltages = const {},
  });
  static const empty = SolvedCircuit();
  double brightnessFor(String id) => bulbBrightness[id] ?? 0.0;
  bool isPowered(String id) => componentStates[id] == true;
  bool isOpen(String id) => openNodes.contains(id);
  bool isShorted(String id) => shortedNodes.contains(id);

  /// 元件电流（A）；未求解或无电流时为 0。
  double currentFor(String id) => currents[id] ?? 0.0;

  /// 元件端电压（V）。
  double voltageFor(String id) => voltages[id] ?? 0.0;
}

/// Sentinel 用于区分"未提供"和"显式设为 null"。
/// 修复 copyWith 中 `null ?? 旧值` 无法清空字段的经典 bug。
class _NullSentinel { const _NullSentinel(); }
const _ns = _NullSentinel();

@immutable
class CircuitState {
  final List<CircuitComponent> components;
  final List<WireSegment> wires;
  final List<Vertex> vertices;
  final String? selectedId;
  final double zoom;
  final int? wireDragIdx;         // 正在拖拽的导线索引(wires列表)
  final WireDragSide? dragSide;   // 拖拽哪一端
  final Offset? dragPos;          // 拖拽中光标位置
  final String? creatingWireStartVertexId; // 正在创建的导线起点顶点ID
  final String? draggingControlPointWireId; // 正在拖拽的控制点所属导线ID
  final int? draggingControlPointIndex; // 正在拖拽的控制点索引
  final String? draggingVertexId;         // 正在拖动的顶点ID
  final Offset? dragVertexNewPos;      // 拖动中的顶点新位置

  const CircuitState({
    this.components = const [], this.wires = const [],
    this.vertices = const [], this.selectedId,
    this.zoom = 1.0,
    this.wireDragIdx, this.dragSide, this.dragPos,
    this.creatingWireStartVertexId,
    this.draggingControlPointWireId,
    this.draggingControlPointIndex,
    this.draggingVertexId,
    this.dragVertexNewPos,
  });

  /// ★ 所有可空字段用 sentinel 模式：传入 null 时真的设为 null，不影响其他字段
  CircuitState copyWith({
    List<CircuitComponent>? components, List<WireSegment>? wires,
    List<Vertex>? vertices,
    Object? selectedId = _ns,
    double? zoom,
    Object? wireDragIdx = _ns, Object? dragSide = _ns,
    Object? dragPos = _ns,
    Object? creatingWireStartVertexId = _ns,
    Object? draggingControlPointWireId = _ns, Object? draggingControlPointIndex = _ns,
    Object? draggingVertexId = _ns, Object? dragVertexNewPos = _ns,
  }) => CircuitState(
    components: components ?? this.components,
    wires: wires ?? this.wires,
    vertices: vertices ?? this.vertices,
    selectedId: identical(selectedId, _ns) ? this.selectedId : selectedId as String?,
    zoom: zoom ?? this.zoom,
    wireDragIdx: identical(wireDragIdx, _ns) ? this.wireDragIdx : wireDragIdx as int?,
    dragSide: identical(dragSide, _ns) ? this.dragSide : dragSide as WireDragSide?,
    dragPos: identical(dragPos, _ns) ? this.dragPos : dragPos as Offset?,
    creatingWireStartVertexId: identical(creatingWireStartVertexId, _ns) ? this.creatingWireStartVertexId : creatingWireStartVertexId as String?,
    draggingControlPointWireId: identical(draggingControlPointWireId, _ns) ? this.draggingControlPointWireId : draggingControlPointWireId as String?,
    draggingControlPointIndex: identical(draggingControlPointIndex, _ns) ? this.draggingControlPointIndex : draggingControlPointIndex as int?,
    draggingVertexId: identical(draggingVertexId, _ns) ? this.draggingVertexId : draggingVertexId as String?,
    dragVertexNewPos: identical(dragVertexNewPos, _ns) ? this.dragVertexNewPos : dragVertexNewPos as Offset?,
  );

  CircuitComponent? get selected => selectedId != null ? _tryFindComp(selectedId!) : null;
  CircuitComponent? findComp(String id) => _tryFindComp(id);
  CircuitComponent? _tryFindComp(String id) { try { return components.firstWhere((c) => c.id == id); } catch (_) { return null; } }

  Vertex? findVertex(String id) { try { return vertices.firstWhere((v) => v.id == id); } catch (_) { return null; } }

  // 查找接触某位置的顶点（<10px）
  Vertex? vertexAt(Offset pos) {
    for (final v in vertices) { if ((v.pos - pos).distance < 10) return v; }
    return null;
  }

  // 查找某位置的元件端子顶点
  Vertex? terminalAt(Offset pos) {
    for (final c in components) {
      for (final vid in [c.startVertexId, c.endVertexId]) {
        final v = findVertex(vid);
        if (v != null && (v.pos - pos).distance < 15) return v;
      }
    }
    return null;
  }

  // 连接某顶点的所有导线
  List<WireSegment> wiresAt(String vertexId) =>
    wires.where((w) => w.startVertexId == vertexId || w.endVertexId == vertexId).toList();

  // === 导线操作方法 ===

  /// 添加导线
  CircuitState addWire(WireSegment wire) {
    return copyWith(wires: [...wires, wire]);
  }

  /// 删除导线
  CircuitState removeWire(String wireId) {
    return copyWith(
      wires: wires.where((w) => w.id != wireId).toList(),
      selectedId: selectedId == wireId ? null : selectedId,
    );
  }

  /// 更新导线（替换同名 ID 的导线）
  CircuitState updateWire(WireSegment wire) {
    final newWires = wires.map((w) => w.id == wire.id ? wire : w).toList();
    return copyWith(wires: newWires);
  }

  /// 移动导线端点到新顶点
  CircuitState moveWireEnd(String wireId, WireDragSide side, String newVertexId) {
    final wire = wires.firstWhere((w) => w.id == wireId);
    final updatedWire = side == WireDragSide.from
        ? wire.copyWith(startVertexId: newVertexId)
        : wire.copyWith(endVertexId: newVertexId);
    return updateWire(updatedWire);
  }

  /// 添加控制点到导线
  CircuitState addControlPointToWire(String wireId, Offset point) {
    final wire = wires.firstWhere((w) => w.id == wireId);
    final updatedWire = wire.addControlPoint(point, vertices);
    return updateWire(updatedWire);
  }

  /// 移动导线控制点
  CircuitState moveWireControlPoint(String wireId, int index, Offset newPosition) {
    final wire = wires.firstWhere((w) => w.id == wireId);
    final updatedWire = wire.moveControlPoint(index, newPosition);
    return updateWire(updatedWire);
  }

  /// 删除导线控制点
  CircuitState removeWireControlPoint(String wireId, int index) {
    final wire = wires.firstWhere((w) => w.id == wireId);
    final updatedWire = wire.removeControlPoint(index);
    return updateWire(updatedWire);
  }

  /// 查找导线经过的最近点（用于命中检测）
  String? findWireAt(Offset pos, {double threshold = 10.0}) {
    for (final wire in wires) {
      final path = wire.buildPath(vertices, zoom: zoom);
      // 使用 Path.contains() 进行精确检测，或使用距离采样
      if (_isPointNearPath(pos, path, threshold)) {
        return wire.id;
      }
    }
    return null;
  }

  /// 判断点是否接近 Path（采样距离）
  bool _isPointNearPath(Offset pos, Path path, double threshold) {
    // 简化实现：采样 Path 上的点到 pos 的距离
    // 完整实现需要使用 PathMetrics
    return false; // TODO: 实现精确的命中检测
  }

  // 删除元件时清理关联顶点和导线
  CircuitState removeComponent(String id) {
    final comp = findComp(id);
    if (comp == null) return this;
    final removedVids = {comp.startVertexId, comp.endVertexId};
    return CircuitState(
      components: components.where((c) => c.id != id).toList(),
      wires: wires.where((w) => !removedVids.contains(w.startVertexId) && !removedVids.contains(w.endVertexId)).toList(),
      vertices: vertices.where((v) => !removedVids.contains(v.id)).toList(),
      selectedId: selectedId == id ? null : selectedId,
      zoom: zoom,
    );
  }

  /// 查找磁吸目标（用于顶点拖动磁吸）— T-9 实现
  SnapTarget? findSnapTarget(Offset pos, {String? excludeVertexId}) {
    const snapRadiusTerminal = 30.0;
    const snapRadiusVertex = 20.0;

    SnapTarget? best;
    var bestDist = double.infinity;

    // 1. 元件端点（最高优先级）
    for (final c in components) {
      for (final vid in [c.startVertexId, c.endVertexId]) {
        final v = findVertex(vid);
        if (v == null) continue;
        final d = (v.pos - pos).distance;
        if (d < snapRadiusTerminal && d < bestDist) {
          bestDist = d;
          // [Fix] 补充 vertexId，使 terminal 类型与 vertex 类型具有一致的数据契约
          best = SnapTarget(type: SnapType.terminal, position: v.pos, vertexId: v.id, componentId: c.id, distance: d);
        }
      }
    }

    // 2. 其他顶点（中等优先级，仅当无端点目标时）
    if (best == null) {
      for (final v in vertices) {
        if (v.id == excludeVertexId || v.isTerminal) continue;
        final d = (v.pos - pos).distance;
        if (d < snapRadiusVertex && d < bestDist) {
          bestDist = d;
          best = SnapTarget(type: SnapType.vertex, position: v.pos, vertexId: v.id, distance: d);
        }
      }
    }

    return best;
  }
}
