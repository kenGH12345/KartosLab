import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/force_solver.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';

void main() {
  group('Defaults', () {
    test('masses, positions, distance, G, notation, ruler', () {
      final m = GravityForceLabModel();
      expect(m.mass1.value, 100);
      expect(m.mass2.value, 400);
      expect(m.mass1.positionX, -3);
      expect(m.mass2.positionX, 1);
      expect(m.distance, 4);
      expect(GravityForceConstants.gravitationalConstant, 6.67408e-11);
      expect(m.constantRadius, isFalse);
      expect(m.showForceValues, isTrue);
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);
    });

    test('default force ≈ 1.66852e-7 N', () {
      final m = GravityForceLabModel();
      final expected = 6.67408e-11 * 100 * 400 / 16;
      expect(m.force, closeTo(expected, 1e-20));
      expect(m.force, closeTo(1.66852e-7, 1e-15));
    });

    test('G is Full PhysicalConstants, not Basics 6.67430e-11', () {
      expect(GravityForceConstants.gravitationalConstant, isNot(6.67430e-11));
      expect(GravityForceConstants.gravitationalConstant, 6.67408e-11);
    });
  });

  group('Force formula / symmetry / inverse-square', () {
    test('formula matches G*m1*m2/r²', () {
      expect(
        ForceSolver.calculateForce(100, 400, 4),
        6.67408e-11 * 100 * 400 / 16,
      );
    });

    test('symmetry: equal magnitude opposite signs', () {
      final m = GravityForceLabModel();
      expect(m.forceOnMass1Sign, 1);
      expect(m.forceOnMass2Sign, -1);
      expect(m.forceMagnitude, m.force.abs());
    });

    test('inverse-square: F(2)≈4×F(4)≈16×F(8)', () {
      final f2 = ForceSolver.calculateForce(100, 400, 2);
      final f4 = ForceSolver.calculateForce(100, 400, 4);
      final f8 = ForceSolver.calculateForce(100, 400, 8);
      expect(f2, closeTo(4 * f4, 1e-20));
      expect(f4, closeTo(4 * f8, 1e-20));
    });

    test('mass proportionality: 2×m1 → 2×F', () {
      final f = ForceSolver.calculateForce(100, 400, 4);
      final f2 = ForceSolver.calculateForce(200, 400, 4);
      expect(f2, closeTo(2 * f, 1e-20));
    });

    test('distance must be positive', () {
      expect(
        () => ForceSolver.calculateForce(100, 400, 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
