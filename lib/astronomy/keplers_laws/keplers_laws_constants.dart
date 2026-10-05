/// Kepler's Laws constants.
///
/// [已确认] `js/common/KeplersLawsConstants.ts`
/// [已确认] `solar-system-common/js/SolarSystemCommonConstants.ts` 单位与时间
library;

class KeplersLawsConstants {
  KeplersLawsConstants._();

  /// [已确认] PERIOD_DIVISIONS_RANGE default 4, min 2, max 6
  static const int periodDivisionsMin = 2;
  static const int periodDivisionsMax = 6;
  static const int periodDivisionsDefault = 4;

  /// [已确认] MASS_OF_OUR_SUN = 200  (× 10^28 kg)
  static const double massOfOurSun = 200;

  /// [已确认] PLANET_MASS = 50
  static const double planetMass = 50;

  /// [已确认] engineTimeScale: 0.002
  static const double engineTimeScale = 0.002;

  /// [已确认] modelToViewTime: 1000 / 12.6
  static const double modelToViewTime = 1000 / 12.6;

  /// [已确认] zoomLevelRange 1..2 default 2
  static const int zoomLevelMin = 1;
  static const int zoomLevelMax = 2;
  static const int zoomLevelDefault = 2;

  /// [已确认] animatedZoomScaleRange 45..100, default max
  static const double zoomScaleMin = 45;
  static const double zoomScaleMax = 100;

  /// [已确认] zoom Animation duration 0.5, Easing.CUBIC_IN_OUT
  static const double zoomDurationSeconds = 0.5;

  /// [已确认] PeriodTracker.fadingDuration = 3
  static const double periodFadeDuration = 3;

  /// [已确认] SolarSystemCommonModel timeSpeedMap
  static const double timeSpeedFast = 7 / 4;
  static const double timeSpeedNormal = 1;
  static const double timeSpeedSlow = 1 / 4;

  /// [已确认] EllipticalOrbitEngine INITIAL_G
  static const double initialG = 4.45669;

  /// [已确认] EllipticalOrbitEngine INITIAL_MU
  static const double initialMu = 891.34;

  /// [已确认] escape velocity scaling epsilon = 0.99
  static const double escapeEpsilon = 0.99;

  /// [已确认] Kepler NR iteration epsilon = 1e-2
  static const double keplerNrEpsilon = 1e-2;

  /// [已确认] default planet position / velocity
  static const double defaultPlanetX = 2.00;
  static const double defaultPlanetY = 0;
  static const double defaultPlanetVx = 0;
  static const double defaultPlanetVy = 17.2358;

  /// [已确认] SCREEN_VIEW margins 10
  static const double screenMargin = 10;

  /// [已确认] PANEL cornerRadius 5, x/yMargin 10
  static const double panelCornerRadius = 5;
  static const double panelMargin = 10;
  static const double vboxSpacing = 7;

  /// [已确认] TITLE font 18 bold, TEXT 16, AXIS_LABEL 16
  static const double titleFontSize = 18;
  static const double textFontSize = 16;
  static const double axisLabelFontSize = 16;

  /// [已确认] orbit Path lineWidth 3
  static const double orbitLineWidth = 3;

  /// [已确认] EllipticalOrbitNode 非法轨道 lineDash=[5]
  static const double orbitInvalidDash = 5;

  /// [已确认] Body.massToRadius
  static const double minBodyRadius = 0.03;
  static const double massToRadiusCoeff = 0.023;

  /// [已确认] BodyNode touch dilation 10 view units
  static const double bodyHitDilation = 10;

  /// [已确认] StarMassPanel SNAP_TOLERANCE 0.05, mass 0.5–2 sun
  static const double starMassSnapTolerance = 0.05;

  /// [已确认] velocity vector minimumMagnitude 1.055
  static const double velocityMinMagnitude = 1.055;

  /// [已确认] planet dragSpeed 150 / shift 50
  static const double planetDragSpeed = 150;

  /// [已确认] GRID_SPACING 1
  static const double gridSpacing = 1;

  /// [已确认] SolarSystemCommonConstants.POSITION_MULTIPLIER
  static const double positionMultiplier = 0.01;

  /// [已确认] VELOCITY_MULTIPLIER from SolarSystemCommonConstants unit test
  /// TIME_MULTIPLIER ≈ 0.00473792; VELOCITY_MULTIPLIER ≈ 10.00538
  static const double velocityMultiplier = 10.00537695437279;

  /// [已确认] VELOCITY_TO_VIEW_MULTIPLIER = 50 * POSITION_MULTIPLIER / VELOCITY_MULTIPLIER
  static const double velocityToViewMultiplier = 50 * positionMultiplier / velocityMultiplier;

  /// [已确认] KeplersLawsConstants.INITIAL_VECTOR_OFFSCALE
  static const double initialVectorOffscale = -3.0;

  /// [已确认] gravityForceScalePowerProperty default 0, range -2..8
  static const double gravityScalePowerMin = -2;
  static const double gravityScalePowerMax = 8;
  static const double gravityScalePowerDefault = 0;

  /// Measuring tape default model positions [已确认 SolarSystemCommonModel]
  static const double tapeBaseX = 0;
  static const double tapeBaseY = 1;
  static const double tapeTipX = 1;
  static const double tapeTipY = 1;
}
