import 'package:flutter/material.dart';

import '../../render/density_render_data.dart';
import 'cuboid_painter.dart';
import 'pool_painter.dart';

/// Mystery floor scale. Size from `Scale.ts` SCALE_WIDTH/HEIGHT.
class ScalePainter extends CustomPainter {
  ScalePainter(this.data);

  final DensityRenderData data;

  static const double scaleWidth = 0.15;
  static const double scaleHeight = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = data.scale;
    if (scale == null) return;
    final mvt = data.mvt;
    final center = mvt.toScreen(scale.position);
    final w = mvt.toScreenDelta(scaleWidth);
    final h = mvt.toScreenDelta(scaleHeight);
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF6B7280),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -h * 0.15),
          width: w * 0.92,
          height: h * 0.45,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFD1D5DB),
    );
    final label = '${scale.massKg.toStringAsFixed(2)} kg';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2 - h * 0.12),
    );
  }

  @override
  bool shouldRepaint(ScalePainter oldDelegate) => oldDelegate.data != data;
}

/// Combined scene. Painters still do not mutate model.
class DensityScenePainter extends CustomPainter {
  DensityScenePainter(this.data);

  final DensityRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    PoolPainter(data).paint(canvas, size);
    ScalePainter(data).paint(canvas, size);
    CuboidPainter(data).paint(canvas, size);
  }

  @override
  bool shouldRepaint(DensityScenePainter oldDelegate) => oldDelegate.data != data;
}
