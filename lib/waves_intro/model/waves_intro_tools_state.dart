import 'dart:ui';

/// Play-area tools from WI ToolboxPanel / WavesModel @ lock `31ebfd7`.
///
/// Measuring tape tip/base are in **view** coordinates; model length uses
/// `multiplier = waveAreaWidth / waveAreaViewWidth` — [已确认] WavesScreenView.
class WavesIntroToolsState {
  bool isMeasuringTapeInPlayArea = false;
  Offset measuringTapeBase = const Offset(200, 200);
  Offset measuringTapeTip = const Offset(250, 200);

  bool isStopwatchVisible = false;
  bool isStopwatchRunning = false;
  double stopwatchTime = 0; // scene time units; range 0..999.99

  bool isWaveMeterInPlayArea = false;
  Offset waveMeterBody = const Offset(420, 80);
  Offset probe1 = const Offset(280, 160);
  Offset probe2 = const Offset(320, 200);

  /// Recent samples for seismograph-like display (probe1 / probe2).
  final List<double> series1 = <double>[];
  final List<double> series2 = <double>[];
  static const int maxSeriesLength = 120;

  void stepStopwatch(double sceneDt) {
    if (!isStopwatchVisible || !isStopwatchRunning) return;
    stopwatchTime = (stopwatchTime + sceneDt).clamp(0.0, 999.99);
  }

  void pushMeterSamples(double v1, double v2) {
    series1.add(v1);
    series2.add(v2);
    while (series1.length > maxSeriesLength) {
      series1.removeAt(0);
    }
    while (series2.length > maxSeriesLength) {
      series2.removeAt(0);
    }
  }

  void resetMeasuringTape() {
    isMeasuringTapeInPlayArea = false;
    measuringTapeBase = const Offset(200, 200);
    measuringTapeTip = const Offset(250, 200);
  }

  void resetStopwatch() {
    isStopwatchVisible = false;
    isStopwatchRunning = false;
    stopwatchTime = 0;
  }

  void resetWaveMeter() {
    isWaveMeterInPlayArea = false;
    waveMeterBody = const Offset(420, 80);
    probe1 = const Offset(280, 160);
    probe2 = const Offset(320, 200);
    series1.clear();
    series2.clear();
  }

  void resetAll() {
    resetMeasuringTape();
    resetStopwatch();
    resetWaveMeter();
  }

  /// View-pixel length → model units.
  double measuringTapeModelLength({
    required double waveAreaWidth,
    required double waveAreaViewWidth,
  }) {
    final dx = measuringTapeTip.dx - measuringTapeBase.dx;
    final dy = measuringTapeTip.dy - measuringTapeBase.dy;
    final viewLen = Offset(dx, dy).distance;
    final multiplier = waveAreaWidth / waveAreaViewWidth;
    return viewLen * multiplier;
  }
}
