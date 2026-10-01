import '../../clb_constants.dart';
import '../../common/model/circuit_config.dart';
import '../../common/model/clb_model.dart';
import '../../common/model/parallel_circuit.dart';
import '../../common/model/time_speed.dart';

/// Light Bulb screen model — `js/light-bulb/model/CLBLightBulbModel.js`
class ClbLightBulbModel extends ClbModel {
  ClbLightBulbModel({
    required super.shared,
    bool twoStateSwitch = false,
  }) : super(
          circuit: LightBulbCircuit(
            CircuitConfig.lightBulbScreen(twoStateSwitch: twoStateSwitch),
          ),
        );

  LightBulbCircuit get lightBulbCircuit => circuit as LightBulbCircuit;

  @override
  void reset() {
    // CLBLightBulbModel.js:81-90
    plateChargesVisible = true;
    topPlateChargeMeterVisible = false;
    storedEnergyMeterVisible = false;
    capacitanceMeter.reset();
    plateChargeMeter.reset();
    storedEnergyMeter.reset();
    voltmeter.reset();
    circuit.reset();
    super.reset();
  }

  double _adjustedDt(double dt, {required bool isManual}) {
    if (isManual) return dt;
    return dt * (timeSpeed == TimeSpeed.slow ? ClbConstants.slowTimeScale : 1);
  }

  @override
  void step(double dt, {bool isManual = false}) {
    super.step(dt, isManual: isManual);
    // Recompute I after discharge — CLBLightBulbModel.js:98-100
    if (isPlaying || isManual) {
      circuit.updateCurrentAmplitude(_adjustedDt(dt, isManual: isManual));
    }
  }

  @override
  void manualStep() {
    // Source calls super.step(0.2, true) only (CLBModel.step).
    // Our step() override already re-updates amplitude.
    step(ClbConstants.manualStepDt, isManual: true);
  }
}
