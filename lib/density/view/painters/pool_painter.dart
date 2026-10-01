import 'package:flutter/material.dart';

import '../../density_colors.dart';
import '../../model/density_vec.dart';
import '../../render/density_mvt.dart';
import '../../render/density_render_data.dart';

class PoolPainter extends CustomPainter {
  PoolPainter(this.data);

  final DensityRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    final mvt = data.mvt;
    _paintSky(canvas, size);
    _paintGround(canvas, mvt);
    _paintPool(canvas, mvt);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(DensityColors.skyTop),
          Color(DensityColors.skyBottom),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, sky);
  }

  void _paintGround(Canvas canvas, DensityMvt mvt) {
    final y0 = mvt.toScreen(const DensityVec(0, 0)).dy;
    final ground = Rect.fromLTRB(0, y0, mvt.canvasSize.width, mvt.canvasSize.height);
    canvas.drawRect(ground, Paint()..color = Color(DensityColors.ground));
    final grassH = mvt.toScreenDelta(0.04);
    canvas.drawRect(
      Rect.fromLTRB(0, y0 - grassH * 0.15, mvt.canvasSize.width, y0 + grassH),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color(DensityColors.grassFar),
            Color(DensityColors.grassClose),
          ],
        ).createShader(Rect.fromLTWH(0, y0 - grassH, mvt.canvasSize.width, grassH * 2)),
    );
  }

  void _paintPool(Canvas canvas, DensityMvt mvt) {
    final left = mvt.toScreen(DensityVec(DensityMvt.poolMinX, DensityMvt.poolMaxY));
    final right = mvt.toScreen(DensityVec(DensityMvt.poolMaxX, DensityMvt.poolMaxY));
    final floor = mvt.toScreen(DensityVec(DensityMvt.poolMinX, DensityMvt.poolMinY));
    final poolRect = Rect.fromLTRB(left.dx, left.dy, right.dx, floor.dy);
    canvas.drawRect(
      poolRect,
      Paint()..color = const Color(0xFF4A3728),
    );
    final surfaceY = mvt.toScreen(DensityVec(0, data.fluidSurfaceY)).dy;
    final waterRect = Rect.fromLTRB(
      poolRect.left,
      surfaceY.clamp(poolRect.top, poolRect.bottom),
      poolRect.right,
      poolRect.bottom,
    );
    canvas.drawRect(
      waterRect,
      Paint()..color = const Color(0xAA4BA3D4),
    );
    canvas.drawLine(
      Offset(poolRect.left, surfaceY),
      Offset(poolRect.right, surfaceY),
      Paint()
        ..color = Color(DensityColors.poolSurface)
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      poolRect,
      Paint()
        ..color = const Color(0xFF2C2118)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(PoolPainter oldDelegate) => oldDelegate.data != data;
}
