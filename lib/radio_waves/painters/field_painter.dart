import 'package:flutter/material.dart';
import '../model/radio_state.dart';

/// Paints the radio-waves EMF field: antenna, oscillating electron,
/// field arrows along X-axis, and connecting curve.
class FieldPainter extends CustomPainter {
  final RadioState state;

  FieldPainter(this.state);

  static const _curveColor = Color(0xFFDC2626);
  static const _arrowColor = Color(0xFF22C55E);
  static const _antennaColor = Color(0xFF1E293B);
  static const _electronColor = Color(0xFF3B82F6);

  @override
  void paint(Canvas canvas, Size size) {
    final ax = state.antennaX;
    final ay = state.antennaY;
    final halfLen = state.antennaHalfLength;

    // Antenna pole
    final polePaint = Paint()
      ..color = _antennaColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(ax, ay - halfLen),
      Offset(ax, ay + halfLen),
      polePaint,
    );

    // Electron (oscillating)
    final ex = ax;
    final ey = ay + state.electronY;
    final elecFill = Paint()..color = _electronColor..style = PaintingStyle.fill;
    final elecBorder = Paint()..color = const Color(0xFF1E40AF)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(Offset(ex, ey), 8, elecFill);
    canvas.drawCircle(Offset(ex, ey), 8, elecBorder);
    canvas.drawCircle(Offset(ex, ey), 3, Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Field arrows along X axis
    final fieldValues = state.fieldValues;
    final spacing = state.fieldSampleSpacing;
    final arrowPaint = Paint()
      ..color = _arrowColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final arrowTips = <Offset>[];
    final arrowStartX = ax + 30;

    for (int i = 0; i < fieldValues.length; i++) {
      double val = fieldValues[i];
      double x = arrowStartX + spacing * i;
      double baseY = ay;
      double tipY = baseY - val * 800; // scale field to visible range

      if (state.showArrows) {
        // Arrow line
        canvas.drawLine(Offset(x, baseY), Offset(x, tipY), arrowPaint);
        // Arrow head (simple triangle)
        double headSize = 4;
        double dir = tipY < baseY ? -1.0 : 1.0;
        var headPath = Path()
          ..moveTo(x, tipY)
          ..lineTo(x - headSize, tipY + headSize * dir)
          ..lineTo(x + headSize, tipY + headSize * dir)
          ..close();
        canvas.drawPath(headPath, Paint()..color = _arrowColor..style = PaintingStyle.fill);
      }
      arrowTips.add(Offset(x, tipY));
    }

    // Curve through arrow tips
    if (state.showCurve && arrowTips.length >= 2) {
      final curvePath = Path()..moveTo(arrowTips.first.dx, arrowTips.first.dy);
      for (int i = 1; i < arrowTips.length; i++) {
        double midX = (arrowTips[i - 1].dx + arrowTips[i].dx) / 2;
        curvePath.cubicTo(
          midX, arrowTips[i - 1].dy,
          midX, arrowTips[i].dy,
          arrowTips[i].dx, arrowTips[i].dy,
        );
      }
      canvas.drawPath(curvePath, Paint()
        ..color = _curveColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant FieldPainter old) => true;
}