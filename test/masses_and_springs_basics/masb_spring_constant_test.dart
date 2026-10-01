import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/masb_constants.dart';
import 'package:kratos/masses_and_springs_basics/model/masb_model.dart';

MasbModel _attached({double damping = 0.7}) {
  final model = MasbModel(damping: damping, gravity: 9.8);
  final mass = model.masses.firstWhere((e) => e.massKg == 0.100);
  model.attachMassToSpring(mass, model.firstSpring);
  return model;
}

void main() {
  group('M3 Spring Constant control', () {
    test('slider path: controller → model → spring.k', () {
      final c = MasbController(autoTick: false);
      expect(c.model.spring.springConstant, MasbConstants.springConstantDefault);
      c.setSpringConstant(10);
      expect(c.model.spring.springConstant, 10);
      c.setSpringConstant(2);
      expect(c.model.spring.springConstant, MasbConstants.springConstantMin);
      c.setSpringConstant(99);
      expect(c.model.spring.springConstant, MasbConstants.springConstantMax);
      c.dispose();
    });

    test('changing k updates equilibrium −mg/k continuously', () {
      final model = _attached(damping: 0.7);
      for (var i = 0; i < 4000; i++) {
        model.step(1 / 60);
      }
      final eq6 = -0.1 * model.gravity / 6;
      expect(model.spring.displacement, closeTo(eq6, 0.03));

      model.setSpringConstant(12);
      final eq12 = -0.1 * model.gravity / 12;
      for (var i = 0; i < 4000; i++) {
        model.step(1 / 60);
      }
      expect(model.spring.displacement, closeTo(eq12, 0.03));
    });

    test('higher k yields higher oscillation frequency (undamped)', () {
      double measurePeriod(double k) {
        final model = _attached(damping: 0);
        model.setSpringConstant(k);
        final mass = model.firstSpring.massAttached!;
        final y = mass.positionY;
        model.beginDrag(mass.positionX, y);
        model.updateDrag(model.spring.positionX, y - 0.15);
        model.endDrag();

        var crossings = 0;
        double? lastSign;
        double? tFirst;
        double? tThird;
        for (var i = 0; i < 5000; i++) {
          model.step(1 / 60);
          final d = model.spring.displacement - (-0.1 * 9.8 / k);
          final sign = d == 0 ? lastSign : d.sign;
          if (lastSign != null && sign != null && sign != lastSign) {
            crossings++;
            if (crossings == 1) tFirst = model.simTime;
            if (crossings == 3) {
              tThird = model.simTime;
              break;
            }
          }
          lastSign = sign;
        }
        expect(tFirst, isNotNull);
        expect(tThird, isNotNull);
        return tThird! - tFirst!;
      }

      final tSoft = measurePeriod(3);
      final tStiff = measurePeriod(12);
      expect(tSoft, greaterThan(tStiff * 1.2));
      final expectedSoft = 2 * math.pi * math.sqrt(0.1 / 3);
      expect(tSoft, closeTo(expectedSoft, expectedSoft * 0.25));
    });

    test('reset restores default k', () {
      final c = MasbController(autoTick: false);
      c.setSpringConstant(9);
      c.reset();
      expect(c.model.spring.springConstant, MasbConstants.springConstantDefault);
      c.dispose();
    });

    test('mid-oscillation k change does not NaN and keeps motion continuous', () {
      final model = _attached(damping: 0);
      for (var i = 0; i < 90; i++) {
        model.step(1 / 60);
      }
      final before = model.spring.displacement;
      model.setSpringConstant(9);
      model.step(1 / 60);
      expect(model.spring.displacement.isFinite, isTrue);
      expect(model.firstSpring.massAttached!.verticalVelocity.isFinite, isTrue);
      expect(model.spring.displacement, isNot(before));
    });

    test('per-spring Strength: setSpringConstantAt only affects that spring', () {
      final model = MasbModel.bounce();
      model.setSpringConstantAt(0, 10);
      model.setSpringConstantAt(1, 4);
      expect(model.firstSpring.springConstant, 10);
      expect(model.secondSpring!.springConstant, 4);
    });

    test('stopSpring zeros velocity and disables stopper glow', () {
      final model = _attached(damping: 0);
      for (var i = 0; i < 60; i++) {
        model.step(1 / 60);
      }
      expect(model.firstSpring.buttonEnabled, isTrue);
      model.stopSpringAt(0);
      expect(model.firstSpring.buttonEnabled, isFalse);
      expect(model.masses.first.verticalVelocity, 0);
      final eq = -0.1 * model.gravity / model.firstSpring.springConstant;
      expect(model.firstSpring.displacement, closeTo(eq, 1e-6));
    });
  });
}
