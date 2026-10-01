import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/famb_constants.dart';
import 'package:kratos/forces/model/motion_model.dart';
import 'package:kratos/forces/model/forces_simulation.dart';

void main() {
  group('friction motion scenarios', () {
    test('force below static friction → no motion', () {
      final sim = ForcesSimulation(mass: 50)..frictionCoeff = 0.25;
      // μmg = 122.5
      sim.setAppliedForce(100);
      for (var i = 0; i < 60; i++) {
        sim.stepModel(1 / 60);
      }
      expect(sim.velocity, 0);
      expect(sim.position, 0);
    });

    test('force above static friction → starts moving', () {
      final sim = ForcesSimulation(mass: 50)..frictionCoeff = 0.25;
      sim.setAppliedForce(200);
      sim.stepModel(1 / 60);
      expect(sim.velocity.abs(), greaterThan(0));
    });

    test('no friction → accelerates with F/m', () {
      final m = MotionModel(MotionScreenStyle.motion);
      m.setAppliedForce(50);
      m.step(1);
      expect(m.sim.velocity, closeTo(1, 1e-9)); // a=1 for 1s
    });

    test('high friction stops object after force removed', () {
      final sim = ForcesSimulation(mass: 50)..frictionCoeff = 0.5;
      sim.setAppliedForce(400);
      for (var i = 0; i < 30; i++) {
        sim.stepModel(1 / 60);
      }
      expect(sim.speed, greaterThan(0));
      sim.setAppliedForce(0);
      for (var i = 0; i < 300; i++) {
        sim.stepModel(1 / 60);
      }
      expect(sim.speed, 0);
    });

    test('μ clamps to MAX_FRICTION', () {
      final m = MotionModel(MotionScreenStyle.friction);
      m.setFriction(999);
      expect(m.sim.frictionCoeff, MotionConstants.maxFriction);
    });
  });
}
