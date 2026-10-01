import 'package:flutter/material.dart';

/// PhET `PerceivedColorNode` — 4 thought-bubble ellipses.
///
/// Stroke `#c0b9b9`, fill = [perceivedColor].
class CvThoughtBubbles extends StatelessWidget {
  const CvThoughtBubbles({
    super.key,
    required this.perceivedColor,
  });

  final Color perceivedColor;

  /// Bounding box of the Path shape in PerceivedColorNode.js.
  static const double width = 274;
  static const double height = 212;

  /// Local origin of first ellipse center within this widget.
  static const Offset origin = Offset(184, 45);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(width, height),
      painter: _ThoughtBubblesPainter(perceivedColor),
    );
  }
}

class _ThoughtBubblesPainter extends CustomPainter {
  _ThoughtBubblesPainter(this.fill);

  final Color fill;

  static const Color stroke = Color(0xFFC0B9B9);

  @override
  void paint(Canvas canvas, Size size) {
    final o = CvThoughtBubbles.origin;
    final fillPaint = Paint()..color = fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = stroke;

    void ellipse(Offset c, double rx, double ry) {
      final rect = Rect.fromCenter(
        center: o + c,
        width: rx * 2,
        height: ry * 2,
      );
      canvas.drawOval(rect, fillPaint);
      canvas.drawOval(rect, strokePaint);
    }

    // From PerceivedColorNode.js — largest → smallest.
    ellipse(Offset.zero, 90, 45);
    ellipse(const Offset(-130, 45), 30, 15);
    ellipse(const Offset(-158, 105), 24, 12);
    ellipse(const Offset(-170, 160), 14, 7);
  }

  @override
  bool shouldRepaint(covariant _ThoughtBubblesPainter oldDelegate) =>
      oldDelegate.fill != fill;
}
