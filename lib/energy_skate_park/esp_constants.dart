import 'package:kratos/energy_skate_park/assets/esp_assets.dart';

/// Constants from EnergySkateParkConstants.ts / ScreenView MVT scale.
class EspConstants {
  EspConstants._();

  /// Conceptual frame rate (EventTimer ConstantEventModel).
  static const double frameRate = 60;
  static const double dt = 1.0 / frameRate;

  static const double minFriction = 0;
  static const double maxFriction = 0.1;
  static const double defaultFriction = minFriction;

  static const double moonGravity = 1.6;
  static const double earthGravity = 9.8;
  static const double jupiterGravity = 24.8;

  /// Signed gravity limits (m/s²), naming matches PhET.
  static const double minGravity = -1;
  static const double maxGravity = -26;

  /// Magnitude range = abs(MIN/MAX_GRAVITY) → [1, 26].
  static double get gravityMagnitudeMin => minGravity.abs(); // 1
  static double get gravityMagnitudeMax => maxGravity.abs(); // 26

  /// GravitySlider / GravityNumberControl constrain intervals (m/s²).
  static const double gravityInterval = 1.0;
  static const double gravityShiftInterval = 0.1;

  static const double referenceHeightMin = 0;
  static const double referenceHeightMax = 8;

  static const int maxNumberControlPoints = 15;

  /// Below this, energies are treated as zero for a11y descriptions.
  static const double energyThreshold = 1e-4;

  /// Residual thermal treated as visually negligible / clearable cutoff.
  static const double thermalEnergyClearThreshold = 1e-2;

  /// E(x) plot / a11y: x=0 is 5 m left of model origin.
  static const double positionPlotOffset = 5;

  /// From EnergySkateParkScreenView: createSinglePointScaleInvertedYMapping scale.
  static const double mvtScale = 61.40;

  static const double defaultSkaterMass = 60;

  /// PhET ScreenView logical size.
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  /// Skater drag snap distance (SkaterNode.ts).
  static const double skaterTrackSnapDistance = 0.5;

  /// Skater hit radius in model meters for picking.
  static const double skaterPickRadius = 0.45;

  /// SkaterPathSensorNode.ts PROBE_THRESHOLD_DISTANCE (view px).
  static const double probeThresholdViewPx = 10;

  /// GraphsConstants.MAX_PLOTTED_TIME.
  static const double maxPlottedTime = 20;

  /// GraphsConstants.PLOT_RANGES — index 11 is default [-3000, 3000].
  static const List<(double, double)> plotRanges = [
    (-20000, 20000),
    (-17500, 17500),
    (-15000, 15000),
    (-12500, 12500),
    (-10000, 10000),
    (-9000, 9000),
    (-8000, 8000),
    (-7000, 7000),
    (-6000, 6000),
    (-5000, 5000),
    (-4000, 4000),
    (-3000, 3000),
    (-2500, 2500),
    (-2000, 2000),
    (-1500, 1500),
    (-1000, 1000),
    (-500, 500),
    (-200, 200),
    (-100, 100),
    (-50, 50),
  ];

  static const int defaultEnergyGraphZoomIndex = 11;

  /// GraphsConstants.TRACK_WIDTH / TRACK_HEIGHT (model meters).
  static const double graphsTrackWidth = 10;
  static const double graphsTrackHeight = 4;

  /// EnergyGraphAccordionBox.ts GRAPH_HEIGHT — plot rect only.
  static const double energyGraphPlotHeight = 141;

  /// Plot width in view px = TRACK_WIDTH × mvtScale (EnergyGraphAccordionBox.ts:175).
  static double get energyGraphPlotWidth => graphsTrackWidth * mvtScale;

  /// Control-point pick radius in model meters.
  static const double controlPointPickRadius = 0.35;

  static const String mountainsAsset = EspAssets.mountains;
  static const String cementTextureAsset = EspAssets.cementTextureDark;

  /// BackgroundNode.ts — mountain image scale.
  static const double mountainsScale = 1.23;

  /// BackgroundNode.ts — cement strip height (view px).
  static const double cementHeight = 5;

  /// Play-area model bounds (subset of availableModelBoundsProperty).
  static const double playAreaModelMinX = -12;
  static const double playAreaModelMaxX = 12;

  /// Reference height line length in model meters (ReferenceHeightLine.ts:42).
  static const double referenceHeightLineModelLength = 9.5;

  /// Measuring-tape handle hit radius in view px.
  static const double tapeHandleRadius = 14;

  /// Stopwatch drag hit padding.
  static const double stopwatchHitPadding = 8;

  /// SkaterRadioButtonGroup.ts corner radius.
  static const double radioButtonCornerRadius = 2;
}