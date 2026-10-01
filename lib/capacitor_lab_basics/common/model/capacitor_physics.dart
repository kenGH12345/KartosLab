import 'dart:math' as math;

import '../../clb_constants.dart';

/// Pure capacitor formulas from PhET `Capacitor.js` / circuit discharge.
///
/// No Flutter UI — unit-testable SSOT for Phase 2.
class CapacitorPhysics {
  CapacitorPhysics._();

  /// C = ε₀ · width · depth / separation  (vacuum)
  static double capacitance({
    required double plateWidth,
    required double plateDepth,
    required double plateSeparation,
  }) {
    assert(plateSeparation > 0);
    return ClbConstants.epsilon0 * plateWidth * plateDepth / plateSeparation;
  }

  /// Default geometry capacitance.
  static double defaultCapacitance() {
    final w = ClbConstants.plateWidthDefault;
    return capacitance(
      plateWidth: w,
      plateDepth: w,
      plateSeparation: ClbConstants.plateSeparationDefault,
    );
  }

  /// Q = C·V with underflow to 0 below [ClbConstants.minPlateCharge].
  ///
  /// PhET applies underflow whenever the connection argument is truthy;
  /// all [CircuitState] enum values are used with the underflow path.
  static double plateCharge({
    required double capacitance,
    required double voltage,
  }) {
    final charge = capacitance * voltage;
    return charge.abs() < ClbConstants.minPlateCharge ? 0.0 : charge;
  }

  /// U = ½ C V²
  static double storedEnergy({
    required double capacitance,
    required double voltage,
  }) =>
      0.5 * capacitance * voltage * voltage;

  /// Effective E = V/d, or 0 if |Q| < min plate charge.
  static double effectiveEField({
    required double voltage,
    required double plateSeparation,
    required double plateCharge,
  }) {
    if (plateCharge.abs() < ClbConstants.minPlateCharge) return 0;
    return voltage / plateSeparation;
  }

  /// One RC discharge step: V *= exp(−dt / (R·C))
  static double dischargeVoltage({
    required double voltage,
    required double dt,
    required double resistance,
    required double capacitance,
  }) {
    return voltage * math.exp(-dt / (resistance * capacitance));
  }

  /// When C changes during discharge: V2 = V1 · (C1/C2) (Q conserved).
  static double voltageAfterCapacitanceChange({
    required double voltage,
    required double oldCapacitance,
    required double newCapacitance,
  }) {
    if (newCapacitance == 0) return voltage;
    return voltage * (oldCapacitance / newCapacitance);
  }

  /// Open-circuit plate voltage from stored disconnected charge.
  static double openCircuitVoltage({
    required double disconnectedCharge,
    required double capacitance,
  }) {
    if (capacitance == 0) return 0;
    return disconnectedCharge / capacitance;
  }

  /// Quantize separation like PlateSeparationDragHandler: round(5e3·s)/5e3
  static double quantizeSeparation(double s) =>
      (5e3 * s).roundToDouble() / 5e3;

  /// Quantize width from area like PlateAreaDragHandler: round(1e5·w²)/1e5
  static double quantizeWidthFromArea(double width) {
    final area = width * width;
    final qArea = (1e5 * area).roundToDouble() / 1e5;
    return qArea <= 0 ? width : math.sqrt(qArea);
  }

  /// Snap battery voltage to 0 if |V| < threshold (endDrag).
  static double snapBatteryVoltage(double v) {
    if (v.abs() < ClbConstants.batteryVoltageSnapToZeroThreshold) return 0;
    return v;
  }

  /// Slider constrain: roundSymmetric(v·20)/20
  static double constrainBatteryVoltage(double v) {
    final stepped = (v * 20).roundToDouble() / 20;
    return stepped.clamp(
      ClbConstants.batteryVoltageMin,
      ClbConstants.batteryVoltageMax,
    );
  }
}
