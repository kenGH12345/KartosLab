import 'package:flutter/material.dart';

import '../model/equation.dart';

/// PhET `EquationsFeedbackNode` — face + Balanced / Simplified | Not simplified.
class EquationsFeedbackNode extends StatelessWidget {
  const EquationsFeedbackNode({super.key, required this.equation});

  final Equation equation;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: equation,
      builder: (context, _) {
        if (!equation.isBalanced) {
          return const SizedBox.shrink();
        }
        final simplified = equation.isSimplified;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(70, 70),
              painter: _FacePainter(smile: true),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StatusRow(
                  ok: true,
                  label: 'Balanced',
                ),
                const SizedBox(height: 8),
                if (simplified)
                  const _StatusRow(ok: true, label: 'Simplified')
                else
                  const _StatusRow(ok: false, label: 'Not simplified'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.ok, required this.label});
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(18, 18),
          painter: ok ? _CheckPainter() : _TimesPainter(),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontFamily: 'Arial', fontSize: 18),
        ),
      ],
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.smile});
  final bool smile;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(c.dx - r * 0.35, c.dy - r * 0.15),
      3,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(c.dx + r * 0.35, c.dy - r * 0.15),
      3,
      Paint()..color = Colors.black,
    );
    final mouth = Path();
    if (smile) {
      mouth.addArc(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.1),
          width: r,
          height: r * 0.7,
        ),
        0.2,
        2.7,
      );
    } else {
      mouth.addArc(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.45),
          width: r,
          height: r * 0.7,
        ),
        3.5,
        2.5,
      );
    }
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.smile != smile;
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.55)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.85, size.height * 0.2);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color.fromRGBO(0, 180, 0, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE50000) // PhetColorScheme.RED_COLORBLIND approx
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
