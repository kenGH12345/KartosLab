import 'dart:ui' show Offset;

/// Source: `fluid-pressure-and-flow/js/common/model/Sensor.js`
///
/// Barometer model: position + measured pressure (Pa) or null when docked.
class PressureSensor {
  PressureSensor({
    required Offset initialPosition,
    double? initialValue,
  })  : position = initialPosition,
        _initialPosition = initialPosition,
        value = initialValue;

  final Offset _initialPosition;

  /// Gauge center in model meters.
  Offset position;

  /// Measured absolute pressure in Pa, or null when docked / no reading.
  double? value;

  /// Listeners notified when chamber displacement changes (source updateEmitter).
  final List<void Function()> _updateListeners = [];

  Offset get initialPosition => _initialPosition;

  /// Docked when position equals the toolbox initial position.
  bool get isDocked =>
      position.dx == _initialPosition.dx && position.dy == _initialPosition.dy;

  void addUpdateListener(void Function() listener) {
    _updateListeners.add(listener);
  }

  void removeUpdateListener(void Function() listener) {
    _updateListeners.remove(listener);
  }

  void emitUpdate() {
    for (final l in List<void Function()>.from(_updateListeners)) {
      l();
    }
  }

  void reset() {
    position = _initialPosition;
    value = null;
  }
}
