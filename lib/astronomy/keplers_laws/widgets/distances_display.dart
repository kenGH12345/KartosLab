import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../keplers_laws_strings.dart';
import '../render/keplers_mvt.dart';

/// Top-center d1/d2 (or R) and a dimension arrows.
///
/// [已确认] DistancesDisplayNode.ts visible when stringVisible && allowedOrbit
class DistancesDisplay extends StatelessWidget {
  const DistancesDisplay({
    super.key,
    required this.controller,
    required this.mvt,
  });

  final KeplersLawsController controller;
  final KeplersMvt mvt;

  @override
  Widget build(BuildContext context) {
    final v = controller.visible;
    if (!v.stringVisible || !controller.engine.allowedOrbit) {
      return const SizedBox.shrink();
    }
    final scale = mvt.scale;
    const dx = 3.0;
    final d1 = controller.engine.d1 * scale - dx;
    final d2 = controller.engine.d2 * scale - dx;
    final a = controller.engine.a * scale - dx;
    final circular = controller.engine.isCircular;
    final d1Label = circular ? KeplersLawsStrings.symbolR : 'd1';
    final d2Label = circular ? KeplersLawsStrings.symbolR : 'd2';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pair(
          leftLen: d1.clamp(8, 400),
          rightLen: d2.clamp(8, 400),
          leftLabel: d1Label,
          rightLabel: d2Label,
          color: KeplersLawsColors.distances,
          dashed: true,
          labelAbove: true,
        ),
        if (v.semiaxesVisible) ...[
          const SizedBox(height: 10),
          _pair(
            leftLen: a.clamp(8, 400),
            rightLen: a.clamp(8, 400),
            leftLabel: KeplersLawsStrings.symbolA,
            rightLabel: KeplersLawsStrings.symbolA,
            color: KeplersLawsColors.semiMajorAxis,
            dashed: false,
            labelAbove: false,
          ),
        ],
      ],
      ),
    );
  }

  Widget _pair({
    required double leftLen,
    required double rightLen,
    required String leftLabel,
    required String rightLabel,
    required Color color,
    required bool dashed,
    required bool labelAbove,
  }) {
    return CustomPaint(
      size: Size(leftLen + rightLen, 36),
      painter: _DimPainter(
        leftLen: leftLen,
        rightLen: rightLen,
        leftLabel: leftLabel,
        rightLabel: rightLabel,
        color: color,
        dashed: dashed,
        labelAbove: labelAbove,
      ),
    );
  }
}

class _DimPainter extends CustomPainter {
  _DimPainter({
    required this.leftLen,
    required this.rightLen,
    required this.leftLabel,
    required this.rightLabel,
    required this.color,
    required this.dashed,
    required this.labelAbove,
  });

  final double leftLen;
  final double rightLen;
  final String leftLabel;
  final String rightLabel;
  final Color color;
  final bool dashed;
  final bool labelAbove;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final mid = leftLen;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    if (dashed) {
      paint.strokeCap = StrokeCap.butt;
    }
    canvas.drawLine(Offset(mid, y - 5), Offset(mid, y + 5), paint);
    canvas.drawLine(Offset(0, y), Offset(mid, y), paint);
    canvas.drawLine(Offset(mid, y), Offset(mid + rightLen, y), paint);
    _text(canvas, leftLabel, Offset(mid / 2, labelAbove ? y - 14 : y + 10));
    _text(
      canvas,
      rightLabel,
      Offset(mid + rightLen / 2, labelAbove ? y - 14 : y + 10),
    );
  }

  void _text(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DimPainter old) =>
      old.leftLen != leftLen ||
      old.rightLen != rightLen ||
      old.leftLabel != leftLabel ||
      old.color != color;
}
