import 'intro_model.dart';
import 'sensors.dart';
import 'substance.dart';

/// More Tools screen model (`MoreToolsModel.ts`).
class MoreToolsModel extends IntroModel {
  MoreToolsModel()
      : super(
          bottomSubstance: Substance.glass,
          horizontalPlayAreaOffset: false,
        ) {
    velocitySensor = VelocitySensor();
    waveSensor = WaveSensor(
      probe1Value: getWaveValue,
      probe2Value: getWaveValue,
    );
    updateModel();
  }

  late final VelocitySensor velocitySensor;
  late final WaveSensor waveSensor;

  void _syncVelocity() {
    velocitySensor.value = getVelocity(velocitySensor.position);
  }

  @override
  void updateModel() {
    super.updateModel();
    _syncVelocity();
  }

  @override
  void afterTimeStep() {
    if (waveSensor.enabled) {
      waveSensor.step();
    }
    super.afterTimeStep();
  }

  @override
  void reset() {
    super.reset();
    velocitySensor.reset();
    waveSensor.reset();
  }
}
