/// Center of mass of active bodies.
///
/// [MSS-SOURCE] `CenterOfMass.ts`
library;

import 'mss_vec.dart';
import 'celestial_body.dart';

class CenterOfMassState {
  const CenterOfMassState({
    required this.position,
    required this.velocity,
    required this.totalMass,
  });

  final MssVec position;
  final MssVec velocity;
  final double totalMass;

  static CenterOfMassState fromBodies(List<CelestialBody> bodies) {
    var totalMass = 0.0;
    for (final b in bodies) {
      if (b.isActive) totalMass += b.mass;
    }
    assert(totalMass != 0, 'Total mass should not go to 0');
    final pos = MssVec.zero();
    final vel = MssVec.zero();
    for (final b in bodies) {
      if (!b.isActive) continue;
      final w = b.mass / totalMass;
      pos.x += b.position.x * w;
      pos.y += b.position.y * w;
      vel.x += b.velocity.x * w;
      vel.y += b.velocity.y * w;
    }
    return CenterOfMassState(
      position: pos,
      velocity: vel,
      totalMass: totalMass,
    );
  }
}
