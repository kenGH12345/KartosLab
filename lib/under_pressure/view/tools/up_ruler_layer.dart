import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';

/// Source: `UnderPressureRuler.js` — vertical ruler, view-space position.
class UpRulerLayer extends StatelessWidget {
  const UpRulerLayer({super.key, required this.controller});

  final UnderPressureController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    if (!m.isRulerVisible) return const SizedBox.shrink();

    final english = m.measureUnits == MeasureUnits.english;
    final majorM = english ? UnderPressureUnits.feetToMeters(1) : 1.0;
    final majors = english ? 10 : 5;
    final heightPx = controller.mvt.modelToViewDeltaX(majorM * majors).abs();
    const widthPx = 50.0;
    final pos = m.rulerPosition;

    return Positioned(
      left: pos.dx - widthPx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          controller.setRulerPosition(
            Offset(
              (pos.dx + d.delta.dx).clamp(0, UpMvt.layoutWidth),
              (pos.dy + d.delta.dy).clamp(0, UpMvt.layoutHeight - heightPx),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: widthPx,
              height: 20,
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => controller.setRulerVisible(false),
                  child: const Icon(Icons.close, size: 14),
                ),
              ),
            ),
            CustomPaint(
              size: Size(widthPx, heightPx),
              painter: _RulerPainter(
                majors: majors,
                unit: english ? 'ft' : 'm',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({required this.majors, required this.unit});

  final int majors;
  final String unit;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF5DEB3),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke,
    );
    final majorH = size.height / majors;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= majors; i++) {
      final y = i * majorH;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.45, y),
        Paint()..strokeWidth = 1.5,
      );
      tp.text = TextSpan(
        text: '$i',
        style: const TextStyle(fontSize: 10, color: Colors.black),
      );
      tp.layout();
      tp.paint(canvas, Offset(size.width * 0.5, y - tp.height / 2));
    }
    tp.text = TextSpan(
      text: unit,
      style: const TextStyle(fontSize: 10, color: Colors.black),
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width * 0.55, majorH * 0.3));
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) =>
      old.majors != majors || old.unit != unit;
}
