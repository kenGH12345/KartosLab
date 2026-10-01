import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/masb_constants.dart';
import 'package:kratos/masses_and_springs_basics/model/masb_model.dart';
import 'package:kratos/masses_and_springs_basics/model/mass.dart';
import 'package:kratos/masses_and_springs_basics/model/spring.dart';

MasbModel attachedModel({double damping = 0, double massKg = 0.100}) {
  final model = MasbModel(damping: damping, gravity: MasbConstants.earthGravity);
  final mass = model.masses.firstWhere((e) => (e.massKg - massKg).abs() < 1e-9);
  model.attachMassToSpring(mass, model.firstSpring);
  return model;
}

void main() {
  group('MasbSpring physics (PhET analytical step)', () {
    test('attached mass at rest length falls and oscillates under gravity', () {
      final model = attachedModel();
      final x0 = model.spring.displacement;
      expect(x0.abs(), lessThan(0.05));

      var crossedEquilibrium = false;
      var minDisp = x0;
      for (var i = 0; i < 600; i++) {
        model.step(1 / 60);
        final x = model.spring.displacement;
        if (x < minDisp) minDisp = x;
        if (x < -0.05) crossedEquilibrium = true;
        expect(x.isFinite, isTrue);
        expect(model.firstSpring.massAttached!.verticalVelocity.isFinite, isTrue);
      }

      expect(crossedEquilibrium, isTrue);
      expect(minDisp, lessThan(-0.05));
      final attached = model.firstSpring.massAttached!;
      expect(attached.verticalVelocity.abs() + model.spring.displacement.abs(),
          greaterThan(0.01));
    });

    test('equilibrium displacement ≈ −mg/k', () {
      const massKg = 0.1;
      const k = 6.0;
      const g = 9.8;
      final expected = -massKg * g / k;

      final spring = MasbSpring(
        positionX: 1.0,
        positionY: MasbConstants.ceilingY,
        initialNaturalRestingLength: 0.5,
        dampingGetter: () => 0.5,
        gravityGetter: () => g,
      );
      spring.springConstant = k;
      final mass = MasbMass(
        massKg: massKg,
        xPosition: 1.0,
        gravityGetter: () => g,
      );
      mass.positionY = spring.positionY -
          spring.naturalRestingLength +
          MasbConstants.hookCenter;
      spring.setMass(mass);

      for (var i = 0; i < 5000; i++) {
        spring.step(1 / 60);
      }
      expect(spring.displacement, closeTo(expected, 0.02));
      expect(mass.verticalVelocity.abs(), lessThan(0.05));
    });

    test('no NaN / Infinity over long undamped run', () {
      final model = attachedModel();
      for (var i = 0; i < 10000; i++) {
        model.step(1 / 60);
      }
      expect(model.spring.displacement.isFinite, isTrue);
      expect(model.firstSpring.massAttached!.verticalVelocity.isFinite, isTrue);
      expect(model.spring.length, greaterThan(0));
    });

    test('pause freezes state; resume continues', () {
      final model = attachedModel();
      for (var i = 0; i < 30; i++) {
        model.step(1 / 60);
      }
      final x = model.spring.displacement;
      final v = model.firstSpring.massAttached!.verticalVelocity;
      model.playing = false;
      for (var i = 0; i < 30; i++) {
        model.step(1 / 60);
      }
      expect(model.spring.displacement, x);
      expect(model.firstSpring.massAttached!.verticalVelocity, v);
      model.playing = true;
      model.step(1 / 60);
      expect(model.spring.displacement, isNot(x));
    });

    test('reset restores all masses to shelf', () {
      final model = attachedModel();
      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      model.reset();
      expect(model.firstSpring.massAttached, isNull);
      expect(model.spring.displacement.abs(), lessThan(0.05));
      expect(model.simTime, 0);
      expect(model.masses.every((e) => e.onShelf), isTrue);
    });
  });
}
