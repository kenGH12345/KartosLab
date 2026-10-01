// Display-only measurement tools — never feed solvers.

class DetectorRulerState {
  DetectorRulerState({
    this.visible = false,
    this.positionX = 0,
    this.positionY = 0,
    this.scaleHalfWidthMm = 15,
  });

  bool visible;
  double positionX;
  double positionY;

  /// Visible half-width in mm (±20/15/10/5 options in Experiment).
  double scaleHalfWidthMm;

  void reset() {
    visible = false;
    positionX = 0;
    positionY = 0;
    scaleHalfWidthMm = 15;
  }
}

class MeasuringTapeState {
  MeasuringTapeState({
    this.visible = false,
    this.startX = 0.18,
    this.startY = 0.28,
    this.endX = 0.52,
    this.endY = 0.28,
    this.unitIsNanometer = false,
  });

  bool visible;

  /// Normalized positions within the wave region [0,1]×[0,1] (display coords).
  double startX;
  double startY;
  double endX;
  double endY;
  bool unitIsNanometer;

  void reset() {
    visible = false;
    startX = 0.18;
    startY = 0.28;
    endX = 0.52;
    endY = 0.28;
    unitIsNanometer = false;
  }
}

/// scenery-phet `Stopwatch` — model-owned; advances only while [isRunning] and
/// the screen model feeds [step] with physical dt (see `getPhysicalDt`).
class QwiStopwatchState {
  QwiStopwatchState({
    this.visible = false,
    this.isRunning = false,
    this.timeSeconds = 0,
    this.left = 320,
    this.top = 280,
  });

  static const double maxSeconds = 59.99;

  bool visible;
  bool isRunning;
  double timeSeconds;

  /// Design-canvas position of the stopwatch top-left.
  double left;
  double top;

  void step(double physicalDt) {
    if (!isRunning || physicalDt <= 0) return;
    timeSeconds = (timeSeconds + physicalDt).clamp(0.0, maxSeconds);
    if (timeSeconds >= maxSeconds) {
      isRunning = false;
    }
  }

  void toggleRunning() => isRunning = !isRunning;

  void resetTime() {
    timeSeconds = 0;
    isRunning = false;
  }

  void reset() {
    visible = false;
    isRunning = false;
    timeSeconds = 0;
    left = 320;
    top = 280;
  }
}
