/// Constants from PhET `js/common/FMWConstants.ts`, plus Discrete clock
/// and FourierSeries fundamental values used across the sim.
class FmwConstants {
  FmwConstants._();

  // --- Model (FMWConstants.ts) ---
  static const int maxHarmonics = 11;
  static const double maxAmplitude = 1.5;
  static const int maxPointsPerDataSet = 1000;
  static const int pointsPerChallenge = 1;
  static const int numberOfGameLevels = 5;

  /// `FourierSeries.ts` fundamental frequency (Hz).
  static const double fundamentalFrequency = 440;

  /// Fundamental wavelength L (m). `FourierSeries.ts`
  static const double L = 1;

  /// Fundamental period T (ms) = 1000 / f0. `FourierSeries.ts`
  static const double T = 1000 / fundamentalFrequency;

  /// Slows space&time Domain clock. `DiscreteModel.ts` TIME_SCALE
  static const double timeScale = 0.001;

  /// Step button dt in milliseconds. `DiscreteModel.ts` STEP_DT
  static const double stepDt = 50;

  // --- View / layout ---
  /// PhET ScreenView.DEFAULT_LAYOUT_BOUNDS (joist); aligned with other sims.
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  static const double screenViewXMargin = 15;
  static const double screenViewYMargin = 15;

  static const double chartWidth = 645;
  static const double chartHeight = 123;
  static const double xChartRectangles = 65;
  static const double secondaryWaveformLineWidth = 4;

  static const int discreteAmplitudeDecimalPlaces = 2;
  static const double discreteAmplitudeStep = 0.05;
  static const double discreteAmplitudeKeyboardStep = 0.05;
  static const double discreteAmplitudeShiftKeyboardStep = 0.01;
  static const double discreteAmplitudePageKeyboardStep = 0.25;

  static const int waveGameAmplitudeDecimalPlaces = 1;
  static const double waveGameAmplitudeStep = 0.1;
  static const double waveGameAmplitudeKeyboardStep = 0.1;
  static const double waveGameAmplitudeShiftKeyboardStep = 0.1;
  static const double waveGameAmplitudePageKeyboardStep = 0.5;

  /// Default Wave Game reward threshold. `FMWQueryParameters.rewardScore`
  static const int rewardScore = 5;

  /// Wave Packet screen uses L === T === 1. `WavePacket.ts`
  static const double wavePacketL = 1;
  static const double wavePacketT = 1;
}
