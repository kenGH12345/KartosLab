import 'dart:ui';

import 'package:kratos/color_vision/model/visible_color.dart';

import '../../constants/qwi_constants.dart';
import '../../domain/source_type.dart';

/// Port of `ScreenBrightnessUtils.ts` (view-only; never feeds solvers).
class ScreenBrightnessUtils {
  ScreenBrightnessUtils._();

  static const double perceptualVisibilityThreshold = 0.004;
  static const double baseHitCoreRadius = 2.0;
  static const double baseHitGlowRadius = 3.4;

  static const double intensityScreenBrightnessMinMultiplier = 1.2;
  static const double intensityScreenBrightnessMaxMultiplier = 6.0;
  static const double intensityBrightnessMaxMultiplier = 0.8;
  static const double computedIntensityBrightnessMaxFraction = 0.25;

  static const double hitsScreenBrightnessMinMultiplier = 0.1;
  static const double hitsScreenBrightnessMaxMultiplier = 1.8;

  static const double hitsCoreAlphaMin = 0.2;
  static const double hitsCoreAlphaMidpointMax = 1;
  static const double hitsGlowAlphaMax = 0.15;
  static const double hitsGlowStartFraction = 0.5;

  static double _linear(double a1, double a2, double b1, double b2, double a) {
    if (a2 == a1) {
      return b1;
    }
    final t = ((a - a1) / (a2 - a1)).clamp(0.0, 1.0);
    return b1 + (b2 - b1) * t;
  }

  static double getIntensityScreenBrightnessMultiplier(double brightnessPercent) {
    final normalized = (brightnessPercent / QwiConstants.screenBrightnessMax).clamp(0.0, 1.0) *
        computedIntensityBrightnessMaxFraction;
    return _linear(
      0,
      1,
      intensityScreenBrightnessMinMultiplier,
      intensityScreenBrightnessMaxMultiplier,
      normalized,
    );
  }

  static double getHitsDisplayGain(double brightness, [double sliderMax = QwiConstants.screenBrightnessMax]) {
    return _linear(
      0,
      sliderMax,
      hitsScreenBrightnessMinMultiplier,
      hitsScreenBrightnessMaxMultiplier,
      brightness.clamp(0.0, sliderMax),
    );
  }

  static double getHitsBrightnessFraction(double brightness) =>
      (brightness / QwiConstants.screenBrightnessMax).clamp(0.0, 1.0);

  static double getHitsCoreAlpha(double brightnessFraction) {
    final f = brightnessFraction.clamp(0.0, 1.0);
    if (f <= hitsGlowStartFraction) {
      return _linear(0, hitsGlowStartFraction, hitsCoreAlphaMin, hitsCoreAlphaMidpointMax, f);
    }
    return hitsCoreAlphaMidpointMax;
  }

  static double getHitsGlowAlpha(double brightnessFraction) {
    final f = brightnessFraction.clamp(0.0, 1.0);
    if (f <= hitsGlowStartFraction) {
      return 0;
    }
    return _linear(hitsGlowStartFraction, 1, 0, hitsGlowAlphaMax, f);
  }

  static double getIntensityDisplayGain(double brightness, double intensity) {
    return getIntensityScreenBrightnessMultiplier(brightness) *
        intensity.clamp(0.0, 1.0) *
        intensityBrightnessMaxMultiplier;
  }

  static Color getSceneColor(SourceType sourceType, double wavelengthNm) {
    if (sourceType == SourceType.photons) {
      return VisibleColor.wavelengthToColor(wavelengthNm);
    }
    return const Color(0xFFFFFFFF);
  }
}
