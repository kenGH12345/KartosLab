/// Constants from `js/common/CollisionLabConstants.js` + QueryParameters defaults.
class CollisionLabConstants {
  CollisionLabConstants._();

  static const double massMin = 0.1;
  static const double massMax = 3.0;
  static const double velocityMin = -3.0;
  static const double velocityMax = 3.0;
  static const double elasticityPercentMin = 0;
  static const double elasticityPercentMax = 100;
  static const double elasticityPercentInterval = 5;

  static const double timeStepDuration = 0.01;
  static const double normalSpeedFactor = 1.0;
  static const double slowSpeedFactor = 0.33;

  static const double minorGridlineSpacing = 0.1;
  static const double majorGridlineSpacing = 0.5;
  static const double playArea1dHeight = 1.1;
  static const double playAreaViewTop1d = 100;

  static const double zeroThreshold = 1e-10;
  static const double minVelocity = 1e-3;

  static const double ballDefaultDensity = 35; // kg/m³
  static const double ballConstantRadius = 0.15; // m

  static const double momentaDiagramAspectW = 7;
  static const double momentaDiagramAspectH = 5.7;
  static const double momentaZoomMin = 0.125;
  static const double momentaZoomMax = 4;
  static const double momentaZoomDefault = 2;

  static const double screenViewXMargin = 15;
  static const double screenViewYMargin = 10.5;
  static const int displayDecimalPlaces = 2;
  static const double controlPanelContentWidth = 218;

  static const double modelToViewScale = 152;
  static const double playAreaLeft = 55;
  static const double ballValuesPanelTop = 410;

  /// QueryParameters defaults
  static const double pathPointLifetime = 3;
  static const double changeInMomentumVisiblePeriod = 0.5;
  static const double changeInMomentumFadePeriod = 0.5;

  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  /// PlayAreaScaleBarNode length in meters (`CollisionLabScreenView.js`).
  static const double scaleBarLengthMeters = 0.5;

  /// Tip-circle radius in view coordinates (`BallVelocityVectorNode.js`).
  static const double velocityTipCircleRadius = 13;
}
