import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/famb_constants.dart';
import 'package:kratos/forces/model/motion_model.dart';

void main() {
  group('MotionModel stack', () {
    test('starts with crate1 (50 kg)', () {
      final m = MotionModel(MotionScreenStyle.motion);
      expect(m.stack.length, 1);
      expect(m.stack.first.id, 'crate1');
      expect(m.totalMass, 50);
      expect(m.sim.frictionCoeff, 0);
    });

    test('friction / acceleration default μ = 0.25', () {
      expect(
        MotionModel(MotionScreenStyle.friction).sim.frictionCoeff,
        MotionConstants.defaultFrictionHalf,
      );
      expect(
        MotionModel(MotionScreenStyle.acceleration).sim.frictionCoeff,
        MotionConstants.defaultFrictionHalf,
      );
    });

    test('acceleration catalog has bucket, no trash', () {
      final m = MotionModel(MotionScreenStyle.acceleration);
      expect(m.catalog.any((i) => i.id == 'bucket'), isTrue);
      expect(m.catalog.any((i) => i.id == 'trash'), isFalse);
      expect(m.catalog.firstWhere((i) => i.id == 'bucket').mass, 100);
    });

    test('motion catalog has trash, no bucket', () {
      final m = MotionModel(MotionScreenStyle.motion);
      expect(m.catalog.any((i) => i.id == 'trash'), isTrue);
      expect(m.catalog.any((i) => i.id == 'bucket'), isFalse);
    });

    test('masses match PhET', () {
      final m = MotionModel(MotionScreenStyle.motion);
      double massOf(String id) => m.catalog.firstWhere((i) => i.id == id).mass;
      expect(massOf('fridge'), 200);
      expect(massOf('crate1'), 50);
      expect(massOf('crate2'), 50);
      expect(massOf('girl'), 40);
      expect(massOf('man'), 80);
      expect(massOf('trash'), 100);
      expect(massOf('mystery'), 50);
    });

    test('max stack 3 splices bottom', () {
      final m = MotionModel(MotionScreenStyle.motion);
      final fridge = m.catalog.firstWhere((i) => i.id == 'fridge');
      final crate2 = m.catalog.firstWhere((i) => i.id == 'crate2');
      final girl = m.catalog.firstWhere((i) => i.id == 'girl');
      final man = m.catalog.firstWhere((i) => i.id == 'man');
      m.addToStack(fridge);
      m.addToStack(crate2);
      expect(m.stack.length, 3);
      m.addToStack(girl); // splices crate1
      expect(m.stack.length, 3);
      expect(m.stack.first.id, 'fridge');
      expect(m.stack.any((i) => i.id == 'crate1'), isFalse);
      m.addToStack(man); // splices fridge → crate2 + girl + man
      expect(m.stack.map((i) => i.id).toList(), ['crate2', 'girl', 'man']);
      expect(m.totalMass, crate2.mass + girl.mass + man.mass);
    });

    test('applied force changes mass-dependent acceleration', () {
      final m = MotionModel(MotionScreenStyle.motion);
      m.setAppliedForce(100);
      m.step(1 / 60);
      expect(m.sim.acceleration, closeTo(100 / 50, 1e-9));
      m.addToStack(m.catalog.firstWhere((i) => i.id == 'fridge'));
      m.setAppliedForce(100);
      m.sim.updateForces();
      // a not stepped yet — check a = F/m after update
      expect(m.sim.mass, 250);
      m.step(1 / 60);
      expect(m.sim.acceleration, closeTo(100 / 250, 1e-6));
    });

    test('pause updates forces but not position', () {
      final m = MotionModel(MotionScreenStyle.friction);
      m.setAppliedForce(300);
      m.isPlaying = false;
      final x0 = m.sim.position;
      m.step(1 / 60);
      expect(m.sim.position, x0);
      expect(m.sim.frictionForce, isNot(0));
    });

    test('reset restores crate1 and defaults', () {
      final m = MotionModel(MotionScreenStyle.friction);
      m.addToStack(m.catalog.firstWhere((i) => i.id == 'fridge'));
      m.setAppliedForce(200);
      m.setFriction(0.5);
      m.reset();
      expect(m.stack.single.id, 'crate1');
      expect(m.sim.appliedForce, 0);
      expect(m.sim.frictionCoeff, 0.25);
      expect(m.sim.position, 0);
    });
  });
}
