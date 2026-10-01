import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Shared PhET-style graph chrome: white L-axes with arrowheads, labels, σ-style
/// double arrows. Used by LJ potential + Phase Diagram.
class SomGraphAxes {
  SomGraphAxes._();

  static const Color axis = Color(0xFFE6E6E6);
  static const Color grid = Color(0xFFA7A7A7);

  /// L-shaped axes: horizontal → right, vertical → up, both with arrowheads.
  static void drawLAxes(
    Canvas canvas, {
    required Offset origin,
    required double right,
    required double top,
    Color color = axis,
    double stroke = 2,
    double head = 7,
  }) {
    drawArrow(canvas, origin, Offset(right, origin.dy),
        color: color, stroke: stroke, head: head);
    drawArrow(canvas, origin, Offset(origin.dx, top),
        color: color, stroke: stroke, head: head);
  }

  static void drawArrow(
    Canvas canvas,
    Offset from,
    Offset to, {
    Color color = axis,
    double stroke = 2,
    double head = 7,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final tip = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - head * math.cos(angle - 0.4),
        to.dy - head * math.sin(angle - 0.4),
      )
      ..lineTo(
        to.dx - head * math.cos(angle + 0.4),
        to.dy - head * math.sin(angle + 0.4),
      )
      ..close();
    canvas.drawPath(tip, Paint()..color = color);
  }

  static void drawDoubleHeadArrow(
    Canvas canvas,
    Offset a,
    Offset b, {
    Color color = axis,
    double head = 6,
    double tail = 2.2,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = tail
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(a, b, paint);
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    void headAt(Offset tip, double dir) {
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - head * math.cos(dir - 0.45),
          tip.dy - head * math.sin(dir - 0.45),
        )
        ..lineTo(
          tip.dx - head * math.cos(dir + 0.45),
          tip.dy - head * math.sin(dir + 0.45),
        )
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    headAt(b, angle);
    headAt(a, angle + math.pi);
  }

  static void drawBottomLabel(
    Canvas canvas,
    String text, {
    required double plotCenterX,
    required double y,
    double fontSize = 11,
    Color color = axis,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(plotCenterX - tp.width / 2, y - tp.height));
  }

  static void drawLeftLabel(
    Canvas canvas,
    String text, {
    required double x,
    required double plotCenterY,
    double fontSize = 11,
    Color color = axis,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(x, plotCenterY + tp.width / 2);
    canvas.rotate(-math.pi / 2);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
