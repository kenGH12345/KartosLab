import 'concentration_constants.dart';

/// Evaporator — beers-law-lab `Evaporator.ts`.
///
/// View snaps rate to 0 on pointer endDrag / blur via [release].
class EvaporatorModel {
  EvaporatorModel({
    this.maxEvaporationRate = ConcentrationConstants.maxEvaporationRate,
  });

  final double maxEvaporationRate;

  double evaporationRate = 0;
  bool enabled = true;

  void setEvaporationRate(double rate) {
    if (!enabled) {
      evaporationRate = 0;
      return;
    }
    evaporationRate = rate.clamp(0.0, maxEvaporationRate);
  }

  /// Source endDrag / blur — rate returns to 0.
  void release() {
    evaporationRate = 0;
  }

  void syncEnabledFromVolume(double volume) {
    enabled = volume > 0;
    if (!enabled) {
      evaporationRate = 0;
    }
  }

  void reset() {
    evaporationRate = 0;
    enabled = true;
  }
}
