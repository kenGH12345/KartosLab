import 'bl_vec2.dart';
import 'reading.dart';

/// Intensity meter model (`IntensityMeter.ts`).
class IntensityMeter {
  IntensityMeter({
    required double sensorX,
    required double sensorY,
    required double bodyX,
    required double bodyY,
  })  : sensorPosition = BlVec2(sensorX, sensorY),
        bodyPosition = BlVec2(bodyX, bodyY),
        _initialSensor = BlVec2(sensorX, sensorY),
        _initialBody = BlVec2(bodyX, bodyY);

  BlVec2 sensorPosition;
  BlVec2 bodyPosition;
  final BlVec2 _initialSensor;
  final BlVec2 _initialBody;

  Reading reading = Reading.miss;
  bool enabled = false;
  final List<Reading> _rayReadings = [];

  /// Sensor circle radius in model meters.
  static const double sensorRadius = 1e-6;

  void reset() {
    reading = Reading.miss;
    sensorPosition = _initialSensor;
    bodyPosition = _initialBody;
    enabled = false;
    _rayReadings.clear();
  }

  void clearRayReadings() {
    _rayReadings.clear();
    reading = Reading.miss;
  }

  void addRayReading(Reading r) {
    _rayReadings.add(r);
    _updateReading();
  }

  void _updateReading() {
    final hits = _rayReadings.where((r) => r.isHit()).toList();
    if (hits.isEmpty) {
      reading = Reading.miss;
    } else {
      var total = 0.0;
      for (final h in hits) {
        total += h.value;
      }
      reading = Reading(total);
    }
  }
}
