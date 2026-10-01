import 'bl_vec2.dart';

class DataPoint {
  const DataPoint(this.time, this.magnitude);
  final double time;
  final double magnitude;
}

class Probe {
  Probe(double x, double y)
      : position = BlVec2(x, y),
        _initial = BlVec2(x, y);

  BlVec2 position;
  final BlVec2 _initial;
  final List<DataPoint> series = [];

  static const int maxSamples = 240;

  void addSample(DataPoint p) {
    series.add(p);
    if (series.length > maxSamples) {
      series.removeRange(0, series.length - maxSamples);
    }
  }

  void reset() {
    position = _initial;
    series.clear();
  }
}

class VelocitySensor {
  VelocitySensor()
      : position = const BlVec2(
          -0.00002051402284781722,
          -0.0000025716197470420186,
        ),
        _initialPosition = const BlVec2(
          -0.00002051402284781722,
          -0.0000025716197470420186,
        );

  BlVec2 position;
  final BlVec2 _initialPosition;
  BlVec2 value = BlVec2.zero;
  bool enabled = false;

  bool get isArrowVisible => value.magnitude > 0;

  void reset() {
    position = _initialPosition;
    value = BlVec2.zero;
    enabled = false;
  }
}

class WaveSensor {
  WaveSensor({
    required this.probe1Value,
    required this.probe2Value,
  })  : probe1 = Probe(-0.00001932, -0.0000052),
        probe2 = Probe(-0.0000198, -0.0000062),
        bodyPosition = const BlVec2(-0.0000172, -0.00000605),
        _initialBody = const BlVec2(-0.0000172, -0.00000605);

  final Probe probe1;
  final Probe probe2;
  BlVec2 bodyPosition;
  final BlVec2 _initialBody;
  bool enabled = false;

  final ({double time, double magnitude})? Function(BlVec2) probe1Value;
  final ({double time, double magnitude})? Function(BlVec2) probe2Value;

  void step() => _simulationTimeChanged();

  void _simulationTimeChanged() {
    _updateProbeSample(probe1, probe1Value);
    _updateProbeSample(probe2, probe2Value);
  }

  void _updateProbeSample(
    Probe probe,
    ({double time, double magnitude})? Function(BlVec2) getter,
  ) {
    final result = getter(probe.position);
    if (result != null) {
      probe.addSample(DataPoint(result.time, result.magnitude));
    }
  }

  void reset() {
    bodyPosition = _initialBody;
    enabled = false;
    probe1.reset();
    probe2.reset();
  }
}
