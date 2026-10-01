import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_constants.dart';
import 'package:kratos/gravity_force_lab_basics/solver/force_solver.dart';

void main() {
  group('ForceSolver PHYSICS_VALIDATION A–G', () {
    test('A. default F ≈ 33.3715', () {
      const m1 = 2e9;
      const m2 = 4e9;
      const r = 4000.0;
      final f = ForceSolver.calculateForce(m1, m2, r);
      expect(f, closeTo(33.3715, 1e-9 * 33.3715 + 1e-12));
      expect(f.toStringAsFixed(1), '33.4');
    });

    test('B. r × 2 → F / 4', () {
      final f = ForceSolver.calculateForce(2e9, 4e9, 8000);
      expect(f, closeTo(8.342875, 1e-9 * 8.342875 + 1e-12));
    });

    test('C. m1 × 2 → F × 2', () {
      final f = ForceSolver.calculateForce(4e9, 4e9, 4000);
      expect(f, closeTo(66.743, 1e-9 * 66.743 + 1e-9));
    });

    test('D. m2 × 2 → F × 2', () {
      final f = ForceSolver.calculateForce(2e9, 8e9, 4000);
      expect(f, closeTo(66.743, 1e-9 * 66.743 + 1e-9));
    });

    test('E. equal masses F = 16.68575', () {
      final f = ForceSolver.calculateForce(2e9, 2e9, 4000);
      expect(f, closeTo(16.68575, 1e-9 * 16.68575 + 1e-12));
    });

    test('F. formula uses G constant', () {
      expect(GflbConstants.g, 6.67430e-11);
      final expected = GflbConstants.g * 2e9 * 4e9 / (4000 * 4000);
      expect(ForceSolver.calculateForce(2e9, 4e9, 4000), expected);
    });

    test('G. distance must be positive', () {
      expect(
        () => ForceSolver.calculateForce(1e9, 1e9, 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
