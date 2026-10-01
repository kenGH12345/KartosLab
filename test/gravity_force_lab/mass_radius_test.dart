import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/model/mass_model.dart';

void main() {
  group('Mass range / snap / keyboard', () {
    test('MASS_RANGE [10, 1000]', () {
      expect(GravityForceConstants.massMin, 10);
      expect(GravityForceConstants.massMax, 1000);
    });

    test('roundToInterval 10', () {
      // Utils.roundToInterval: roundSymmetric(v/10)*10 → 105 → 110
      expect(GravityForceConstants.roundMassToInterval(105), 110);
      expect(GravityForceConstants.roundMassToInterval(104), 100);
      expect(GravityForceConstants.roundMassToInterval(5), 10);
      expect(GravityForceConstants.roundMassToInterval(2000), 1000);
    });

    test('keyboard steps documented', () {
      expect(GravityForceConstants.massKeyboardStep, 50);
      expect(GravityForceConstants.massPageKeyboardStep, 100);
    });

    test('density 150, not Basics 1.5', () {
      expect(GravityForceConstants.massDensity, 150);
      expect(GravityForceConstants.massDensity, isNot(1.5));
    });
  });

  group('Radius / Constant Size', () {
    test('OFF: radius ≈ 0.542 / 0.860 / 1.168', () {
      final r100 = GravityForceConstants.calculateRadius(100);
      final r400 = GravityForceConstants.calculateRadius(400);
      final r1000 = GravityForceConstants.calculateRadius(1000);
      expect(r100, closeTo(0.5419260701392891, 1e-9));
      expect(r400, closeTo(0.8602540138280996, 1e-9));
      expect(r1000, closeTo(1.167544324940736, 1e-9));
      expect(r400, greaterThan(r100));
      expect(r1000, greaterThan(r400));
    });

    test('ON: radius always 0.5', () {
      final m = GravityForceLabModel();
      m.setConstantRadius(true);
      m.setMassValue(1, 100);
      m.setMassValue(2, 400);
      expect(m.radius1, 0.5);
      expect(m.radius2, 0.5);
    });

    test('OFF: mass increase grows radius', () {
      final m = GravityForceLabModel();
      expect(m.constantRadius, isFalse);
      final r0 = m.mass1.radius;
      m.setMassValue(1, 400);
      expect(m.mass1.radius, greaterThan(r0));
    });

    test('displayColor changes with Constant Size', () {
      final m = GravityForceLabModel();
      final offColor = m.mass1.displayColor;
      m.setConstantRadius(true);
      m.setMassValue(1, 100);
      final onColor = m.mass1.displayColor;
      // Both valid colors; ON uses mass-dependent brighter amount.
      expect(offColor, isNot(onColor));
      expect(
        MassModel.brighter(
          GravityForceConstants.mass1BaseColor,
          GravityForceConstants.baseColorModifier,
        ),
        offColor,
      );
    });
  });
}
