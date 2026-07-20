/// 电路元件基类
///
/// 对应 PhET CCK 的 CircuitElement.js
/// 保真度目标：100% 功能匹配
///
/// 这是所有电路元件的基类，定义了电路元件的通用接口和属性。
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'vertex.dart';

/// 电路元件类型枚举
enum CircuitElementType {
  battery,
  resistor,
  lightBulb,
  switch_,
  wire,
  fuse,
  ground,
  capacitor,
  inductor,
}

/// 电路元件基类
///
/// 对应 PhET CCK 的 CircuitElement.js
abstract class CircuitElement {
  /// 唯一标识符
  final String id;

  /// 起始顶点（对应 PhET: startVertexProperty）
  final Vertex startVertex;

  /// 结束顶点（对应 PhET: endVertexProperty）
  final Vertex endVertex;

  /// 元件类型
  final CircuitElementType elementType;

  /// 电阻值 (Ω)
  /// 对应 PhET: resistanceProperty
  final double resistance;

  /// 电导值 (S = 1/R)
  double get conductance => resistance > 0 ? 1.0 / resistance : double.infinity;

  /// 是否能够通过电流
  /// 对应 PhET: canPassCurrent()
  bool get canPassCurrent => resistance < double.infinity;

  /// 是否短路（电阻 ≈ 0）
  bool get isShortCircuit => resistance < 1e-6;

  /// 元件标签（可选）
  final String? label;

  /// 是否选中（对应 PhET: selectedProperty）
  bool isSelected;

  /// 是否高亮（对应 PhET: highlightedProperty）
  bool isHighlighted;

  /// 构造器
  CircuitElement({
    required this.id,
    required this.startVertex,
    required this.endVertex,
    required this.elementType,
    this.resistance = 0.0,
    this.label,
    this.isSelected = false,
    this.isHighlighted = false,
  });

  /// 计算电流（对应 PhET: getCurrent）
  ///
  /// 参数:
  ///   voltage: 元件两端电压 (V)
  /// 返回:
  ///   电流 (A)
  double getCurrent(double voltage) {
    if (resistance < 1e-9) {
      return double.infinity; // 短路
    }
    return voltage / resistance;
  }

  /// 计算功率（对应 PhET: getPower）
  ///
  /// 参数:
  ///   current: 流经元件的电流 (A)
  /// 返回:
  ///   功率 (W)
  double getPower(double current) {
    return current * current * resistance;
  }

  /// 计算电压降（对应 PhET: getVoltageDrop）
  ///
  /// 参数:
  ///   current: 流经元件的电流 (A)
  /// 返回:
  ///   电压降 (V)
  double getVoltageDrop(double current) {
    return current * resistance;
  }

  /// 命中检测（对应 PhET: containsPoint）
  ///
  /// 参数:
  ///   position: 世界坐标位置
  /// 返回:
  ///   是否命中
  bool hitTest(Offset position);

  /// 获取元件中心位置（对应 PhET: getCenter）
  Offset getCenter() {
    return Offset(
      (startVertex.x + endVertex.x) / 2,
      (startVertex.y + endVertex.y) / 2,
    );
  }

  /// 获取元件长度（对应 PhET: getLength）
  double getLength() {
    final dx = endVertex.x - startVertex.x;
    final dy = endVertex.y - startVertex.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// 获取元件角度（对应 PhET: getAngle）
  double getAngle() {
    return atan2(
      endVertex.y - startVertex.y,
      endVertex.x - startVertex.x,
    );
  }

  /// 绘制元件（对应 PhET: CircuitElementNode.paint）
  ///
  /// 参数:
  ///   canvas: Flutter 画布
  ///   paint: 绘制参数
  void paint(Canvas canvas, Paint paint);

  /// 创建副本（对应 PhET: copy）
  CircuitElement copyWith({
    String? id,
    Vertex? startVertex,
    Vertex? endVertex,
    double? resistance,
    String? label,
    bool? isSelected,
    bool? isHighlighted,
  });
}

/// 电池元件
///
/// 对应 PhET CCK 的 Battery.js
class Battery extends CircuitElement {
  /// 电压 (V)（对应 PhET: voltageProperty）
  final double voltage;

  /// 内阻 (Ω)（对应 PhET: internalResistance）
  final double internalResistance;

  /// 是否可反转极性（对应 PhET: reversible）
  final bool isReversible;

  /// 是否反转（对应 PhET: reversedProperty）
  bool isReversed;

  Battery({
    required super.id,
    required super.startVertex,
    required super.endVertex,
    this.voltage = 10.0,
    this.internalResistance = 0.01,
    this.isReversible = true,
    this.isReversed = false,
    super.label,
    super.isSelected,
    super.isHighlighted,
  }) : super(
          elementType: CircuitElementType.battery,
          resistance: internalResistance,
        );

