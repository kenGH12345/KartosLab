import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/masb_constants.dart';
import 'package:kratos/masses_and_springs_basics/model/masb_model.dart';

MasbModel _attached({double massKg = 0.100, double damping = 0}) {
  final m = MasbModel(damping: damping);
  final mass = m.masses.firstWhere((e) => (e.massKg - massKg).abs() < 1e-9);
  m.attachMassToSpring(mass, m.firstSpring);
  return m;
}

void main() {
  group('Shelf masses / attach / detach', () {
    test('Bounce starts with 9 shelf masses and 2 empty springs', () {
      final m = MasbModel();
      expect(m.masses.length, 9);
      expect(m.springs.length, 2);
      expect(m.firstSpring.massAttached, isNull);
      expect(m.secondSpring!.massAttached, isNull);
      expect(m.masses.every((e) => e.onShelf), isTrue);
    });

    test('drag 250g onto spring updates equilibrium for that mass', () {
      final m = MasbModel(damping: 0.7);
      final heavy = m.masses.firstWhere((e) => e.massKg == 0.250);
      m.attachMassToSpring(heavy, m.firstSpring);
      for (var i = 0; i < 4000; i++) {
        m.step(1 / 60);
      }
      final eq = -0.250 * 9.8 / 6;
      expect(m.firstSpring.displacement, closeTo(eq, 0.05));

      // Swap to 50g
      m.firstSpring.removeMass();
      heavy.detach();
      final light = m.masses.firstWhere((e) => e.massKg == 0.050);
      m.attachMassToSpring(light, m.firstSpring);
      for (var i = 0; i < 4000; i++) {
        m.step(1 / 60);
      }
      final eqLight = -0.050 * 9.8 / 6;
      expect(m.firstSpring.displacement, closeTo(eqLight, 0.04));
    });

    test('detach beyond release distance then shelf return animates', () {
      final m = MasbModel();
      final mass = m.masses.firstWhere((e) => e.massKg == 0.100);
      final homeX = mass.positionX;
      m.attachMassToSpring(mass, m.firstSpring);
      expect(mass.spring, isNotNull);

      m.beginDrag(mass.positionX, mass.positionY);
      m.updateDrag(
        m.firstSpring.positionX + MasbConstants.releaseDistance + 0.05,
        mass.positionY,
      );
      expect(mass.spring, isNull);
      m.endDrag();

      // Fall to floor
      for (var i = 0; i < 300; i++) {
        m.step(1 / 60);
      }
      expect(mass.isAnimating || mass.onShelf, isTrue);
      for (var i = 0; i < 600; i++) {
        m.step(1 / 60);
      }
      expect(mass.onShelf, isTrue);
      expect(mass.positionX, closeTo(homeX, 0.02));
    });

    test('reset returns all masses to shelf seats', () {
      final c = MasbController(autoTick: false);
      final m = c.model;
      m.attachMassToSpring(m.masses[2], m.firstSpring);
      m.attachMassToSpring(m.masses[3], m.secondSpring!);
      c.reset();
      expect(m.firstSpring.massAttached, isNull);
      expect(m.secondSpring!.massAttached, isNull);
      expect(m.masses.every((e) => e.onShelf && e.spring == null), isTrue);
      c.dispose();
    });
  });

  group('Physics with attach helper', () {
    test('attached oscillates', () {
      final model = _attached(damping: 0);
      var minD = 0.0;
      for (var i = 0; i < 600; i++) {
        model.step(1 / 60);
        minD = math.min(minD, model.spring.displacement);
      }
      expect(minD, lessThan(-0.05));
    });
  });
}
