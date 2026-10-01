
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/capacitor_physics.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/circuit_geometry.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/plate_area_drag_handler.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/yaw_pitch_mvt.dart';

void main() {
  group('Battery voltage slider semantics', () {
    test('default 0; set 1.5; constrain 0.07→0.05; snap 0.1→0', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final bat = model.circuit.battery;
      expect(bat.voltage, 0);

      bat.voltage = 1.5;
      expect(bat.voltage, 1.5);

      bat.voltage = 0.07;
      expect(bat.voltage, 0.05);
      expect(CapacitorPhysics.constrainBatteryVoltage(0.07), 0.05);

      bat.voltage = 0.1;
      expect(bat.voltage, 0.1);
      bat.endDragSnap();
      expect(bat.voltage, 0);
      expect(CapacitorPhysics.snapBatteryVoltage(0.1), 0);
    });

    test('open-circuit voltage change still notifies (polarity + voltmeter)', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      c.setCircuitConnection(CircuitState.openCircuit);
      var notified = 0;
      c.addListener(() => notified++);

      c.battery.voltage = 1.0;
      expect(notified, greaterThan(0));
      expect(c.battery.isPositiveTerminalUp, isTrue);

      notified = 0;
      c.battery.voltage = -1.0;
      expect(notified, greaterThan(0));
      expect(c.battery.isPositiveTerminalUp, isFalse);
      // Open: plates keep stored V, battery itself flipped.
      expect(c.capacitor.plateVoltage, isNot(closeTo(-1.0, 1e-9)));
    });

    test('battery-connected voltage tracks plates', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      expect(c.circuitConnection, CircuitState.batteryConnected);
      c.battery.voltage = -0.75;
      expect(c.capacitor.plateVoltage, closeTo(-0.75, 1e-12));
      expect(c.battery.isPositiveTerminalUp, isFalse);
    });
  });

  group('Switch Capacitance 2-state', () {
    test('battery→open stores Q; reconnect; switchUsed', () {
      final shared = ClbSharedState();
      final model = CapacitanceModel(shared: shared);
      final c = model.capacitanceCircuit;

      c.battery.voltage = 1.0;
      final q = c.getTotalCharge();
      expect(q, greaterThan(0));
      expect(shared.switchUsed, isFalse);

      c.setCircuitConnection(CircuitState.openCircuit);
      expect(c.disconnectedPlateCharge, closeTo(q, 1e-20));
      expect(
        c.capacitor.plateVoltage,
        closeTo(q / c.capacitor.capacitance, 1e-12),
      );
      shared.markSwitchUsed();
      expect(shared.switchUsed, isTrue);

      c.setCircuitConnection(CircuitState.batteryConnected);
      expect(c.capacitor.plateVoltage, 1.0);
      expect(shared.switchUsed, isTrue);

      // Angles snap to steady poses
      expect(
        c.topSwitchAngle,
        CircuitGeometry.angleForConnection(
          connection: CircuitState.batteryConnected,
          isTop: true,
        ),
      );
    });

    test('snap abs(angle) center→open left→battery', () {
      expect(
        CircuitGeometry.snapConnectionFromAbsAngle(mathPi / 2),
        CircuitState.openCircuit,
      );
      expect(
        CircuitGeometry.snapConnectionFromAbsAngle(3 * mathPi / 4),
        CircuitState.batteryConnected,
      );
    });

    test('in-transit tip angles update without leaving allowed set', () {
      final c = CapacitanceModel(shared: ClbSharedState()).capacitanceCircuit;
      c.setSwitchAngleInTransit(isTop: true, angle: -mathPi / 2);
      expect(c.circuitConnection, CircuitState.switchInTransit);
      expect(c.topSwitchAngle, closeTo(-mathPi / 2, 1e-9));
      c.setCircuitConnection(CircuitState.openCircuit);
      expect(c.circuitConnection, CircuitState.openCircuit);
    });
  });

  group('Plate handles model', () {
    test('setPlateSeparation mutates C; limits', () {
      final cap = CapacitanceModel(shared: ClbSharedState()).circuit.capacitor;
      final c0 = cap.capacitance;
      cap.setPlateSeparation(0.003);
      expect(cap.plateSeparation, 0.003);
      expect(cap.capacitance, isNot(closeTo(c0, 1e-20)));

      cap.setPlateSeparation(0.001); // below min → clamp
      expect(cap.plateSeparation, ClbConstants.plateSeparationMin);
      cap.setPlateSeparation(0.02);
      expect(cap.plateSeparation, ClbConstants.plateSeparationMax);
    });

    test('setPlateWidth mutates C', () {
      final cap = CapacitanceModel(shared: ClbSharedState()).circuit.capacitor;
      final c0 = cap.capacitance;
      cap.setPlateWidth(0.018);
      expect(cap.plateWidth, greaterThan(ClbConstants.plateWidthDefault));
      expect(cap.capacitance, isNot(closeTo(c0, 1e-20)));
    });

    test('PlateAreaDragHandler LinearFunction recovers width at grab', () {
      final mvt = YawPitchMvt();
      const w = ClbConstants.plateWidthDefault;
      final origin = mvt.modelToViewDeltaXYZ(w / 2, 0, w / 2);
      // Click exactly on the front-left→back-right projected corner offset.
      final pMouse = Offset(origin.dx, 0);
      final handler = PlateAreaDragHandler(mvt: mvt)..start(pMouse: pMouse, plateWidth: w);
      expect(handler.getPlateWidth(pMouse), closeTo(w, 1e-9));
    });
  });

  group('Voltmeter', () {
    test('visible toggle; body position; reset restores probes', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      expect(model.voltmeterVisible, isFalse);

      model.setVoltmeterVisible(true);
      expect(model.voltmeterVisible, isTrue);
      model.voltmeter.bodyX = 0.05;
      model.voltmeter.bodyY = 0.04;
      model.voltmeter.positiveProbeX = 0.01;
      model.voltmeter.negativeProbeY = 0.01;

      model.reset();
      expect(model.voltmeterVisible, isFalse);
      expect(model.voltmeter.bodyX, 0);
      expect(model.voltmeter.bodyY, 0);
      expect(model.voltmeter.positiveProbeX, ClbConstants.positiveProbeX);
      expect(model.voltmeter.positiveProbeY, ClbConstants.positiveProbeY);
      expect(model.voltmeter.negativeProbeX, ClbConstants.negativeProbeX);
      expect(model.voltmeter.negativeProbeY, ClbConstants.negativeProbeY);
      expect(model.voltmeter.measuredVoltage, isNull);
    });
  });

  group('Integration', () {
    test('voltage change updates plateVoltage when connected', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      expect(model.circuit.circuitConnection, CircuitState.batteryConnected);
      model.circuit.battery.voltage = 1.25;
      expect(model.circuit.capacitor.plateVoltage, 1.25);

      model.circuit.setCircuitConnection(CircuitState.openCircuit);
      model.circuit.battery.voltage = 0.5;
      // Open: plates keep V=Q/C, not battery
      expect(model.circuit.capacitor.plateVoltage, isNot(0.5));
    });
  });
}

const mathPi = 3.141592653589793;
