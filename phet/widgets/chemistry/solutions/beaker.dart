/// PhET Beaker — a glass container for liquids/solutions.
library;

import 'package:flutter/material.dart';
import 'solution.dart';

class Beaker {
  Offset position;
  double width;
  double height;
  double liquidLevel; // 0-1
  Solution? solution;

  Beaker({
    this.position = Offset.zero,
    this.width = 120,
    this.height = 160,
    this.liquidLevel = 0.5,
    this.solution,
  });

  void draw(Canvas canvas) {
    final left = position.dx - width / 2;
    final top = position.dy - height / 2;
    final right = position.dx + width / 2;
    final bottom = position.dy + height / 2;

    // Liquid
    if (liquidLevel > 0 && solution != null) {
      final liquidH = height * liquidLevel;
      final liquidTop = bottom - liquidH;
      // Liquid body
      canvas.drawRect(
        Rect.fromLTWH(left + 2, liquidTop, width - 4, liquidH),
        Paint()..color = solution!.color,
      );
      // Liquid surface line
      canvas.drawLine(
        Offset(left + 2, liquidTop),
        Offset(right - 2, liquidTop),
        Paint()..color = solution!.color.withValues(alpha: 0.6)..strokeWidth = 2,
      );
    }

    // Glass walls
    final glassPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left wall
    canvas.drawLine(Offset(left, top), Offset(left, bottom), glassPaint);
    // Right wall
    canvas.drawLine(Offset(right, top), Offset(right, bottom), glassPaint);
    // Bottom
    canvas.drawLine(Offset(left - 4, bottom), Offset(right + 4, bottom), glassPaint);

    // Spout (left top)
    canvas.drawLine(
      Offset(left, top),
      Offset(left - 8, top - 5),
      glassPaint,
    );

    // Volume marks
    for (int i = 1; i <= 4; i++) {
      final y = bottom - height * i / 5;
      canvas.drawLine(
        Offset(left, y),
        Offset(left + 8, y),
        Paint()..color = Colors.white38..strokeWidth = 1,
      );
    }
  }
}
