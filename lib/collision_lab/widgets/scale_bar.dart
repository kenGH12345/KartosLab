import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';

/// PlayAreaScaleBarNode — fixed 0.5 m scale bar (all screens).
///
/// Orientation: HORIZONTAL for 1D, VERTICAL for 2D.
/// Length is model meters mapped via MVT (`modelToViewDeltaX`).
/// No zoom coupling — constant length from CollisionLabScreenView.
class ScaleBar extends StatelessWidget {
  const ScaleBar({
    super.key,
    required this.lengthMeters,
    required this.orientation,
    required this.viewLength,
  });

  final double lengthMeters;
  final Axis orientation;
  final double viewLength;

  @override
  Widget build(BuildContext context) {
    final label = '${lengthMeters.toStringAsFixed(1)} m';
    final bar = CustomPaint(
      size: orientation == Axis.horizontal
          ? Size(viewLength.clamp(20, 400), 16)
          : Size(16, viewLength.clamp(20, 400)),
      painter: _ScaleBarPainter(orientation: orientation),
    );

    if (orientation == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          bar,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        bar,
      ],
    );
  }
}

class _ScaleBarPainter extends CustomPainter {
  _ScaleBarPainter({required this.orientation});
  final Axis orientation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CollisionLabColors.scaleBar
      ..strokeWidth = 2.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    const side = 8.0;
    if (orientation == Axis.horizontal) {
      final y = size.height / 2;
      final left = 1.0;
      final right = size.width - 1;
      canvas.drawLine(Offset(left, y - side / 2), Offset(left, y + side / 2), paint);
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
      canvas.drawLine(
          Offset(right, y - side / 2), Offset(right, y + side / 2), paint);
      _head(canvas, Offset(left, y), true, paint);
      _head(canvas, Offset(right, y), false, paint);
    } else {
      final x = size.width / 2;
      final top = 1.0;
      final bottom = size.height - 1;
      canvas.drawLine(Offset(x - side / 2, top), Offset(x + side / 2, top), paint);
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
      canvas.drawLine(
          Offset(x - side / 2, bottom), Offset(x + side / 2, bottom), paint);
      _vHead(canvas, Offset(x, top), true, paint);
      _vHead(canvas, Offset(x, bottom), false, paint);
    }
  }

  void _head(Canvas canvas, Offset tip, bool pointingLeft, Paint paint) {
    const h = 7.0;
    const w = 3.75;
    final s = pointingLeft ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + s * h, tip.dy - w)
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + s * h, tip.dy + w);
    canvas.drawPath(path, paint);
  }

  void _vHead(Canvas canvas, Offset tip, bool pointingUp, Paint paint) {
    const h = 7.0;
    const w = 3.75;
    final s = pointingUp ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - w, tip.dy + s * h)
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + w, tip.dy + s * h);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScaleBarPainter oldDelegate) =>
      oldDelegate.orientation != orientation;
}
