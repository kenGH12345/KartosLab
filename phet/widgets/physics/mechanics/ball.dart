/// PhET Ball — a circular physics object.
library;

import 'package:flutter/material.dart';
import '../physics_object.dart';

class Ball extends PhysicsObject {
  double radius;
  Color color;

  Ball({
    required this.radius,
    this.color = const Color(0xffef5350),
    super.position,
    super.velocity,
    super.mass,
    super.charge,
  });

  void draw(Canvas canvas) {
    // Shadow
    canvas.drawCircle(position + const Offset(2, 3), radius,
        Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Body
    canvas.drawCircle(position, radius,
        Paint()..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [color.withValues(alpha: 0.9), color, color.withValues(alpha: 0.6)],
        ).createShader(Rect.fromCircle(center: position, radius: radius)));
    // Highlight
    canvas.drawCircle(
      Offset(position.dx - radius * 0.35, position.dy - radius * 0.35),
      radius * 0.25,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }
}

class Block extends PhysicsObject {
  double width;
  double height;
  Color color;

  Block({
    required this.width,
    required this.height,
    this.color = const Color(0xff8d6e63),
    super.position,
    super.velocity,
    super.mass,
    super.charge,
  });

  void draw(Canvas canvas) {
    final rect = Rect.fromCenter(center: position, width: width, height: height);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(rect, Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }
}
