import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../caf_colors.dart';
import '../caf_constants.dart';
import '../model/charges_and_fields_model.dart';
import '../model/vec2.dart';
import '../transform/caf_mvt.dart';

/// Potential → color mapping shared by voltage field + voltmeter circle.
class CafPotentialColors {
  CafPotentialColors._();

  static int _ch(Color c, double component) =>
      (component * 255.0).round().clamp(0, 255);

  /// Canvas / WebGL display mapping: `|V|/40` → lerp(zero, extreme).
  /// Uses continuous float blend (ElectricPotentialCanvasNode imageData).
  static Color forField(double v) {
    final zero = CafColors.electricPotentialGridZero;
    final extreme = v >= 0
        ? CafColors.electricPotentialGridSaturationPositive
        : CafColors.electricPotentialGridSaturationNegative;
    var value = v.abs() / CafConstants.maxElectricPotential;
    if (value > 1) value = 1;
    final zr = _ch(zero, zero.r);
    final zg = _ch(zero, zero.g);
    final zb = _ch(zero, zero.b);
    final za = _ch(zero, zero.a);
    final er = _ch(extreme, extreme.r);
    final eg = _ch(extreme, extreme.g);
    final eb = _ch(extreme, extreme.b);
    final ea = _ch(extreme, extreme.a);
    return Color.fromARGB(
      (ea * value + za * (1 - value)).round().clamp(0, 255),
      (er * value + zr * (1 - value)).round().clamp(0, 255),
      (eg * value + zg * (1 - value)).round().clamp(0, 255),
      (eb * value + zb * (1 - value)).round().clamp(0, 255),
    );
  }

  /// Circle fill with transparency (0–1), matching ScreenView.getElectricPotentialColor.
  static Color forCircle(double v, double transparency) {
    final zero = CafColors.electricPotentialGridZero;
    final pos = CafColors.electricPotentialGridSaturationPositive;
    final neg = CafColors.electricPotentialGridSaturationNegative;
    late int r, g, b;
    if (v > 0) {
      final d = (v / CafConstants.maxElectricPotential).clamp(0.0, 1.0);
      r = _lerpChannel(_ch(zero, zero.r), _ch(pos, pos.r), d);
      g = _lerpChannel(_ch(zero, zero.g), _ch(pos, pos.g), d);
      b = _lerpChannel(_ch(zero, zero.b), _ch(pos, pos.b), d);
    } else {
      final d = ((v - CafConstants.minElectricPotential) /
              (0 - CafConstants.minElectricPotential))
          .clamp(0.0, 1.0);
      r = _lerpChannel(_ch(neg, neg.r), _ch(zero, zero.r), d);
      g = _lerpChannel(_ch(neg, neg.g), _ch(zero, zero.g), d);
      b = _lerpChannel(_ch(neg, neg.b), _ch(zero, zero.b), d);
    }
    final a = (transparency * 255).round().clamp(0, 255);
    return Color.fromARGB(a, r, g, b);
  }

  static int _lerpChannel(int a, int b, double t) =>
      (a + (b - a) * t).round().clamp(0, 255);

  /// Canvas-style V for coloring: skip zero-distance (no ±∞ holes).
  static double samplePotential(ChargesAndFieldsModel model, CafVec2 position) {
    var v = 0.0;
    for (final p in model.activeChargedParticles) {
      final d = p.position.distance(position);
      if (d != 0) {
        v += p.charge * CafConstants.kConstant / d;
      }
    }
    return v;
  }
}

class PotentialFieldGridSize {
  const PotentialFieldGridSize(this.numHorizontal, this.numVertical);
  final int numHorizontal;
  final int numVertical;
}

/// Sample spacing for voltage color field.
///
/// Evidence:
/// - WebGL: 1 sample / canvas pixel, TEXTURE_*_FILTER = NEAREST
/// - Canvas fallback: `ELECTRIC_POTENTIAL_SENSOR_SPACING` (0.1 m) + drawImage stretch
///
/// Flutter targets WebGL-like smoothness without a GPU runtime: dense sampling
/// (~2 view px / cell) + NEAREST (`FilterQuality.none`). Color mapping stays
/// identical to Canvas/WebGL (`|V|/40`).
double potentialSampleSpacing(double viewScale) {
  final webglLike = 2.0 / viewScale;
  return webglLike.clamp(0.0125, CafConstants.electricPotentialSensorSpacing);
}

/// Builds potential Image — dense sample toward WebGL pixel field.
Future<(ui.Image, PotentialFieldGridSize)?> buildPotentialFieldImage(
  ChargesAndFieldsModel model, {
  double viewScale = 128,
}) async {
  if (!model.isElectricPotentialVisible) return null;
  if (model.activeChargedParticles.isEmpty) return null;

  final bounds = model.enlargedBounds;
  final spacing = potentialSampleSpacing(viewScale);
  final numHorizontal = (bounds.width / spacing).ceil();
  final numVertical = (bounds.height / spacing).ceil();
  final bytes = Uint8List(numHorizontal * numVertical * 4);

  var i = 0;
  // Match ElectricPotentialCanvasNode: image row 0 = model minY, drawn with
  // sy < 0 from viewBounds.maxY so minY lands at the bottom of the screen.
  // Flutter drawImageRect places row 0 at dest.top, so fill top-first = model maxY.
  for (var row = 0; row < numVertical; row++) {
    final y = bounds.maxY - (row + 0.5) * bounds.height / numVertical;
    for (var col = 0; col < numHorizontal; col++) {
      final x = bounds.minX + (col + 0.5) * bounds.width / numHorizontal;
      final v = CafPotentialColors.samplePotential(model, CafVec2(x, y));
      final c = CafPotentialColors.forField(v);
      bytes[i++] = (c.r * 255.0).round().clamp(0, 255);
      bytes[i++] = (c.g * 255.0).round().clamp(0, 255);
      bytes[i++] = (c.b * 255.0).round().clamp(0, 255);
      bytes[i++] = (c.a * 255.0).round().clamp(0, 255);
    }
  }

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    bytes,
    numHorizontal,
    numVertical,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  final image = await completer.future;
  return (image, PotentialFieldGridSize(numHorizontal, numVertical));
}

