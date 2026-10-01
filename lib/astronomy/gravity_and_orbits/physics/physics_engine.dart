/// Physics engine — port of `GravityAndOrbitsPhysicsEngine.ts`.
library;

import '../gao_constants.dart';
import '../model/gao_body.dart';
import 'model_state.dart';

class GaoPhysicsEngine {
  GaoPhysicsEngine({
    required this.baseDtValue,
    required this.adjustMoonOrbit,
  });

  final double baseDtValue;
  final bool adjustMoonOrbit;
  final List<GaoBody> bodies = [];

  bool gravityEnabled = true;
  GaoTimeSpeed timeSpeed = GaoTimeSpeed.normal;
  double simulationTime = 0;

  void addBody(GaoBody body) {
    bodies.add(body);
    updateForceVectors();
  }

  /// One animation-frame model advance (`stepModel`).
  /// Returns elapsed simulation time (seconds).
  double stepModel() {
    for (final body in bodies) {
      body.storePreviousPosition();
    }

    final smallestTimeStep =
        baseDtValue * GaoConstants.smallestTimeStepFactor;
    final numberOfSteps = switch (timeSpeed) {
      GaoTimeSpeed.slow => GaoConstants.substepsSlow,
      GaoTimeSpeed.normal => GaoConstants.substepsNormal,
      GaoTimeSpeed.fast => GaoConstants.substepsFast,
    };

    for (var i = 0; i < numberOfSteps; i++) {
      step(smallestTimeStep);
      for (final body in bodies) {
        body.modelStepped();
      }
    }

    final elapsed = smallestTimeStep * numberOfSteps;
    simulationTime += elapsed;
    return elapsed;
  }

  void step(double dt) {
    final states = [for (final b in bodies) b.toBodyState()];
    final next = ModelState(states, adjustMoonOrbit: adjustMoonOrbit)
        .getNextState(dt, gravityEnabled: gravityEnabled);

    for (var i = 0; i < bodies.length; i++) {
      bodies[i].updateFromModel(next.bodyStates[i]);
    }

    for (var j = 0; j < bodies.length; j++) {
      final body = bodies[j];
      for (var k = 0; k < bodies.length; k++) {
        final other = bodies[k];
        if (identical(other, body)) continue;
        if (other.isCollided || body.isCollided) continue;
        if (other.collidesWith(body)) {
          final smaller = other.mass < body.mass ? other : body;
          smaller.isCollided = true;
        }
      }
    }
  }

  void updateForceVectors() => step(0);

  void resetAll() {
    resetBodies();
    simulationTime = 0;
    updateForceVectors();
  }

  void resetBodies() {
    for (final body in bodies) {
      body.resetAll();
    }
    updateForceVectors();
  }

  void rewindAll() {
    for (final body in bodies) {
      body.rewind();
    }
    updateForceVectors();
  }

  void clearPaths() {
    for (final body in bodies) {
      body.clearPath();
    }
  }
}
