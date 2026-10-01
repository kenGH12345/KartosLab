import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/beaker.dart';
import '../../model/ph_scale_constants.dart';
import '../ph_scale_fonts.dart';

/// Beaker outline + tick marks — PhET `BeakerNode.ts`.
///
/// Origin at bottom-center of beaker (model identity MVT).
class BeakerPainter extends CustomPainter {
  BeakerPainter({required this.beaker});

  final Beaker beaker;

  static const double rimOffset = 20;
  static const double minorTickSpacing = 0.1; // L
  static const int minorTicksPerMajor = 5;
  static const double majorTickLength = 30;
  static const double minorTickLength = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final w = beaker.size.width;
    final h = beaker.size.height;
    final cx = beaker.position.dx;
    final bottom = beaker.position.dy;

    final outline = Path()
      ..moveTo(cx - w / 2 - rimOffset, bottom - h - rimOffset)
      ..lineTo(cx - w / 2, bottom - h)
      ..lineTo(cx - w / 2, bottom)
      ..lineTo(cx + w / 2, bottom)
      ..lineTo(cx + w / 2, bottom - h)
      ..lineTo(cx + w / 2 + rimOffset, bottom - h - rimOffset);

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(outline, stroke);

    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;

    final nTicks =
        PhScaleConstants.roundSymmetric(beaker.volume / minorTickSpacing);
    final dy = h / nTicks;
    final left = cx - w / 2;
    final right = cx + w / 2;

    final labelStyle = PhScaleFonts.beakerTick;

    for (var i = 1; i <= nTicks; i++) {
      final isMajor = i % minorTicksPerMajor == 0;
      final tickLen = isMajor ? majorTickLength : minorTickLength;
      final y = bottom - i * dy;

      canvas.drawLine(Offset(left, y), Offset(left + tickLen, y), tickPaint);
      canvas.drawLine(Offset(right, y), Offset(right - tickLen, y), tickPaint);

      if (isMajor) {
        final labelIndex = (i / minorTicksPerMajor).round() - 1;
        final labels = ['½ L', '1 L'];
        if (labelIndex >= 0 && labelIndex < labels.length) {
          final tp = TextPainter(
            text: TextSpan(text: labels[labelIndex], style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(right + 8, y - tp.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BeakerPainter oldDelegate) =>
      oldDelegate.beaker != beaker;
}

/// Solution rectangle in beaker — PhET `SolutionNode.ts`.
class SolutionPainter extends CustomPainter {
  SolutionPainter({
    required this.beaker,
    required this.volume,
    required this.color,
  });

  final Beaker beaker;
  final double volume;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var v = volume;
    if (v != 0 && v < PhScaleConstants.minSolutionVolume) {
      v = PhScaleConstants.minSolutionVolume;
    }
    if (v <= 0) return;

    final height = _linear(0, beaker.volume, 0, beaker.size.height, v);
    final left = beaker.position.dx - beaker.size.width / 2;
    final top = beaker.position.dy - height;
    final rect = Rect.fromLTWH(left, top, beaker.size.width, height);

    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = Color.lerp(color, Colors.black, 0.5)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);
  }

  static double _linear(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    if (x2 == x1) return y1;
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  @override
  bool shouldRepaint(covariant SolutionPainter oldDelegate) =>
      oldDelegate.volume != volume ||
      oldDelegate.color != color ||
      oldDelegate.beaker != beaker;
}

/// Macro pH color bar — PhET `ScaleNode.ts` (range −1…15, size 55×450 in meter).
class PhScaleBarPainter extends CustomPainter {
  PhScaleBarPainter({
    this.width = 55,
    this.height = 450,
    this.phMin = PhScaleConstants.phMin,
    this.phMax = PhScaleConstants.phMax,
  });

  final double width;
  final double height;
  final double phMin;
  final double phMax;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color.fromARGB(255, 70, 129, 206), // basic
        Colors.white,
        Color.fromARGB(255, 238, 79, 73), // acidic
      ],
    ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..shader = shader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Acidic / Basic rotated labels
    _drawRotatedLabel(
      canvas,
      'Basic',
      Offset(width / 2, height * 0.25),
      -math.pi / 2,
    );
    _drawRotatedLabel(
      canvas,
      'Acidic',
      Offset(width / 2, height * 0.75),
      -math.pi / 2,
    );

    // Ticks on left; label even values except skip styling for 7 (neutral longer)
    final rangeLen = phMax - phMin;
    for (var pH = phMin; pH <= phMax; pH++) {
      final y = height * (phMax - pH) / rangeLen;
      final isNeutral = pH == 7;
      final tickLen = isNeutral ? 40.0 : 15.0;
      canvas.drawLine(
        Offset(-tickLen, y),
        Offset(0, y),
        Paint()
          ..color = Colors.black
          ..strokeWidth = isNeutral ? 2 : 1,
      );
      if (pH % 2 == 0 || isNeutral) {
        final label = pH == pH.roundToDouble() ? '${pH.toInt()}' : '$pH';
        final style = isNeutral ? PhScaleFonts.scaleNeutral : PhScaleFonts.scaleTick;
        final tp = TextPainter(
          text: TextSpan(text: label, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(-tickLen - 5 - tp.width, y - tp.height / 2));
      }
    }
  }

  void _drawRotatedLabel(
    Canvas canvas,
    String text,
    Offset center,
    double angle,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: PhScaleFonts.scaleWord),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PhScaleBarPainter oldDelegate) => false;
}

/// Maps pH → Y on scale bar (top = max pH).
double phToScaleY(double pH, double height,
    {double phMin = PhScaleConstants.phMin,
    double phMax = PhScaleConstants.phMax}) {
  return height * (phMax - pH) / (phMax - phMin);
}
