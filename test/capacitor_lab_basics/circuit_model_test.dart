import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/model/parallel_circuit.dart';
import 'package:kratos/capacitor_lab_basics/common/model/time_speed.dart';
import 'package:kratos/capacitor_lab_basics/light_bulb/model/clb_light_bulb_model.dart';

void main() {
  group('CapacitanceCircuit', () {
    test('default: battery connected, V_plates = V_battery = 0', () {
      final c = CapacitanceCircuit();
      expect(c.circuitConnection, CircuitState.batteryConnected);
      expect(c.capacitor.plateVoltage, 0);
      expect(c.lightBulb, isNull);
      expect(c.allowedConnections, [
        CircuitState.batteryConnected,
        CircuitState.openCircuit,
      ]);
    });

    test('battery voltage tracks plates while connected', () {
      final c = CapacitanceCircuit();
      c.battery.voltage = 1.5;
      expect(c.capacitor.plateVoltage, 1.5);
      expect(c.capacitor.plateCharge, greaterThan(0));
    });

    test('open circuit stores Q and uses V=Q/C', () {
      final c = CapacitanceCircuit();
      c.battery.voltage = 1.0;
      final q = c.getTotalCharge();
      expect(q, greaterThan(0));

      c.setCircuitConnection(CircuitState.openCircuit);
      expect(c.disconnectedPlateCharge, closeTo(q, 1e-20));
      expect(
        c.capacitor.plateVoltage,
        closeTo(q / c.capacitor.capacitance, 1e-12),
      );

      // Changing C while open updates V = Q/C
      final oldV = c.capacitor.plateVoltage;
      c.capacitor.setPlateSeparation(0.003);
      expect(c.capacitor.plateVoltage, isNot(closeTo(oldV, 1e-15)));
      expect(
        c.capacitor.plateVoltage,
        closeTo(
          c.disconnectedPlateCharge / c.capacitor.capacitance,
          1e-12,
        ),
      );
    });

    test('reconnect battery restores V_battery', () {
      final c = CapacitanceCircuit();
      c.battery.voltage = 1.2;
      c.setCircuitConnection(CircuitState.openCircuit);
      c.setCircuitConnection(CircuitState.batteryConnected);
      expect(c.capacitor.plateVoltage, 1.2);
    });

    test('rejects lightBulbConnected', () {
      final c = CapacitanceCircuit();
      expect(
        () => c.setCircuitConnection(CircuitState.lightBulbConnected),
        throwsArgumentError,
      );
    });

    test('current amplitude ≈ dQ/dt when charging', () {
      final c = CapacitanceCircuit();
      c.battery.voltage = 0;
      c.step(0.1); // establish previous Q
      c.battery.voltage = 1.5;
      final qAfter = c.getTotalCharge();
      c.previousTotalCharge = 0;
      c.updateCurrentAmplitude(0.2);
      expect(c.currentAmplitude, closeTo(qAfter / 0.2, 1e-20));
    });

    test('reset restores defaults', () {
      final c = CapacitanceCircuit();
      c.battery.voltage = 1.5;
      c.setCircuitConnection(CircuitState.openCircuit);
      c.reset();
      expect(c.battery.voltage, 0);
      expect(c.circuitConnection, CircuitState.batteryConnected);
      expect(c.capacitor.plateVoltage, 0);
      expect(c.disconnectedPlateCharge, 0);
      expect(c.currentAmplitude, 0);
    });
  });

  group('LightBulbCircuit', () {
    test('has bulb and three allowed connections', () {
      final c = LightBulbCircuit();
      expect(c.lightBulb, isNotNull);
      expect(c.lightBulb!.resistance, ClbConstants.lightBulbResistance);
      expect(c.allowedConnections.length, 3);
    });

    test('discharge when bulb connected', () {
      final c = LightBulbCircuit();
      c.battery.voltage = 1.5;
      expect(c.capacitor.plateVoltage, 1.5);

      c.setCircuitConnection(CircuitState.lightBulbConnected);
      // Leaving battery stores Q; voltage not forced by updatePlateVoltages for bulb
      // After connection change from battery, LightBulbCircuit.updatePlateVoltages
      // does not set voltage for LIGHT_BULB_CONNECTED — voltage remains until discharge.
      final v0 = c.capacitor.plateVoltage;
      expect(v0.abs(), greaterThan(ClbConstants.minVoltageForDischarge));

      c.step(0.2);
      expect(c.capacitor.plateVoltage.abs(), lessThan(v0.abs()));
    });

    test('I = V/R when bulb connected', () {
      final c = LightBulbCircuit();
      c.battery.voltage = 1.5;
      c.setCircuitConnection(CircuitState.lightBulbConnected);
      c.updateCurrentAmplitude(0.1);
      final expected = c.capacitor.plateVoltage / c.lightBulb!.resistance;
      final cutoff =
          2 * ClbConstants.minVoltageForDischarge / c.lightBulb!.resistance;
      if (expected.abs() < cutoff) {
        expect(c.currentAmplitude, 0);
      } else {
        expect(c.currentAmplitude, closeTo(expected, 1e-30));
      }
    });

    test('voltage clamps to 0 below MIN_VOLTAGE while discharging', () {
      final c = LightBulbCircuit();
      c.battery.voltage = 1.5;
      c.setCircuitConnection(CircuitState.lightBulbConnected);
      // Drive voltage near zero with many steps
      for (var i = 0; i < 50; i++) {
        c.step(1.0);
      }
      expect(c.capacitor.plateVoltage, 0);
      expect(c.currentAmplitude, 0);
    });

    test('open circuit V = Q/C', () {
      final c = LightBulbCircuit();
      c.battery.voltage = 1.0;
      final q = c.getTotalCharge();
      c.setCircuitConnection(CircuitState.openCircuit);
      expect(
        c.capacitor.plateVoltage,
        closeTo(q / c.capacitor.capacitance, 1e-12),
      );
    });
  });

  group('CapacitanceModel / ClbLightBulbModel', () {
    test('independent circuits, shared switchUsed', () {
      final shared = ClbSharedState();
      final cap = CapacitanceModel(shared: shared);
      final bulb = ClbLightBulbModel(shared: shared);

      expect(identical(cap.shared, bulb.shared), isTrue);
      expect(identical(cap.circuit, bulb.circuit), isFalse);

      cap.circuit.battery.voltage = 1.0;
      expect(bulb.circuit.battery.voltage, 0);

      shared.markSwitchUsed();
      expect(cap.shared.switchUsed, isTrue);
      expect(bulb.shared.switchUsed, isTrue);

      cap.reset();
      expect(shared.switchUsed, isFalse);
      expect(cap.circuit.battery.voltage, 0);
      // Bulb screen state untouched by cap.reset except shared
      expect(bulb.circuit.battery.voltage, 0); // still default
    });

    test('CapacitanceModel reset restores meter visibles via BarMeter', () {
      final m = CapacitanceModel(shared: ClbSharedState());
      m.topPlateChargeMeterVisible = true;
      m.storedEnergyMeterVisible = true;
      m.electricFieldVisible = true;
      m.circuit.battery.voltage = 1.5;
      m.reset();
      expect(m.topPlateChargeMeterVisible, isFalse);
      expect(m.storedEnergyMeterVisible, isFalse);
      expect(m.electricFieldVisible, isFalse);
      expect(m.capacitanceMeterVisible, isTrue);
      expect(m.circuit.battery.voltage, 0);
      expect(m.voltmeter.measuredVoltage, isNull);
      expect(m.voltmeter.positiveProbeX, ClbConstants.positiveProbeX);
    });

    test('LightBulbModel step discharges and updates I', () {
      final m = ClbLightBulbModel(shared: ClbSharedState());
      m.circuit.battery.voltage = 1.5;
      m.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      final v0 = m.circuit.capacitor.plateVoltage;
      m.step(0.2);
      expect(m.circuit.capacitor.plateVoltage.abs(), lessThan(v0.abs()));
    });

    test('pause stops discharge', () {
      final m = ClbLightBulbModel(shared: ClbSharedState());
      m.circuit.battery.voltage = 1.5;
      m.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      m.setPlaying(false);
      final v0 = m.circuit.capacitor.plateVoltage;
      m.step(0.2);
      expect(m.circuit.capacitor.plateVoltage, v0);
    });

    test('slow time scale stretches discharge', () {
      final a = ClbLightBulbModel(shared: ClbSharedState());
      final b = ClbLightBulbModel(shared: ClbSharedState());
      a.circuit.battery.voltage = 1.5;
      b.circuit.battery.voltage = 1.5;
      a.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      b.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      a.setTimeSpeed(TimeSpeed.slow);
      a.step(0.2);
      b.step(0.2);
      // Slow should discharge less
      expect(
        a.circuit.capacitor.plateVoltage.abs(),
        greaterThan(b.circuit.capacitor.plateVoltage.abs()),
      );
    });

    test('defaults: plate charges on, E-field off, current on', () {
      final m = CapacitanceModel(shared: ClbSharedState());
      expect(m.plateChargesVisible, isTrue);
      expect(m.electricFieldVisible, isFalse);
      expect(m.currentVisible, isTrue);
      expect(m.arrowStyle, CurrentArrowStyle.electrons);
      m.setCurrentOrientation(math.pi);
      expect(m.arrowStyle, CurrentArrowStyle.conventional);
    });

    test('maxPlateCharge / maxE match CLBModel formulas', () {
      final m = CapacitanceModel(shared: ClbSharedState());
      final maxArea =
          ClbConstants.plateWidthMax * ClbConstants.plateWidthMax;
      final minArea =
          ClbConstants.plateWidthMin * ClbConstants.plateWidthMin;
      expect(
        m.maxPlateCharge,
        closeTo(
          ClbConstants.epsilon0 *
              maxArea *
              ClbConstants.batteryVoltageMax /
              ClbConstants.plateSeparationMin,
          1e-20,
        ),
      );
      expect(
        m.maxEffectiveEField,
        closeTo(
          maxArea /
              minArea *
              ClbConstants.batteryVoltageMax /
              ClbConstants.plateSeparationMin,
          1e-9,
        ),
      );
    });
  });
}
