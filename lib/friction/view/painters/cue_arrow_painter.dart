import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Port of PhET `CueArrow` / scenery-phet `ArrowNode` (simplified).
class CueArrowPainter extends CustomPainter {
  CueArrowPainter({
    this.fill = const Color(0xFFFFD700), // HighlightPath.INNER_FOCUS_COLOR approx
    this.stroke = Colors.black,
    this.headHeight = 32,
    this.headWidth = 30,
    this.tailWidth = 15,
    this.arrowLength = 70,
    this.lineWidth = 2,
  });

  final Color fill;
  final Color stroke;
  final double headHeight;
  final double headWidth;
  final double tailWidth;
  final double arrowLength;
  final double lineWidth;

  static Size sizeFor({double arrowLength = 70, double headWidth = 30}) =>
      Size(arrowLength, headWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _arrowPath();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _arrowPath() {
    final tipX = arrowLength;
    final midY = headWidth / 2;
    final tailHalf = tailWidth / 2;
    final headBaseX = tipX - headHeight;

    return Path()
      ..moveTo(0, midY - tailHalf)
      ..lineTo(headBaseX, midY - tailHalf)
      ..lineTo(headBaseX, 0)
      ..lineTo(tipX, midY)
      ..lineTo(headBaseX, headWidth)
      ..lineTo(headBaseX, midY + tailHalf)
      ..lineTo(0, midY + tailHalf)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CueArrowPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.arrowLength != arrowLength;
}

class CueArrow extends StatelessWidget {
  const CueArrow({
    super.key,
    this.rotation = 0,
    this.scale = 1,
    this.fill = Colors.white,
    this.arrowLength = 70,
  });

  final double rotation;
  final double scale;
  final Color fill;
  final double arrowLength;

  @override
  Widget build(BuildContext context) {
    final sz = CueArrowPainter.sizeFor(arrowLength: arrowLength);
    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: scale,
        child: CustomPaint(
          size: sz,
          painter: CueArrowPainter(fill: fill, arrowLength: arrowLength),
        ),
      ),
    );
  }
}

/// Double-headed white cue used inside the magnifier.
class MagnifierHintArrows extends StatelessWidget {
  const MagnifierHintArrows({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CueArrow(rotation: math.pi, fill: Colors.white, arrowLength: 55),
        const SizedBox(width: 20),
        const CueArrow(fill: Colors.white, arrowLength: 55),
      ],
    );
  }
}
