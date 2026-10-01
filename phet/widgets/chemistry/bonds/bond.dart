/// PhET Chemical Bond — represents chemical bonds between atoms.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BondType { single, double, triple, ionic }

class Bond {
  final Offset start;
  final Offset end;
  final BondType type;
  final double strokeWidth;

  Bond({
    required this.start,
    required this.end,
    this.type = BondType.single,
    this.strokeWidth = 2,
  });

  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xff424242)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case BondType.single:
        canvas.drawLine(start, end, paint);
        break;
      case BondType.double:
        final dx = end.dx - start.dx;
        final dy = end.dy - start.dy;
        final len = math.sqrt(dx * dx + dy * dy);
        if (len < 1e-9) break;
        final px = -dy / len * 3;
        final py = dx / len * 3;
        canvas.drawLine(Offset(start.dx + px, start.dy + py), Offset(end.dx + px, end.dy + py), paint);
        canvas.drawLine(Offset(start.dx - px, start.dy - py), Offset(end.dx - px, end.dy - py), paint);
        break;
      case BondType.triple:
        final dx = end.dx - start.dx;
        final dy = end.dy - start.dy;
        final len = math.sqrt(dx * dx + dy * dy);
        if (len < 1e-9) break;
        final px = -dy / len * 4;
        final py = dx / len * 4;
        canvas.drawLine(start, end, paint);
        canvas.drawLine(Offset(start.dx + px, start.dy + py), Offset(end.dx + px, end.dy + py), paint);
        canvas.drawLine(Offset(start.dx - px, start.dy - py), Offset(end.dx - px, end.dy - py), paint);
        break;
      case BondType.ionic:
        // Dashed line for ionic
        final dx = end.dx - start.dx;
        final dy = end.dy - start.dy;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < 1e-9) break;
        final dashLen = 4.0;
        final gapLen = 3.0;
        var t = 0.0;
        while (t < d) {
          final t2 = (t + dashLen).clamp(0.0, d);
          canvas.drawLine(
            Offset(start.dx + dx * t / d, start.dy + dy * t / d),
            Offset(start.dx + dx * t2 / d, start.dy + dy * t2 / d),
            paint,
          );
          t += dashLen + gapLen;
        }
        break;
    }
  }
}
