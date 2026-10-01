import 'package:flutter/material.dart';

import '../model/intensity_sample.dart';
import '../model/lattice.dart';
import '../model/water_side_geometry.dart';
import '../waves_intro_constants.dart';

/// Light screen at right of wave area — [已确认] LightScreenNode @ 31ebfd7
///
/// Uses IntensitySample values (not Widget-computed). Intro: piecewise brightness,
/// averaging window 40 (BaseScreen options).
class LightScreenPainter extends CustomPainter {
  LightScreenPainter({
    required this.lattice,
    required this.intensitySample,
    required this.baseColor,
    this.averagingWindowSize = 40,
  });

  final Lattice lattice;
  final IntensitySample intensitySample;
  final Color baseColor;

  /// [已确认] BaseScreen lightScreenAveragingWindowSize: 40
  final int averagingWindowSize;

  static const double canvasWidth = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final intensities = intensitySample.getIntensityValues();
    if (intensities.isEmpty) return;

    final h = intensities.length;
    final rowH = size.height / h;
    final windowRadius = averagingWindowSize;

    for (var k = 0; k < h; k++) {
      var sum = intensities[k];
      var count = 1;
      for (var i = 1; i < windowRadius; i++) {
        if (k + i < h) {
          sum += intensities[k + i];
          count++;
        }
        if (k - i >= 0) {
          sum += intensities[k - i];
          count++;
        }
      }
      final intensity = sum / count;
      final brightness =
          WaterSideGeometry.piecewiseBrightness(intensity).clamp(0.0, 1.0);
      final color = Color.fromARGB(
        255,
        ((baseColor.r * 255.0) * brightness).round().clamp(0, 255),
        ((baseColor.g * 255.0) * brightness).round().clamp(0, 255),
        ((baseColor.b * 255.0) * brightness).round().clamp(0, 255),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, k * rowH, size.width, rowH + 0.5),
        Paint()..color = color,
      );
    }

    // Subtle shear hint (orthogonal look) — [视觉近似] vs Matrix3 shear -0.3
    // Applied by parent Transform; painter itself is upright column.
  }

  @override
  bool shouldRepaint(covariant LightScreenPainter oldDelegate) => true;
}

/// Base color from light frequency (approx VisibleColor).
Color lightBaseColorFromWavelengthNm(double wavelengthNm) {
  final argb = WavesIntroConstants.wavelengthToArgb(wavelengthNm);
  return Color(argb);
}
