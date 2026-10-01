import '../../common/model/clb_model.dart';
import '../../common/model/parallel_circuit.dart';

/// Capacitance screen model — `js/capacitance/model/CapacitanceModel.js`
class CapacitanceModel extends ClbModel {
  CapacitanceModel({required super.shared})
      : super(circuit: CapacitanceCircuit());

  CapacitanceCircuit get capacitanceCircuit =>
      circuit as CapacitanceCircuit;

  @override
  void reset() {
    // CapacitanceModel.js:52-58 — meters → voltmeter → circuit → super
    capacitanceMeter.reset();
    plateChargeMeter.reset();
    storedEnergyMeter.reset();
    voltmeter.reset();
    circuit.reset();
    super.reset();
  }
}
