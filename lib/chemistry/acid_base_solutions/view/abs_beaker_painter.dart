import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/abs_beaker.dart';
import '../model/abs_colors.dart';

/// Procedural beaker — PhET `BeakerNode.ts`. Origin at bottom-center.
class AbsBeakerPainter extends CustomPainter {
  AbsBeakerPainter(this.beaker);

  final AbsBeaker beaker;

  static const double majorTickLength = 25;
  static const double minorTickLength = 10;
  static const int minorTicksPerMajor = 5;
  static const double minorTickSpacing = 0.1; // L
  static const double rimOffset = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final w = beaker.size.width;
    final h = beaker.size.height;
    // Local coords with origin at bottom-center of beaker.
    canvas.save();
    canvas.translate(beaker.position.dx, beaker.position.dy);

    // Liquid
    final liquid = Path()
      ..moveTo(-w / 2, -h)
      ..lineTo(-w / 2, 0)
      ..lineTo(w / 2, 0)
      ..lineTo(w / 2, -h)
      ..close();
    canvas.drawPath(
      liquid,
      Paint()..color = AbsColors.transparentSolutionColor,
    );

    // Beaker outline
    final outline = Path()
      ..moveTo(-w / 2 - rimOffset, -h - rimOffset)
      ..lineTo(-w / 2, -h)
      ..lineTo(-w / 2, 0)
      ..lineTo(w / 2, 0)
      ..lineTo(w / 2, -h)
      ..lineTo(w / 2 + rimOffset, -h - rimOffset);
    canvas.drawPath(
      outline,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Ticks
    final nTicks = (1 / minorTickSpacing).round();
    final dy = h / nTicks;
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= nTicks; i++) {
      final isMajor = i % minorTicksPerMajor == 0;
      final y = -(i * dy);
      final leftX = w / 2;
      final rightX = leftX - (isMajor ? majorTickLength : minorTickLength);
      canvas.drawLine(Offset(leftX, y), Offset(rightX, y), tickPaint);
    }

    // 1L label at top major tick
    const label = '1L';
    final tp = TextPainter(
      text: const TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelY = -dy * nTicks;
    tp.paint(
      canvas,
      Offset(w / 2 - majorTickLength - 5 - tp.width, labelY - tp.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AbsBeakerPainter oldDelegate) =>
      oldDelegate.beaker != beaker;
}

/// Small beaker icon for Hide Views radio.
class AbsBeakerIcon extends StatelessWidget {
  const AbsBeakerIcon({super.key, this.width = 20, this.height = 15});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width + 4, height + 4),
      painter: _BeakerIconPainter(width, height),
    );
  }
}

class _BeakerIconPainter extends CustomPainter {
  _BeakerIconPainter(this.w, this.h);

  final double w;
  final double h;

  @override
  void paint(Canvas canvas, Size size) {
    final lip = 0.1 * w;
    canvas.drawRect(
      Rect.fromLTWH(2, 2, w, h),
      Paint()..color = AbsColors.opaqueSolutionColor,
    );
    final path = Path()
      ..moveTo(2 - lip, 2 - lip)
      ..lineTo(2, 2)
      ..lineTo(2, 2 + h)
      ..lineTo(2 + w, 2 + h)
      ..lineTo(2 + w, 2)
      ..lineTo(2 + w + lip, 2 - lip);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BeakerIconPainter oldDelegate) => false;
}

/// Lens radius helper matching ParticlesNode.
double absLensRadius(AbsBeaker beaker) => 0.465 * beaker.size.height;

Offset absLensCenter(AbsBeaker beaker) =>
    beaker.position + Offset(0, -beaker.size.height / 2);

double absLensHandleExtent(AbsBeaker beaker) {
  final r = absLensRadius(beaker);
  // handle extends ~ lensRadius * 0.9 at angle π/6
  return r + 2 + r * 0.9 * math.cos(math.pi / 6);
}
