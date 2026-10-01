// Transformer Painters — source, wires, coils, electrons, bulb/voltmeter, field
//
// Magnetic field uses the same PhET dipole model as magnet_and_compass:
//   Electromagnet (current × loops) → MagneticDipole → MagneticField
//   → FieldArrowPainter → PhetArrow
// Current direction → N/S pole orientation
// |Current| × loops → field strength

import 'dart:math';
import 'package:flutter/material.dart';
import '../phet/widgets/physics/magnetism/electromagnet.dart';
import '../phet/widgets/visualization/field.dart';
import '../phet/widgets/visualization/field_arrow_painter.dart';
import '../phet/widgets/shapes/phet_arrow.dart';
import '../phet/widgets/core/phet_types.dart';
import 'transformer_model.dart';

// ─────────────────────────────────────────────
//  Geometry constants
// ─────────────────────────────────────────────
class TransformerGeometry {
  static const double coilW = 120.0;
  static const double coilH = 140.0;
  static const double bulbSize = 50.0;
  static const double sourceW = 70.0;
  static const double sourceH = 70.0;
  static const double pickupRadius = 60.0;
}

// ─────────────────────────────────────────────
//  Main Transformer Painter
// ─────────────────────────────────────────────
class TransformerPainter extends CustomPainter {
  final Offset primaryCenter;
  final Offset secondaryCenter;
  final Offset sourcePos;
  final Offset bulbPos;
  final double sourceVoltage;
  final int primaryTurns;
  final int secondaryTurns;
  final double primaryCurrent;
  final double secondaryCurrent;
  final double bulbBrightness;
  final double voltmeterReading;
  final PowerMode powerMode;
  final IndicatorMode indicatorMode;
  final double pickupAreaFactor;

