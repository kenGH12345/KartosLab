import 'dart:math' as math;

/// Constants from gas-properties @ `7a52c48` for Diffusion screen.
class DiffusionConstants {
  DiffusionConstants._();

  static const double boltzmann = 8.316e3; // GasPropertiesConstants.BOLTZMANN
  static const double modelTimeStepPs = 0.2; // MODEL_TIME_STEP
  static const double normalPsPerSecond = 2.5; // TimeTransform.NORMAL
  static const double slowPsPerSecond = 0.3; // TimeTransform.SLOW

  static const double containerWidthPm = 16000;
  static const double containerHeightPm = 8750;
  static const double containerDepthPm = 4000;
  static const double wallThicknessPm = 75;
  static const double dividerThicknessPm = 100;

  static const int numberOfParticlesMin = 0;
  static const int numberOfParticlesMax = 200;
  static const int numberOfParticlesDefault = 0;
  static const int numberOfParticlesDelta = 10;

  static const int massMin = 4;
  static const int massMax = 32;
  static const int massDefault = 28;
  static const int massDelta = 1;

  static const int radiusMin = 50;
  static const int radiusMax = 250;
  static const int radiusDefault = 125;
  static const int radiusDelta = 5;

  static const int temperatureMin = 50;
  static const int temperatureMax = 500;
  static const int temperatureDefault = 300;
  static const int temperatureDelta = 50;

  /// px per pm — BaseModel MODEL_VIEW_SCALE
  static const double modelViewScale = 0.040;

  static const int particle1Color = 0xFF00E6FF;
  static const int particle1Highlight = 0xFFCBF7FC;
  static const int particle2Color = 0xFFE84E20;
  static const int particle2Highlight = 0xFFFFAAAA;

  static const double layoutWidth = 960;
  static const double layoutHeight = 560;

  /// GasPropertiesConstants.MAX_TIME — stopwatch range
  static const double maxTimePs = 999.99;

  static double speedFromTemperature({
    required double temperatureK,
    required double massAmu,
  }) {
    assert(massAmu > 0);
    return math.sqrt(3 * boltzmann * temperatureK / massAmu);
  }

  static double timeTransform(bool slow) =>
      slow ? slowPsPerSecond : normalPsPerSecond;

  /// Real seconds that yield [modelTimeStepPs] under current transform.
  static double stepButtonRealSeconds({required bool slow}) =>
      modelTimeStepPs / timeTransform(slow);
}
