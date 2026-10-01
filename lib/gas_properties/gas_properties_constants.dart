/// Constants from PhET gas-properties (Phase 1 forensics).
/// Internal units: pm, ps, AMU, K, kPa.
class GasPropertiesConstants {
  GasPropertiesConstants._();

  // —— Physics ——
  static const double boltzmann = 8.316e3; // (pm²·AMU)/(ps²·K)
  static const double pressureConversionScale = 1.66e6;
  static const double atmPerKpa = 0.00986923;
  static const double kgPerAmu = 1.66e-27;

  static const double heavyMass = 28; // AMU
  static const double lightMass = 4; // AMU
  static const double heavyRadius = 125; // pm
  static const double lightRadius = 87.5; // pm

  static const int particleMin = 0;
  static const int particleMax = 1000;

  // —— Container (Ideal / Explore / Energy base) ——
  static const double widthMin = 5000; // pm
  static const double widthMax = 15000;
  static const double widthDefault = 10000;
  static const double energyFixedWidth = 10000; // Energy screen
  static const double height = 8750; // pm
  static const double depth = 4000; // pm
  static const double wallThickness = 75; // pm
  static const double lidThickness = 175;
  static const double openingLeftInset = 1250;
  static const double openingRightInset = 2000;
  static const double openingWidthThreshold = 1500;
  static const double wallSpeedLimit = 800; // pm/ps (Explore)

  // —— Clock / sampling ——
  static const double modelTimeStepPs = 0.2;
  static const double normalPsPerSecond = 2.5; // 1 ps = 0.4 s
  static const double slowPsPerSecond = 0.3; // Diffusion Slow
  static const double pressureGaugeRefreshPs = 0.75;
  static const double energySamplePeriodPs = 1.0;
  static const double maxStopwatchPs = 999.99;

  // —— Query-parameter defaults ——
  static const double heatCoolDivisor = 800;
  static const double maxPressureKpa = 20000;
  static const double maxTemperatureK = 1e5;
  static const double maxPressureNoiseKpa = 50;
  static const double minPressureNoiseKpa = 0;

  static const double particleDispersionAngle = 3.141592653589793 / 2; // π/2
  static const double initialTemperatureDefault = 300; // K
  static const double injectionTemperatureMin = 50;
  static const double injectionTemperatureMax = 1000;

  // —— Energy histograms ——
  static const int histogramBinCount = 19;
  static const double speedBinWidth = 170; // pm/ps
  static const double kineticEnergyBinWidth = 8e5; // AMU·pm²/ps²
  /// Zoom levels by descending yMax (HistogramsModel.ZOOM_LEVELS).
  static const List<double> histogramZoomYMax = [
    2000,
    1500,
    1000,
    500,
    200,
    100,
    50,
  ];
  /// Default zoomLevelIndex = length - 2 → yMax 100.
  static const int defaultHistogramZoomIndex = 5;

  // —— Diffusion ——
  static const double diffusionWidth = 16000; // pm
  static const double dividerThickness = 100;
  static const int diffusionParticleMax = 200;
  static const int diffusionParticleDelta = 10;
  static const int diffusionMassMin = 4;
  static const int diffusionMassMax = 32;
  static const int diffusionMassDefault = 28;
  static const int diffusionRadiusMin = 50;
  static const int diffusionRadiusMax = 250;
  static const int diffusionRadiusDefault = 125;
  static const int diffusionRadiusDelta = 5;
  static const int diffusionTempMin = 50;
  static const int diffusionTempMax = 500;
  static const int diffusionTempDefault = 300;
  static const int diffusionTempDelta = 50;
  static const int flowRateSampleCount = 300;

  // —— Collision counter ——
  static const List<int> collisionSamplePeriods = [5, 10, 20];
  static const int defaultCollisionSamplePeriod = 10;

  // —— MVT (for Phase 3) ——
  static const double mvtScale = 0.040;
  static const double modelOriginOffsetX = 645;
  static const double modelOriginOffsetY = 475;
  static const double diffusionModelOriginOffsetX = 670;
  static const double diffusionModelOriginOffsetY = 520;

  /// ScreenView margins / right panel — GasPropertiesConstants.ts
  static const double screenViewMargin = 20;
  static const double rightPanelWidth = 225;

  static const List<String> stepOrder = [
    'heat',
    'move',
    'escape',
    'container',
    'collide',
    'holdConstant',
    'temperature',
    'pressure',
  ];
}
