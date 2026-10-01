import 'dart:math' as math;

/// Constants from `js/common/NormalModesConstants.js`.
class NormalModesConstants {
  NormalModesConstants._();

  static const double screenViewXMargin = 10;
  static const double screenViewYMargin = 10;

  /// PhET ScreenView.DEFAULT_LAYOUT_BOUNDS (joist since 2014).
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  static const double fixedDt = 1 / 60;
  static const double maxWallDt = 0.15;
  static const double normalSpeed = 1;
  static const double slowSpeed = 0.2;

  static const int minMassesPerRow = 1;
  static const int maxMassesPerRow = 10;
  static const int defaultNumberOfMasses = 3;

  static const int maxMasses = maxMassesPerRow + 2;
  static const int maxSprings = maxMasses - 1;

  static const double massValue = 0.1;
  static const double springConstant = 0.1 * 4 * math.pi * math.pi;

  static const double minAmplitude = 0;
  static const double maxAmplitude = 0.1;
  static const double initialAmplitude = 0;

  static const double minPhase = -math.pi;
  static const double maxPhase = math.pi;
  static const double initialPhase = 0;

  static const double leftWallX = -1;
  static const double topWallY = 1;
  static const double distanceBetweenXWalls = 2;
  static const double distanceBetweenYWalls = 2;

  static const double viewSpringWidth = 745;
  static const double twoDRightReserve = 420;

  static const double massNodeSize = 20;
  static const double massStrokeWidth = 4;
  static const double wallWidth = 6;
  static const double wallHeight = 80;
  static const double springLineWidth = 5;
  static const double dragBoundsHeight1D = 100;

  static const double staticGraphWidth = 40;
  static const double staticGraphHeight = 25;
  static const double modeGraphWidth = 133;
  static const double modeGraphHeight = 11;
  static const int staticGraphResolution = 100;
  static const int modeGraphResolution = 50;
  static const double staticGraphAmplitude = 0.075;

  static const double amplitudesPanelSize = 270;
  static const int rectGridUnits = 5;
  static const int paddingGridUnits = 1;
  static const double twoDBaseMaxAmplitude = 0.3;

  static const double controlFontSize = 18;
  static const double modeNumberFontSize = 16;
  static const double generalFontSize = 14;
  static const double smallFontSize = 13;
  static const double smallerFontSize = 12;
}
