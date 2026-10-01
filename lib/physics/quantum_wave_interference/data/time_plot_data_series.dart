/// Port of PhET `TimePlotDataSeries.ts`.
class TimePlotDataPoint {
  const TimePlotDataPoint({required this.time, required this.value});
  final double time;
  final double value;
}

class TimePlotDataSeries {
  static const double maxTimeWindow = 1.0;
  static const int maxSamples = 600;
  static const double timeSampleInterval = maxTimeWindow / maxSamples;
  static const double timeEpsilon = 1e-12;

  final List<TimePlotDataPoint> _points = [];
  double _elapsedTime = 0;
  double? _previousSolverTime;
  double? _nextSampleSolverTime;

  List<TimePlotDataPoint> get points => List.unmodifiable(_points);

  void reset() {
    _points.clear();
    _elapsedTime = 0;
    _previousSolverTime = null;
    _nextSampleSolverTime = null;
  }

  ({double minTime, double maxTime}) getChartTimeRange() {
    final latest = _points.isEmpty ? null : _points.last;
    final maxTime = latest?.time ?? maxTimeWindow;
    final minTime = maxTime - maxTimeWindow < 0 ? 0.0 : maxTime - maxTimeWindow;
    return (minTime: minTime, maxTime: minTime + maxTimeWindow);
  }

  /// Advances series to [currentSolverTime]. Returns whether chart should refresh.
  bool stepAtSolverTime(
    double currentSolverTime,
    double Function(double solverTime) sampleFunction,
  ) {
    if (_previousSolverTime != null &&
        currentSolverTime + timeEpsilon < _previousSolverTime!) {
      reset();
    }

    if (_previousSolverTime == null) {
      _addPoint(currentSolverTime, _elapsedTime, sampleFunction);
      _previousSolverTime = currentSolverTime;
      _nextSampleSolverTime = currentSolverTime + timeSampleInterval;
      return true;
    }

    if (currentSolverTime <= _previousSolverTime! + timeEpsilon) {
      return false;
    }

    final previousSolverTime = _previousSolverTime!;
    final previousElapsedTime = _elapsedTime;
    final solverDt = currentSolverTime - previousSolverTime;
    _elapsedTime += solverDt;

    var nextSample = _nextSampleSolverTime ?? previousSolverTime + timeSampleInterval;
    final minVisible = currentSolverTime - maxTimeWindow;

    if (nextSample < minVisible) {
      final skip = ((minVisible - nextSample) / timeSampleInterval).floor();
      nextSample += skip * timeSampleInterval;
      while (nextSample < minVisible) {
        nextSample += timeSampleInterval;
      }
    }

    while (nextSample <= currentSolverTime + timeEpsilon) {
      final plotTime = previousElapsedTime + nextSample - previousSolverTime;
      _addPoint(nextSample, plotTime, sampleFunction);
      nextSample += timeSampleInterval;
    }

    _previousSolverTime = currentSolverTime;
    _nextSampleSolverTime = nextSample;
    _trimToVisibleWindow();
    return true;
  }

  void _addPoint(
    double solverTime,
    double plotTime,
    double Function(double) sampleFunction,
  ) {
    _points.add(TimePlotDataPoint(time: plotTime, value: sampleFunction(solverTime)));
  }

  void _trimToVisibleWindow() {
    final minTime = _elapsedTime - maxTimeWindow;
    while (_points.isNotEmpty && _points.first.time < minTime) {
      _points.removeAt(0);
    }
    while (_points.length > maxSamples) {
      _points.removeAt(0);
    }
  }
}
