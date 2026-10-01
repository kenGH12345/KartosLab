import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/famb_constants.dart';
import 'package:kratos/forces/model/forces_simulation.dart';

void main() {
  group('ForcesSimulation friction (PhET)', () {
    test('static friction cancels applied when below μmg', () {
      final sim = ForcesSimulation(mass: 50)..frictionCoeff = 0.25;
      sim.setAppliedForce(50); // μmg = 0.25*50*9.8 = 122.5
      expect(sim.frictionForce, closeTo(-50, 0.01));
      expect(sim.sumOfForces, closeTo(0, 0.01));
    });

    test('static friction yields when applied exceeds μmg', () {
      final sim = ForcesSimulation(mass: 50)..frictionCoeff = 0.25;
      sim.setAppliedForce(200);
      // kinetic at breakaway uses μmg (not yet moving), magnitude 122.5
      expect(sim.frictionForce, closeTo(-122.5.roundToDouble(), 1));
      expect(sim.sumOfForces.abs(), greaterThan(0));
    });

    test('kinetic friction is 0.75 * μmg opposing velocity', () {
      final sim = ForcesSimulation(mass: 50)
        ..frictionCoeff = 0.25
        ..velocity = 5
        ..appliedForce = 0;
      sim.updateForces();
      // -sign(v) * 0.25*50*9.8 * 0.75 = -91.875 → roundSymmetric
      expect(sim.frictionForce, closeTo(roundSymmetric(-91.875), 0.01));
    });

    test('zero friction means zero friction force', () {
      final sim = ForcesSimulation(mass: 50)
        ..frictionCoeff = 0
        ..setAppliedForce(100);
      expect(sim.frictionForce, 0);
      expect(sim.sumOfForces, 100);
    });
  });

  group('ForcesSimulation motion', () {
    test('F=ma with no friction', () {
      final sim = ForcesSimulation(mass: 50)..frictionCoeff = 0;
      sim.setAppliedForce(100);
      sim.stepModel(1 / 60);
      expect(sim.acceleration, closeTo(2, 1e-9));
      expect(sim.velocity, closeTo(2 / 60, 1e-9));
    });

    test('velocity reverse from friction clamps to zero', () {
      final sim = ForcesSimulation(mass: 50)
        ..frictionCoeff = 0.5
        ..velocity = 0.01
        ..appliedForce = 0;
      sim.updateForces();
      // Large kinetic friction will reverse tiny velocity → clamp 0
      for (var i = 0; i < 120; i++) {
        sim.stepModel(1 / 60);
      }
      expect(sim.velocity, 0);
    });

    test('speed capped at MAX_SPEED and pusher falls', () {
      final sim = ForcesSimulation(mass: 10)..frictionCoeff = 0;
      sim.setAppliedForce(500);
      for (var i = 0; i < 600; i++) {
        sim.stepModel(1 / 60);
      }
      expect(sim.speed, closeTo(MotionConstants.maxSpeed, 0.01));
      expect(sim.fallen, isTrue);
      expect(sim.appliedForce, 0);
    });

    test('empty mass does not accelerate', () {
      final sim = ForcesSimulation(mass: 0)..setAppliedForce(100);
      sim.stepModel(1 / 60);
      expect(sim.acceleration, 0);
      expect(sim.velocity, 0);
    });
  });
}
