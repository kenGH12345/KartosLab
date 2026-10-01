import 'package:flutter/foundation.dart';

import '../../clb_constants.dart';
import 'capacitor_physics.dart';
import 'circuit_state.dart';

/// Parallel-plate capacitor (vacuum) — `js/common/model/Capacitor.js`
class Capacitor extends ChangeNotifier {
  Capacitor({
    double? plateWidth,
    double? plateSeparation,
    double? x,
    double? y,
    double? z,
  })  : _plateWidth = plateWidth ?? ClbConstants.plateWidthDefault,
        _plateDepth = plateWidth ?? ClbConstants.plateWidthDefault,
        _plateSeparation =
            plateSeparation ?? ClbConstants.plateSeparationDefault,
        _plateVoltage = 0,
        x = x ??
            ClbConstants.batteryX + ClbConstants.capacitanceCapacitorXSpacing,
        y = y ??
            ClbConstants.batteryY + ClbConstants.capacitanceCapacitorYSpacing,
        z = z ?? ClbConstants.batteryZ;

  double _plateWidth;
  double _plateDepth;
  double _plateSeparation;
  double _plateVoltage;

  /// Model position (meters) — `Capacitor.js` from BATTERY_POSITION + spacing
  final double x;
  final double y;
  final double z;

  /// Optional: current circuit connection for discharge-parameter updates.
  CircuitState Function()? connectionProvider;

  /// Fired after plate geometry changes with (oldC, newC).
  void Function(double oldCapacitance, double newCapacitance)?
      onCapacitanceChanged;

  double get plateWidth => _plateWidth;
  double get plateDepth => _plateDepth;
  double get plateSeparation => _plateSeparation;
  double get plateVoltage => _plateVoltage;

  /// Plate thickness — `CapacitorConstants.PLATE_HEIGHT`
  double get plateHeight => ClbConstants.plateHeight;

  double get plateArea => _plateWidth * _plateDepth;

  /// Outside center of top plate — `Capacitor.getTopConnectionPoint`
  ({double x, double y, double z}) getTopConnectionPoint() => (
        x: x,
        y: y - (_plateSeparation / 2) - plateHeight,
        z: z,
      );

  /// Outside center of bottom plate — `Capacitor.getBottomConnectionPoint`
  ({double x, double y, double z}) getBottomConnectionPoint() => (
        x: x,
        y: y + (_plateSeparation / 2) + plateHeight,
        z: z,
      );

  double get capacitance => CapacitorPhysics.capacitance(
        plateWidth: _plateWidth,
        plateDepth: _plateDepth,
        plateSeparation: _plateSeparation,
      );

  double get plateCharge => CapacitorPhysics.plateCharge(
        capacitance: capacitance,
        voltage: _plateVoltage,
      );

  double get storedEnergy => CapacitorPhysics.storedEnergy(
        capacitance: capacitance,
        voltage: _plateVoltage,
      );

  double get effectiveEField => CapacitorPhysics.effectiveEField(
        voltage: _plateVoltage,
        plateSeparation: _plateSeparation,
        plateCharge: plateCharge,
      );

  void setPlateVoltage(double v) {
    if (v == _plateVoltage) return;
    _plateVoltage = v;
    notifyListeners();
  }

  void setPlateSeparation(double s) {
    final q = CapacitorPhysics.quantizeSeparation(s).clamp(
      ClbConstants.plateSeparationMin,
      ClbConstants.plateSeparationMax,
    );
    if (q == _plateSeparation) return;
    final oldC = capacitance;
    _plateSeparation = q;
    _afterCapacitanceChange(oldC);
  }

  void setPlateWidth(double w) {
    final qw = CapacitorPhysics.quantizeWidthFromArea(w).clamp(
      ClbConstants.plateWidthMin,
      ClbConstants.plateWidthMax,
    );
    if (qw == _plateWidth) return;
    final oldC = capacitance;
    _plateWidth = qw;
    _plateDepth = qw; // square plates in Basics
    _afterCapacitanceChange(oldC);
  }

  void _afterCapacitanceChange(double oldC) {
    final newC = capacitance;
    // Capacitor.js capacitanceProperty.lazyLink → updateDischargeParameters
    final connection = connectionProvider?.call();
    if (connection == CircuitState.lightBulbConnected) {
      applyCapacitanceChangeWhileDischarging(oldCapacitance: oldC);
    }
    onCapacitanceChanged?.call(oldC, newC);
    notifyListeners();
  }

  /// `Capacitor.updateDischargeParameters` — V2 = V1 / (C2/C1)
  void applyCapacitanceChangeWhileDischarging({
    required double oldCapacitance,
  }) {
    _plateVoltage = CapacitorPhysics.voltageAfterCapacitanceChange(
      voltage: _plateVoltage,
      oldCapacitance: oldCapacitance,
      newCapacitance: capacitance,
    );
  }

  /// `Capacitor.discharge(R, dt)` — V *= exp(−dt/(R·C))
  void discharge(double resistance, double dt) {
    _plateVoltage = CapacitorPhysics.dischargeVoltage(
      voltage: _plateVoltage,
      dt: dt,
      resistance: resistance,
      capacitance: capacitance,
    );
    notifyListeners();
  }

  void reset() {
    _plateWidth = ClbConstants.plateWidthDefault;
    _plateDepth = ClbConstants.plateWidthDefault;
    _plateSeparation = ClbConstants.plateSeparationDefault;
    _plateVoltage = 0;
    notifyListeners();
  }
}
