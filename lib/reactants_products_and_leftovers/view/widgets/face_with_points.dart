import 'package:flutter/material.dart';

/// Face + points feedback — `FaceWithPointsNode` subset.
class FaceWithPoints extends StatelessWidget {
  const FaceWithPoints({
    super.key,
    required this.visible,
    required this.smile,
    required this.points,
    this.diameter = 120,
  });

  final bool visible;
  final bool smile;
  final int points;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        width: diameter + 40,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(diameter, diameter),
              painter: _FacePainter(smile: smile),
            ),
            if (points > 0)
              Positioned(
                right: 0,
                child: Text(
                  '+$points',
                  style: const TextStyle(
                    color: Color(0xFFFFFF00),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                    shadows: [
                      Shadow(color: Color(0xFF323232), blurRadius: 2),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.smile});
  final bool smile;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFFFFD700);
    final stroke = Paint()
      ..color = const Color(0xFF323232)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    canvas.drawCircle(c, r, fill);
    canvas.drawCircle(c, r, stroke);

    final eyePaint = Paint()..color = const Color(0xFF323232);
    canvas.drawCircle(Offset(c.dx - r * 0.35, c.dy - r * 0.2), r * 0.08, eyePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.35, c.dy - r * 0.2), r * 0.08, eyePaint);

    final mouth = Path();
    if (smile) {
      mouth.addArc(
        Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.05), width: r * 1.0, height: r * 0.8),
        0.2,
        2.7,
      );
    } else {
      mouth.addArc(
        Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.55), width: r * 1.0, height: r * 0.8),
        3.5,
        2.5,
      );
    }
    canvas.drawPath(mouth, stroke);
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.smile != smile;
}
