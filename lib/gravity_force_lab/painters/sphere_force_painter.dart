import 'package:flutter/material.dart';

import '../gfl_colors.dart';
import '../render/gfl_render_data.dart';

/// Draws spheres, dashed stems, force arrows, and force labels.
class SphereForcePainter extends CustomPainter {
  SphereForcePainter({required this.render});

  final GflRenderData render;

  @override
  void paint(Canvas canvas, Size size) {
    _paintMass(
      canvas,
      size,
      center: render.mass1Center,
      radius: render.mass1RadiusView,
      color: render.mass1Color,
      label: render.mass1Label,
      constantRadius: render.constantRadius,
      arrowTipDx: render.arrow1TipDx,
      arrowY: render.arrow1Y,
      stemColor: GflColors.forceStem1,
      forceLabel: render.forceLabel1,
    );
    _paintMass(
      canvas,
      size,
      center: render.mass2Center,
      radius: render.mass2RadiusView,
      color: render.mass2Color,
      label: render.mass2Label,
      constantRadius: render.constantRadius,
      arrowTipDx: render.arrow2TipDx,
      arrowY: render.arrow2Y,
      stemColor: GflColors.forceStem2,
      forceLabel: render.forceLabel2,
    );
  }

  void _paintMass(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required String label,
    required bool constantRadius,
    required double arrowTipDx,
    required double arrowY,
    required Color stemColor,
    required String forceLabel,
  }) {
    // Stem = arrowColor (#66f / #f66); shaft = MassNode arrowFill (#000).
    final stemPaint = Paint()
      ..color = stemColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      Offset(center.dx, center.dy - 4),
      Offset(center.dx, arrowY),
      stemPaint,
    );

    // MassNode.updateGradient: center (-0.6r,-0.6r), brighter 0.5 → base.
    final highlight = Color.lerp(color, Colors.white, 0.5)!;
    final gradient = RadialGradient(
      center: const Alignment(-0.6, -0.6),
      radius: 1,
      colors: [highlight, color],
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius, Paint()..shader = gradient.createShader(rect));
    if (constantRadius) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Color.lerp(color, Colors.black, 0.15)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    canvas.drawCircle(center, 2, Paint()..color = Colors.black);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 50);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + radius + 1));

    _drawArrow(
      canvas,
      Offset(center.dx, arrowY),
      Offset(center.dx + arrowTipDx, arrowY),
      GflColors.forceArrowFill,
    );

    // Always draw force label (Hidden → qualitative only; Decimal/Scientific → with N).
    _paintForceLabel(canvas, size, center.dx, arrowY - 20, forceLabel);
  }

  /// Scientific: draw `10^exp` with raised exponent (scenery-phet RichText <sup>).
  /// PhET `arrowLabelFont: PhetFont(16)`, `arrowLabelFill: '#000'`.
  void _paintForceLabel(
    Canvas canvas,
    Size size,
    double centerX,
    double centerY,
    String label,
  ) {
    const base = TextStyle(
      fontSize: 16,
      color: GflColors.forceLabel,
      fontWeight: FontWeight.w500,
    );
    const supStyle = TextStyle(
      fontSize: 11,
      color: GflColors.forceLabel,
      fontWeight: FontWeight.w500,
      height: 1,
    );
    final marker = '10^';
    final i = label.indexOf(marker);
    var left = 0.0;
    var top = centerY;
    double totalWidth;
    double totalHeight;

    if (i < 0) {
      final ftp = TextPainter(
        text: TextSpan(text: label, style: base),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 320);
      totalWidth = ftp.width;
      totalHeight = ftp.height;
      left = (centerX - totalWidth / 2)
          .clamp(10.0, size.width - totalWidth - 10)
          .toDouble();
      top = centerY - totalHeight / 2;
      canvas.drawRect(
        Rect.fromLTWH(left - 2, top - 1, totalWidth + 4, totalHeight + 2),
        Paint()..color = GflColors.forceLabelBackground,
      );
      ftp.paint(canvas, Offset(left, top));
      return;
    }

    // "… × 10^exp …" → paint mantissa+10, then raised exp, then rest.
    final before = label.substring(0, i + 2); // includes "10"
    final afterCaret = label.substring(i + marker.length);
    final expEnd = afterCaret.indexOf(' ');
    final exp = expEnd < 0 ? afterCaret : afterCaret.substring(0, expEnd);
    final rest = expEnd < 0 ? '' : afterCaret.substring(expEnd);

    final beforeTp = TextPainter(
      text: TextSpan(text: before, style: base),
      textDirection: TextDirection.ltr,
    )..layout();
    final expTp = TextPainter(
      text: TextSpan(text: exp, style: supStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final restTp = TextPainter(
      text: TextSpan(text: rest, style: base),
      textDirection: TextDirection.ltr,
    )..layout();

    totalWidth = beforeTp.width + expTp.width + restTp.width;
    totalHeight = beforeTp.height;
    left = (centerX - totalWidth / 2)
        .clamp(10.0, size.width - totalWidth - 10)
        .toDouble();
    top = centerY - totalHeight / 2;
    canvas.drawRect(
      Rect.fromLTWH(left - 2, top - 1, totalWidth + 4, totalHeight + 2),
      Paint()..color = GflColors.forceLabelBackground,
    );
    beforeTp.paint(canvas, Offset(left, top));
    // Raise exponent ~45% of base cap height (RichText <sup> approx).
    expTp.paint(canvas, Offset(left + beforeTp.width, top - totalHeight * 0.28));
    restTp.paint(canvas, Offset(left + beforeTp.width + expTp.width, top));
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    // ISLCForceArrowNode defaults: tailWidth 3, headHeight/Width 10.4.
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);

    final dx = to.dx - from.dx;
    if (dx.abs() < 0.5) return;
    final dir = dx.sign;
    const headLen = 10.4;
    const headWidth = 10.4;
    final tip = to;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir * headLen, tip.dy - headWidth / 2)
      ..lineTo(tip.dx - dir * headLen, tip.dy + headWidth / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final total = (b - a).distance;
    if (total < 1) return;
    final dir = (b - a) / total;
    var drawn = 0.0;
    while (drawn < total) {
      final start = a + dir * drawn;
      final end = a + dir * (drawn + dash).clamp(0, total);
      canvas.drawLine(start, end, paint);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant SphereForcePainter oldDelegate) =>
      oldDelegate.render != render;
}
