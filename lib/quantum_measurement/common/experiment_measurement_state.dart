/// Measurement lifecycle for Coins — mirrors `ExperimentMeasurementState.ts`.
library;

enum ExperimentMeasurementState {
  /// Coin is being flipped / re-prepared (animation window).
  preparingToBeMeasured,

  /// Quantum-only: prepared but not yet observed (no definite values yet).
  readyToBeMeasured,

  /// Values exist but are hidden from the user.
  measuredAndHidden,

  /// Values are shown to the observer.
  revealed,
}
