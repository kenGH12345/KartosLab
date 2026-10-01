import '../gas_properties_constants.dart';

/// Time transform + play/pause/step — PhET BaseModel + TimeTransform.
///
/// Pure Dart: no Flutter [Ticker]. Drive via [stepRealTime] / [stepModel].
class SimulationClock {
  SimulationClock({
    this.psPerSecond = GasPropertiesConstants.normalPsPerSecond,
  });

  bool isPlaying = true;
  double simulationTimePs = 0;
  double psPerSecond;

  bool get isPaused => !isPlaying;

  void pause() => isPlaying = false;

  void resume() => isPlaying = true;

  void setSlow(bool slow) {
    psPerSecond = slow
        ? GasPropertiesConstants.slowPsPerSecond
        : GasPropertiesConstants.normalPsPerSecond;
  }

  /// Convert real seconds → model ps.
  double toModelDt(double realSeconds) => realSeconds * psPerSecond;

  /// Advance when playing. Returns model dt used (0 if paused).
  double stepRealTime(double realSeconds) {
    if (!isPlaying || realSeconds <= 0) return 0;
    return stepModel(toModelDt(realSeconds));
  }

  /// Always advances model time (Step button / manual).
  double stepModel(double dtPs) {
    assert(dtPs > 0 && dtPs.isFinite);
    simulationTimePs =
        (simulationTimePs + dtPs).clamp(0.0, GasPropertiesConstants.maxStopwatchPs);
    return dtPs;
  }

  /// Step button: fixed 0.2 ps.
  double stepOnce() => stepModel(GasPropertiesConstants.modelTimeStepPs);

  void reset() {
    isPlaying = true;
    simulationTimePs = 0;
    psPerSecond = GasPropertiesConstants.normalPsPerSecond;
  }
}
