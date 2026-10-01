import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/model/probe_target.dart';
import 'package:kratos/capacitor_lab_basics/common/render/circuit_render_data.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/circuit_geometry.dart';
import 'package:kratos/capacitor_lab_basics/common/widgets/switch_gesture_layer.dart';
import 'package:kratos/capacitor_lab_basics/light_bulb/model/clb_light_bulb_model.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';

void main() {
  group('Light Bulb 3-state switch', () {
    test('snap right→bulb center→open left→battery', () {
      expect(
        CircuitGeometry.snapConnectionFromAbsAngle(0.1, threeState: true),
        CircuitState.lightBulbConnected,
      );
      expect(
        CircuitGeometry.snapConnectionFromAbsAngle(mathPi / 2, threeState: true),
        CircuitState.openCircuit,
      );
      expect(
        CircuitGeometry.snapConnectionFromAbsAngle(3 * mathPi / 4,
            threeState: true),
        CircuitState.batteryConnected,
      );
    });

    test('rightLimit expands to ±π/4 with bulb', () {
      expect(
        CircuitGeometry.rightLimitAngle(isTop: true, hasLightBulb: true),
        closeTo(-mathPi / 4, 1e-12),
      );
      expect(
        CircuitGeometry.rightLimitAngle(isTop: false, hasLightBulb: true),
        closeTo(mathPi / 4, 1e-12),
      );
    });

    test('set lightBulbConnected discharges path available', () {
      final model = ClbLightBulbModel(shared: ClbSharedState());
      final c = model.lightBulbCircuit;
      c.battery.voltage = 1.5;
      c.setCircuitConnection(CircuitState.lightBulbConnected);
      expect(c.circuitConnection, CircuitState.lightBulbConnected);
      expect(c.lightBulb, isNotNull);
      model.step(0.2, isManual: true);
      expect(c.capacitor.plateVoltage.abs(), lessThan(1.5));
    });

    test('ConnectionNode tap: battery ↔ open ↔ bulb freely', () {
      final shared = ClbSharedState();
      final model = ClbLightBulbModel(shared: shared);
      final c = model.circuit;
      expect(c.circuitConnection, CircuitState.batteryConnected);

      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.openCircuit,
        ),
        isTrue,
      );
      expect(c.circuitConnection, CircuitState.openCircuit);
      expect(shared.switchUsed, isTrue);
      expect(
        c.topSwitchAngle,
        CircuitGeometry.angleForConnection(
          connection: CircuitState.openCircuit,
          isTop: true,
        ),
      );

      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.lightBulbConnected,
        ),
        isTrue,
      );
      expect(c.circuitConnection, CircuitState.lightBulbConnected);

      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.batteryConnected,
        ),
        isTrue,
      );
      expect(c.circuitConnection, CircuitState.batteryConnected);

      // Same port — no-op (PhET would start drag).
      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.batteryConnected,
        ),
        isFalse,
      );
    });
  });

  group('Capacitance 2-state ConnectionNode', () {
    test('tap open/battery; lightBulb rejected', () {
      final shared = ClbSharedState();
      final model = CapacitanceModel(shared: shared);
      final c = model.circuit;

      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.openCircuit,
        ),
        isTrue,
      );
      expect(c.circuitConnection, CircuitState.openCircuit);

      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.lightBulbConnected,
        ),
        isFalse,
      );
      expect(c.circuitConnection, CircuitState.openCircuit);

      expect(
        trySelectSwitchConnection(
          circuit: c,
          shared: shared,
          target: CircuitState.batteryConnected,
        ),
        isTrue,
      );
      expect(c.circuitConnection, CircuitState.batteryConnected);
    });
  });

  group('Light Bulb wires + render', () {
    test('lightBulbScreenSegments has 12 segments', () {
      final model = ClbLightBulbModel(shared: ClbSharedState());
      final c = model.lightBulbCircuit;
      final segs = CircuitGeometry.lightBulbScreenSegments(
        battery: c.battery,
        capacitor: c.capacitor,
        lightBulb: c.lightBulb!,
        config: c.config,
        connection: c.circuitConnection,
      );
      expect(segs.length, 12);
    });

    test('CircuitRenderData includes bulb center', () {
      final model = ClbLightBulbModel(shared: ClbSharedState());
      final data = CircuitRenderData.fromClbModel(model);
      expect(data.hasLightBulb, isTrue);
      expect(data.bulbViewCenter, isNotNull);
      expect(data.topWireSegments.length, greaterThan(4));
    });

    test('bulb connection points match LightBulb.js', () {
      final model = ClbLightBulbModel(shared: ClbSharedState());
      final bulb = model.circuit.lightBulb!;
      expect(bulb.getTopConnectionPoint().x, bulb.x);
      expect(
        bulb.getBottomConnectionPoint().x,
        closeTo(bulb.x - ClbConstants.bulbBaseWidth * 3 / 5, 1e-12),
      );
    });
  });

  group('Voltmeter on bulb rails', () {
    test('LIGHT_BULB_CONNECTED remaps bulb positions to capacitor V', () {
      final model = ClbLightBulbModel(shared: ClbSharedState());
      final c = model.lightBulbCircuit;
      c.battery.voltage = 1.0;
      c.setCircuitConnection(CircuitState.openCircuit);
      // Store Q then connect bulb
      c.setCircuitConnection(CircuitState.lightBulbConnected);
      final vPlate = c.capacitor.plateVoltage;
      final vm = model.voltmeter;
      vm.positiveProbeTarget = ProbeTarget.lightBulbTop;
      vm.negativeProbeTarget = ProbeTarget.lightBulbBottom;
      // Remap bulb→capacitor then opposite → ±V_plate; same after remap if both top→0
      // top vs bottom → ±V
      expect(vm.computeValue(c), closeTo(vPlate, 1e-9));
    });
  });
}

const mathPi = 3.141592653589793;
