import 'package:flutter/material.dart';

/// Hose from bicycle pump to particle-container attachment (PhET).
class PumpHosePainter extends CustomPainter {
  const PumpHosePainter({
    required this.from,
    required this.to,
  });

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset(
      (from.dx + to.dx) / 2,
      from.dy - 40,
    );
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + 40,
        from.dy - 20,
        mid.dx,
        mid.dy,
        to.dx,
        to.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB3B3B3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    // Connector stub at chamber
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: to, width: 10, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF888888),
    );
  }

  @override
  bool shouldRepaint(covariant PumpHosePainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to;
}