/// Voltage color field — WebGL-density samples, NEAREST stretch (like WebGL).
class ElectricPotentialGridPainter extends CustomPainter {
  ElectricPotentialGridPainter({
    required this.model,
    required this.mvt,
    this.cachedImage,
    this.numHorizontal = 0,
    this.numVertical = 0,
  });

  final ChargesAndFieldsModel model;
  final CafMvt mvt;
  final ui.Image? cachedImage;
  final int numHorizontal;
  final int numVertical;

  @override
  void paint(Canvas canvas, Size size) {
    if (!model.isElectricPotentialVisible) return;
    if (model.activeChargedParticles.isEmpty) return;

    final bounds = model.enlargedBounds;
    final topLeft = mvt.modelToView(CafVec2(bounds.minX, bounds.maxY));
    final bottomRight = mvt.modelToView(CafVec2(bounds.maxX, bounds.minY));
    final dest = Rect.fromPoints(topLeft, bottomRight);

    if (cachedImage != null && numHorizontal > 0 && numVertical > 0) {
      // WebGL uses NEAREST — keep none when sample density ≈ view pixels.
      canvas.drawImageRect(
        cachedImage!,
        Rect.fromLTWH(
          0,
          0,
          numHorizontal.toDouble(),
          numVertical.toDouble(),
        ),
        dest,
        Paint()..filterQuality = FilterQuality.none,
      );
      return;
    }

    // Sync fallback — Canvas spacing; same Y orientation as Image (top = maxY)
    final fallbackSpacing = CafConstants.electricPotentialSensorSpacing;
    final fbH = (bounds.width / fallbackSpacing).ceil();
    final fbV = (bounds.height / fallbackSpacing).ceil();
    final cellW = dest.width / fbH;
    final cellH = dest.height / fbV;
    for (var row = 0; row < fbV; row++) {
      final y = bounds.maxY - (row + 0.5) * bounds.height / fbV;
      for (var col = 0; col < fbH; col++) {
        final x = bounds.minX + (col + 0.5) * bounds.width / fbH;
        final v = CafPotentialColors.samplePotential(model, CafVec2(x, y));
        final color = CafPotentialColors.forField(v);
        canvas.drawRect(
          Rect.fromLTWH(
            dest.left + col * cellW,
            dest.top + row * cellH,
            cellW + 0.5,
            cellH + 0.5,
          ),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ElectricPotentialGridPainter oldDelegate) =>
      oldDelegate.cachedImage != cachedImage ||
      oldDelegate.numHorizontal != numHorizontal ||
      oldDelegate.model.isElectricPotentialVisible !=
          model.isElectricPotentialVisible ||
      oldDelegate.model.activeChargedParticles.length !=
          model.activeChargedParticles.length;
}

/// Equipotential lines — Path stroke width 1, color #32FF64 (ElectricPotentialLineView).
class EquipotentialLinesPainter extends CustomPainter {
  EquipotentialLinesPainter({
    required this.model,
    required this.mvt,
  });

  final ChargesAndFieldsModel model;
  final CafMvt mvt;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CafColors.electricPotentialLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..isAntiAlias = true;

    for (final line in model.electricPotentialLines) {
      final pts = line.getPrunedPositionArray();
      if (pts.length < 2) continue;
      final path = Path();
      final first = mvt.modelToView(pts.first);
      path.moveTo(first.dx, first.dy);
      final segments = line.isLineClosed ? pts.length : pts.length - 1;
      for (var i = 1; i < segments + 1; i++) {
        final p = mvt.modelToView(pts[i % pts.length]);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);

      if (model.areValuesVisible) {
        final labelPos = mvt.modelToView(line.voltageLabelPosition);
        // ElectricPotentialLineView: toFixed(2) if |V|<1 else toFixed(1)
        final ep = line.electricPotential;
        final text = absFixedVoltage(ep);
        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(color: CafColors.voltageLabel, fontSize: 14),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        final bg = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            labelPos.dx - tp.width / 2 - 4,
            labelPos.dy - tp.height / 2 - 2,
            tp.width + 8,
            tp.height + 4,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(bg, Paint()..color = CafColors.voltageLabelBackground);
        tp.paint(
          canvas,
          Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
        );
      }
    }
  }

  /// VoltageLabel formatting from ElectricPotentialLineView.
  static String absFixedVoltage(double electricPotential) {
    final s = electricPotential.abs() < 1
        ? electricPotential.toStringAsFixed(2)
        : electricPotential.toStringAsFixed(1);
    return '$s V';
  }

  /// Port of ElectricPotentialSensorNode.decimalAdjust.
  static String decimalAdjust(double number, {int maxDecimalPlaces = 3}) {
    final absolute = number.abs();
    if (absolute == 0) return number.toStringAsFixed(maxDecimalPlaces);
    final exponent = (math.log(absolute) / math.ln10).floor();
    late int decimalPlaces;
    if (exponent >= maxDecimalPlaces) {
      decimalPlaces = 0;
    } else if (exponent > 0) {
      decimalPlaces = maxDecimalPlaces - exponent;
    } else {
      decimalPlaces = maxDecimalPlaces;
    }
    return number.toStringAsFixed(decimalPlaces);
  }

  @override
  bool shouldRepaint(covariant EquipotentialLinesPainter oldDelegate) => true;
}
