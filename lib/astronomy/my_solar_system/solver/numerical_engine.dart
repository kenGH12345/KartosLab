/// PEFRL N-body engine.
///
/// [MSS] `js/common/model/NumericalEngine.ts` 逐行移植。
/// 禁止换成 Euler / Verlet / RK4。
library;

import 'dart:math' as math;

import '../my_solar_system_constants.dart';
import '../model/celestial_body.dart';
import '../model/mss_vec.dart';

class NumericalEngine {
  NumericalEngine(this.bodies);

  List<CelestialBody> bodies;

  final MssVec _scratch = MssVec.zero();

  void update(List<CelestialBody> next) {
    bodies = next;
    checkCollisions();
    updateForces();
  }

  void reset() => updateForces();

  /// [MSS] 重叠则小体失活，大体 `v += v_small * m_small/m_large`。质量不合并。
  void checkCollisions() {
    var hadCollision = true;
    while (hadCollision) {
      hadCollision = false;
      for (var i = 0; i < bodies.length; i++) {
        final body1 = bodies[i];
        if (!body1.isActive) continue;
        for (var j = i + 1; j < bodies.length; j++) {
          final body2 = bodies[j];
          if (!body2.isActive) continue;
          if (body1.isOverlapping(body2)) {
            final body1Larger = body1.mass > body2.mass;
            final larger = body1Larger ? body1 : body2;
            final smaller = body1Larger ? body2 : body1;
            larger.velocity.add(
              smaller.velocity * (smaller.mass / larger.mass),
            );
            smaller.isActive = false;
            hadCollision = true;
          }
        }
      }
    }
  }

  /// [MSS] `NumericalEngine.run`
  void run(double dt, {bool notifyPropertyListeners = true}) {
    final active = [for (final b in bodies) if (b.isActive) b];
    if (active.isEmpty) return;

    final iterationCount =
        MySolarSystemConstants.pefrlIterationBudget / active.length;
    final n = active.length;
    dt /= iterationCount;

    final masses = [for (final b in active) b.mass];
    final positions = [for (final b in active) b.position.copy()];
    final velocities = [for (final b in active) b.velocity.copy()];
    final accelerations = [for (final b in active) b.acceleration.copy()];
    final gravityForces = [for (final b in active) b.gravityForce.copy()];

    const xi = MySolarSystemConstants.pefrlXi;
    const lambda = MySolarSystemConstants.pefrlLambda;
    const chi = MySolarSystemConstants.pefrlChi;

    for (var k = 0; k < iterationCount; k++) {
      for (var i = 0; i < n; i++) {
        gravityForces[i].setXY(0, 0);
      }

      for (var i = 0; i < n; i++) {
        final mass1 = masses[i];
        for (var j = i + 1; j < n; j++) {
          final mass2 = masses[j];
          _scratch.setFrom(positions[j]);
          _scratch.subtract(positions[i]);
          final distance = _scratch.magnitude;
          assert(distance >= 0, 'Negative distances not allowed!!');
          final gravityForceMagnitude = MySolarSystemConstants.G *
              mass1 *
              mass2 *
              math.pow(distance, -3).toDouble();
          _scratch.multiplyScalar(gravityForceMagnitude);
          gravityForces[i].add(_scratch);
          gravityForces[j].subtract(_scratch);
        }
      }

      for (var i = 0; i < n; i++) {
        accelerations[i].setFrom(gravityForces[i]);
        accelerations[i].multiplyScalar(1 / masses[i]);
      }

      // Position Extended Forest-Ruth Like. Same `a` for all five steps.
      for (var i = 0; i < n; i++) {
        positions[i].add(_scratch.setFrom(velocities[i])..multiplyScalar(xi * dt));
        velocities[i].add(
          _scratch.setFrom(accelerations[i])
            ..multiplyScalar((1 - 2 * lambda) * dt / 2),
        );

        positions[i].add(_scratch.setFrom(velocities[i])..multiplyScalar(chi * dt));
        velocities[i].add(
          _scratch.setFrom(accelerations[i])..multiplyScalar(lambda * dt),
        );

        positions[i].add(
          _scratch.setFrom(velocities[i])
            ..multiplyScalar((1 - 2 * (chi + xi)) * dt),
        );
        velocities[i].add(
          _scratch.setFrom(accelerations[i])..multiplyScalar(lambda * dt),
        );

        positions[i].add(_scratch.setFrom(velocities[i])..multiplyScalar(chi * dt));

        velocities[i].add(
          _scratch.setFrom(accelerations[i])
            ..multiplyScalar((1 - 2 * lambda) * dt / 2),
        );
        positions[i].add(_scratch.setFrom(velocities[i])..multiplyScalar(xi * dt));
      }
    }

    for (var i = 0; i < active.length; i++) {
      final body = active[i];
      if (notifyPropertyListeners) {
        body.position = positions[i];
        body.velocity = velocities[i];
        body.acceleration = accelerations[i];
        body.gravityForce = gravityForces[i];
      } else {
        body.position.setFrom(positions[i]);
        body.velocity.setFrom(velocities[i]);
        body.acceleration.setFrom(accelerations[i]);
        body.gravityForce.setFrom(gravityForces[i]);
      }
    }
  }

  void updateForces() {
    for (final body in bodies) {
      if (!body.isActive) continue;
      body.acceleration = MssVec.zero();
      body.gravityForce = MssVec.zero();
    }
    for (var i = 0; i < bodies.length; i++) {
      final body1 = bodies[i];
      if (!body1.isActive) continue;
      final mass1 = body1.mass;
      for (var j = i + 1; j < bodies.length; j++) {
        final body2 = bodies[j];
        if (!body2.isActive) continue;
        assert(body2.mass > 0, 'mass2 should not be 0');
        final gravityForce = getGravityForce(body1, body2);
        body1.gravityForce.add(gravityForce);
        body2.gravityForce.subtract(gravityForce);
        body1.acceleration.setFrom(body1.gravityForce);
        body1.acceleration.multiplyScalar(1 / mass1);
        body2.acceleration.setFrom(body2.gravityForce);
        body2.acceleration.multiplyScalar(1 / body2.mass);
      }
    }
  }

  /// Force on body1 because of body2. [MSS] `getGravityForce`
  MssVec getGravityForce(CelestialBody body1, CelestialBody body2) {
    final direction = body2.position - body1.position;
    final distance = direction.magnitude;
    if (distance == 0) {
      return MssVec.zero();
    }
    assert(distance > 0, 'Negative distances not allowed!!');
    final gravityForceMagnitude = MySolarSystemConstants.G *
        body1.mass *
        body2.mass *
        math.pow(distance, -3).toDouble();
    direction.multiplyScalar(gravityForceMagnitude);
    return direction;
  }
}
