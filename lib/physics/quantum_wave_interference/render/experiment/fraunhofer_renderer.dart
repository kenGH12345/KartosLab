import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../render_data/experiment/fraunhofer_render_data.dart';
import '../../view/common/qwi_coordinate_transform.dart';
import '../common/screen_brightness_utils.dart';

/// Paints vertical intensity bands from [FraunhoferRenderData] into a detector rect.
///
/// Does not recompute physics — samples already come from [FraunhoferSolver].
class FraunhoferRenderer {
  const FraunhoferRenderer();

  void paint(
    Canvas canvas,
    Size size,
    FraunhoferRenderData data,
    QwiCoordinateTransform transform,
  ) {
    final rect = transform.detectorRect;
    canvas.drawRect(rect, Paint()..color = Colors.black);

    if (!data.isEmitting) {
      return;
    }

    final sceneColor = ScreenBrightnessUtils.getSceneColor(data.sourceType, data.wavelengthNm);
    final gain = ScreenBrightnessUtils.getIntensityDisplayGain(data.screenBrightness, data.sourceStrength);
    final n = data.intensities.length;
    if (n == 0) {
      return;
    }

    final bandWidth = rect.width / n;
    for (var i = 0; i < n; i++) {
      final intensity = (data.intensities[i] * gain).clamp(0.0, 1.0);
      if (intensity < ScreenBrightnessUtils.perceptualVisibilityThreshold) {
        continue;
      }
      final color = Color.lerp(Colors.black, sceneColor, intensity)!;
      canvas.drawRect(
        Rect.fromLTWH(rect.left + i * bandWidth, rect.top, bandWidth + 0.5, rect.height),
        Paint()..color = color,
      );
    }
  }

  /// Build a 1D intensity strip image (width × 1) for testing / caching.
  static ui.Image? debugUnused() => null;
}

/// CustomPainter wrapper for [FraunhoferRenderer].
class FraunhoferPainter extends CustomPainter {
  FraunhoferPainter({
    required this.data,
    required this.transform,
  });

  final FraunhoferRenderData data;
  final QwiCoordinateTransform transform;

  @override
  void paint(Canvas canvas, Size size) {
    const FraunhoferRenderer().paint(canvas, size, data, transform);
  }

  @override
  bool shouldRepaint(covariant FraunhoferPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.transform.scaleIndex != transform.scaleIndex ||
        oldDelegate.transform.detectorRect != transform.detectorRect;
  }
}
