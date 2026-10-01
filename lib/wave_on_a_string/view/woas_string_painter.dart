import 'package:flutter/material.dart';

import '../model/woas_model.dart';
import '../woas_constants.dart';
import 'woas_layout.dart';

/// Paints string polyline + 61 beads from model display Y values.
///
/// **No wave physics** — only geometry from [beadModelY].
class WoasStringPainter extends CustomPainter {
  WoasStringPainter({
    required this.beadModelY,
    required this.repaintListenable,
  }) : super(repaint: repaintListenable);

  /// Model-unit Y for each bead index (length 61).
  ///
  /// Source `StringNode`: index 0 uses `nextLeftY`; others use `yDraw[i]`.
  final List<double> Function() beadModelY;

  final Listenable repaintListenable;

  @override
  void paint(Canvas canvas, Size size) {
    final ys = beadModelY();
    assert(ys.length == numberOfBeads);

    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < numberOfBeads; i++) {
      final p = Offset(beadViewX(i), modelToViewY(ys[i]));
      points.add(p);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    final stringPaint = Paint()
      ..color = const Color(woasStringArgb)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(path, stringPaint);

    final r = beadViewRadius;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final highlight = Paint()..color = Colors.white;

    for (var i = 0; i < numberOfBeads; i++) {
      final isRef = i % 10 == 0;
      final radius = i == 0 ? r * 1.2 : r;
      final fill = Paint()
        ..color = Color(isRef ? woasReferenceBeadArgb : woasRegularBeadArgb);
      final c = points[i];
      canvas.drawCircle(c, radius, fill);
      canvas.drawCircle(c, radius, stroke);
      // Soft highlight (source Circle highlight child).
      canvas.drawCircle(
        c.translate(-0.45 * radius, -0.45 * radius),
        radius * 0.3,
        highlight,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WoasStringPainter oldDelegate) => true;
}

/// Helper: source-compatible bead Y list for painting.
List<double> woasBeadDisplayYs(WoasModel model) {
  final ys = List<double>.filled(numberOfBeads, 0);
  ys[0] = model.nextLeftY; // StringNode uses nextLeftY for bead 0
  for (var i = 1; i < numberOfBeads; i++) {
    ys[i] = model.yDrawAt(i);
  }
  return ys;
}
