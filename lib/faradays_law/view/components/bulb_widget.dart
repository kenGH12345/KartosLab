import 'package:flutter/material.dart';

import '../../faradays_law_assets.dart';
import '../../faradays_law_constants.dart';
import '../../model/bulb_model.dart';

/// Composite bulb — `BulbNode.js` + scenery-phet `lightBulbBase`.
class BulbWidget extends StatelessWidget {
  const BulbWidget({super.key, required this.bulb});

  final BulbModel bulb;

  @override
  Widget build(BuildContext context) {
    final center = FaradaysLawConstants.bulbPosition;
    // Source: center at BULB_POSITION then translate(BULB_X_DISPLACEMENT, 0)
    final origin = Offset(
      center.dx + FaradaysLawConstants.bulbXDisplacement,
      center.dy,
    );

    return Positioned(
      left: origin.dx - 90,
      top: origin.dy - 70,
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _BulbPainter(bulb: bulb),
        child: Align(
          alignment: const Alignment(0.55, 0),
          child: Image.asset(
            FaradaysLawAssets.lightBulbBase,
            height: FaradaysLawConstants.bulbBaseWidth,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _BulbPainter extends CustomPainter {
  _BulbPainter({required this.bulb});

  final BulbModel bulb;

  @override
  void paint(Canvas canvas, Size size) {
    // Local frame: (0,0) at left of base / right of body (source comment).
    // Widget places base near right; body extends left.
    final origin = Offset(size.width * 0.62, size.height / 2);
    canvas.translate(origin.dx, origin.dy);

    const bodyH = FaradaysLawConstants.bulbBodyHeight;
    const bulbW = FaradaysLawConstants.bulbWidth;
    const neck = FaradaysLawConstants.bulbBaseWidth * 0.85;
    final cpY = bulbW * 0.7;

    final body = Path()
      ..moveTo(0, -neck / 2)
      ..cubicTo(
        -bodyH * 0.33,
        -cpY,
        -bodyH * 0.95,
        -cpY,
        -bodyH,
        0,
      )
      ..cubicTo(
        -bodyH * 0.95,
        cpY,
        -bodyH * 0.33,
        cpY,
        0,
        neck / 2,
      );

    final bounds = body.getBounds();
    final fill = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: const [Color(0xFFEEEEEE), Color(0xFFBBCCBB)],
      ).createShader(bounds);
    canvas.drawPath(body, fill);

    // Filament supports + zig-zag
    final filamentH = bodyH * 0.6;
    final top = Offset(-filamentH, -bulbW * 0.3);
    final bottom = Offset(-filamentH, bulbW * 0.3);
    final wirePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final supports = Path()
      ..moveTo(0, -FaradaysLawConstants.bulbBaseWidth * 0.3)
      ..cubicTo(
        -filamentH * 0.3,
        -FaradaysLawConstants.bulbBaseWidth * 0.3,
        -filamentH * 0.4,
        top.dy,
        top.dx,
        top.dy,
      )
      ..moveTo(0, FaradaysLawConstants.bulbBaseWidth * 0.3)
      ..cubicTo(
        -filamentH * 0.3,
        FaradaysLawConstants.bulbBaseWidth * 0.3,
        -filamentH * 0.4,
        bottom.dy,
        bottom.dx,
        bottom.dy,
      );
    canvas.drawPath(supports, wirePaint);

    final zig = Path()..moveTo(bottom.dx, bottom.dy);
    const spans = 4;
    const span = 4.0;
    for (var i = 1; i <= spans; i++) {
      final t = i / spans;
      final x = bottom.dx + (top.dx - bottom.dx) * t;
      final y = bottom.dy + (top.dy - bottom.dy) * t;
      final side = i.isOdd ? span : -span;
      zig.lineTo(x + side, y);
    }
    zig.lineTo(top.dx, top.dy);
    canvas.drawPath(zig, wirePaint);

    // Halo
    if (bulb.haloVisible) {
      final scale = bulb.haloScale;
      final haloCenter = Offset((top.dx + bottom.dx) / 2, 0);
      canvas.save();
      canvas.translate(haloCenter.dx, haloCenter.dy);
      canvas.scale(scale);
      canvas.drawCircle(
        Offset.zero,
        5,
        Paint()..color = Colors.white.withValues(alpha: 0.46),
      );
      canvas.drawCircle(
        Offset.zero,
        3.75,
        Paint()..color = Colors.white.withValues(alpha: 0.51),
      );
      canvas.drawCircle(Offset.zero, 2, Paint()..color = Colors.white);
      canvas.restore();
    }

    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BulbPainter oldDelegate) =>
      oldDelegate.bulb.haloScale != bulb.haloScale ||
      oldDelegate.bulb.haloVisible != bulb.haloVisible;
}
