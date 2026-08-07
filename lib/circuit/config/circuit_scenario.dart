import 'package:flutter/foundation.dart';

import '../../common/widgets/inquiry_models.dart';
import '../models/circuit_state.dart';
import 'circuit_constraint.dart';
import 'circuit_inventory.dart';
import 'circuit_learning_objective.dart';

/// Circuit scenario (Step 1a · §C1 + Step 1b · §C2 + Step 1c · §C4).
///
/// Counterpart to optical `LabScenario` (`lib/optics/config/lab_scenario.dart`).
///
/// 电路 `initialLayout` 必须 3 层表达（比光学复杂）：
/// - components：电池 / 电阻 / 灯泡 / 开关 / 保险丝 / 接地 / 导线元件
/// - wires：导线段（起止顶点 id + 控制点）
/// - vertices：顶点表（元件端子 + 导线端点 + 连接点）
///
/// 顶点 id 与元件/导线的 startVertexId/endVertexId 关联，是电路拓扑的粘合剂。
@immutable
class CircuitScenario {
  const CircuitScenario({
    required this.scenarioId,
    required this.name,
    required this.description,
    required this.version,
    required this.initialLayout,
    this.inventory,
    this.constraints = const [],
    this.objectives,
    this.inquiryTask,
  });

  final String scenarioId;
  final String name;
  final String description;
  final String version;
  final CircuitLayout initialLayout;
  final CircuitComponentInventory? inventory;
  final List<CircuitConstraint> constraints;
  final CircuitLearningObjective? objectives;
  final InquiryTask? inquiryTask;

  factory CircuitScenario.fromJson(Map<String, dynamic> json) {
    return CircuitScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      initialLayout: CircuitLayout.fromJson(
        json['initialLayout'] as Map<String, dynamic>,
      ),
      inventory: json['inventory'] != null
          ? CircuitComponentInventory.fromJson(
              json['inventory'] as Map<String, dynamic>)
          : null,
      constraints: (json['constraints'] as List<dynamic>?)
              ?.map((e) =>
                  CircuitConstraint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      objectives: json['objectives'] != null
          ? CircuitLearningObjective.fromJson(
              json['objectives'] as Map<String, dynamic>)
          : null,
      inquiryTask: json['inquiryTask'] != null
          ? InquiryTask.fromJson(json['inquiryTask'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'name': name,
      'description': description,
      'version': version,
      'initialLayout': initialLayout.toJson(),
      if (inventory != null) 'inventory': inventory!.toJson(),
      if (constraints.isNotEmpty)
        'constraints': constraints.map((e) => e.toJson()).toList(),
      if (objectives != null) 'objectives': objectives!.toJson(),
      if (inquiryTask != null) 'inquiryTask': inquiryTask!.toJson(),
    };
  }
}

/// 电路拓扑三元组：components + wires + vertices。
@immutable
class CircuitLayout {
  const CircuitLayout({
    this.components = const [],
    this.wires = const [],
    this.vertices = const [],
  });

  final List<ComponentPlacement> components;
  final List<WirePlacement> wires;
  final List<VertexPlacement> vertices;

  factory CircuitLayout.fromJson(Map<String, dynamic> json) {
    return CircuitLayout(
      components: (json['components'] as List<dynamic>? ?? const [])
          .map((e) => ComponentPlacement.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      wires: (json['wires'] as List<dynamic>? ?? const [])
          .map((e) => WirePlacement.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      vertices: (json['vertices'] as List<dynamic>? ?? const [])
          .map((e) => VertexPlacement.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'components': components.map((e) => e.toJson()).toList(),
      'wires': wires.map((e) => e.toJson()).toList(),
      'vertices': vertices.map((e) => e.toJson()).toList(),
    };
  }
}

/// 元件放置（对应 `CircuitComponent`）。
///
/// type 序列化为字符串（`ComponentType.name`），加载时通过 `parseComponentType` 反解。
@immutable
class ComponentPlacement {
  const ComponentPlacement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.startVertexId,
    required this.endVertexId,
    this.rotation = 0.0,
    this.value = 10.0,
    this.isClosed = true,
  });

  final String id;
  final ComponentType type;
  final double x;
  final double y;
  final double rotation;
  final double value;
  final bool isClosed;
  final String startVertexId;
  final String endVertexId;

  factory ComponentPlacement.fromJson(Map<String, dynamic> json) {
    return ComponentPlacement(
      id: json['id'] as String,
      type: parseComponentType(json['type'] as String),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 10.0,
      isClosed: json['isClosed'] as bool? ?? true,
      startVertexId: json['startVertexId'] as String,
      endVertexId: json['endVertexId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'rotation': rotation,
      'value': value,
      'isClosed': isClosed,
      'startVertexId': startVertexId,
      'endVertexId': endVertexId,
    };
  }
}

/// 导线段放置（对应 `WireSegment`）。
///
/// controlPoints 为可选弯曲控制点列表（无弯曲时留空）。
@immutable
class WirePlacement {
  const WirePlacement({
    required this.id,
    required this.startVertexId,
    required this.endVertexId,
    this.controlPoints = const [],
  });

  final String id;
  final String startVertexId;
  final String endVertexId;

  /// 每项形如 {"x": 100.0, "y": 50.0}，加载后由 scenario_manager 转 Offset。
  final List<Map<String, double>> controlPoints;

  factory WirePlacement.fromJson(Map<String, dynamic> json) {
    return WirePlacement(
      id: json['id'] as String,
      startVertexId: json['startVertexId'] as String,
      endVertexId: json['endVertexId'] as String,
      controlPoints: (json['controlPoints'] as List<dynamic>? ?? const [])
          .map((e) => <String, double>{
                'x': ((e as Map<String, dynamic>)['x'] as num).toDouble(),
                'y': (e['y'] as num).toDouble(),
              })
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startVertexId': startVertexId,
      'endVertexId': endVertexId,
      'controlPoints': controlPoints,
    };
  }
}

/// 顶点放置（对应 `Vertex`）。
///
/// isTerminal=true 表示元件端子顶点（不可独立删除）。
/// isJunction=true 表示多导线汇合点（渲染时用较大圆点）。
@immutable
class VertexPlacement {
  const VertexPlacement({
    required this.id,
    required this.x,
    required this.y,
    this.isJunction = false,
    this.isTerminal = false,
  });

  final String id;
  final double x;
  final double y;
  final bool isJunction;
  final bool isTerminal;

  factory VertexPlacement.fromJson(Map<String, dynamic> json) {
    return VertexPlacement(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      isJunction: json['isJunction'] as bool? ?? false,
      isTerminal: json['isTerminal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'isJunction': isJunction,
      'isTerminal': isTerminal,
    };
  }
}

/// 反解 ComponentType 枚举字符串。
///
/// 未知类型抛异常，避免静默降级引入错误元件。
ComponentType parseComponentType(String raw) {
  for (final t in ComponentType.values) {
    if (t.name == raw) return t;
  }
  throw ArgumentError('Unknown ComponentType: $raw');
}
