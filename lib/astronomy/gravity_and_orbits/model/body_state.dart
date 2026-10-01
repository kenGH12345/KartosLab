/// Mutable body state snapshot for PEFRL — `BodyState.ts`.
library;

import 'body_type.dart';
import 'gao_vec.dart';

class BodyState {
  BodyState({
    required this.type,
    required this.position,
    required this.velocity,
    required this.acceleration,
    required this.mass,
    required this.exploded,
    required this.rotation,
    this.rotationPeriod,
  });

  final GaoBodyType type;
  final GaoVec position;
  final GaoVec velocity;
  final GaoVec acceleration;
  double mass;
  bool exploded;
  double rotation;
  final double? rotationPeriod;

  BodyState copy() => BodyState(
        type: type,
        position: position.copy(),
        velocity: velocity.copy(),
        acceleration: acceleration.copy(),
        mass: mass,
        exploded: exploded,
        rotation: rotation,
        rotationPeriod: rotationPeriod,
      );
}
