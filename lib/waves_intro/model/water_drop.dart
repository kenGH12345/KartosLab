/// PhET `WaterDrop.js` @ wave-interference lock `31ebfd7`.
///
/// [已确认] WATER_DROP_SPEED=140；INITIAL_DISTANCE_ABOVE_LATTICE=100（view coords）。
class WaterDrop {
  WaterDrop({
    required this.amplitude,
    required this.startsOscillation,
    required this.sourceSeparation,
    required this.sign,
    required this.onAbsorption,
  }) : y = initialDistanceAboveLattice;

  /// [已确认] WaterDrop.js
  static const double waterDropSpeed = 140;
  static const double initialDistanceAboveLattice = 100;

  final double amplitude;
  final bool startsOscillation;
  final double sourceSeparation;

  /// -1 top faucet, +1 bottom (Intro uses +1 only).
  final int sign;
  final void Function() onAbsorption;

  double y;
  bool absorbed = false;

  void step(double dt) {
    y -= dt * waterDropSpeed;
    if (y < 0) {
      onAbsorption();
    }
  }
}
