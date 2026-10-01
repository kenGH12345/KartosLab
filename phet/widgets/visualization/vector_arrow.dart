/// PhET Vector Arrow Painter — draws a single vector arrow with label.
///
/// A convenience painter wrapping [Vector].
library;

import 'package:flutter/material.dart';
import 'vector.dart';

class VectorArrowPainter extends CustomPainter {
  final Vector vector;
  const VectorArrowPainter(this.vector);

  @override
  void paint(Canvas canvas, Size size) {
    vector.draw(canvas);
  }

  @override
  bool shouldRepaint(VectorArrowPainter old) =>
      old.vector.magnitude != vector.magnitude || old.vector.direction != vector.direction;
}
