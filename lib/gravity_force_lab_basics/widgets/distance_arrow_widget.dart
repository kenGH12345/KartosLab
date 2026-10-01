import 'package:flutter/material.dart';

import '../gflb_colors.dart';
import '../gflb_constants.dart';
import '../render/gflb_render_data.dart';

/// Double-headed distance arrow between mass centers.
class DistanceArrowWidget extends StatelessWidget {
  const DistanceArrowWidget({super.key, required this.render});

  final GflbRenderData render;

  @override
  Widget build(BuildContext context) {
    if (!render.showDistance) return const SizedBox.shrink();
    return CustomPaint(
      size: render.layoutSize,
      painter: _DistancePainter(render: render),
    );
  }
}

class _DistancePainter extends CustomPainter {
  _DistancePainter({required this.render});

  final GflbRenderData render;

  @override
  void paint(Canvas canvas, Size size) {
    final y = GflbConstants.distanceArrowY;
    final x1 = render.mass1Center.dx;
    final x2 = render.mass2Center.dx;
    final paint = Paint()
      ..color = GflbColors.distanceArrow
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);

    _head(canvas, Offset(x1, y), pointingRight: x2 > x1);
    _head(canvas, Offset(x2, y), pointingRight: x1 > x2);

    final tp = TextPainter(
      text: TextSpan(
        text: render.distanceKmLabel,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final cx = (x1 + x2) / 2;
    tp.paint(canvas, Offset(cx - tp.width / 2, y - 14));
  }

  void _head(Canvas canvas, Offset tip, {required bool pointingRight}) {
    const hw = 8.0;
    const hh = 8.0;
    final dir = pointingRight ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir * hh, tip.dy - hw / 2)
      ..lineTo(tip.dx - dir * hh, tip.dy + hw / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = GflbColors.distanceArrow);
  }

  @override
  bool shouldRepaint(covariant _DistancePainter oldDelegate) =>
      oldDelegate.render != render;
}
