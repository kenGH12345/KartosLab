/// PhET Wire — a connecting wire between circuit elements.
library;

import 'package:flutter/material.dart';

class Wire {
  Offset start;
  Offset end;
  double thickness;
  Color color;

  Wire({
    required this.start,
    required this.end,
    this.thickness = 4,
    this.color = const Color(0xffb0bec5),
  });

  void draw(Canvas canvas) {
    canvas.drawLine(start, end, Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round);
  }
}
