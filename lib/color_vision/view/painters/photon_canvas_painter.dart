import 'package:flutter/material.dart';
import 'package:kratos/color_vision/model/cv_photon.dart';

/// Draw photons as 3×2 rects (PhET CanvasNode fillRect).
class PhotonCanvasPainter extends CustomPainter {
  PhotonCanvasPainter({
    required this.photons,
    this.fixedColor,
    this.skipZeroIntensity = false,
  });

  final List<RgbPhoton> photons;

  /// When set (RGB beams), all photons use this fill; otherwise use
  /// [SingleBulbPhoton.color].
  final Color? fixedColor;

  /// RGB beams skip intensity-0 black sentinel photons.
  final bool skipZeroIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in photons) {
      if (skipZeroIntensity && p.intensity == 0) continue;
      if (fixedColor != null) {
        paint.color = fixedColor!;
      } else if (p is SingleBulbPhoton) {
        paint.color = p.color;
      } else {
        continue;
      }
      canvas.drawRect(Rect.fromLTWH(p.x, p.y, 3, 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PhotonCanvasPainter oldDelegate) => true;
}
