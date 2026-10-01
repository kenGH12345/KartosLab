import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/balloons_static_electricity_constants.dart';
import '../model/base_vec2.dart';
import '../model/point_charge_model.dart';

/// Programmatic ± charge glyphs — PhET `ChargeNode` / `PlusChargeNode` / `MinusChargeNode`.
abstract final class ChargeGlyph {
  static const double radius = BaseConstants.pointChargeRadius; // 8
  static const double barLength = 11;
  static const double barWidth = 2;

  static ui.Image? _plusImage;
  static ui.Image? _minusImage;

  static Future<void> ensureRasterized() async {
    _plusImage ??= await _rasterize(isPlus: true);
    _minusImage ??= await _rasterize(isPlus: false);
  }

  static ui.Image? get plusImage => _plusImage;
  static ui.Image? get minusImage => _minusImage;

  static Future<ui.Image> _rasterize({required bool isPlus}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(radius + 1, radius + 1);
    _paintCharge(canvas, center, isPlus: isPlus);
    final picture = recorder.endRecording();
    final size = ((radius + 1) * 2 * 2).ceil(); // IMAGE_SCALE=2 padding
    return picture.toImage(size, size);
  }

  static void paintAt(
    Canvas canvas,
    Offset center, {
    required bool isPlus,
  }) {
    _paintCharge(canvas, center, isPlus: isPlus);
  }

  static void _paintCharge(
    Canvas canvas,
    Offset center, {
    required bool isPlus,
  }) {
    final gradient = RadialGradient(
      center: const Alignment(0.25, -0.4),
      radius: 1,
      colors: isPlus
          ? const [
              Color(0xFFF97D7D),
              Color(0xFFED4545),
              Color(0xFFFF0000),
            ]
          : const [
              Color(0xFF0FBBFF),
              Color(0xFF009DD6),
              Color(0xFF0092C7),
            ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final barPaint = Paint()..color = Colors.white;
    // Horizontal bar
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: barLength,
        height: barWidth,
      ),
      barPaint,
    );
    if (isPlus) {
      canvas.drawRect(
        Rect.fromCenter(
          center: center,
          width: barWidth,
          height: barLength,
        ),
        barPaint,
      );
    }
  }
}

/// Draws a list of ± charges at absolute positions (model coords).
class ChargesPainter extends CustomPainter {
  ChargesPainter({
    required this.plusCenters,
    required this.minusCenters,
    required this.plusVisible,
    required this.minusVisible,
  });

  final List<BaseVec2> plusCenters;
  final List<BaseVec2> minusCenters;
  final List<bool> plusVisible;
  final List<bool> minusVisible;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < plusCenters.length; i++) {
      if (i < plusVisible.length && !plusVisible[i]) continue;
      final p = plusCenters[i];
      ChargeGlyph.paintAt(
        canvas,
        Offset(p.x + PointChargeModel.radius, p.y + PointChargeModel.radius),
        isPlus: true,
      );
    }
    for (var i = 0; i < minusCenters.length; i++) {
      if (i < minusVisible.length && !minusVisible[i]) continue;
      final p = minusCenters[i];
      ChargeGlyph.paintAt(
        canvas,
        Offset(p.x + PointChargeModel.radius, p.y + PointChargeModel.radius),
        isPlus: false,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ChargesPainter oldDelegate) => true;
}

/// Wall charges canvas — PhET `ChargesCanvasNode`.
///
/// Plus/minus model positions are upper-left. At rest, PhET paints plus so it
/// appears up-and-left of minus (red crescent behind blue), via
/// `PLUS_CHARGE_OFFSET` + `IMAGE_PADDING` — not coincident centers.
class WallChargesPainter extends CustomPainter {
  WallChargesPainter({
    required this.wallX,
    required this.plusPositions,
    required this.minusPositions,
  });

  final double wallX;
  final List<BaseVec2> plusPositions;
  final List<BaseVec2> minusPositions;

  /// PhET `ChargesCanvasNode.PLUS_CHARGE_OFFSET`.
  static const double plusChargeOffset = 8;

  /// PhET `BASEConstants.IMAGE_PADDING`.
  static const double imagePadding = 1;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw plus first, then minus (PhET layering).
    // paintAt uses circle *center*; PhET drawImage uses image TL of ChargeNode
    // whose circle center sits at IMAGE_PADDING after ChargeNode.translate.
    for (final p in plusPositions) {
      ChargeGlyph.paintAt(
        canvas,
        Offset(
          p.x - wallX - plusChargeOffset + imagePadding,
          p.y - plusChargeOffset + imagePadding,
        ),
        isPlus: true,
      );
    }
    for (final p in minusPositions) {
      ChargeGlyph.paintAt(
        canvas,
        Offset(
          p.x - wallX + PointChargeModel.radius - imagePadding,
          p.y + PointChargeModel.radius - imagePadding,
        ),
        isPlus: false,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WallChargesPainter oldDelegate) => true;
}