  const TransformerPainter({
    required this.primaryCenter,
    required this.secondaryCenter,
    required this.sourcePos,
    required this.bulbPos,
    required this.sourceVoltage,
    required this.primaryTurns,
    required this.secondaryTurns,
    required this.primaryCurrent,
    required this.secondaryCurrent,
    required this.bulbBrightness,
    required this.voltmeterReading,
    required this.powerMode,
    required this.indicatorMode,
    required this.pickupAreaFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSource(canvas, sourcePos, sourceVoltage, powerMode);
    _drawWiresToPrimary(canvas, sourcePos, primaryCenter);
    _drawCoil(canvas, primaryCenter, primaryTurns, const Color(0xffb71c1c));
    _drawWiresToSecondary(canvas, secondaryCenter, bulbPos);
    _drawCoil(canvas, secondaryCenter, secondaryTurns, const Color(0xff1b5e20));
    _drawPickupArea(canvas, secondaryCenter, pickupAreaFactor);
    if (indicatorMode == IndicatorMode.bulb) {
      _drawBulb(canvas, bulbPos, bulbBrightness);
    } else {
      _drawVoltmeter(canvas, bulbPos, voltmeterReading);
    }
  }

  void _drawSource(Canvas canvas, Offset c, double voltage, PowerMode mode) {
    final w = TransformerGeometry.sourceW;
    final h = TransformerGeometry.sourceH;
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(2, 3), const Radius.circular(10)),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xff424242), Color(0xff212121)],
        ).createShader(rect),
    );

    if (mode == PowerMode.ac) {
      final wavePaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final path = Path();
      for (double t = 0; t <= 2 * pi; t += 0.05) {
        final x = c.dx - 18 + (t / (2 * pi)) * 36;
        final y = c.dy + sin(t) * 12;
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wavePaint);
    } else {
      final tpPlus = TextPainter(
        text: TextSpan(
          text: voltage >= 0 ? '+' : '−',
          style: TextStyle(
            color: voltage >= 0 ? Colors.red : Colors.blue,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpPlus.paint(canvas, Offset(c.dx - tpPlus.width / 2, c.dy - tpPlus.height / 2));
    }

    _drawText(canvas, '${voltage.toStringAsFixed(1)}V',
        Offset(c.dx, c.dy + h / 2 + 14), 11, Colors.yellow);

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawWiresToPrimary(Canvas canvas, Offset source, Offset coil) {
    final wirePaint = Paint()
      ..color = const Color(0xffb0bec5)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Battery is directly above coil — wires go straight down
    final srcBottomL = Offset(source.dx - TransformerGeometry.sourceW * 0.25,
        source.dy + TransformerGeometry.sourceH / 2);
    final srcBottomR = Offset(source.dx + TransformerGeometry.sourceW * 0.25,
        source.dy + TransformerGeometry.sourceH / 2);
    final coilTopL = Offset(coil.dx - TransformerGeometry.coilW / 2,
        coil.dy - TransformerGeometry.coilH / 2);
    final coilTopR = Offset(coil.dx + TransformerGeometry.coilW / 2,
        coil.dy - TransformerGeometry.coilH / 2);

    // Left wire: battery bottom-left → down → coil top-left
    canvas.drawLine(srcBottomL, Offset(srcBottomL.dx, coilTopL.dy), wirePaint);
    canvas.drawLine(Offset(srcBottomL.dx, coilTopL.dy), coilTopL, wirePaint);

    // Right wire: coil top-right → up → battery bottom-right
    canvas.drawLine(coilTopR, Offset(srcBottomR.dx, coilTopR.dy), wirePaint);
    canvas.drawLine(Offset(srcBottomR.dx, coilTopR.dy), srcBottomR, wirePaint);
  }

  void _drawWiresToSecondary(Canvas canvas, Offset coil, Offset bulb) {
    final wirePaint = Paint()
      ..color = const Color(0xffb0bec5)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Bulb is directly above coil — wires go straight up
    final coilTopL = Offset(coil.dx - TransformerGeometry.coilW * 0.3,
        coil.dy - TransformerGeometry.coilH / 2);
    final coilTopR = Offset(coil.dx + TransformerGeometry.coilW * 0.3,
        coil.dy - TransformerGeometry.coilH / 2);
    final bulbLeft = Offset(bulb.dx - 12, bulb.dy + 15);
    final bulbRight = Offset(bulb.dx + 12, bulb.dy + 15);

    canvas.drawLine(coilTopL, Offset(coilTopL.dx, bulbLeft.dy), wirePaint);
    canvas.drawLine(Offset(coilTopL.dx, bulbLeft.dy), bulbLeft, wirePaint);

    canvas.drawLine(coilTopR, Offset(coilTopR.dx, bulbRight.dy), wirePaint);
    canvas.drawLine(Offset(coilTopR.dx, bulbRight.dy), bulbRight, wirePaint);
  }

  void _drawCoil(Canvas canvas, Offset c, int turns, Color wireColor) {
    final w = TransformerGeometry.coilW;
    final h = TransformerGeometry.coilH;
    final left = c.dx - w / 2;

    final loopSpacing = w / turns;
    final loopW = loopSpacing * 0.85;
    final loopH = h;

    for (int i = 0; i < turns; i++) {
      final cx = left + (i + 0.5) * loopSpacing;
      final cy = c.dy;
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: loopW, height: loopH);

      canvas.drawOval(
        rect.translate(1, 2),
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              wireColor.withValues(alpha: 0.9),
              wireColor,
              wireColor.withValues(alpha: 0.6),
            ],
          ).createShader(rect),
      );

      canvas.drawOval(
        rect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      canvas.drawOval(
        rect,
        Paint()
          ..color = wireColor.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  /// Draw the effective pickup coil area indicator
  void _drawPickupArea(Canvas canvas, Offset c, double areaFactor) {
    final radius = TransformerGeometry.pickupRadius * sqrt(areaFactor);

    // Dashed circle showing effective area
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw dashed circle
    const dashLen = 4.0;
    const dashGap = 3.0;
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashLen + dashGap)).floor();
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLen + dashGap) / circumference) * 2 * pi;
      final endAngle = ((i * (dashLen + dashGap) + dashLen) / circumference) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  void _drawBulb(Canvas canvas, Offset c, double brightness) {
    final size = TransformerGeometry.bulbSize;
    final rect = Rect.fromCenter(center: c, width: size, height: size);

    if (brightness > 0.01) {
      final glowRadius = size * 0.8 + brightness * 40;
      final glowPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          colors: [
            Colors.yellow.withValues(alpha: brightness * 0.6),
            Colors.yellow.withValues(alpha: brightness * 0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCenter(
            center: c, width: glowRadius * 2, height: glowRadius * 2));
      canvas.drawCircle(c, glowRadius, glowPaint);
    }

    final bulbPaint = Paint()..style = PaintingStyle.fill;

    if (brightness > 0.01) {
      bulbPaint.shader = RadialGradient(
        center: Alignment.center,
        colors: [
          Colors.yellow.withValues(alpha: brightness),
          Colors.orange.withValues(alpha: brightness * 0.8),
          Colors.yellow.withValues(alpha: brightness * 0.3),
        ],
      ).createShader(rect);
    } else {
      bulbPaint.color = const Color(0xff424242);
    }

    canvas.drawCircle(c, size / 2, bulbPaint);

    canvas.drawCircle(
      c,
      size / 2,
      Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (brightness > 0.01) {
      final filamentPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: brightness)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path();
      path.moveTo(c.dx - 8, c.dy + 8);
      path.lineTo(c.dx - 4, c.dy - 4);
      path.lineTo(c.dx, c.dy + 4);
      path.lineTo(c.dx + 4, c.dy - 4);
      path.lineTo(c.dx + 8, c.dy + 8);
      canvas.drawPath(path, filamentPaint);
    }

    final baseRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + size / 2 + 4),
      width: size * 0.5,
      height: 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(2)),
      Paint()..color = const Color(0xff9e9e9e),
    );
  }

  /// Draw voltmeter indicator
  void _drawVoltmeter(Canvas canvas, Offset c, double reading) {
    final size = TransformerGeometry.bulbSize;
    final rect = Rect.fromCenter(center: c, width: size + 10, height: size + 10);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(2, 3), const Radius.circular(8)),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = const Color(0xff1a1a2e),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Voltmeter dial — arc with needle
    final cx = c.dx;
    final cy = c.dy + 2;
    final r = size * 0.35;

    // Arc background
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      pi * 0.75,
      pi * 1.5,
      false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Tick marks
    for (int i = 0; i <= 10; i++) {
      final angle = pi * 0.75 + (i / 10) * pi * 1.5;
      final inner = Offset(cx + cos(angle) * (r - 3), cy + sin(angle) * (r - 3));
      final outer = Offset(cx + cos(angle) * r, cy + sin(angle) * r);
      canvas.drawLine(inner, outer, Paint()
        ..color = Colors.white30
        ..strokeWidth = 1);
    }

    // Needle — angle based on reading
    final maxV = 5.0;
    final normalizedV = (reading / maxV).clamp(-1.0, 1.0);
    final needleAngle = pi * 0.75 + ((normalizedV + 1) / 2) * pi * 1.5;
    final needleEnd = Offset(cx + cos(needleAngle) * (r - 2), cy + sin(needleAngle) * (r - 2));
    canvas.drawLine(
      Offset(cx, cy),
      needleEnd,
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = Colors.white);

    // Reading text
    _drawText(canvas, '${reading.toStringAsFixed(2)}V', Offset(c.dx, c.dy + size * 0.4), 10, Colors.lightBlueAccent);
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
  bool shouldRepaint(TransformerPainter old) => true;
}

