enum ProbeState {
  ready,
  detected,
  notDetected,
}

/// Circular detector probe (Single Particles, noBarrier only).
class DetectorProbe {
  DetectorProbe({
    this.normalizedX = 0.5,
    this.normalizedY = 0.5,
    this.radius = 0.1,
  });

  double normalizedX;
  double normalizedY;
  double radius;
  ProbeState state = ProbeState.ready;
  double probability = 0;

  void reset() {
    state = ProbeState.ready;
    probability = 0;
  }

  /// Port of `DetectorProbe.resetMeasurementState` — clears detect result to ready.
  void resetMeasurementState({double? recomputedProbability}) {
    state = ProbeState.ready;
    probability = recomputedProbability ?? 0;
  }

  void resetFully() {
    normalizedX = 0.5;
    normalizedY = 0.5;
    radius = 0.1;
    reset();
  }
}
