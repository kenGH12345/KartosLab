/// 电池元件
///
/// 对应 PhET CCK 的 Battery.js
library;

import 'package:flutter/material.dart';
import 'circuit_element.dart';
import 'vertex.dart';

/// 电池元件类
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
  final bool isReversed;

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
  Battery copyWithVoltage(double v) {
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
  Battery copyWithReversed() {
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
  bool hitTest(Offset position) {
    final center = getCenter();
    final length = getLength();
    final width = 40.0;

    final rect = Rect.fromCenter(
      center: center,
      width: length,
      height: width,
    );

    return rect.contains(position);
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    final center = getCenter();

    // 绘制电池主体
    final rect = Rect.fromCenter(
      center: center,
      width: 60,
      height: 30,
    );

    canvas.drawRect(rect, paint..style = PaintingStyle.fill);

    // 绘制 + 和 - 符号
    final textPainter = TextPainter(
      text: TextSpan(
        text: isReversed ? '- +' : '+ -',
        style: const TextStyle(color: Colors.white, fontSize: 12),
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
