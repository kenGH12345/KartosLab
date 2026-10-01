/// PhET Bulb — a light bulb component for circuits.
library;

import 'package:flutter/material.dart';

class Bulb {
  Offset position;
  double voltage;
  double ratedVoltage;
  double size;

  Bulb({
    this.position = Offset.zero,
    this.voltage = 0,
    this.ratedVoltage = 3,
    this.size = 30,
  });

  bool get isOn => voltage.abs() > ratedVoltage * 0.3;
  double get brightness => (voltage.abs() / ratedVoltage).clamp(0, 1);

  void draw(Canvas canvas) {
    final s = size;
    // Base
    canvas.drawRect(
      Rect.fromLTWH(position.dx - s * 0.3, position.dy + s * 0.2, s * 0.6, s * 0.3),
      Paint()..color = const Color(0xff9e9e9e),
    );

    // Bulb glass
    final bulbCenter = Offset(position.dx, position.dy - s * 0.15);
    final glowRadius = s * 0.5;
    if (isOn) {
      // Glow
      canvas.drawCircle(bulbCenter, glowRadius * 2, Paint()
        ..color = Colors.yellow.withValues(alpha: brightness * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(bulbCenter, glowRadius, Paint()
        ..color = Colors.yellow.withValues(alpha: brightness * 0.3));
    }
    canvas.drawCircle(bulbCenter, glowRadius, Paint()..color = const Color(0xfffff9c4));
    canvas.drawCircle(bulbCenter, glowRadius, Paint()
      ..color = const Color(0xff8d6e63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Filament
    if (isOn) {
      final filPath = Path()
        ..moveTo(bulbCenter.dx - 4, bulbCenter.dy)
        ..lineTo(bulbCenter.dx - 2, bulbCenter.dy - 3)
        ..lineTo(bulbCenter.dx, bulbCenter.dy)
        ..lineTo(bulbCenter.dx + 2, bulbCenter.dy - 3)
        ..lineTo(bulbCenter.dx + 4, bulbCenter.dy);
      canvas.drawPath(filPath, Paint()
        ..color = Colors.orange.withValues(alpha: brightness)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke);
    }
  }
}
