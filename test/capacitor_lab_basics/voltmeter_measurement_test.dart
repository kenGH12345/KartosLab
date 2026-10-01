import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/model/probe_target.dart';
import 'package:kratos/capacitor_lab_basics/common/painters/plate_charge_painter.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/voltmeter_shape_creator.dart';

void main() {
  group('Voltmeter.computeValue', () {
    test('NONE → null; OTHER_PROBE → 0; same rail → 0', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final vm = model.voltmeter;
      final c = model.circuit;

      vm.positiveProbeTarget = ProbeTarget.none;
      vm.negativeProbeTarget = ProbeTarget.capacitorBottom;
      expect(vm.computeValue(c), isNull);

      vm.positiveProbeTarget = ProbeTarget.otherProbe;
      vm.negativeProbeTarget = ProbeTarget.otherProbe;
      expect(vm.computeValue(c), 0);

      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.wireCapacitorTop;
      expect(vm.computeValue(c), 0);
    });

    test('battery connected: opposite plates → ±V_battery', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      c.battery.voltage = 1.5;
      final vm = model.voltmeter;

      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.capacitorBottom;
      expect(vm.computeValue(c), closeTo(1.5, 1e-12));

      vm.positiveProbeTarget = ProbeTarget.capacitorBottom;
      vm.negativeProbeTarget = ProbeTarget.capacitorTop;
      expect(vm.computeValue(c), closeTo(-1.5, 1e-12));
    });

    test('open circuit: opposite plates → ±V_plate from stored Q', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.capacitanceCircuit;
      c.battery.voltage = 1.0;
      final q = c.getTotalCharge();
      c.setCircuitConnection(CircuitState.openCircuit);
      final vPlate = q / c.capacitor.capacitance;
      expect(c.capacitor.plateVoltage, closeTo(vPlate, 1e-12));

      final vm = model.voltmeter;
      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.capacitorBottom;
      expect(vm.computeValue(c), closeTo(vPlate, 1e-12));
    });

    test('battery connected: battery top vs bottom wire → ±V', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      c.battery.voltage = 0.75;
      final vm = model.voltmeter;
      vm.positiveProbeTarget = ProbeTarget.batteryTopTerminal;
      vm.negativeProbeTarget = ProbeTarget.wireBatteryBottom;
      expect(vm.computeValue(c), closeTo(0.75, 1e-12));
    });
  });

  group('Voltmeter.updateMeasuredVoltage + hit', () {
    test('invisible → measuredVoltage null', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      expect(model.voltmeterVisible, isFalse);
      model.refreshVoltmeterReading();
      expect(model.voltmeter.measuredVoltage, isNull);
    });

    test('probes on opposite plates when connected → |V|', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.setVoltmeterVisible(true);
      final c = model.circuit;
      c.battery.voltage = 1.2;
      final cap = c.capacitor;
      final top = cap.getTopConnectionPoint();
      final bottom = cap.getBottomConnectionPoint();

      final vm = model.voltmeter;
      vm.positiveProbeX = top.x - VoltmeterShapeCreator.tipOffsetX;
      vm.positiveProbeY = top.y - VoltmeterShapeCreator.tipOffsetY;
      vm.negativeProbeX = bottom.x - VoltmeterShapeCreator.tipOffsetX;
      vm.negativeProbeY = bottom.y - VoltmeterShapeCreator.tipOffsetY;

      model.refreshVoltmeterReading();
      expect(vm.positiveProbeTarget, isNot(ProbeTarget.none));
      expect(vm.negativeProbeTarget, isNot(ProbeTarget.none));
      expect(vm.measuredVoltage, closeTo(1.2, 1e-9));
    });
  });

  group('PlateChargePainter.numberOfCharges', () {
    test('zero charge → 0; tiny nonzero → min 1; scales to max', () {
      expect(PlateChargePainter.numberOfCharges(0, 1e-10), 0);
      expect(PlateChargePainter.numberOfCharges(1e-20, 1e-10), 1);
      final maxQ = 1e-10;
      expect(
        PlateChargePainter.numberOfCharges(maxQ, maxQ),
        PlateChargePainter.maxCharges,
      );
    });
  });
}
