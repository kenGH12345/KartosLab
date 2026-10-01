import 'package:flutter/material.dart';

import '../../domain/detector_mode.dart';
import '../../domain/hit.dart';
import '../../render_data/high_intensity/wave_field_render_data.dart';
import '../../view/common/qwi_layout.dart';
import '../../view/layout/high_intensity_layout_spec.dart';
import '../common/screen_brightness_utils.dart';

/// HI detector: time-averaged PDF or hits — parallelogram skewed at PhET 20°.
class HiDetectorRenderer {
  const HiDetectorRenderer();

  void paint(Canvas canvas, HiDetectorRenderData data, {Rect? rect}) {
    final r = rect ?? QwiLayout.hiDetectorRect;
    final skew = HighIntensityLayoutConstants.detectorSkew *
        HighIntensityLayoutConstants.detectorVisibleFraction;

    final path = Path()
      ..moveTo(r.left, r.top + skew)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right, r.bottom - skew)
      ..lineTo(r.left, r.bottom)
      ..close();

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, Paint()..color = Colors.black);

    if (data.detectionMode == DetectorMode.hits) {
      _paintHits(canvas, data, r, skew);
    } else {
      _paintIntensity(canvas, data, r, skew);
    }
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF666666)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintIntensity(Canvas canvas, HiDetectorRenderData data, Rect r, double skew) {
    if (!data.isEmitting || data.pdf.isEmpty) {
      return;
    }
    final color = ScreenBrightnessUtils.getSceneColor(data.sourceType, data.wavelengthNm);
    final gain = ScreenBrightnessUtils.getIntensityDisplayGain(data.brightness, 1) *
        data.formationFactor.clamp(0.0, 1.0);
    final n = data.pdf.length;
    final bandH = r.height / n;
    for (var i = 0; i < n; i++) {
      final pdfIndex = n - 1 - i;
      final intensity = (data.pdf[pdfIndex] * gain).clamp(0.0, 1.0);
      if (intensity < ScreenBrightnessUtils.perceptualVisibilityThreshold) {
        continue;
      }
      // Horizontal strip; clipPath already applies parallelogram.
      canvas.drawRect(
        Rect.fromLTWH(r.left, r.top + i * bandH, r.width, bandH + 0.5),
        Paint()..color = Color.lerp(Colors.black, color, intensity)!,
      );
    }
  }

  void _paintHits(Canvas canvas, HiDetectorRenderData data, Rect r, double skew) {
    final color = ScreenBrightnessUtils.getSceneColor(data.sourceType, data.wavelengthNm);
    final frac = ScreenBrightnessUtils.getHitsBrightnessFraction(data.brightness);
    final coreA = ScreenBrightnessUtils.getHitsCoreAlpha(frac);
    final coreR = ScreenBrightnessUtils.baseHitCoreRadius;
    for (final hit in data.hits) {
      if (hit.domain != DetectorHitDomain.waveRegion) {
        continue;
      }
      final t = hit.y.clamp(0.0, 1.0);
      final dy = r.top + t * r.height;
      // Interpolate horizontal inset along skew so hits sit inside the parallelogram.
      final xShift = skew * (0.5 - t); // rough centerline lean
      final dx = r.left + r.width * 0.5 + hit.x * r.width * 0.35 + xShift * 0.15;
      canvas.drawCircle(Offset(dx, dy), coreR, Paint()..color = color.withValues(alpha: coreA));
    }
  }
}

class HiDetectorPainter extends CustomPainter {
  HiDetectorPainter({required this.data, this.rect});

  final HiDetectorRenderData data;
  final Rect? rect;

  @override
  void paint(Canvas canvas, Size size) {
    const HiDetectorRenderer().paint(canvas, data, rect: rect);
  }

  @override
  bool shouldRepaint(covariant HiDetectorPainter oldDelegate) {
    return oldDelegate.data.pdf != data.pdf ||
        oldDelegate.data.hits.length != data.hits.length ||
        oldDelegate.data.formationFactor != data.formationFactor ||
        oldDelegate.data.detectionMode != data.detectionMode ||
        oldDelegate.data.brightness != data.brightness;
  }
}
