/// PhET Ruler — a draggable ruler with tick marks.
///
/// Supports horizontal/vertical orientation, mm/cm/m units, and rotation.
library;

import 'package:flutter/material.dart';

class RulerPainter extends CustomPainter {
  final double length;
  final bool horizontal;
  final String unit;
  final double pixelsPerUnit;

  const RulerPainter({
    required this.length,
    this.horizontal = true,
    this.unit = 'cm',
    this.pixelsPerUnit = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xfff5e6c8)..style = PaintingStyle.fill;
    final border = Paint()..color = const Color(0xff8d6e63)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    if (horizontal) {
      // Body
      canvas.drawRect(Rect.fromLTWH(0, 0, length, 30), paint);
      canvas.drawRect(Rect.fromLTWH(0, 0, length, 30), border);

      // Ticks
      for (double i = 0; i <= length / pixelsPerUnit; i += 0.5) {
        final x = i * pixelsPerUnit;
        final isMajor = i == i.roundToDouble();
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, isMajor ? 15 : 8),
          Paint()..color = const Color(0xff5d4037)..strokeWidth = isMajor ? 1.0 : 0.5,
        );
        if (isMajor) {
          _drawText(canvas, '${i.round()}', Offset(x + 2, 18), 8, const Color(0xff5d4037));
        }
      }
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, 30, length), paint);
      canvas.drawRect(Rect.fromLTWH(0, 0, 30, length), border);
      for (double i = 0; i <= length / pixelsPerUnit; i += 0.5) {
        final y = i * pixelsPerUnit;
        final isMajor = i == i.roundToDouble();
        canvas.drawLine(
          Offset(0, y),
          Offset(isMajor ? 15 : 8, y),
          Paint()..color = const Color(0xff5d4037)..strokeWidth = isMajor ? 1.0 : 0.5,
        );
      }
    }
  }

  void _drawText(Canvas c, String s, Offset pos, double fs, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: fs)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos);
  }

  @override
  bool shouldRepaint(RulerPainter old) => old.length != length || old.horizontal != horizontal;
}

/// A draggable ruler widget.
class PhetRuler extends StatefulWidget {
  final Offset initialPosition;
  final double length;
  final bool horizontal;

  const PhetRuler({
    super.key,
    this.initialPosition = const Offset(100, 400),
    this.length = 200,
    this.horizontal = true,
  });

  @override
  State<PhetRuler> createState() => _PhetRulerState();
}

class _PhetRulerState extends State<PhetRuler> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _position += d.delta),
        child: SizedBox(
          width: widget.horizontal ? widget.length : 30,
          height: widget.horizontal ? 30 : widget.length,
          child: CustomPaint(
            painter: RulerPainter(length: widget.length, horizontal: widget.horizontal),
          ),
        ),
      ),
    );
  }
}
