/// Constants from PhET `ColorVisionConstants.js`, `SingleBulbConstants.js`,
/// `RGBConstants.js`.
class ColorVisionConstants {
  ColorVisionConstants._();

  /// layoutBounds width × height (ScreenView).
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;

  /// Height of all photonBeamNodes.
  static const double beamHeight = 130;

  /// Many nodes use this offset from layoutBounds.centerY.
  static const double centerYOffset = -20;

  /// Content baseline Y ≈ centerY + offset = 252 - 20.
  static const double contentCenterY = layoutHeight / 2 + centerYOffset;

  /// Photons move at constant x-velocity (ScreenView px / s), leftward.
  static const double xVelocity = -240;

  /// Amount of fanning of photons.
  static const double fanFactor = 1.05;

  static const String sliderBorderStroke = '#c0b9b9';

  /// Single Bulb beam length (model coordinate).
  static const double singleBeamLength = 280;

  /// Gaussian transmission width for filter (nm). Half-width = 35.
  static const double gaussianWidth = 70;

  static const double redBeamLength = 300;
  static const double greenBeamLength = 250;
  static const double blueBeamLength = 330;

  /// `COLOR_SCALE_FACTOR` in RGBModel — percent → 0–255.
  static const double colorScaleFactor = 2.55;

  /// Solid beam default alpha.
  static const double defaultBeamAlpha = 0.8;

  /// Cap dt (color-vision#115 / joist#130).
  static const double maxDt = 0.5;

  /// manualStep assumes 60 fps.
  static const double manualStepDt = 1 / 60;

  /// Single Bulb photon emission rate (ConstantEventModel).
  static const double singleBulbPhotonRate = 120;

  /// ResetAllButton radius in ColorVisionScreenView.
  static const double resetAllRadius = 18;

  /// Photon canvas start X on Single Bulb screen.
  static const double photonBeamStartX = 320;

  static const double minWavelength = 380;
  static const double maxWavelength = 780;
  static const double defaultWavelength = 570;

  /// White-photon filter pass probability (aesthetic choice in source).
  static const double whitePhotonFilterProbability = 0.5;

  /// Minimum intensity floor after colored filter pass.
  static const double minFilteredIntensity = 0.2;
}

enum LightType { white, colored }

enum BeamType { beam, photon }

/// Exterior = no-brain, Interior = brain (PhET headModeProperty).
enum HeadMode { noBrain, brain }
