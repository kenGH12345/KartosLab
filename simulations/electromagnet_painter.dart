// Electromagnet Painters — battery, coil, wires, electrons, field meter

import 'dart:math';
import 'package:flutter/material.dart';
import 'electromagnet_model.dart';

// ─────────────────────────────────────────────
//  Electromagnet Painter: battery + wires + coil
// ─────────────────────────────────────────────
class ElectromagnetPainter extends CustomPainter {
  final Offset center;
  final double voltage;
  final int loops;
  final double current;

  // Geometry constants
  static const double _batteryW = 60.0;
  static const double _batteryH = 120.0;
  static const double _coilW = 200.0;
  static const double _coilH = 160.0;

  const ElectromagnetPainter({
    required this.center,
    required this.voltage,
    required this.loops,
    required this.current,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Battery is above the coil, wires connect them
    final batteryCenter = Offset(center.dx, center.dy - _coilH / 2 - _batteryH / 2 - 20);
    final coilCenter = center;

    _drawBattery(canvas, batteryCenter);
    _drawWires(canvas, batteryCenter, coilCenter);
    _drawCoil(canvas, coilCenter);
  }

  void _drawBattery(Canvas canvas, Offset c) {
    final w = _batteryW;
    final h = _batteryH;
    final left = c.dx - w / 2;
    final top = c.dy - h / 2;

    // Battery body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(8),
    );

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2, top + 3, w, h),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black45..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main body gradient
    canvas.drawRRect(
      body,
      Paint()..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xff6d4c41), Color(0xff8d6e63), Color(0xff6d4c41)],
      ).createShader(Rect.fromLTWH(left, top, w, h)),
    );

    // Terminal cap (top = positive)
    final capH = 10.0;
    final capW = w * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - capW / 2, top - capH / 2, capW, capH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xffbf360c)..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xffd84315), Color(0xffff7043), Color(0xffd84315)],
      ).createShader(Rect.fromLTWH(c.dx - capW / 2, top - capH / 2, capW, capH)),
    );

    // Bottom terminal (negative)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - capW / 2, c.dy + h / 2 - capH / 2, capW, capH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xff37474f),
    );

    // Labels: + and -
    _drawText(canvas, '+', Offset(c.dx, top + 12), 14, Colors.white);
    _drawText(canvas, '−', Offset(c.dx, c.dy + h / 2 - 12), 14, Colors.white);

    // Voltage label
    _drawText(canvas, '${voltage.toStringAsFixed(1)} V', Offset(c.dx, c.dy), 12, Colors.white);

    // Border
    canvas.drawRRect(
      body,
      Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
  }

  void _drawWires(Canvas canvas, Offset battery, Offset coil) {
    final wireColor = const Color(0xffb0bec5);
    final wirePaint = Paint()
      ..color = wireColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Left wire: from battery bottom-left to coil left
    final batBottom = Offset(battery.dx - _batteryW * 0.3, battery.dy + _batteryH / 2);
    final coilLeft = Offset(coil.dx - _coilW / 2 + 10, coil.dy);
    // route: down then left then to coil
    final midL = Offset(batBottom.dx, coilLeft.dy);
    canvas.drawLine(batBottom, midL, wirePaint);
    canvas.drawLine(midL, coilLeft, wirePaint);

    // Right wire: from battery bottom-right to coil right
    final batBottomR = Offset(battery.dx + _batteryW * 0.3, battery.dy + _batteryH / 2);
    final coilRight = Offset(coil.dx + _coilW / 2 - 10, coil.dy);
    final midR = Offset(batBottomR.dx, coilRight.dy);
    canvas.drawLine(batBottomR, midR, wirePaint);
    canvas.drawLine(midR, coilRight, wirePaint);
  }

  void _drawCoil(Canvas canvas, Offset c) {
    final w = _coilW;
    final h = _coilH;
    final left = c.dx - w / 2;

    // Draw loops as ellipse arcs
    final loopSpacing = w / loops;
    final loopW = loopSpacing * 0.85;
    final loopH = h;

    for (int i = 0; i < loops; i++) {
      final cx = left + (i + 0.5) * loopSpacing;
      final cy = c.dy;

      // Shadow
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: loopW, height: loopH);
      canvas.drawOval(
        rect,
        Paint()
          ..color = const Color(0xff8d6e63)
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: const [Color(0xffa1887f), Color(0xff5d4037)],
          ).createShader(rect),
      );

      // Wire highlight
      canvas.drawOval(
        rect,
        Paint()
          ..color = const Color(0xffd7ccc8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Border
      canvas.drawOval(
        rect,
        Paint()
          ..color = const Color(0xff3e2723)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(ElectromagnetPainter old) =>
      old.voltage != voltage || old.loops != loops || old.current != current;
}

// ─────────────────────────────────────────────
//  Electron Painter — draws electrons moving along wire path
// ─────────────────────────────────────────────
class ElectronPainter extends CustomPainter {
  final Offset center;
  final List<double> positions; // [0,1) along the path
  final double current;
  final int loops;

  static const double _batteryW = 60.0;
  static const double _batteryH = 120.0;
  static const double _coilW = 200.0;
  static const double _coilH = 160.0;

  const ElectronPainter({
    required this.center,
    required this.positions,
    required this.current,
    required this.loops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final batteryCenter = Offset(center.dx, center.dy - _coilH / 2 - _batteryH / 2 - 20);
    final coilCenter = center;

    // Build path points: left wire down → through coil → right wire up
    final pathPoints = _buildWirePath(batteryCenter, coilCenter);

    if (pathPoints.length < 2) return;

    final electronPaint = Paint()
      ..color = const Color(0xff42a5f5)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xff64b5f6).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (final pos in positions) {
      final p = _pointOnPath(pathPoints, pos);
      // Glow
      canvas.drawCircle(p, 5, glowPaint);
      // Electron
      canvas.drawCircle(p, 3.5, electronPaint);
      // Highlight
      canvas.drawCircle(
        Offset(p.dx - 1, p.dy - 1),
        1.2,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  List<Offset> _buildWirePath(Offset battery, Offset coil) {
    final pts = <Offset>[];

    // Start at battery bottom-left terminal
    final batBottomL = Offset(battery.dx - _batteryW * 0.3, battery.dy + _batteryH / 2);
    // Down
    final midL = Offset(batBottomL.dx, coil.dy);
    // To coil left
    final coilLeft = Offset(coil.dx - _coilW / 2 + 10, coil.dy);

    pts.add(batBottomL);
    pts.add(midL);
    pts.add(coilLeft);

    // Through coil: zigzag through loops
    final loopSpacing = _coilW / loops;
    for (int i = 0; i < loops; i++) {
      final cx = coil.dx - _coilW / 2 + (i + 0.5) * loopSpacing;
      // Top of loop
      pts.add(Offset(cx, coil.dy - _coilH / 2));
      // Bottom of loop (back side — but for visual, we go up and over)
      pts.add(Offset(cx, coil.dy + _coilH / 2));
    }

    // To right wire
    final coilRight = Offset(coil.dx + _coilW / 2 - 10, coil.dy);
    pts.add(coilRight);
    final midR = Offset(battery.dx + _batteryW * 0.3, coil.dy);
    pts.add(midR);
    final batBottomR = Offset(battery.dx + _batteryW * 0.3, battery.dy + _batteryH / 2);
    pts.add(batBottomR);

    return pts;
  }

  Offset _pointOnPath(List<Offset> pts, double t) {
    // Compute total path length
    double totalLen = 0;
    final segLens = <double>[];
    for (int i = 0; i < pts.length - 1; i++) {
      final d = (pts[i + 1] - pts[i]).distance;
      segLens.add(d);
      totalLen += d;
    }

    final target = t * totalLen;
    double accum = 0;
    for (int i = 0; i < segLens.length; i++) {
      if (accum + segLens[i] >= target) {
        final local = (target - accum) / segLens[i];
        return Offset.lerp(pts[i], pts[i + 1], local)!;
      }
      accum += segLens[i];
    }
    return pts.last;
  }

  @override
  bool shouldRepaint(ElectronPainter old) => true;
}

// ─────────────────────────────────────────────
//  Field Meter Painter — reuses design from Magnet page
// ─────────────────────────────────────────────
class FieldMeterPainter extends CustomPainter {
  final double magnitude;
  final double angleDeg;
  final double bx;
  final double by;

  const FieldMeterPainter({
    required this.magnitude,
    required this.angleDeg,
    required this.bx,
    required this.by,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    final bgPaint = Paint()
      ..color = const Color(0xff0d2255).withValues(alpha: 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      bgPaint,
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Text
    _text(canvas, 'B = ${magnitude.toStringAsFixed(3)} T', Offset(10, 10), 13, Colors.white, true);
    _text(canvas, 'θ = ${angleDeg.toStringAsFixed(1)}°', Offset(10, 32), 11, Colors.white70);
    _text(canvas, 'Bx = ${bx.toStringAsFixed(3)}', Offset(10, 54), 10, Colors.white54);
    _text(canvas, 'By = ${by.toStringAsFixed(3)}', Offset(10, 74), 10, Colors.white54);

    // Direction arrow
    final cx = w - 35;
    final cy = h - 35;
    final arrowLen = 18.0;
    final a = angleDeg * pi / 180;
    final head = Offset(cx + cos(a) * arrowLen, cy + sin(a) * arrowLen);
    final tail = Offset(cx - cos(a) * arrowLen, cy - sin(a) * arrowLen);

    canvas.drawLine(tail, head, Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // Arrowhead
    final ah = 5.0;
    canvas.drawPath(
      Path()
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx - cos(a - 0.4) * ah, head.dy - sin(a - 0.4) * ah)
        ..lineTo(head.dx - cos(a + 0.4) * ah, head.dy - sin(a + 0.4) * ah)
        ..close(),
      Paint()..color = Colors.lightBlueAccent,
    );

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
  }

  void _text(Canvas canvas, String s, Offset pos, double fs, Color color, [bool bold = false]) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: color, fontSize: fs, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(FieldMeterPainter old) =>
      old.magnitude != magnitude || old.angleDeg != angleDeg;
}

// ─────────────────────────────────────────────
//  Electromagnet Field Needle Painter
//  — Same concept as FieldNeedlePainter but uses ElectromagnetField
// ─────────────────────────────────────────────
class ElectromagnetFieldPainter extends CustomPainter {
  final Offset coilCenter;
  final double coilAxisAngle;
  final double halfLen;
  final double current;
  final int loops;
  final double coilW;
  final double coilH;

  const ElectromagnetFieldPainter({
    required this.coilCenter,
    required this.coilAxisAngle,
    required this.halfLen,
    required this.current,
    required this.loops,
    required this.coilW,
    required this.coilH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 34;
    const rows = 19;
    final cw = size.width / cols;
    final ch = size.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final px = (col + 0.5) * cw;
        final py = (row + 0.5) * ch;
        final p = Offset(px, py);

        // Skip inside coil area
        final d = p - coilCenter;
        if (d.dx.abs() < coilW / 2 + 5 && d.dy.abs() < coilH / 2 + 5) continue;

        final b = ElectromagnetField.compute(
          p: p,
          coilCenter: coilCenter,
          coilAxisAngle: coilAxisAngle,
          halfLen: halfLen,
          current: current,
          loops: loops,
        );
        final mag = ElectromagnetField.magnitude(b);
        if (mag < 1e-6) continue;

        final angle = ElectromagnetField.fieldAngle(b);
        final len = (log(1 + mag * 0.28) * 100).clamp(8.0, 36.0).toDouble();
        _drawNeedle(canvas, p, angle, len);
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset c, double angle, double len) {
    final half = len / 2;
    final hw = (len / 18.0 * 5.6).clamp(3.0, 5.6);
    final ca = cos(angle);
    final sa = sin(angle);
    final cp = cos(angle + pi / 2);
    final sp = sin(angle + pi / 2);

    final head = Offset(c.dx + ca * half, c.dy + sa * half);
    final tail = Offset(c.dx - ca * half, c.dy - sa * half);
    final left = Offset(c.dx + cp * hw, c.dy + sp * hw);
    final right = Offset(c.dx - cp * hw, c.dy - sp * hw);

    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcccccc)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcc2222)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(tail.dx, tail.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.3);
  }

  @override
  bool shouldRepaint(ElectromagnetFieldPainter old) => true;
}
