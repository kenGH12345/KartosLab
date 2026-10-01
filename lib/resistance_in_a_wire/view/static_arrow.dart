import 'package:flutter/material.dart';

import '../resistance_in_a_wire_view_constants.dart';

/// PhET scenery-phet `ArrowNode` under the wire — static direction cue.
///
/// Does **not** animate with resistance (no current flow).
class StaticArrow extends StatelessWidget {
  const StaticArrow({super.key});

  @override
  Widget build(BuildContext context) {
    const len = ResistanceInAWireViewConstants.tailLength;
    const headH = ResistanceInAWireViewConstants.headHeight;
    const headW = ResistanceInAWireViewConstants.headWidth;
    final paintW = len + headH;
    final paintH = headW + 4;

    return CustomPaint(
      size: Size(paintW, paintH),
      painter: _ArrowPainter(),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = ResistanceInAWireViewConstants.tailLength;
    const headH = ResistanceInAWireViewConstants.headHeight;
    const headW = ResistanceInAWireViewConstants.headWidth;
    const tailW = ResistanceInAWireViewConstants.tailWidth;

    final cy = size.height / 2;
    final tipX = size.width;
    final tailX = tipX - len - headH;
    final headBaseX = tipX - headH;

    final path = Path()
      ..moveTo(tailX, cy - tailW / 2)
      ..lineTo(headBaseX, cy - tailW / 2)
      ..lineTo(headBaseX, cy - headW / 2)
      ..lineTo(tipX, cy)
      ..lineTo(headBaseX, cy + headW / 2)
      ..lineTo(headBaseX, cy + tailW / 2)
      ..lineTo(tailX, cy + tailW / 2)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = ResistanceInAWireViewConstants.white,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = ResistanceInAWireViewConstants.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
