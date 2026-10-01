import '../domain/source_type.dart';

/// Constants from `QuantumWaveInterferenceConstants.ts` and screen-specific sources.
class QwiConstants {
  QwiConstants._();

  static const double planckConstant = 6.626e-34; // J·s
  static const double speedOfLight = 3e8; // m/s

  static const double electronMassKg = 9.109e-31;
  static const double neutronMassKg = 1.675e-27;
  static const double heliumAtomMassKg = 6.646e-27;

  static const double defaultPhotonWavelengthNm = 650;
  static const double photonWavelengthPropertyMinNm = 380;
  static const double photonWavelengthPropertyMaxNm = 780;
  static const double photonWavelengthControlMinNm = 400;
  static const double photonWavelengthControlMaxNm = 700;

  static const int displayWavelengths = 15;

  static const double wavePacketTraversalTime = 1.5;
  static const double wavePacketSigmaXFraction = 0.15;
  static const double wavePacketSigmaYFraction = 0.15;
  static const double wavePacketStartOffsetSigmas = 2;
  static const double wavePacketReEmissionTimeAdvanceSigmas = 1.5;
  static const double wavePacketLongitudinalSpreadTraversals = 2.5;
  static const double wavePacketTransverseSpreadTraversals = 1.5;

  static const double screenBrightnessMax = 100;
  static const double defaultScreenBrightness = 50;

  static const int maxHits = 25000;
  static const int maxSnapshots = 4;
  static const int hitsGraphBinCount = 100;
  static const int maxRenderedHits = 10000;

  static const double waveRegionWidth = 420;
  static const double waveRegionHeight = 385;
  static const int defaultWaveSolverGridSize = 120;

  static const double barrierPositionFractionMin = 0.38;
  static const double barrierPositionFractionMax = 0.62;
  static const double defaultBarrierPositionFraction = 0.5;

  static const double highIntensityDisplayTraversalTime = 2.0;
  static const double singleParticlesMinEmissionInterval = 0.3;

  static const double experimentMaxEmissionRate = 100;
  static const double highIntensityDetectorHitRate = 40;
  static const double highIntensityDetectorHitRateWithSlitDetectors = 5;
  static const double highIntensitySlitDetectorEventRate = 5;

  static const double detectorPatternFormationTimeConstant = 0.20;
  static const double detectorPatternFormationEasePower = 2;
  static const double detectorPatternFormationCompleteThreshold = 0.95;
  static const double detectorPatternFormationSnapToComplete = 0.995;

  static const double nominalDt = 1 / 60;
  static const double baseScreenSlowTimeSpeedFactor = 0.15;

  static const double experimentSlowFactor = 0.25;
  static const double experimentNormalFactor = 1.0;
  static const double experimentFastFactor = 4.0;

  static const double highIntensityNormalFactor = 0.35;
  static const double highIntensityFastFactor = 0.65;

  static const double singleParticlesNormalFactor = 0.7;
  static const double singleParticlesFastFactor = 16.0;

  static const double experimentDefaultScreenDistanceM = 0.6;
  static const double experimentScreenDistanceMinM = 0.4;
  static const double experimentScreenDistanceMaxM = 0.8;
  static const double experimentDefaultSourceStrength = 0.5;

  static const int experimentMaxRejectionIterations = 1000;
  static const double singleOpenSlitIntensityScale = 0.5;

  static const double probeDefaultRadius = 0.1;
  static const double probeRadiusMin = 0.06;
  static const double probeRadiusMax = 0.3;

  static double particleMassKg(SourceType type) {
    switch (type) {
      case SourceType.photons:
        return 0;
      case SourceType.electrons:
        return electronMassKg;
      case SourceType.neutrons:
        return neutronMassKg;
      case SourceType.heliumAtoms:
        return heliumAtomMassKg;
    }
  }

  /// de Broglie wavelength in meters. Photons must not use this path.
  static double deBroglieWavelengthM({
    required double massKg,
    required double speedMps,
  }) {
    if (massKg <= 0 || speedMps <= 0) {
      return 0;
    }
    return planckConstant / (massKg * speedMps);
  }
}
