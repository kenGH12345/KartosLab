import 'package:flutter/material.dart';

import '../model/lattice.dart';

/// Center-line wave graph (PhET WaveAreaGraphNode simplified).
class CenterLineGraphPainter extends CustomPainter {
  CenterLineGraphPainter({required this.lattice});

  final Lattice lattice;
  final List<double> _buffer = [];

  @override
  void paint(Canvas canvas, Size size) {
    lattice.getCenterLineValues(_buffer);
    if (_buffer.isEmpty) return;

    final bg = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(4),
      ),
      bg,
    );

    final axis = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      axis,
    );

    final path = Path();
    final n = _buffer.length;
    for (var i = 0; i < n; i++) {
      final x = i / (n - 1) * size.width;
      final y = size.height / 2 - _buffer[i] / 12 * size.height / 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final stroke = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CenterLineGraphPainter oldDelegate) => true;
}
