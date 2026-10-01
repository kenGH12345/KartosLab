/// PhET slit configuration enums (`SlitConfiguration.ts`).
///
/// Experiment overhead left/right maps to front-facing top/bottom.
enum SlitConfiguration {
  bothOpen,
  leftCovered,
  rightCovered,
  leftDetector,
  rightDetector,
  bothDetectors,
  noBarrier,
}

extension SlitConfigurationQuery on SlitConfiguration {
  bool get hasBarrier => this != SlitConfiguration.noBarrier;

  /// Experiment left covered → front-facing top covered.
  bool get isTopSlitCovered => this == SlitConfiguration.leftCovered;

  /// Experiment right covered → front-facing bottom covered.
  bool get isBottomSlitCovered => this == SlitConfiguration.rightCovered;

  bool get hasAnyDetector =>
      this == SlitConfiguration.bothDetectors ||
      this == SlitConfiguration.leftDetector ||
      this == SlitConfiguration.rightDetector;

  bool get hasDetectorOnTop =>
      this == SlitConfiguration.bothDetectors || this == SlitConfiguration.leftDetector;

  bool get hasDetectorOnBottom =>
      this == SlitConfiguration.bothDetectors || this == SlitConfiguration.rightDetector;

  bool get showsDoubleSlitInterferencePattern => this == SlitConfiguration.bothOpen;

  /// Open aperture flags for double-slit barrier (ignored when [noBarrier]).
  bool get isTopSlitOpen => !isTopSlitCovered;

  bool get isBottomSlitOpen => !isBottomSlitCovered;

  /// Which-path detectors make each open slit decoherent (own coherence group).
  bool get slitsAreDecoherent => hasAnyDetector;
}
