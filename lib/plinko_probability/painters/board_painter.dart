import 'package:flutter/material.dart';

import '../plinko_colors.dart';
import '../transform/plinko_mvt.dart';

/// Wooden triangular board — `Board.js`.
class BoardPainter extends CustomPainter {
  BoardPainter({required this.mvt});

  final PlinkoMvt mvt;

  @override
  void paint(Canvas canvas, Size size) {
    final left = mvt.viewBoardLeft;
    final top = mvt.viewBoardTop;
    final w = mvt.viewBoardWidth;
    final h = mvt.viewBoardHeight;
    final cx = left + w / 2;

    final path = Path()
      ..moveTo(cx, top)
      ..lineTo(left + w, top + h)
      ..lineTo(left, top + h)
      ..close();

    final facePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Color(0xFFFBEFD0),
          Color(0xFFFADBA2),
          Color(0xFFFAE3B0),
          Color(0xFFE8CFA1),
          Color(0xFFF0D3A1),
          Color(0xFFFBEED2),
          Color(0xFFF9E2BA),
        ],
        stops: const [0.0112, 0.1742, 0.2978, 0.5393, 0.6573, 0.7809, 0.9607],
      ).createShader(Rect.fromLTWH(left, top, w, h));

    // Bottom shadow
    final shadowFill = const Color.fromRGBO(136, 136, 136, 1);
    final bottomShadow = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + 4, top + h, w + 8, 10),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      bottomShadow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shadowFill, shadowFill, PlinkoColors.background],
          stops: const [0, 0.2, 1],
        ).createShader(Rect.fromLTWH(left, top + h, w, 10)),
    );

    canvas.drawPath(path, facePaint);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.mvt.viewBoardWidth != mvt.viewBoardWidth ||
      oldDelegate.mvt.viewBoardLeft != mvt.viewBoardLeft;
}
