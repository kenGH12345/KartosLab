/// PhET Field Meter — a draggable meter that displays |B|, Bx, By, θ at its
/// position.
///
/// Works with any [Field] implementation.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'field.dart';

/// Painter for the field meter display.
class FieldMeterPainter extends CustomPainter {
  final double magnitude;
  final double angleDeg;
  final double bx;
  final double by;

  const FieldMeterPainter({
    required this.magnitude,
    required this.angleDeg,
    required this.bx,
    required this.by,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      Paint()..color = const Color(0xff0d2255).withValues(alpha: 0.95),
    );
    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      Paint()..color = Colors.lightBlueAccent..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Text
    _text(canvas, 'B = ${magnitude.toStringAsFixed(3)} T', const Offset(10, 10), 13, Colors.white, true);
    _text(canvas, 'θ = ${angleDeg.toStringAsFixed(1)}°', const Offset(10, 32), 11, Colors.white70);
    _text(canvas, 'Bx = ${bx.toStringAsFixed(3)}', const Offset(10, 54), 10, Colors.white54);
    _text(canvas, 'By = ${by.toStringAsFixed(3)}', const Offset(10, 74), 10, Colors.white54);

    // Direction arrow
    final cx = w - 35;
    final cy = h - 35;
    final arrowLen = 18.0;
    final a = angleDeg * pi / 180;
    final head = Offset(cx + cos(a) * arrowLen, cy + sin(a) * arrowLen);
    final tail = Offset(cx - cos(a) * arrowLen, cy - sin(a) * arrowLen);
    canvas.drawLine(tail, head, Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);
    // Arrowhead
    final ah = 5.0;
    canvas.drawPath(
      Path()
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx - cos(a - 0.4) * ah, head.dy - sin(a - 0.4) * ah)
        ..lineTo(head.dx - cos(a + 0.4) * ah, head.dy - sin(a + 0.4) * ah)
        ..close(),
      Paint()..color = Colors.lightBlueAccent,
    );
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
  }

  void _text(Canvas c, String s, Offset pos, double fs, Color color, [bool bold = false]) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: fs, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos);
  }

  @override
  bool shouldRepaint(FieldMeterPainter old) =>
      old.magnitude != magnitude || old.angleDeg != angleDeg;
}

/// A draggable field meter widget.
class PhetFieldMeter extends StatefulWidget {
  final Field field;
  final Offset initialPosition;

  const PhetFieldMeter({
    super.key,
    required this.field,
    this.initialPosition = const Offset(200, 200),
  });

  @override
  State<PhetFieldMeter> createState() => _PhetFieldMeterState();
}

class _PhetFieldMeterState extends State<PhetFieldMeter> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.field.valueAt(_position);
    final mag = b.magnitude;
    final angleDeg = b.angle * 180 / pi;

    return Positioned(
      left: _position.dx - 70,
      top: _position.dy - 50,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _position += d.delta),
        child: SizedBox(
          width: 140,
          height: 100,
          child: CustomPaint(
            painter: FieldMeterPainter(
              magnitude: mag,
              angleDeg: angleDeg,
              bx: b.dx,
              by: b.dy,
            ),
          ),
        ),
      ),
    );
  }
}
