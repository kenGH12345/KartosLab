import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/lj_potential_calculator.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';

void main() {
  group('LjPotentialCalculator', () {
    test('potential and forces at known distance', () {
      const sigma = 308.0; // Neon sigma (pm)
      const epsilon = 35.8;
      final calc = LjPotentialCalculator(sigma, epsilon);

      final rMin = calc.getMinimumForceDistance();
      expect(rMin, closeTo(sigma * math.pow(2, 1 / 6), 1e-9));

      // At r = sigma, potential = 0
      expect(calc.getLjPotential(sigma), closeTo(0, 1e-30));

      // At minimum-force distance, potential ? -epsilon * k_B
      final potAtMin = calc.getLjPotential(rMin);
      expect(
        potAtMin,
        closeTo(-epsilon * SomConstants.kBoltzmann, 1e-30),
      );

      final r = sigma * 1.5;
      final repulsive = calc.getRepulsiveLjForce(r);
      final attractive = calc.getAttractiveLjForce(r);
      expect(repulsive, greaterThan(0));
      expect(attractive, greaterThan(0));
      // Net force = repulsive - attractive; at r > r_min attractive dominates
      expect(attractive, greaterThan(repulsive));
    });

    test('setEpsilon updates epsilonForCalcs', () {
      final calc = LjPotentialCalculator(300, 100);
      calc.setEpsilon(200);
      expect(calc.getEpsilon(), 200);
      final pot = calc.getLjPotential(300);
      expect(pot, closeTo(0, 1e-30));
    });
  });
}
