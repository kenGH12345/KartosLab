/// Constants from PhET `PlinkoProbabilityConstants.js` + query defaults.
class PlinkoConstants {
  PlinkoConstants._();

  static const double boardMinX = -0.5;
  static const double boardMaxX = 0.5;
  static const double boardMinY = -1.0;
  static const double boardMaxY = 0.0;
  static const double boardWidth = boardMaxX - boardMinX; // 1.0

  static const double histogramMinX = -0.5;
  static const double histogramMaxX = 0.5;
  static const double histogramMinY = -1.70;
  static const double histogramMaxY = -1.03;

  static const double cylinderMinX = -0.5;
  static const double cylinderMaxX = 0.5;
  static const double cylinderMinY = -1.80;
  static const double cylinderMaxY = -1.05;

  static const double binaryProbabilityMin = 0.0;
  static const double binaryProbabilityMax = 1.0;
  static const double binaryProbabilityDefault = 0.5;
  static const double binaryProbabilityStep = 0.01;

  static const int rowsMin = 1;
  static const int rowsMax = 26;
  static const int rowsDefault = 12;

  static const double pegHeightFractionOffset = 0.7;
  static const double ballSizeFraction = 0.193;

  static const double soundTimeInterval = 0.1;

  static const int maxBallsIntro = 100;
  static const int maxBallsLab = 9999;

  /// Peg visual radius when numberOfRows == 1 (PegsNode default).
  static const double pegRadiusAtOneRow = 50.0;

  static const double playPauseButtonRadius = 30.0;
  static const double resetAllButtonScale = 0.75;

  /// Intro cylinder perspective tilt (radians).
  static const double perspectiveTilt = 3.141592653589793 / 1.4;

  static const double introBallCreationInterval = 0.150;
  static const double labIntervalBall = 0.100;
  static const double labIntervalPath = 0.050;
  static const double labIntervalNone = 0.015;

  static const double introDtCapFactor = 5.0;
  static const double introDtCap = 0.1;
  static const double labDtCapFactor = 10.0;
  static const double labDtCap = 0.090;
}
