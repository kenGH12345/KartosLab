/// PEFRL integrator + Newtonian gravity — port of `ModelState.ts`.
///
/// MUST NOT replace with Euler / Verlet / closed-form ellipse.
library;

import 'dart:math' as math;

import '../gao_constants.dart';
import '../model/body_state.dart';
import '../model/body_type.dart';
import '../model/gao_vec.dart';

class ModelState {
  ModelState(this.bodyStates, {required this.adjustMoonOrbit});

  final List<BodyState> bodyStates;
  final bool adjustMoonOrbit;

  final GaoVec _posDelta = GaoVec.zero();
  final GaoVec _netForce = GaoVec.zero();

  ModelState getNextState(double dt, {required bool gravityEnabled}) {
    if (gravityEnabled) {
      return getNextInteractingState(dt);
    }
    return getNextCoastingState(dt);
  }

  ModelState getNextCoastingState(double dt) {
    _updatePositions(dt);
    _setAccelerationToZero();
    _updateRotations(dt);
    return this;
  }

  ModelState getNextInteractingState(double dt) {
    const xi = GaoConstants.pefrlXi;
    const lambda = GaoConstants.pefrlLambda;
    const chi = GaoConstants.pefrlChi;

    _updatePositions(xi * dt);
    _updateVelocities((1 - 2 * lambda) * dt / 2);

    _updatePositions(chi * dt);
    _updateVelocities(lambda * dt);

    _updatePositions((1 - 2 * (chi + xi)) * dt);
    _updateVelocities(lambda * dt);

    _updatePositions(chi * dt);

    _updateVelocities((1 - 2 * lambda) * dt / 2);
    _updatePositions(xi * dt);

    _updateAccelerations();
    _updateRotations(dt);
    return this;
  }

  void _updatePositions(double dt) {
    for (final body in bodyStates) {
      _posDelta.setXY(body.velocity.x * dt, body.velocity.y * dt);
      body.position.add(_posDelta);
    }
  }

  void _updateVelocities(double dt) {
    _updateAccelerations();
    for (final body in bodyStates) {
      body.velocity.addScaled(body.acceleration, dt);
    }
  }

  void _updateAccelerations() {
    for (final body in bodyStates) {
      final force = _getNetForce(body);
      body.acceleration.setXY(force.x / body.mass, force.y / body.mass);
    }
  }

  void _setAccelerationToZero() {
    for (final body in bodyStates) {
      body.acceleration.setXY(0, 0);
    }
  }

  void _updateRotations(double dt) {
    for (final body in bodyStates) {
      final period = body.rotationPeriod;
      if (period != null) {
        body.rotation += -math.pi * 2 * dt / period;
      }
    }
  }

  GaoVec _getNetForce(BodyState bodyState) {
    _netForce.setXY(0, 0);
    for (final other in bodyStates) {
      if (identical(bodyState, other)) continue;
      final f = _getTwoBodyForce(bodyState, other);
      _netForce.add(f);
    }
    // Return a copy so callers don't alias the scratch.
    return _netForce.copy();
  }

  GaoVec _getTwoBodyForce(BodyState source, BodyState target) {
    if (source.position.equalsApprox(target.position)) {
      return GaoVec.zero();
    }
    if (source.exploded || target.exploded) {
      return GaoVec.zero();
    }

    final dx = target.position.x - source.position.x;
    final dy = target.position.y - source.position.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return GaoVec.zero();

    final unitX = dx / dist;
    final unitY = dy / dist;
    var magnitude =
        GaoConstants.G * source.mass * target.mass / (dist * dist);

    if (adjustMoonOrbit &&
        source.type == GaoBodyType.moon &&
        target.type == GaoBodyType.planet) {
      magnitude *= GaoConstants.moonOrbitFudgeFactor;
    }

    return GaoVec(unitX * magnitude, unitY * magnitude);
  }
}
