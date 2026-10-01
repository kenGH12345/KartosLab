import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/dual_atom_model.dart';

void main() {
  group('DualAtomModel', () {
    test('force balance near rmin when at rest', () {
      final model = DualAtomModel();
      model.resetMovableAtomPos();
      model.updateForces();

      final r = model.movableAtom.getX();
      expect(r, closeTo(model.getSigma() * 1.122462048309373, 1e-6));

      // At force minimum, attractive ≈ repulsive
      final net = (model.repulsiveForce - model.attractiveForce).abs();
      final scale = (model.attractiveForce.abs() + model.repulsiveForce.abs()) /
          2;
      expect(net / scale, lessThan(1e-6));
    });

    test('drag pauses motion and moves atom', () {
      final model = DualAtomModel();
      model.resetMovableAtomPos();
      final rMin = model.movableAtom.getX();

      model.dragMovableAtomTo(rMin + 50);
      expect(model.motionPaused, isTrue);
      expect(model.movableAtom.getVx(), 0);
      expect(model.movableAtom.getX(), closeTo(rMin + 50, 1e-9));

      model.endDrag();
      expect(model.motionPaused, isFalse);
    });

    test('reset restores neon pair at rmin', () {
      final model = DualAtomModel();
      model.dragMovableAtomTo(500);
      model.setPlaying(false);
      model.setTimeSpeed(InteractionTimeSpeed.slow);

      model.reset();

      expect(model.isPlaying, isTrue);
      expect(model.motionPaused, isFalse);
      expect(model.timeSpeed, InteractionTimeSpeed.normal);
      expect(
        model.movableAtom.getX(),
        closeTo(model.ljPotentialCalculator.getMinimumForceDistance(), 1e-9),
      );
      expect(model.movableAtom.getVx(), 0);
    });

    test('step advances when playing and not paused', () {
      final model = DualAtomModel();
      // Displace from equilibrium so net force is non-zero
      model.dragMovableAtomTo(model.getSigma() * 0.95);
      model.endDrag();
      final x0 = model.movableAtom.getX();

      model.isPlaying = true;
      for (var i = 0; i < 5; i++) {
        model.step(0.016);
      }
      expect(model.movableAtom.getX(), isNot(closeTo(x0, 1e-12)));
    });
  });
}
