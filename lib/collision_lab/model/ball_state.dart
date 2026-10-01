import 'cl_vec.dart';

/// Immutable snapshot — `js/common/model/BallState.js`
class BallState {
  const BallState({
    required this.position,
    required this.velocity,
    required this.mass,
  });

  final ClVec position;
  final ClVec velocity;
  final double mass;

  bool equals(BallState o) =>
      position == o.position && velocity == o.velocity && mass == o.mass;

  @override
  String toString() =>
      'BallState[position: $position, velocity: $velocity, mass: $mass]';
}
