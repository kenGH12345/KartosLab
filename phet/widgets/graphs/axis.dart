/// PhET Axis — coordinate axis with ticks and labels.
library;

import 'package:flutter/material.dart';

class AxisPainter extends CustomPainter {
  final String label;
  final double min;
  final double max;
  final String unit;
  final bool horizontal;
  final int tickCount;

  const AxisPainter({
    required this.label,
    this.min = 0,
    this.max = 1,
    this.unit = '',
    this.horizontal = true,
    this.tickCount = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5;

    if (horizontal) {
      // Axis line
      canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), paint);
      // Ticks
      for (int i = 0; i <= tickCount; i++) {
        final x = size.width * i / tickCount;
        canvas.drawLine(Offset(x, size.height - 10), Offset(x, size.height), paint);
        final val = min + (max - min) * i / tickCount;
        _drawText(canvas, val.toStringAsFixed(1), Offset(x, size.height + 2), 9, Colors.white54);
      }
    } else {
      canvas.drawLine(const Offset(1, 0), Offset(1, size.height), paint);
      for (int i = 0; i <= tickCount; i++) {
        final y = size.height - size.height * i / tickCount;
        canvas.drawLine(Offset(0, y), Offset(10, y), paint);
        final val = min + (max - min) * i / tickCount;
        _drawText(canvas, val.toStringAsFixed(1), Offset(12, y - 5), 9, Colors.white54);
      }
    }

    // Label
    _drawText(canvas, label + (unit.isNotEmpty ? ' ($unit)' : ''),
        Offset(size.width / 2 - 20, size.height + 15), 10, Colors.white70);
  }

  void _drawText(Canvas c, String s, Offset pos, double fs, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: fs)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos);
  }

  @override
  bool shouldRepaint(AxisPainter old) => true;
}
