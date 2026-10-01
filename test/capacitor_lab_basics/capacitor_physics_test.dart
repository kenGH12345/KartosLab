import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/capacitor_physics.dart';

void main() {
  group('CapacitorPhysics', () {
    test('default C ≈ ε₀ · A / d with A=200mm² d=6mm', () {
      final c = CapacitorPhysics.defaultCapacitance();
      final expected = ClbConstants.epsilon0 *
          ClbConstants.plateWidthDefault *
          ClbConstants.plateWidthDefault /
          ClbConstants.plateSeparationDefault;
      expect(c, closeTo(expected, 1e-20));
      // ~2.95e-13 F
      expect(c, closeTo(2.951e-13, 1e-15));
    });

    test('Q = CV with underflow', () {
      const c = 2e-13;
      expect(CapacitorPhysics.plateCharge(capacitance: c, voltage: 1.0), closeTo(2e-13, 1e-20));
      expect(
        CapacitorPhysics.plateCharge(capacitance: c, voltage: 1e-5),
        0.0,
      ); // |Q|=2e-18 < 1e-14
    });

    test('U = ½CV²', () {
      expect(
        CapacitorPhysics.storedEnergy(capacitance: 2e-13, voltage: 1.5),
        closeTo(0.5 * 2e-13 * 2.25, 1e-20),
      );
    });

    test('E = V/d when charge above min', () {
      expect(
        CapacitorPhysics.effectiveEField(
          voltage: 1.5,
          plateSeparation: 0.006,
          plateCharge: 1e-13,
        ),
        closeTo(250.0, 1e-9),
      );
      expect(
        CapacitorPhysics.effectiveEField(
          voltage: 1.5,
          plateSeparation: 0.006,
          plateCharge: 0,
        ),
        0,
      );
    });

    test('RC discharge step', () {
      const v0 = 1.5;
      const dt = 0.2;
      const r = ClbConstants.lightBulbResistance;
      const c = 2e-13;
      final v1 = CapacitorPhysics.dischargeVoltage(
        voltage: v0,
        dt: dt,
        resistance: r,
        capacitance: c,
      );
      // R·C = 5e12 · 2e-13 = 1 s; exp(-0.2/1)
      final expected = v0 * math.exp(-dt / (r * c));
      expect(v1, closeTo(expected, 1e-12));
      expect(v1, lessThan(v0));
    });

    test('Q conserved when C changes during discharge', () {
      expect(
        CapacitorPhysics.voltageAfterCapacitanceChange(
          voltage: 1.0,
          oldCapacitance: 2e-13,
          newCapacitance: 1e-13,
        ),
        closeTo(2.0, 1e-12),
      );
    });

    test('open circuit V = Q/C', () {
      expect(
        CapacitorPhysics.openCircuitVoltage(
          disconnectedCharge: 2e-13,
          capacitance: 2e-13,
        ),
        closeTo(1.0, 1e-12),
      );
    });

    test('battery snap and constrain', () {
      expect(CapacitorPhysics.snapBatteryVoltage(0.1), 0);
      expect(CapacitorPhysics.snapBatteryVoltage(0.2), 0.2);
      expect(CapacitorPhysics.constrainBatteryVoltage(1.53), 1.5);
      expect(CapacitorPhysics.constrainBatteryVoltage(0.07), 0.05);
    });
  });
}
