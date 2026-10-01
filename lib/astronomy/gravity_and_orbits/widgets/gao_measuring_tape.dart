/// Measuring tape for To Scale — endpoints from scene ModeConfig.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../render/gao_mvt.dart';

class GaoMeasuringTape extends StatefulWidget {
  const GaoMeasuringTape({
    super.key,
    required this.controller,
    required this.mvt,
  });

  final GaoController controller;
  final GaoMvt mvt;

  @override
  State<GaoMeasuringTape> createState() => _GaoMeasuringTapeState();
}

class _GaoMeasuringTapeState extends State<GaoMeasuringTape> {
  bool _dragStart = false;
  bool _dragEnd = false;

  @override
  Widget build(BuildContext context) {
    final scene = widget.controller.model.scene;
    if (scene.measuringTapeStart == null || scene.measuringTapeEnd == null) {
      return const SizedBox.shrink();
    }
    final a = widget.mvt.modelToView(scene.measuringTapeStart!);
    final b = widget.mvt.modelToView(scene.measuringTapeEnd!);
    final distM = (scene.measuringTapeEnd! - scene.measuringTapeStart!).magnitude;
    final km = distM / 1000.0;
    final label = km >= 1000
        ? '${(km / 1000).toStringAsFixed(0)} × 10⁶ km'
        : '${km.toStringAsFixed(0)} km';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _TapeLinePainter(a: a, b: b),
        ),
        Positioned(
          left: (a.dx + b.dx) / 2 - 40,
          top: (a.dy + b.dy) / 2 - 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: const Color(0xCCFFFFFF),
            child: Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ),
        _handle(a, isStart: true),
        _handle(b, isStart: false),
      ],
    );
  }

  Widget _handle(Offset p, {required bool isStart}) {
    const s = 24.0;
    return Positioned(
      left: p.dx - s / 2,
      top: p.dy - s / 2,
      width: s,
      height: s,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            if (isStart) {
              _dragStart = true;
            } else {
              _dragEnd = true;
            }
          });
        },
        onPanUpdate: (d) {
          final scene = widget.controller.model.scene;
          final cur = isStart
              ? widget.mvt.modelToView(scene.measuringTapeStart!)
              : widget.mvt.modelToView(scene.measuringTapeEnd!);
          final next = widget.mvt.viewToModel(cur + d.delta);
          if (isStart) {
            scene.measuringTapeStart!.setFrom(next);
          } else {
            scene.measuringTapeEnd!.setFrom(next);
          }
          widget.controller.touch();
        },
        onPanEnd: (_) {
          setState(() {
            _dragStart = false;
            _dragEnd = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: (_dragStart && isStart) || (_dragEnd && !isStart)
                ? Colors.orange
                : const Color(0xFFFFCC00),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

class _TapeLinePainter extends CustomPainter {
  _TapeLinePainter({required this.a, required this.b});

  final Offset a;
  final Offset b;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFCC00)
      ..strokeWidth = 2;
    canvas.drawLine(a, b, paint);
    // tick marks
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final ux = dx / len;
    final uy = dy / len;
    final nx = -uy;
    final ny = ux;
    for (var t = 0.0; t <= 1.0; t += 0.1) {
      final px = a.dx + dx * t;
      final py = a.dy + dy * t;
      canvas.drawLine(
        Offset(px - nx * 4, py - ny * 4),
        Offset(px + nx * 4, py + ny * 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TapeLinePainter old) =>
      old.a != a || old.b != b;
}
