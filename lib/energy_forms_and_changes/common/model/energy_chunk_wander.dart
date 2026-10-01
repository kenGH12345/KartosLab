import 'dart:math' as math;
import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';

/// PhET `EnergyChunkWanderController`.
class EnergyChunkWanderController {
  EnergyChunkWanderController({
    required this.chunk,
    required this.destination,
    this.minSpeed = 0.06,
    this.maxSpeed = 0.10,
    this.wanderAngleVariation = math.pi * 0.2,
    this.horizontalConstraintMin,
    this.horizontalConstraintMax,
  }) {
    _changeVelocity();
    _resetCountdown();
  }

  final EnergyChunk chunk;
  Offset destination;
  double minSpeed;
  double maxSpeed;
  double wanderAngleVariation;
  double? horizontalConstraintMin;
  double? horizontalConstraintMax;

  Offset velocity = Offset.zero;
  bool wandering = true;
  double _countdown = 0.4;
  final math.Random _rng = math.Random();

  static const double stopWanderingDistance = 0.05;
  static const double minTimeInOneDirection = 0.4;
  static const double maxTimeInOneDirection = 0.8;

  bool get isDestinationReached =>
      (chunk.position - destination).distance < 1e-9;

  void updatePosition(double dt) {
    final dist = (chunk.position - destination).distance;
    final speed = velocity.distance;
    if (speed <= 0 && dist < 1e-12) return;

    if (dist <= speed * dt) {
      chunk.position = destination;
      velocity = Offset.zero;
      return;
    }

    if (horizontalConstraintMin != null && horizontalConstraintMax != null) {
      final proposedX = chunk.position.dx + dt * velocity.dx;
      if ((proposedX < horizontalConstraintMin! && velocity.dx < 0) ||
          (proposedX > horizontalConstraintMax! && velocity.dx > 0)) {
        velocity = Offset(-velocity.dx, velocity.dy);
      }
    }

    chunk.position += velocity * dt;
    _countdown -= dt;
    if (_countdown <= 0 || dist < stopWanderingDistance) {
      _changeVelocity();
      _resetCountdown();
    }
  }

  void _changeVelocity() {
    final delta = destination - chunk.position;
    var angle = math.atan2(delta.dy, delta.dx);
    if (delta.distance > stopWanderingDistance && wandering) {
      angle += (_rng.nextDouble() * 2 - 1) * wanderAngleVariation;
    }
    final spd = minSpeed + (maxSpeed - minSpeed) * _rng.nextDouble();
    velocity = Offset(spd * math.cos(angle), spd * math.sin(angle));
  }

  void _resetCountdown() {
    _countdown = minTimeInOneDirection +
        (maxTimeInOneDirection - minTimeInOneDirection) * _rng.nextDouble();
  }
}
