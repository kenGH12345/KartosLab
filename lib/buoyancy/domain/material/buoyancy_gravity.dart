import '../../physics/constants.dart';

/// Gravity presets from `Gravity.ts`.
class BuoyancyGravity {
  const BuoyancyGravity({
    required this.id,
    required this.value,
    this.custom = false,
    this.hidden = false,
  });

  final String id;

  /// m/s²
  final double value;
  final bool custom;
  final bool hidden;

  static const moon = BuoyancyGravity(id: 'moon', value: 1.6);
  static const earth =
      BuoyancyGravity(id: 'earth', value: BuoyancyPhysicsConstants.gEarth);
  static const jupiter = BuoyancyGravity(id: 'jupiter', value: 24.8);
  static const planetX =
      BuoyancyGravity(id: 'planetX', value: 19.6, hidden: true);

  static BuoyancyGravity customValue(double g) {
    final clamped = g.clamp(
      BuoyancyPhysicsConstants.gravityMin,
      BuoyancyPhysicsConstants.gravityMax,
    );
    return BuoyancyGravity(id: 'custom', value: clamped.toDouble(), custom: true);
  }
}
