/// BlochSphereNode paint — projection in, no physics.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../projection/bloch_projection.dart';

/// Source defaults: blockSphereMainColor #0FF, highlight #FFF.
const blochSphereMainColor = Color(0xFF00FFFF);
const blochSphereHighlightColor = Color(0xFFFFFFFF);
const blochAxesStroke = Color(0xFF000000);

class BlochSpherePaintInput {
  const BlochSpherePaintInput({
    required this.center,
    required this.polar,
    required this.azimuthal,
    this.scale = 1.0,
    this.drawKets = true,
    this.drawAngleIndicators = true,
    this.drawAxesLabels = true,
    this.stateVectorScale = 1.0,
    this.stateVectorVisible = true,
  });

  final Offset center;
  final double polar;
  final double azimuthal;
  final double scale;
  final bool drawKets;
  final bool drawAngleIndicators;
  final bool drawAxesLabels;
  final double stateVectorScale;
  final bool stateVectorVisible;
}

class BlochSpherePainter extends CustomPainter {
  BlochSpherePainter({required this.input})
      : _projection = BlochProjection(radius: blochSphereRadius * input.scale);

  final BlochSpherePaintInput input;
  final BlochProjection _projection;

  @override
  void paint(Canvas canvas, Size size) {
    final c = input.center;
    final r = _projection.radius;
    final p = _projection;

    // --- Sphere body (ShadedSphereNode equivalent) ---
    final sphereRect = Rect.fromCircle(center: c, radius: r);
    final gradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.95,
      colors: const [
        blochSphereHighlightColor,
        blochSphereMainColor,
        Color(0xFF00B8B8),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawCircle(
      c,
      r,
      Paint()..shader = gradient.createShader(sphereRect),
    );

    // --- Equator ellipse ---
    final equatorPaint = Paint()
      ..color = blochAxesStroke.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = axesLineWidth
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: p.equatorSemiMajor * 2,
        height: p.equatorSemiMinor * 2,
      ),
      equatorPaint
        ..color = blochAxesStroke
        ..strokeWidth = axesLineWidth,
    );

    // Dashed axes in local coords
    final dashPaint = Paint()
      ..color = blochAxesStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = axesLineWidth;

    _drawDashedLine(canvas, p.plusX, p.minusX, dashPaint);
    _drawDashedLine(canvas, p.plusY, p.minusY, dashPaint);
    _drawDashedLine(canvas, Offset(0, -r), Offset(0, r), dashPaint);

    // Angle indicators + XY projection
    final tipLocal = p.pointOnTheSphere(input.azimuthal, input.polar);
    if (input.drawAngleIndicators &&
        (math.sin(input.polar * 2)).abs() >= 1e-5) {
      final xyTip = Offset(
        p.pointOnTheEquator(input.azimuthal).dx * math.sin(input.polar),
        p.pointOnTheEquator(input.azimuthal).dy * math.sin(input.polar),
      );
      final projPaint = Paint()
        ..color = blochAxesStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      _drawDashedLine(canvas, Offset.zero, xyTip, projPaint);
      _drawDashedLine(canvas, tipLocal, Offset(tipLocal.dx, xyTip.dy), projPaint);
    }

    canvas.restore();

    // --- Axis labels ---
    if (input.drawAxesLabels) {
      final plusX = c + p.plusX;
      final plusY = c + p.plusY;
      _drawLabel(
        canvas,
        '+X',
        Offset(plusX.dx + 3 * labelsOffset * input.scale,
            plusX.dy + 2 * labelsOffset * input.scale),
      );
      _drawLabel(
        canvas,
        '+Y',
        Offset(plusY.dx, plusY.dy - 2 * labelsOffset * input.scale),
      );
      _drawLabel(
        canvas,
        '+Z',
        Offset(c.dx - 4 * labelsOffset * input.scale,
            c.dy - r + labelsOffset * input.scale),
      );
    }

    if (input.drawKets) {
      _drawLabel(canvas, '|↑_Z ⟩', Offset(c.dx, c.dy - r - 3 * labelsOffset * input.scale));
      _drawLabel(canvas, '|↓_Z ⟩', Offset(c.dx, c.dy + r + 3 * labelsOffset * input.scale));
    }

    // --- State vector (always on top; opacity depth cue) ---
    if (input.stateVectorVisible) {
      final tip = c + tipLocal;
      final tipCart = (
        x: math.sin(input.polar) * math.cos(input.azimuthal),
        y: math.sin(input.polar) * math.sin(input.azimuthal),
        z: math.cos(input.polar),
      );
      final dist = math.sqrt(
        math.pow(tipCart.x - (-1), 2) +
            tipCart.y * tipCart.y +
            tipCart.z * tipCart.z,
      );
      final tipOpacity = math.pow(dist / 2, 2).clamp(0.0, 1.0).toDouble();
      _drawArrow(
        canvas,
        c,
        tip,
        tipOpacity: tipOpacity,
        scale: input.stateVectorScale,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 2.0;
    const gap = 2.0;
    final total = (b - a).distance;
    if (total < 1e-6) return;
    final dir = (b - a) / total;
    var t = 0.0;
    while (t < total) {
      final t2 = math.min(t + dash, total);
      canvas.drawLine(a + dir * t, a + dir * t2, paint);
      t += dash + gap;
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawArrow(
    Canvas canvas,
    Offset tail,
    Offset tip, {
    required double tipOpacity,
    required double scale,
  }) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        tail,
        tip,
        [
          const Color.fromRGBO(0, 0, 0, 0.4),
          Color.fromRGBO(0, 0, 0, tipOpacity),
        ],
      )
      ..strokeWidth = 3 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, paint);

    final dir = tip - tail;
    final len = dir.distance;
    if (len < 1e-6) return;
    final unit = dir / len;
    final ortho = Offset(-unit.dy, unit.dx);
    final headH = 10.0 * scale;
    final headW = 10.0 * scale;
    final base = tip - unit * headH;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + ortho.dx * headW / 2, base.dy + ortho.dy * headW / 2)
      ..lineTo(base.dx - ortho.dx * headW / 2, base.dy - ortho.dy * headW / 2)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = Color.fromRGBO(0, 0, 0, tipOpacity),
    );
  }

  @override
  bool shouldRepaint(covariant BlochSpherePainter oldDelegate) {
    return oldDelegate.input.polar != input.polar ||
        oldDelegate.input.azimuthal != input.azimuthal ||
        oldDelegate.input.center != input.center ||
        oldDelegate.input.scale != input.scale ||
        oldDelegate.input.stateVectorVisible != input.stateVectorVisible;
  }
}
