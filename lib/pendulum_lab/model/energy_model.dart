import 'pendulum.dart';
import 'pendulum_lab_model.dart';

/// Energy-screen model. Source: `EnergyModel.js`.
class EnergyModel extends PendulumLabModel {
  EnergyModel({
    super.hasPeriodTimer = false,
    super.rulerInitiallyVisible = false,
    this.energyBoxExpandedDefault = true,
  }) {
    isEnergyBoxExpanded = energyBoxExpandedDefault;
    activeEnergyPendulum = pendula[0];
  }

  final bool energyBoxExpandedDefault;
  late bool isEnergyBoxExpanded;
  late Pendulum activeEnergyPendulum;

  void setEnergyBoxExpanded(bool value) {
    isEnergyBoxExpanded = value;
    notifyListeners();
  }

  void setActiveEnergyPendulum(Pendulum pendulum) {
    activeEnergyPendulum = pendulum;
    notifyListeners();
  }

  void setEnergyZoom(double value) {
    energyZoom = value;
    notifyListeners();
  }

  @override
  void setNumberOfPendula(int value) {
    super.setNumberOfPendula(value);
    if (numberOfPendula == 1) {
      activeEnergyPendulum = pendula[0];
    }
  }

  @override
  void reset() {
    super.reset();
    isEnergyBoxExpanded = energyBoxExpandedDefault;
    activeEnergyPendulum = pendula[0];
    notifyListeners();
  }
}
