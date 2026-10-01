import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bce_constants.dart';
import '../model/atom_count.dart';
import '../model/bce_element.dart';
import '../model/equation.dart';

/// PhET `BalanceScalesNode` — one scale per element, vertical stack.
class BalanceScalesNode extends StatelessWidget {
  const BalanceScalesNode({super.key, required this.equation});

  final Equation equation;

  static const yOffset = 120.0;
  static const nodeScale = 0.85;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: equation,
      builder: (context, _) {
        final counts = equation.getAtomCounts();
        if (counts.isEmpty) return const SizedBox.shrink();
        return Transform.scale(
          scale: nodeScale,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < counts.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _BalanceScale(atomCount: counts[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BalanceScale extends StatelessWidget {
  const _BalanceScale({required this.atomCount});
  final AtomCount atomCount;

  static const fulcrumW = 60.0;
  static const fulcrumH = 45.0;
  static const beamLength = 205.0;
  static const beamThickness = 6.0;
  static const tiltSteps = 6;

  @override
  Widget build(BuildContext context) {
    final left = atomCount.reactantsCount;
    final right = atomCount.productsCount;
    final balanced = atomCount.isElementBalanced;
    final maxAngle =
        (math.pi / 2) - math.acos(fulcrumH / (beamLength / 2));
    final difference = right - left;
    double angle;
    if (difference.abs() >= tiltSteps) {
      angle = difference.sign * maxAngle;
    } else {
      angle = difference * (maxAngle / tiltSteps);
    }

    return SizedBox(
      width: beamLength + 40,
      height: 110,
      child: CustomPaint(
        painter: _ScalePainter(
          element: atomCount.element,
          leftCount: left,
          rightCount: right,
          angle: angle,
          highlighted: balanced,
        ),
      ),
    );
  }
}

class _ScalePainter extends CustomPainter {
  _ScalePainter({
    required this.element,
    required this.leftCount,
    required this.rightCount,
    required this.angle,
    required this.highlighted,
  });

  final BceElement element;
  final int leftCount;
  final int rightCount;
  final double angle;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height - 8);

    // Fulcrum triangle
    final fulcrum = Path()
      ..moveTo(origin.dx, origin.dy - _BalanceScale.fulcrumH)
      ..lineTo(origin.dx - _BalanceScale.fulcrumW / 2, origin.dy)
      ..lineTo(origin.dx + _BalanceScale.fulcrumW / 2, origin.dy)
      ..close();
    canvas.drawPath(
      fulcrum,
      Paint()
        ..color = const Color(0xFF6B6B6B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      fulcrum,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75,
    );

    // Element symbol on fulcrum
    final tp = TextPainter(
      text: TextSpan(
        text: element.symbol,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(origin.dx - tp.width / 2, origin.dy - _BalanceScale.fulcrumH * 0.55),
    );

    canvas.save();
    canvas.translate(origin.dx, origin.dy - _BalanceScale.fulcrumH);
    canvas.rotate(angle);

    final beamPaint = Paint()
      ..color = highlighted ? const Color(0xFFFFFF00) : Colors.black;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: _BalanceScale.beamLength,
        height: _BalanceScale.beamThickness,
      ),
      beamPaint,
    );
    if (highlighted) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: _BalanceScale.beamLength,
          height: _BalanceScale.beamThickness,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25
          ..color = Colors.black,
      );
    }

    _drawPile(canvas, -_BalanceScale.beamLength * 0.25, leftCount);
    _drawPile(canvas, _BalanceScale.beamLength * 0.25, rightCount);

    canvas.restore();
  }

  void _drawPile(Canvas canvas, double centerX, int count) {
    final countTp = TextPainter(
      text: TextSpan(
        text: '$count',
        style: const TextStyle(fontFamily: 'Arial', fontSize: 18, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final atomR = 8.0 * BceConstants.particlesScaleFactor;
    var pile = 0;
    var row = 0;
    var atomsInRow = 0;
    var x = centerX - 2.5 * atomR;
    var y = -atomR;

    for (var i = 0; i < count; i++) {
      final c = Offset(x + atomR, y);
      canvas.drawCircle(
        c,
        atomR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.lerp(Color(element.colorArgb), Colors.white, 0.5)!,
              Color(element.colorArgb),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: atomR)),
      );
      canvas.drawCircle(
        c,
        atomR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.black,
      );

      atomsInRow++;
      if (atomsInRow < 5 - row) {
        x += atomR * 2;
      } else if (row < 4) {
        row++;
        atomsInRow = 0;
        x = centerX - 2.5 * atomR + row * atomR;
        y -= atomR * 1.7;
      } else {
        row = 0;
        pile++;
        atomsInRow = 0;
        x = centerX - 2.5 * atomR + pile * atomR;
        y = -atomR;
      }
    }

    countTp.paint(
      canvas,
      Offset(centerX - countTp.width / 2, y - atomR - countTp.height - 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScalePainter oldDelegate) =>
      oldDelegate.leftCount != leftCount ||
      oldDelegate.rightCount != rightCount ||
      oldDelegate.angle != angle ||
      oldDelegate.highlighted != highlighted;
}
