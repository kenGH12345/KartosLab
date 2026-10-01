import 'package:flutter/foundation.dart';

import '../../clb_constants.dart';
import 'capacitor_physics.dart';

/// DC battery — `js/common/model/Battery.js`
///
/// Origin is at the geometric center of the battery body.
class Battery extends ChangeNotifier {
  Battery({
    double voltage = ClbConstants.batteryVoltageDefault,
    double? x,
    double? y,
    double? z,
  })  : _voltage = voltage,
        x = x ?? ClbConstants.batteryX,
        y = y ?? ClbConstants.batteryY,
        z = z ?? ClbConstants.batteryZ;

  double _voltage;

  /// Model position (meters) — `CLBConstants.BATTERY_POSITION`
  final double x;
  final double y;
  final double z;

  double get voltage => _voltage;

  /// Positive when voltage ≥ 0 (PhET polarity derived from sign).
  bool get isPositiveTerminalUp => _voltage >= 0;

  /// `Battery.getTopTerminalYOffset` — depends on polarity.
  double get topTerminalYOffset => isPositiveTerminalUp
      ? ClbConstants.batteryPositiveTerminalYOffset
      : ClbConstants.batteryNegativeTerminalYOffset;

  /// `Battery.getBottomTerminalYOffset` — always body half-height.
  double get bottomTerminalYOffset => ClbConstants.batteryBottomTerminalYOffset;

  set voltage(double value) {
    final next = CapacitorPhysics.constrainBatteryVoltage(value);
    if (next == _voltage) return;
    _voltage = next;
    notifyListeners();
  }

  void endDragSnap() {
    final snapped = CapacitorPhysics.snapBatteryVoltage(_voltage);
    if (snapped == _voltage) return;
    _voltage = snapped;
    notifyListeners();
  }

  void reset() {
    _voltage = ClbConstants.batteryVoltageDefault;
    notifyListeners();
  }
}
