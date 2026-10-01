import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/render/esp_render_data.dart';

/// Skater figure — PhET PNG assets; bottom-center registration (SkaterNode.ts).
class SkaterPainter extends CustomPainter {
  SkaterPainter({
    required this.data,
    this.leftImage,
    this.rightImage,
  });

  final EspRenderData data;
  final ui.Image? leftImage;
  final ui.Image? rightImage;

  @override
  void paint(Canvas canvas, Size size) {
    final c = data.skaterCenter;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(data.skaterAngle);

    final scale = data.skaterMassScale;
    final img = data.skaterDirectionLeft ? leftImage : rightImage;
    if (img != null) {
      final w = img.width * scale;
      final h = img.height * scale;
      // Registration: bottom center (SkaterNode matrix translation -w/2, -h).
      final rect = Rect.fromLTWH(-w / 2, -h, w, h);
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        rect,
        Paint(),
      );
    } else {
      final facing = data.skaterDirectionLeft ? -1.0 : 1.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 36 * scale, height: 8 * scale),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF333333),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(2 * facing, -18 * scale),
          width: 16 * scale,
          height: 28 * scale,
        ),
        Paint()..color = EspColors.skaterBody,
      );
      canvas.drawCircle(
        Offset(2 * facing, -36 * scale),
        8 * scale,
        Paint()..color = const Color(0xFFFFDBAC),
      );
    }

    // Particle model point (red dot) — constant screen size (SkaterNode circle radius 3.5/scale).
    canvas.drawCircle(
      Offset.zero,
      3.5 / scale,
      Paint()..color = EspColors.particleCircle,
    );

    canvas.restore();

    if (data.speedVisible) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${data.speed.toStringAsFixed(1)} m/s',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(c.dx + 20, c.dy - 50));
    }
  }

  @override
  bool shouldRepaint(covariant SkaterPainter old) =>
      old.data.skaterCenter != data.skaterCenter ||
      old.data.skaterAngle != data.skaterAngle ||
      old.data.skaterMassScale != data.skaterMassScale ||
      old.data.speed != data.speed ||
      old.data.speedVisible != data.speedVisible ||
      old.data.skaterDirectionLeft != data.skaterDirectionLeft ||
      old.leftImage != leftImage ||
      old.rightImage != rightImage;
}