// ─────────────────────────────────────────────
//  Electron Painter
// ─────────────────────────────────────────────
class TransformerElectronPainter extends CustomPainter {
  final Offset primaryCenter;
  final Offset secondaryCenter;
  final Offset sourcePos;
  final Offset bulbPos;
  final List<double> primaryElectronPositions;
  final List<double> secondaryElectronPositions;
  final int primaryTurns;
  final int secondaryTurns;
  final bool showPrimary;
  final bool showSecondary;

  const TransformerElectronPainter({
    required this.primaryCenter,
    required this.secondaryCenter,
    required this.sourcePos,
    required this.bulbPos,
    required this.primaryElectronPositions,
    required this.secondaryElectronPositions,
    required this.primaryTurns,
    required this.secondaryTurns,
    required this.showPrimary,
    required this.showSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showPrimary) {
      _drawElectronsOnPath(canvas, _buildPrimaryPath(), primaryElectronPositions);
    }
    if (showSecondary) {
      _drawElectronsOnPath(canvas, _buildSecondaryPath(), secondaryElectronPositions);
    }
  }

  List<Offset> _buildPrimaryPath() {
    final pts = <Offset>[];

    final srcBottomL = Offset(sourcePos.dx - TransformerGeometry.sourceW * 0.2,
        sourcePos.dy + TransformerGeometry.sourceH / 2);
    final coilLeft = Offset(primaryCenter.dx - TransformerGeometry.coilW / 2, primaryCenter.dy);
    final midL = Offset(srcBottomL.dx, coilLeft.dy);

    pts.add(srcBottomL);
    pts.add(midL);
    pts.add(coilLeft);

    final loopSpacing = TransformerGeometry.coilW / primaryTurns;
    for (int i = 0; i < primaryTurns; i++) {
      final cx = primaryCenter.dx - TransformerGeometry.coilW / 2 + (i + 0.5) * loopSpacing;
      pts.add(Offset(cx, primaryCenter.dy - TransformerGeometry.coilH / 2));
      pts.add(Offset(cx, primaryCenter.dy + TransformerGeometry.coilH / 2));
    }

    final coilRight = Offset(primaryCenter.dx + TransformerGeometry.coilW / 2, primaryCenter.dy);
    pts.add(coilRight);
    final midR = Offset(sourcePos.dx + TransformerGeometry.sourceW * 0.2, coilRight.dy);
    pts.add(midR);
    final srcBottomR = Offset(sourcePos.dx + TransformerGeometry.sourceW * 0.2,
        sourcePos.dy + TransformerGeometry.sourceH / 2);
    pts.add(srcBottomR);

    return pts;
  }

