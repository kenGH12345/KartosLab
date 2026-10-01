/// Constants from gas-properties @ 10c7c08 (Ideal / IdealGasLaw path).
class GasesIntroConstants {
  GasesIntroConstants._();

  // GasPropertiesConstants
  static const double boltzmann = 8.316e3; // (pm²·AMU)/(ps²·K)
  static const double pressureConversionScale = 1.66e6;
  static const double atmPerKpa = 0.00986923;

  static const double heavyMass = 28; // AMU
  static const double lightMass = 4; // AMU
  static const double heavyRadius = 125; // pm
  static const double lightRadius = 87.5; // pm

  static const int particleMin = 0;
  static const int particleMax = 1000;

  static const double widthMin = 5000; // pm
  static const double widthMax = 15000;
  static const double widthDefault = 10000;
  static const double height = 8750; // pm
  static const double depth = 4000; // pm
  static const double wallThickness = 75; // pm

  // GasPropertiesQueryParameters
  static const double heatCoolDivisor = 800;
  static const double maxPressureKpa = 20000;
  static const double maxTemperatureK = 1e5;

  // Clock
  static const double modelTimeStepPs = 0.2;
  static const double normalPsPerSecond = 2.5;
  static const double slowPsPerSecond = 0.3;
  static const double pressureGaugeRefreshPs = 0.75;
  static const double maxPressureNoiseKpa = 50;

  static const int pumpParticlesPerAction = 50;
  static const double particleDispersionAngle = 3.141592653589793 / 2; // π/2

  static const double initialTemperatureDefault = 300; // K

  static const double lidThickness = 175;
  static const double openingLeftInset = 1250;
  static const double openingRightInset = 2000;

  // BaseModel MVT
  static const double mvtScale = 0.040;
  static const double modelOriginOffsetX = 645;
  static const double modelOriginOffsetY = 475;
  static const double layoutWidth = 1008;
  static const double layoutHeight = 618;
  /// GasPropertiesConstants.RIGHT_PANEL_WIDTH — panel *content* width.
  static const double rightPanelWidth = 225;
  static const double maxStopwatchPs = 999.99;

  // GasPropertiesColors ProfileColorProperty defaults
  static const int heavyParticleColor = 0xFF7772F4; // rgb(119,114,244)
  static const int heavyParticleHighlight = 0xFFDCDCFF;
  static const int lightParticleColor = 0xFFE84E20; // rgb(232,78,32)
  static const int lightParticleHighlight = 0xFFFFAAAA;

  static const int playAreaBackground = 0xFF1E293B;
}
