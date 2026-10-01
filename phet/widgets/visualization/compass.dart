/// PhET Compass — a reusable compass widget + painter.
///
/// The compass rotates to align with a magnetic field direction at its
/// position. It is not tied to any specific simulation; any simulation
/// that provides a field angle can use it.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

/// Compass painter — draws the compass dial and needle.
///
/// [needleAngle] is the target field direction in radians.
/// The caller should smooth this angle before passing it in.
class CompassPainter extends CustomPainter {
  final double needleAngle;
  final double size;

  const CompassPainter({
    required this.needleAngle,
    this.size = 90,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final s = size;
    final center = Offset(s / 2, s / 2);
    final radius = s / 2 - 4;

    // ── Outer ring ──
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xff333333));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xff888888)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── Face ──
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [const Color(0xfff5f5f5), const Color(0xffcfd8dc)],
        ).createShader(Rect.fromCircle(center: center, radius: radius - 2)),
    );

    // ── Tick marks ──
    for (int i = 0; i < 16; i++) {
      final a = i * pi / 8;
      final isMajor = i % 4 == 0;
      final r1 = radius - (isMajor ? 8 : 4);
      final r2 = radius - 2;
      canvas.drawLine(
        Offset(center.dx + cos(a) * r1, center.dy + sin(a) * r1),
        Offset(center.dx + cos(a) * r2, center.dy + sin(a) * r2),
        Paint()
          ..color = isMajor ? const Color(0xff333333) : const Color(0xff888888)
          ..strokeWidth = isMajor ? 1.5 : 0.5,
      );
    }

    // ── N/E/S/W labels ──
    _drawText(canvas, 'N', Offset(center.dx, center.dy - radius + 10), 10, const Color(0xff333333));
    _drawText(canvas, 'S', Offset(center.dx, center.dy + radius - 10), 10, const Color(0xff333333));
    _drawText(canvas, 'E', Offset(center.dx + radius - 10, center.dy), 10, const Color(0xff333333));
    _drawText(canvas, 'W', Offset(center.dx - radius + 10, center.dy), 10, const Color(0xff333333));

    // ── Needle ──
    final nTip = Offset(center.dx + cos(needleAngle) * (radius - 6),
                         center.dy + sin(needleAngle) * (radius - 6));
    final sTip = Offset(center.dx - cos(needleAngle) * (radius - 6),
                         center.dy - sin(needleAngle) * (radius - 6));
    final perp = needleAngle + pi / 2;
    final w = 5.0;
    final left = Offset(center.dx + cos(perp) * w, center.dy + sin(perp) * w);
    final right = Offset(center.dx - cos(perp) * w, center.dy - sin(perp) * w);

    // Red (North) half
    canvas.drawPath(
      Path()..moveTo(nTip.dx, nTip.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = PhetThemeData.defaultTheme.compassNeedleNorth,
    );
    // Gray (South) half
    canvas.drawPath(
      Path()..moveTo(sTip.dx, sTip.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = PhetThemeData.defaultTheme.compassNeedleSouth,
    );
    // Outline
    canvas.drawPath(
      Path()..moveTo(nTip.dx, nTip.dy)..lineTo(left.dx, left.dy)..lineTo(sTip.dx, sTip.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.black38..style = PaintingStyle.stroke..strokeWidth = 0.5,
    );

    // ── Center pivot ──
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xff333333));
    canvas.drawCircle(center, 1.5, Paint()..color = const Color(0xffaaaaaa));
  }

  void _drawText(Canvas canvas, String text, Offset pos, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(CompassPainter old) => old.needleAngle != needleAngle;
}

/// A draggable compass widget.
class PhetCompass extends StatefulWidget {
  final Offset initialPosition;
  final double needleAngle;
  final ValueChanged<Offset>? onPositionChanged;
  final double size;

  const PhetCompass({
    super.key,
    this.initialPosition = const Offset(200, 300),
    required this.needleAngle,
    this.onPositionChanged,
    this.size = 90,
  });

  @override
  State<PhetCompass> createState() => _PhetCompassState();
}

class _PhetCompassState extends State<PhetCompass> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx - widget.size / 2,
      top: _position.dy - widget.size / 2,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() => _position += d.delta);
          widget.onPositionChanged?.call(_position);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: CompassPainter(needleAngle: widget.needleAngle, size: widget.size),
          ),
        ),
      ),
    );
  }
}
