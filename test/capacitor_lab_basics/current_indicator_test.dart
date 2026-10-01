import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/light_bulb/model/clb_light_bulb_model.dart';

void main() {
  group('Current indicators model hooks', () {
    test('default currentVisible true; orientation electrons=0', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      expect(model.currentVisible, isTrue);
      expect(model.currentOrientation, 0);
      model.setCurrentOrientation(3.141592653589793);
      expect(model.currentOrientation, isNot(0));
      model.setCurrentVisible(false);
      expect(model.currentVisible, isFalse);
    });

    test('voltage step produces nonzero currentAmplitude when charging', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      expect(c.circuitConnection, CircuitState.batteryConnected);
      c.battery.voltage = 1.0;
      c.step(0.016);
      expect(c.currentAmplitude.abs(), greaterThan(0));
    });

    test('Light Bulb: bulb connection keeps currentVisible independent', () {
      final shared = ClbSharedState();
      final lb = ClbLightBulbModel(shared: shared);
      lb.setCurrentVisible(false);
      expect(lb.currentVisible, isFalse);
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      expect(lb.currentVisible, isFalse);
    });
  });
}
