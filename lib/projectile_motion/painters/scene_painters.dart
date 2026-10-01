import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../pm_assets.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';
import '../transform/pm_transform.dart';
import '../view/pm_image_cache.dart';

/// BackgroundNode.ts：天空渐变 / 草地 / 路面 / 黄虚线 / Flatirons / david。
class PmBackgroundPainter extends CustomPainter {
  PmBackgroundPainter({
    required this.transform,
    required this.images,
    required this.flatironsVisible,
  });

  final PmTransform transform;
  final PmImageCache images;
  final bool flatironsVisible;

  static const double _cementWidth = 20; // BackgroundNode:21
  static const double _grassAboveRoad = 4; // :22
  static const double _yellowLineWidth = 1.5; // :23
  static const double _flatironsWidth = 450; // :25
  static const double _flatironsLeft = 8; // :26 m

  @override
  void paint(Canvas canvas, Size size) {
    final originY = PmConstants.viewOrigin.dy;

    // 天空（:64-66）：LinearGradient (0,0)→(0, 2h/3)
    final skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, 2 * size.height / 3),
        const [PmColors.skyTop, PmColors.skyBottom],
      );
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Flatirons（:74, 83-85）：bottom=VIEW_ORIGIN.y, left=modelToViewX(8)
    if (flatironsVisible) {
      final flatirons = images[PmAssets.flatirons];
      if (flatirons != null) {
        final w = _flatironsWidth;
        final h = w * flatirons.height / flatirons.width;
        canvas.drawImageRect(
          flatirons,
          Rect.fromLTWH(
              0, 0, flatirons.width.toDouble(), flatirons.height.toDouble()),
          Rect.fromLTWH(transform.modelToViewDeltaX(_flatironsLeft) +
                  PmConstants.viewOrigin.dx -
                  0, // modelToViewX(8)
              originY - h, w, h),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }
    }

    // 草地（:70）：road.top − 4 向下
    final roadTop = originY - _cementWidth / 2;
    canvas.drawRect(
      Rect.fromLTRB(0, roadTop - _grassAboveRoad, size.width, size.height),
      Paint()..color = PmColors.grass,
    );

    // 路面（:68）
    canvas.drawRect(
      Rect.fromLTRB(0, roadTop, size.width, roadTop + _cementWidth),
      Paint()..color = PmColors.road,
    );

    // 黄虚线（:71）
    final dashPaint = Paint()
      ..color = PmColors.roadDashedLine
      ..strokeWidth = _yellowLineWidth;
    const dash = 10.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
          Offset(x, originY), Offset(x + dash, originY), dashPaint);
      x += dash * 2;
    }

    // david（Model:220-221）：2m @ (7,0)，bottom 对齐地面
    final david = images[PmAssets.david];
    if (david != null) {
      final h = transform.modelToViewDeltaY(PmConstants.davidHeight);
      final w = h * david.width / david.height;
      final base = transform.modelToView(PmConstants.davidPosition);
      canvas.drawImageRect(
        david,
        Rect.fromLTWH(0, 0, david.width.toDouble(), david.height.toDouble()),
        Rect.fromLTWH(base.dx - w / 2, base.dy - h, w, h),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
  }

  @override
  bool shouldRepaint(PmBackgroundPainter oldDelegate) =>
      oldDelegate.transform.zoom != transform.zoom ||
      oldDelegate.flatironsVisible != flatironsVisible ||
      oldDelegate.images.isLoaded != images.isLoaded;
}
