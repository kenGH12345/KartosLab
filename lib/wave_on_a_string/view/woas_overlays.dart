import 'package:flutter/material.dart';

import '../model/woas_model.dart';
import '../woas_constants.dart';
import 'woas_layout.dart';

/// Permanent dashed equilibrium line (NOT the Reference Line tool).
class WoasCenterLine extends StatelessWidget {
  const WoasCenterLine({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(woasLayoutWidth, woasLayoutHeight),
      painter: _CenterLinePainter(),
    );
  }
}

class _CenterLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = modelToViewY(0);
    final x0 = beadViewX(0);
    final x1 = beadViewX(numberOfBeads - 1);
    final paint = Paint()
      ..color = const Color(woasCenterLineArgb)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawDashed(canvas, Offset(x0, y), Offset(x1, y), paint, 8, 5);
  }

  void _drawDashed(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint,
    double dash,
    double gap,
  ) {
    final total = (b - a).distance;
    if (total <= 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * (d + dash).clamp(0, total);
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple rulers when `rulersVisible` (play-area tools; Control checkboxes = Phase 3).
class WoasRulersOverlay extends StatelessWidget {
  const WoasRulersOverlay({super.key, required this.model});

  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.rulersVisible) return const SizedBox.shrink();
    final cm = scaleFromOriginal * modelUnitsPerCm;
    return Stack(
      children: [
        Positioned(
          left: model.horizontalRulerX,
          top: model.horizontalRulerY,
          child: _RulerBar(length: 10 * cm, vertical: false),
        ),
        Positioned(
          left: model.verticalRulerX,
          top: model.verticalRulerY - 5 * cm,
          child: _RulerBar(length: 5 * cm, vertical: true),
        ),
      ],
    );
  }
}

class _RulerBar extends StatelessWidget {
  const _RulerBar({required this.length, required this.vertical});
  final double length;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vertical ? 50 : length,
      height: vertical ? length : 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6C8),
        border: Border.all(color: Colors.black54),
      ),
      alignment: Alignment.center,
      child: Text(
        vertical ? '0–5 cm' : '0–10 cm',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

/// Stopwatch tool when `stopwatch.isVisible` — uses simulation time, not wall clock.
class WoasStopwatchOverlay extends StatelessWidget {
  const WoasStopwatchOverlay({super.key, required this.model});

  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.stopwatch.isVisible) return const SizedBox.shrink();
    final t = model.stopwatch.time;
    final text =
        '${t.floor().toString().padLeft(2, '0')}.${((t % 1) * 100).floor().toString().padLeft(2, '0')}';
    return Positioned(
      left: 774,
      top: 414,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black54),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
        ),
      ),
    );
  }
}
