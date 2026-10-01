import 'package:flutter/material.dart';

import '../gfl_colors.dart';
import '../gfl_strings.dart';
import '../render/gfl_render_data.dart';

/// scenery-phet `RulerNode` equivalent for Full GFL (ISLCRulerNode).
class RulerPainter extends CustomPainter {
  RulerPainter({required this.render});

  final GflRenderData render;

  @override
  void paint(Canvas canvas, Size size) {
    final w = render.rulerWidthView;
    final h = render.rulerHeightView;
    final center = render.rulerCenterView;
    final left = center.dx - w / 2;
    final top = center.dy - h / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(2),
    );

    canvas.drawRRect(rect, Paint()..color = GflColors.rulerBackground);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    const majorLabels = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
    final major = render.majorTickSpacingView; // 50 px = 1 m
    final inset = 10.0; // RULER_INSET
    final tickOriginX = left + inset;

    for (var i = 0; i < majorLabels.length; i++) {
      final x = tickOriginX + i * major;
      if (x > left + w - inset + 0.5) break;
      // Major tick
      canvas.drawLine(
        Offset(x, top + h),
        Offset(x, top + h * 0.35),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5,
      );
      // PhET RulerNode: major label; unit string follows first label ("0 meters").
      final labelText = i == 0
          ? '${majorLabels[i]} ${GflStrings.rulerUnit}'
          : majorLabels[i];
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            fontSize: i == 0 ? 10 : 12,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // "0 meters" sits to the right of tick 0 (unitsSpacing ≈ 3).
      final labelX = i == 0 ? x + 3 : x - tp.width / 2;
      tp.paint(canvas, Offset(labelX, top + 2));

      if (i < majorLabels.length - 1) {
        for (var m = 1; m <= 4; m++) {
          final mx = x + m * (major / 5);
          // Medium tick at half-major (m==2 → 0.4… use m==2.5 no; half is m=2.5)
          // 4 minors → 0.2,0.4,0.6,0.8; half-height for mid ones.
          final minorH = (m == 2 || m == 3) ? 0.55 : 0.7;
          canvas.drawLine(
            Offset(mx, top + h),
            Offset(mx, top + h * minorH),
            Paint()
              ..color = Colors.black87
              ..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) =>
      oldDelegate.render.rulerCenterView != render.rulerCenterView ||
      oldDelegate.render.rulerWidthView != render.rulerWidthView;
}
