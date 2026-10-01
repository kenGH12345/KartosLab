import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

/// Sky gradient + mountains + cement strip + ground (BackgroundNode.ts).
class BackgroundPainter extends CustomPainter {
  BackgroundPainter({
    required this.mvt,
    this.mountains,
    this.cementTexture,
  });

  final EspMvt mvt;
  final ui.Image? mountains;
  final ui.Image? cementTexture;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [EspColors.skyTop, EspColors.skyBottom],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final groundY = mvt.viewOrigin.dy;

    if (mountains != null) {
      final img = mountains!;
      final scale = EspConstants.mountainsScale;
      final h = img.height * scale * (size.height / EspConstants.layoutHeight);
      final w = img.width * scale * (size.height / EspConstants.layoutHeight);
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(
          size.width * 0.08,
          groundY - h + 4,
          w,
          h,
        ),
        image: img,
        fit: BoxFit.fill,
      );
    }

    final groundRect = Rect.fromLTRB(0, groundY, size.width, size.height);
    canvas.drawRect(groundRect, Paint()..color = EspColors.ground);

    // Cement strip with texture pattern (BackgroundNode.ts cementWidth = 5).
    final cementH = EspConstants.cementHeight;
    final cementRect = Rect.fromLTWH(0, groundY, size.width, cementH);
    if (cementTexture != null) {
      canvas.save();
      canvas.clipRect(cementRect);
      final img = cementTexture!;
      for (var x = cementRect.left; x < cementRect.right; x += img.width.toDouble()) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(x, cementRect.top, img.width.toDouble(), cementH),
          image: img,
          fit: BoxFit.fill,
        );
      }
      canvas.restore();
    } else {
      canvas.drawRect(cementRect, Paint()..color = const Color(0xFF6B6B6B));
    }

    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      Paint()
        ..color = EspColors.groundLine
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter old) =>
      old.mvt.viewOrigin != mvt.viewOrigin ||
      old.mvt.scale != mvt.scale ||
      old.mountains != mountains ||
      old.cementTexture != cementTexture;
}
