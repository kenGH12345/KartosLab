// Copyright 2024-2026, University of Colorado Boulder
/// Measurement experiment lifecycle states (classical and quantum).
///
/// Corresponds to `js/coins/model/ExperimentMeasurementState.ts`.
library;

enum ExperimentMeasurementState {
  preparingToBeMeasured,
  readyToBeMeasured,
  measuredAndHidden,
  revealed,
}
