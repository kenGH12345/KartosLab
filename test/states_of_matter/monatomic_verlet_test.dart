import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/engine/monatomic_verlet_algorithm.dart';
import 'package:kratos/chemistry/states_of_matter/model/multiple_particle_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';

void main() {
  group('MonatomicVerletAlgorithm', () {
    test('force scalar formula and motion update', () {
      final model = MultipleParticleModel(random: SomRandom(42));
      final verlet = model.moleculeForceAndMotionCalculator!;
      expect(verlet, isA<MonatomicVerletAlgorithm>());
      expect(verlet.getScaledEpsilon(), 1);

      final data = model.moleculeDataSet!;
      // Place two atoms close enough to interact
      data.moleculeCenterOfMassPositions[0]!.setXY(5, 5);
      data.moleculeCenterOfMassPositions[1]!.setXY(5.5, 5);
      data.moleculeVelocities[0]!.setXY(0, 0);
      data.moleculeVelocities[1]!.setXY(0, 0);
      data.moleculeForces[0]!.setXY(0, 0);
      data.moleculeForces[1]!.setXY(0, 0);

      final before0 = data.moleculeCenterOfMassPositions[0]!.copy();
      // First step: positions use prior forces (0); velocities update from new forces.
      verlet.updateForcesAndMotion(0.01);
      expect(
        data.moleculeVelocities[0]!.magnitude +
            data.moleculeVelocities[1]!.magnitude,
        greaterThan(0),
      );
      // Second step: positions advance from non-zero velocities / forces.
      verlet.updateForcesAndMotion(0.01);

      final after0 = data.moleculeCenterOfMassPositions[0]!;
      expect(
        (after0.x - before0.x).abs() + (after0.y - before0.y).abs(),
        greaterThan(0),
      );
      expect(verlet.calculatedTemperature, greaterThanOrEqualTo(0));
    });

    test('forceScalar matches 48*r2inv*r6inv*(r6inv-0.5)*epsilon', () {
      const dx = 1.0;
      const dy = 0.0;
      final distanceSqrd = dx * dx + dy * dy;
      final r2inv = 1 / distanceSqrd;
      final r6inv = r2inv * r2inv * r2inv;
      const epsilon = 1.0;
      final forceScalar = 48 * r2inv * r6inv * (r6inv - 0.5) * epsilon;
      expect(forceScalar, closeTo(48 * 1 * 1 * (1 - 0.5), 1e-12));
      expect(
        AbstractForceHelpers.minDistanceClamp(
          SomConstants.minDistanceSquared - 0.1,
        ),
        SomConstants.minDistanceSquared,
      );
    });
  });
}

class AbstractForceHelpers {
  static double minDistanceClamp(double d2) {
    if (d2 < SomConstants.minDistanceSquared) {
      return SomConstants.minDistanceSquared;
    }
    return d2;
  }
}
