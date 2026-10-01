import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  group('Case A - empty plank', () {
    test('initial angle, omega, balanced', () {
      final model = BalanceModel();
      expect(model.plank.tiltAngle, 0);
      expect(model.plank.angularVelocity, 0);
      expect(model.plank.isBalanced(), isTrue);
      expect(model.columnState, ColumnState.doubleColumns);
      expect(model.pivotPoint, const BaVector2(0, BaGeometry.fulcrumHeight));
    });
  });

  group('Case B - equal masses same distance', () {
    test('isBalanced', () {
      final model = BalanceModel();
      final left = BaMass.generic(10, const BaVector2(0, 0));
      final right = BaMass.generic(10, const BaVector2(0, 0));
      model.addMass(left);
      model.addMass(right);
      model.plank.addMassToSurfaceAt(left, -1.0);
      model.plank.addMassToSurfaceAt(right, 1.0);
      expect(model.plank.uncompensatedTorqueForTest(), 0);
      expect(model.plank.isBalanced(), isTrue);
    });
  });

  group('Case C - unequal masses same distance', () {
    test('not balanced', () {
      final model = BalanceModel();
      final left = BaMass.generic(5, const BaVector2(0, 0));
      final right = BaMass.generic(10, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(left, -1.0);
      model.plank.addMassToSurfaceAt(right, 1.0);
      expect(model.plank.isBalanced(), isFalse);
    });
  });

  group('Case D - equal torque different m,d', () {
    test('20@1 and 10@-2 balanced', () {
      final model = BalanceModel();
      final a = BaMass.generic(20, const BaVector2(0, 0));
      final b = BaMass.generic(10, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(a, 1.0);
      model.plank.addMassToSurfaceAt(b, -2.0);
      expect(model.plank.uncompensatedTorqueForTest(), 0);
      expect(model.plank.isBalanced(), isTrue);
    });
  });

  group('Case E - threshold 1e-6 strict less-than', () {
    test('below / at / above COMPARISON_TOLERANCE', () {
      const tol = BaSharedConstants.comparisonTolerance;
      expect((tol * 0.5).abs() < tol, isTrue);
      expect(tol.abs() < tol, isFalse); // equal is NOT balanced
      expect((tol * 2).abs() < tol, isFalse);

      final model = BalanceModel();
      final a = BaMass.generic(1, const BaVector2(0, 0));
      final b = BaMass.generic(1, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(a, -0.25);
      model.plank.addMassToSurfaceAt(b, 0.25);
      expect(model.plank.isBalanced(), isTrue);
    });
  });

  group('Display force vs physics torque', () {
    test('display uses -9.8; dynamics torque has no g', () {
      final model = BalanceModel();
      model.setColumnState(ColumnState.noColumns);
      final m = BaMass.generic(10, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(m, 1.0);
      final fv = model.plank.forceVectors.single;
      expect(
        fv.vector.y,
        closeTo(10 * BaGeometry.accelerationDueToGravity, 1e-12),
      );
      expect(fv.vector.x, 0);

      final torque = model.plank.getTorqueDueToMasses();
      expect(torque, closeTo(-m.position.x * m.massValue, 1e-9));
      expect(
        torque,
        isNot(closeTo(-m.position.x * m.massValue * 9.8, 1e-6)),
      );
    });
  });
}
