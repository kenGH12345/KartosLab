import 'package:flutter/material.dart';

import '../../model/ph_scale_constants.dart';
import '../ph_scale_fonts.dart';
import 'graph_math.dart';

/// Logarithmic vertical scale background + ticks — PhET `LogarithmicGraphNode`.
class LogarithmicScalePainter extends CustomPainter {
  LogarithmicScalePainter({
    required this.scaleHeight,
    this.scaleWidth = 100,
  });

  final double scaleHeight;
  final double scaleWidth;

  static const double cornerRadius = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final w = scaleWidth;
    final h = scaleHeight;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(cornerRadius),
    );
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 200, 200, 200),
          Colors.white,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final minE = PhScaleConstants.logarithmicExponentMin.toInt();
    final maxE = PhScaleConstants.logarithmicExponentMax.toInt();
    final nTicks = maxE - minE + 1;
    final maxHeight = h - 2 * LogGraphMath.scaleYMargin;
    final ySpacing = maxHeight / (nTicks - 1);

    for (var i = 0; i < nTicks; i++) {
      final exponent = maxE - i;
      final y = LogGraphMath.scaleYMargin + i * ySpacing;
      final isMajor = exponent % 2 == 0;
      final tickLen = isMajor ? 15.0 : 7.0;
      final stroke = Paint()
        ..color = Colors.black
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, y), Offset(tickLen, y), stroke);
      canvas.drawLine(Offset(w, y), Offset(w - tickLen, y), stroke);

      if (isMajor) {
        final label = _pow10Label(exponent);
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: PhScaleFonts.graphLogTick,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((w - tp.width) / 2, y - tp.height / 2));
      }
    }
  }

  String _pow10Label(int exp) {
    const supers = {
      '-': '⁻',
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };
    final e = exp.toString();
    final buf = StringBuffer('10');
    for (final ch in e.split('')) {
      buf.write(supers[ch] ?? ch);
    }
    return buf.toString();
  }

  @override
  bool shouldRepaint(covariant LogarithmicScalePainter oldDelegate) =>
      oldDelegate.scaleHeight != scaleHeight ||
      oldDelegate.scaleWidth != scaleWidth;
}

/// Linear scale body (simplified arrow + column) — PhET `LinearGraphNode`.
class LinearScalePainter extends CustomPainter {
  LinearScalePainter({
    required this.scaleHeight,
    required this.exponent,
    this.scaleWidth = 100,
  });

  final double scaleHeight;
  final int exponent;
  final double scaleWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = scaleWidth;
    final arrowH = 28.0;
    final bodyTop = arrowH;
    final bodyH = scaleHeight - arrowH;

    // Off-scale arrow head
    final arrow = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, arrowH * 0.55)
      ..lineTo(w * 0.72, arrowH * 0.55)
      ..lineTo(w * 0.72, arrowH)
      ..lineTo(w * 0.28, arrowH)
      ..lineTo(w * 0.28, arrowH * 0.55)
      ..lineTo(0, arrowH * 0.55)
      ..close();
    canvas.drawPath(
      arrow,
      Paint()..color = const Color.fromARGB(255, 230, 230, 230),
    );
    canvas.drawPath(
      arrow,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, bodyTop, w, bodyH),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      body,
      Paint()..color = const Color.fromARGB(255, 230, 230, 230),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Mantissa ticks 8 → 0
    for (var m = 8; m >= 0; m--) {
      final t = m / 8.0;
      final y = bodyTop + 10 + (1 - t) * (bodyH - 20);
      canvas.drawLine(
        Offset(0, y),
        Offset(10, y),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1,
      );
      final label = m == 0
          ? '0'
          : '$m×10${_super(exponent)}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((w - tp.width) / 2, y - tp.height / 2));
    }
  }

  String _super(int exp) {
    const map = {
      '-': '⁻',
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };
    return exp.toString().split('').map((c) => map[c] ?? c).join();
  }

  @override
  bool shouldRepaint(covariant LinearScalePainter oldDelegate) =>
      oldDelegate.scaleHeight != scaleHeight ||
      oldDelegate.exponent != exponent;
}

/// Useful Y positions for linear indicators.
({double topTickY, double bottomTickY, double offScaleY}) linearTickYs(
  double scaleHeight,
) {
  const arrowH = 28.0;
  final bodyTop = arrowH;
  final bodyH = scaleHeight - arrowH;
  return (
    topTickY: bodyTop + 10,
    bottomTickY: bodyTop + bodyH - 10,
    offScaleY: arrowH * 0.55,
  );
}
