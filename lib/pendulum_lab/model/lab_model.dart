import 'energy_model.dart';
import 'period_timer.dart';

/// Lab-screen model. Source: `LabModel.js`.
class LabModel extends EnergyModel {
  LabModel()
      : super(
          hasPeriodTimer: true,
          energyBoxExpandedDefault: false,
        ) {
    periodTimer = PeriodTimer(pendula);
    for (final p in pendula) {
      p.userMovedListeners.add(() {
        periodTimer?.onPendulumParameterChanged(p);
      });
    }
  }

  bool isVelocityVisible = false;
  bool isAccelerationVisible = false;

  void setVelocityVisible(bool value) {
    isVelocityVisible = value;
    notifyListeners();
  }

  void setAccelerationVisible(bool value) {
    isAccelerationVisible = value;
    notifyListeners();
  }

  @override
  void returnPendula() {
    super.returnPendula();
    periodTimer?.isRunning = false;
    notifyListeners();
  }

  @override
  void reset() {
    super.reset();
    isVelocityVisible = false;
    isAccelerationVisible = false;
    periodTimer?.reset();
    notifyListeners();
  }
}