  List<Offset> _buildSecondaryPath() {
    final pts = <Offset>[];

    final coilTopLeft = Offset(
      secondaryCenter.dx - TransformerGeometry.coilW * 0.3,
      secondaryCenter.dy - TransformerGeometry.coilH / 2,
    );
    final coilTopRight = Offset(
      secondaryCenter.dx + TransformerGeometry.coilW * 0.3,
      secondaryCenter.dy - TransformerGeometry.coilH / 2,
    );

    final loopSpacing = TransformerGeometry.coilW / secondaryTurns;
    for (int i = 0; i < secondaryTurns; i++) {
      final cx = secondaryCenter.dx - TransformerGeometry.coilW / 2 + (i + 0.5) * loopSpacing;
      pts.add(Offset(cx, secondaryCenter.dy - TransformerGeometry.coilH / 2));
      pts.add(Offset(cx, secondaryCenter.dy + TransformerGeometry.coilH / 2));
    }

    pts.add(coilTopLeft);
    final bulbLeft = Offset(bulbPos.dx - 12, bulbPos.dy);
    final midL = Offset(coilTopLeft.dx, bulbLeft.dy);
    pts.add(midL);
    pts.add(bulbLeft);
    pts.add(bulbPos);
    final bulbRight = Offset(bulbPos.dx + 12, bulbPos.dy);
    pts.add(bulbRight);
    final midR = Offset(coilTopRight.dx, bulbRight.dy);
    pts.add(midR);
    pts.add(coilTopRight);

    return pts;
  }

  void _drawElectronsOnPath(Canvas canvas, List<Offset> pts, List<double> positions) {
    if (pts.length < 2) return;

    final segLens = <double>[];
    double totalLen = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      final d = (pts[i + 1] - pts[i]).distance;
      segLens.add(d);
      totalLen += d;
    }