  /// 获取电动势（对应 PhET: getEMF）
  double get emf => isReversed ? -voltage : voltage;

  /// 设置电压（对应 PhET: setVoltage）
  Battery setVoltage(double v) {
    return Battery(
      id: id,
      startVertex: startVertex,
      endVertex: endVertex,
      voltage: v,
      internalResistance: internalResistance,
      isReversible: isReversible,
      isReversed: isReversed,
      label: label,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
    );
  }

  /// 反转极性（对应 PhET: reversePolarity）
  Battery reversePolarity() {
    if (!isReversible) return this;
    return Battery(
      id: id,
      startVertex: startVertex,
      endVertex: endVertex,
      voltage: voltage,
      internalResistance: internalResistance,
      isReversible: isReversible,
      isReversed: !isReversed,
      label: label,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
    );
  }

  @override
  double getCurrent(double voltage) {
    // 电池作为电源，电流由外部电路决定
    return super.getCurrent(voltage);
  }

  @override
  bool hitTest(Offset position) {
    // 简化的命中检测：矩形区域
    final center = getCenter();
    final length = getLength();
    final width = 40.0; // 电池宽度

    // 创建旋转矩形
    final rect = Rect.fromCenter(
      center: center,
      width: length,
      height: width,
    );

    return rect.contains(position);
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    // 绘制电池符号
    final start = Offset(startVertex.x, startVertex.y);
    final end = Offset(endVertex.x, endVertex.y);

    // 绘制导线
    canvas.drawLine(start, end, paint);

    // 绘制电池主体
    final center = getCenter();
    final rect = Rect.fromCenter(
      center: center,
      width: 60,
      height: 30,
    );

    canvas.drawRect(rect, paint..style = PaintingStyle.stroke);

    // 绘制 + 和 - 符号
    final textPainter = TextPainter(
      text: TextSpan(
        text: isReversed ? '- +' : '+ -',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  CircuitElement copyWith({
    String? id,
    Vertex? startVertex,
    Vertex? endVertex,
    double? resistance,
    String? label,
    bool? isSelected,
    bool? isHighlighted,
  }) {
    return Battery(
      id: id ?? this.id,
      startVertex: startVertex ?? this.startVertex,
      endVertex: endVertex ?? this.endVertex,
      voltage: voltage,
      internalResistance: internalResistance,
      isReversible: isReversible,
      isReversed: isReversed,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

/// 电阻元件
///
/// 对应 PhET CCK 的 Resistor.js
class Resistor extends CircuitElement {
  Resistor({
    required super.id,
    required super.startVertex,
    required super.endVertex,
    super.resistance = 10.0,
    super.label,
    super.isSelected,
    super.isHighlighted,
  }) : super(
          elementType: CircuitElementType.resistor,
        );

  @override
  bool hitTest(Offset position) {
    final center = getCenter();
    final length = getLength();
    final width = 20.0;

    final rect = Rect.fromCenter(
      center: center,
      width: length,
      height: width,
    );

    return rect.contains(position);
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    final start = Offset(startVertex.x, startVertex.y);
    final end = Offset(endVertex.x, endVertex.y);

    // 绘制锯齿形电阻符号
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final dx = (end.dx - start.dx) / 10;
    final dy = (end.dy - start.dy) / 10;

    for (int i = 0; i < 10; i++) {
      final x = start.dx + i * dx;
      final y = start.dy + i * dy;
      final offset = (i % 2 == 0) ? 10.0 : -10.0;
      path.lineTo(x + dx / 2, y + dy / 2 + offset);
      path.lineTo(x + dx, y + dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  CircuitElement copyWith({
    String? id,
    Vertex? startVertex,
    Vertex? endVertex,
    double? resistance,
    String? label,
    bool? isSelected,
    bool? isHighlighted,
  }) {
    return Resistor(
      id: id ?? this.id,
      startVertex: startVertex ?? this.startVertex,
      endVertex: endVertex ?? this.endVertex,
      resistance: resistance ?? this.resistance,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

/// 灯泡元件
///
/// 对应 PhET CCK 的 LightBulb.js
class LightBulb extends CircuitElement {
  /// 灯丝温度 (K)（对应 PhET: temperatureProperty）
  final double temperature;

  /// 最大温度 (K)（对应 PhET: maxTemperature）
  final double maxTemperature;

  /// 是否烧毁（对应 PhET: isBurnoutProperty）
  final bool isBurnout;

  LightBulb({
    required super.id,
    required super.startVertex,
    required super.endVertex,
    super.resistance = 10.0,
    this.temperature = 300.0,
    this.maxTemperature = 3000.0,
    this.isBurnout = false,
    super.label,
    super.isSelected,
    super.isHighlighted,
  }) : super(
          elementType: CircuitElementType.lightBulb,
        );

  /// 计算亮度（对应 PhET: getBrightness）
  ///
  /// 基于功率和温度计算亮度
  double getBrightness(double current) {
    if (isBurnout) return 0.0;

    // 计算功率 P = I²R
    final power = current * current * resistance;

    // 更新温度（简化热平衡模型）
    final newTemperature = 300.0 + power * 10.0; // 简化

    // 温度过高 → 烧毁
    if (newTemperature > maxTemperature) {
      return 0.0;
    }

    // 亮度 ∝ 温度^4 (Stefan-Boltzmann law)
    final brightness = pow(newTemperature / maxTemperature, 4).toDouble();
    return brightness.clamp(0.0, 1.0);
  }

  @override
  bool hitTest(Offset position) {
    final center = getCenter();
    final radius = 30.0;

    final distance = (position - center).distance;
    return distance <= radius;
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    final center = getCenter();

    // 绘制灯泡圆形
    canvas.drawCircle(
      center,
      30,
      paint..color = isBurnout ? Colors.grey : Colors.yellow,
    );

    // 绘制灯丝
    if (!isBurnout) {
      final filamentPath = Path();
      filamentPath.moveTo(center.dx - 10, center.dy);
      filamentPath.quadraticBezierTo(
        center.dx,
        center.dy - 20,
        center.dx + 10,
        center.dy,
      );
      canvas.drawPath(filamentPath, paint..color = Colors.orange);
    } else {
      // 烧毁时显示断裂
      canvas.drawLine(
        Offset(center.dx - 10, center.dy),
        Offset(center.dx + 10, center.dy),
        paint..color = Colors.red..strokeWidth = 2,
      );
    }
  }

  @override
  CircuitElement copyWith({
    String? id,
    Vertex? startVertex,
    Vertex? endVertex,
    double? resistance,
    String? label,
    bool? isSelected,
    bool? isHighlighted,
  }) {
    return LightBulb(
      id: id ?? this.id,
      startVertex: startVertex ?? this.startVertex,
      endVertex: endVertex ?? this.endVertex,
      resistance: resistance ?? this.resistance,
      temperature: temperature,
      maxTemperature: maxTemperature,
      isBurnout: isBurnout,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

/// 开关元件
///
/// 对应 PhET CCK 的 Switch.js
class Switch extends CircuitElement {
  /// 是否闭合（对应 PhET: closedProperty）
  final bool isClosed;

  /// 开路电阻 (Ω)
  final double openResistance;

  /// 闭合电阻 (Ω)
  final double closedResistance;

  Switch({
    required super.id,
    required super.startVertex,
    required super.endVertex,
    this.isClosed = false,
    this.openResistance = double.infinity,
    this.closedResistance = 0.01,
    super.label,
    super.isSelected,
    super.isHighlighted,
  }) : super(
          elementType: CircuitElementType.switch_,
          resistance: isClosed ? closedResistance : openResistance,
        );

  /// 切换开关状态（对应 PhET: toggle）
  Switch toggle() {
    return Switch(
      id: id,
      startVertex: startVertex,
      endVertex: endVertex,
      isClosed: !isClosed,
      openResistance: openResistance,
      closedResistance: closedResistance,
      label: label,
      isSelected: isSelected,
      isHighlighted: isHighlighted,
    );
  }

  @override
  bool get canPassCurrent => isClosed;

  @override
  bool hitTest(Offset position) {
    final center = getCenter();
    final length = getLength();
    final width = 20.0;

    final rect = Rect.fromCenter(
      center: center,
      width: length,
      height: width,
    );

    return rect.contains(position);
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    final start = Offset(startVertex.x, startVertex.y);
    final end = Offset(endVertex.x, endVertex.y);

    if (isClosed) {
      // 绘制闭合开关
      canvas.drawLine(start, end, paint);
    } else {
      // 绘制打开开关（45度角）
      final mid = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2 - 20,
      );
      canvas.drawLine(start, mid, paint);
      canvas.drawLine(mid, end, paint..strokeWidth = 1);
    }
  }

  @override
  CircuitElement copyWith({
    String? id,
    Vertex? startVertex,
    Vertex? endVertex,
    double? resistance,
    String? label,
    bool? isSelected,
    bool? isHighlighted,
  }) {
    return Switch(
      id: id ?? this.id,
      startVertex: startVertex ?? this.startVertex,
      endVertex: endVertex ?? this.endVertex,
      isClosed: isClosed,
      openResistance: openResistance,
      closedResistance: closedResistance,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}
