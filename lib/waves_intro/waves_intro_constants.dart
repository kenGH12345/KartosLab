import 'dart:math' as math;

/// Constants from PhET `WaveInterferenceConstants.ts`, `WavesModel.ts`,
/// `WaveInterferenceQueryParameters.ts`, and `VisibleColor.ts`.
///
/// [已确认] latticeSize default 151; LATTICE_PADDING=20; CALIBRATION_SCALE.
class WavesIntroConstants {
  WavesIntroConstants._();

  // —— Lattice / calibration ——
  static const int latticeSize = 151;
  static const int latticePadding = 20;

  /// `(151-40)/(101-40)` — [已确认] WaveInterferenceConstants.ts
  static const double calibrationScale =
      (latticeSize - latticePadding * 2) / (101 - 20 * 2);

  static final int pointSourceHorizontal =
      _roundSymmetric(3 * calibrationScale) + latticePadding;

  static const double amplitudeMin = 0;
  static const double amplitudeMax = 10;
  static const double initialAmplitude = 8;
  static const double amplitudeCalibrationScale = 1.2;

  static const double waveSpeed = 0.5;
  static const double waveSpeedSquared = 0.25;

  /// [已确认] WavesModel.ts: `20 * CALIBRATION_SCALE`
  static const double eventRate = 20 * calibrationScale;

  static const double femto = 1e-15;

  // VisibleColor (nm / Hz) — [已确认] scenery-phet VisibleColor.ts
  static const double speedOfLightMs = 299792458;
  static const double violetWavelengthNm = 380;
  static const double redWavelengthNm = 780;
  static const double minFrequencyHz =
      speedOfLightMs / redWavelengthNm * 1e9;
  static const double maxFrequencyHz =
      speedOfLightMs / violetWavelengthNm * 1e9;

  static double toFemto(double value) => value * femto;

  // —— Scene physics (WavesModel.ts) ——
  static const double waterFreqMin = 0.25;
  static const double waterFreqMax = 1.0;
  static const double waterWaveSpeed = 1.65;
  static const double waterTimeScale = 1.0;
  static const double waterWaveAreaWidth = 10;

  static const double soundFreqMin = 220 / 1000;
  static const double soundFreqMax = 440 / 1000;
  static const double soundWaveSpeed = 34.3;
  static const double soundTimeScale = 244.7 / 103.939 * 35.24 / 34.3;
  static const double soundWaveAreaWidth = 500;

  static final double lightFreqMin = toFemto(minFrequencyHz);
  static final double lightFreqMax = toFemto(maxFrequencyHz);
  static const double lightWaveSpeed = 299.792458;
  static const double lightTimeScale = 1416.5 / 511.034;
  static const double lightWaveAreaWidth = 5000;

  // —— Sound particles ——
  static const int soundParticleRows = 20;
  static const int soundParticleColumns = 20;
  static const double soundParticleRandomRadius = 2;
  static const double soundParticleGradientForceScale = 0.67;
  static const int soundParticleSeed = 42;

  // —— Layout (PhET ScreenView.DEFAULT 1024×618 + WavesScreenView.ts) ——
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  /// [已确认] WaveInterferenceConstants.WAVE_AREA_WIDTH
  static const double waveAreaViewSize = 500;

  /// [已确认] WaveInterferenceConstants.PANEL_MAX_WIDTH
  static const double panelMaxWidth = 200;
  static const double controlColumnWidth = panelMaxWidth;

  static const double bottomBarHeight = 56;

  /// [已确认] WaveInterferenceConstants.MARGIN
  static const double layoutMargin = 8;

  /// [已确认] WavesScreenView.ts WAVE_MARGIN / SPACING
  static const double waveMargin = 8;
  static const double layoutSpacing = 6;

  /// `waveAreaNode.top = MARGIN + WAVE_MARGIN + 15`
  static const double waveAreaTop = layoutMargin + waveMargin + 15;

  /// `waveAreaNode.centerX = layoutBounds.centerX - 142`
  static const double waveAreaCenterX = layoutWidth / 2 - 142;

  static const double waveAreaLeft = waveAreaCenterX - waveAreaViewSize / 2;
  static const double waveAreaRight = waveAreaLeft + waveAreaViewSize;
  static const double waveAreaBottom = waveAreaTop + waveAreaViewSize;
  static const double waveAreaCenterY = waveAreaTop + waveAreaViewSize / 2;

  /// [已确认] LatticeCanvasNode WATER_BLUE / WaveAreaNode sound fill
  static const int waterLatticeBaseArgb = 0xFF58C0FA;
  static const int soundWaveAreaFillArgb = 0xFF4C4C4C;

  /// LatticeCanvasNode intensity mapping
  static const double latticeCutoff = 0.4;
  static const double latticeMinShade = 0.03;
  /// Wave meter chart — [已确认] WaveMeterNode SeismographNode
  static const double waveMeterChartWidth = 150;
  static const double waveMeterChartHeight = 110;
  static const ColorAccent waterAccent = ColorAccent(0xFF1177AA);
  static const ColorAccent soundAccent = ColorAccent(0xFF64748B);
  static const ColorAccent lightAccent = ColorAccent(0xFFDB2777);
  static const int waveGeneratorButtonColor = 0xFF33DD33;

  static int _roundSymmetric(double n) {
    return n < 0 ? -(-n).round() : n.round();
  }

  static double rangeMidpoint(double min, double max) => (min + max) / 2;

  static double wavelength({
    required double waveSpeedValue,
    required double frequency,
  }) =>
      waveSpeedValue / frequency;

  /// Approximate visible wavelength color (nm → RGB). [视觉近似]
  static int wavelengthToArgb(double wavelengthNm) {
    final w = wavelengthNm.clamp(violetWavelengthNm, redWavelengthNm);
    late double r, g, b;
    if (w < 440) {
      r = -(w - 440) / (440 - 380);
      g = 0;
      b = 1;
    } else if (w < 490) {
      r = 0;
      g = (w - 440) / (490 - 440);
      b = 1;
    } else if (w < 510) {
      r = 0;
      g = 1;
      b = -(w - 510) / (510 - 490);
    } else if (w < 580) {
      r = (w - 510) / (580 - 510);
      g = 1;
      b = 0;
    } else if (w < 645) {
      r = 1;
      g = -(w - 645) / (645 - 580);
      b = 0;
    } else {
      r = 1;
      g = 0;
      b = 0;
    }
    var factor = 1.0;
    if (w < 420) {
      factor = 0.3 + 0.7 * (w - 380) / (420 - 380);
    } else if (w > 700) {
      factor = 0.3 + 0.7 * (780 - w) / (780 - 700);
    }
    int ch(double v) => (v * factor * 255).clamp(0, 255).round();
    return 0xFF000000 | (ch(r) << 16) | (ch(g) << 8) | ch(b);
  }

  static double linear(
    double x0,
    double x1,
    double y0,
    double y1,
    double x,
  ) {
    if ((x1 - x0).abs() < 1e-12) return y0;
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
  }

  static double gaussian(math.Random rng) {
    // Box-Muller
    final u1 = math.max(rng.nextDouble(), 1e-12);
    final u2 = rng.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }
}

/// Tiny color holder to avoid importing Flutter in constants used by tests.
class ColorAccent {
  const ColorAccent(this.value);
  final int value;
}