    final electronPaint = Paint()
      ..color = const Color(0xffab47bc)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xffce93d8).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (final pos in positions) {
      final target = pos * totalLen;
      double accum = 0;
      Offset? p;

      for (int i = 0; i < segLens.length; i++) {
        if (accum + segLens[i] >= target) {
          final local = (target - accum) / segLens[i];
          p = Offset.lerp(pts[i], pts[i + 1], local);
          break;
        }
        accum += segLens[i];
      }
      p ??= pts.last;

      canvas.drawCircle(p, 5, glowPaint);
      canvas.drawCircle(p, 3.5, electronPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: '−',
          style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(TransformerElectronPainter old) => true;
}

// ─────────────────────────────────────────────
//  Transformer Magnetic Field — uses PhET dipole model (same as magnet_and_compass)
//
//  Electromagnet (current × loops) → MagneticDipole → MagneticField
//  → FieldArrowPainter → PhetArrow
//
//  Current direction → N/S pole orientation
//  |Current| × loops → field strength
// ─────────────────────────────────────────────

/// A [Field] that sums the B-fields from primary and secondary electromagnets.
class TransformerField extends Field {
  final Electromagnet primary;
  final Electromagnet secondary;

  TransformerField({required this.primary, required this.secondary});

  @override
  PhetVector valueAt(Offset point) {
    final bP = primary.field.valueAt(point);
    final bS = secondary.field.valueAt(point);
    return bP + bS;
  }
}

/// Backwards-compatible painter that wraps [FieldArrowPainter].
/// Uses [PhetArrow] for rendering — identical to magnet_and_compass.
class TransformerFieldPainter extends CustomPainter {
  final Offset primaryCenter;
  final Offset secondaryCenter;
  final double primaryCurrent;
  final double secondaryCurrent;
  final int primaryTurns;
  final int secondaryTurns;

  const TransformerFieldPainter({
    required this.primaryCenter,
    required this.secondaryCenter,
    required this.primaryCurrent,
    required this.secondaryCurrent,
    required this.primaryTurns,
    required this.secondaryTurns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (primaryCurrent.abs() < 1e-12 && secondaryCurrent.abs() < 1e-12) return;

    final primaryEmag = Electromagnet(
      center: primaryCenter,
      axisAngle: 0,
      halfLength: 70,
      loops: primaryTurns,
      current: primaryCurrent,
    );
    final secondaryEmag = Electromagnet(
      center: secondaryCenter,
      axisAngle: 0,
      halfLength: 70,
      loops: secondaryTurns,
      current: secondaryCurrent,
    );

    final field = TransformerField(primary: primaryEmag, secondary: secondaryEmag);

    FieldArrowPainter(
      field: field,
      cols: 34,
      rows: 19,
      minLen: 8,
      maxLen: 36,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(TransformerFieldPainter old) => true;
}

// ─────────────────────────────────────────────
//  Field Meter Painter
// ─────────────────────────────────────────────
class TransformerFieldMeterPainter extends CustomPainter {
  final double magnitude;
  final double angleDeg;
  final double bx;
  final double by;

  const TransformerFieldMeterPainter({
    required this.magnitude,
    required this.angleDeg,
    required this.bx,
    required this.by,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()..color = const Color(0xff0d2255).withValues(alpha: 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      bgPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _text(canvas, 'B = ${magnitude.toStringAsFixed(4)} T', const Offset(10, 10), 13, Colors.white, true);
    _text(canvas, 'θ = ${angleDeg.toStringAsFixed(1)}°', const Offset(10, 32), 11, Colors.white70);
    _text(canvas, 'Bx = ${bx.toStringAsFixed(4)}', const Offset(10, 54), 10, Colors.white54);
    _text(canvas, 'By = ${by.toStringAsFixed(4)}', const Offset(10, 74), 10, Colors.white54);

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

    final ah = 5.0;
    canvas.drawPath(
      Path()
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx - cos(a - 0.4) * ah, head.dy - sin(a - 0.4) * ah)
        ..lineTo(head.dx - cos(a + 0.4) * ah, head.dy - sin(a + 0.4) * ah)
        ..close(),
      Paint()..color = Colors.lightBlueAccent,
    );

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
  bool shouldRepaint(TransformerFieldMeterPainter old) =>
      old.magnitude != magnitude || old.angleDeg != angleDeg;
}
