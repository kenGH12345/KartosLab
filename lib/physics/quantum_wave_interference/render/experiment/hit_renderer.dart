import 'package:flutter/material.dart';

import '../../render_data/experiment/hit_render_data.dart';
import '../../view/common/qwi_coordinate_transform.dart';
import '../common/screen_brightness_utils.dart';

/// Canvas hit stamps — never one Widget per hit.
class HitRenderer {
  const HitRenderer();

  void paint(
    Canvas canvas,
    HitRenderData data,
    QwiCoordinateTransform transform,
  ) {
    final sceneColor = ScreenBrightnessUtils.getSceneColor(data.sourceType, data.wavelengthNm);
    final brightnessFraction = ScreenBrightnessUtils.getHitsBrightnessFraction(data.brightness);
    final coreAlpha = ScreenBrightnessUtils.getHitsCoreAlpha(brightnessFraction);
    final glowAlpha = ScreenBrightnessUtils.getHitsGlowAlpha(brightnessFraction);
    final displayGain = ScreenBrightnessUtils.getHitsDisplayGain(data.brightness);
    final coreR = ScreenBrightnessUtils.baseHitCoreRadius * displayGain.clamp(0.5, 2.0);
    final glowR = ScreenBrightnessUtils.baseHitGlowRadius * displayGain.clamp(0.5, 2.0);

    for (final hit in data.hits) {
      if (!transform.isNormalizedXVisible(hit.x)) {
        continue;
      }
      final dx = transform.normalizedXToDesignX(hit.x);
      final dy = transform.normalizedYToDesignY(hit.y);
      final center = Offset(dx, dy);
      if (glowAlpha > 0) {
        canvas.drawCircle(
          center,
          glowR,
          Paint()..color = sceneColor.withValues(alpha: glowAlpha),
        );
      }
      canvas.drawCircle(
        center,
        coreR,
        Paint()..color = sceneColor.withValues(alpha: coreAlpha),
      );
    }
  }
}

class HitPainter extends CustomPainter {
  HitPainter({
    required this.data,
    required this.transform,
  });

  final HitRenderData data;
  final QwiCoordinateTransform transform;

  @override
  void paint(Canvas canvas, Size size) {
    const HitRenderer().paint(canvas, data, transform);
  }

  @override
  bool shouldRepaint(covariant HitPainter oldDelegate) {
    return oldDelegate.data.hits.length != data.hits.length ||
        oldDelegate.data.brightness != data.brightness ||
        oldDelegate.data.wavelengthNm != data.wavelengthNm ||
        oldDelegate.transform.scaleIndex != transform.scaleIndex;
  }
}
