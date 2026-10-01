/// Constants from PhET `BlackbodyConstants.js` + view layout values.
///
/// All physical constants are sourced directly from PhET source code:
/// [来源: phet/js/BlackbodyConstants.js:12-35]
/// [来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:19-25]
class BlackbodySpectrumConstants {
  BlackbodySpectrumConstants._();

  // —— Temperature bounds ——
  /// [来源: BlackbodyConstants.js:15]
  static const double minTemperature = 200;

  /// [来源: BlackbodyConstants.js:16]
  static const double maxTemperature = 11000;

  /// [来源: BlackbodyConstants.js:17]
  static const double earthTemperature = 250;

  /// [来源: BlackbodyConstants.js:18]
  static const double lightBulbTemperature = 3000;

  /// [来源: BlackbodyConstants.js:19]
  static const double sunTemperature = 5800;

  /// [来源: BlackbodyConstants.js:20]
  static const double siriusATemperature = 9950;

  // —— Wavelength region boundaries (nm) ——
  /// [来源: BlackbodyConstants.js:23]
  static const double xRayWavelength = 10;

  /// [来源: BlackbodyConstants.js:24]
  static const double ultravioletWavelength = 380;

  /// [来源: BlackbodyConstants.js:25]
  static const double visibleWavelength = 780;

  /// [来源: BlackbodyConstants.js:26]
  static const double infraredWavelength = 100000;

  // —— Zoom bounds ——
  /// [来源: BlackbodyConstants.js:29]
  static const double minHorizontalZoom = 750;

  /// [来源: BlackbodyConstants.js:30]
  static const double maxHorizontalZoom = 48000;

  /// [来源: BlackbodyConstants.js:31]
  static const double minVerticalZoom = 0.00001024;

  /// [来源: BlackbodyConstants.js:32]
  static const double maxVerticalZoom = 2500;

  // —— Physical constants (BlackbodyBodyModel.js) ——
  /// 2πhc² in W·m². [来源: BlackbodyBodyModel.js:82]
  static const double planckConstantA = 3.74192e-16;

  /// hc/k in nm·K. [来源: BlackbodyBodyModel.js:83]
  static const double planckConstantB = 1.438770e7;

  /// Stefan-Boltzmann σ in W/(m²·K⁴). [来源: BlackbodyBodyModel.js:131]
  static const double stefanBoltzmannConstant = 5.670373e-8;

  /// Wien's b in m·K. [来源: BlackbodyBodyModel.js:146]
  static const double wienConstant = 2.897773e-3;

  // —— RGB channel wavelengths (nm) ——
  /// [来源: BlackbodyBodyModel.js:21]
  static const double redWavelength = 650;

  /// [来源: BlackbodyBodyModel.js:22]
  static const double greenWavelength = 550;

  /// [来源: BlackbodyBodyModel.js:23]
  static const double blueWavelength = 450;

  // —— Star halo radius bounds (px) ——
  /// [来源: BlackbodyBodyModel.js:24]
  static const double glowingStarHaloMinimumRadius = 5;

  /// [来源: BlackbodyBodyModel.js:25]
  static const double glowingStarHaloMaximumRadius = 100;

  // —— Temperature normalization ——
  /// [来源: BlackbodyBodyModel.js:97]
  static const double powerExponent = 0.5;

  /// Draper point in K. [来源: BlackbodyBodyModel.js:98]
  static const double draperPoint = 798;

  /// [来源: BlackbodyBodyModel.js:99]
  static const double normalizationScaling = 0.02;

  // —— Graph dimensions (ZoomableAxesView.js:72-73) ——
  static const double axesWidth = 550;
  static const double axesHeight = 400;

  // —— Curve sampling (GraphDrawingNode.js:28) ——
  static const int graphNumberPoints = 300;

  // —— Zoom scales (ZoomableAxesView.js:90-91) ——
  static const double horizontalZoomScale = 2;
  static const double verticalZoomScale = 5;

  // —— Tick settings (ZoomableAxesView.js:86-94) ——
  static const double wavelengthPerTick = 100;
  static const int minorTicksPerMajorTick = 5;
  static const double minorTickLength = 10;
  static const double majorTickLength = 20;
  static const double minorTickMaxHorizontalZoom = 12000;

  // —— SPD conversion (ZoomableAxesView.js:30) ——
  /// nm to m^5 (1e45) and Mega/micron (1e-12) → 1e33
  static const double spectralPowerDensityConversionFactor = 1e33;

  // —— EM spectrum label cutoff (ZoomableAxesView.js:31) ——
  static const double electromagneticSpectrumLabelCutoff = 20;

  // —— Thermometer (BlackbodySpectrumThermometer.js:49-69) ——
  static const double bulbDiameter = 35;
  static const double tubeWidth = 20;
  static const double tubeHeight = 400;
  static const double majorTickLength2 = 10;
  static const double minorTickLength2 = 5;
  static const double glassThickness = 5;
  static const double thermometerLineWidth = 3;
  static const double tickSpacingTemperature = 500;
  static const double snapInterval = 50;

  // —— Triangle slider thumb (TriangleSliderThumb.js:31) ——
  static const double thumbWidth = 30;
  static const double thumbHeight = 15;

  // —— BGR & Star (BGRAndStarDisplay.js) ——
  static const double circleRadius = 15;
  static const double starOuterRadius = 35;
  static const double starInnerRadius = 20;
  static const double bgrSpacing = 50;
  static const double starSpacing = 50;

  // —— Default zoom (ZoomableAxesView.js:92-93) ——
  static const double defaultHorizontalZoom = 3000;
  static const double defaultVerticalZoom = 100.0;

  // —— Layout bounds (ScreenView.js) ——
  static const double layoutInset = 10;

  // —— Fonts ——
  static const double labelFontSize = 22;
  static const double emSpectrumLabelFontSize = 14;
  static const double subtitleFontSize = 16;
  static const double thermometerLabelFontSize = 18;
}
