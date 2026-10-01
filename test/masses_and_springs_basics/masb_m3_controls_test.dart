import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/masb_constants.dart';
import 'package:kratos/masses_and_springs_basics/model/masb_model.dart';

void main() {
  group('M3 Gravity', () {
    test('setGravity updates model and equilibrium −mg/k', () {
      final c = MasbController(autoTick: false);
      c.model.damping = 0.7;
      final mass = c.model.masses.firstWhere((e) => e.massKg == 0.100);
      c.model.attachMassToSpring(mass, c.model.firstSpring);
      for (var i = 0; i < 3000; i++) {
        c.model.step(1 / 60);
      }
      final eqEarth = -0.1 * 9.8 / c.model.spring.springConstant;
      expect(c.model.spring.displacement, closeTo(eqEarth, 0.04));

      c.setGravity(1.6);
      expect(c.model.gravity, 1.6);
      expect(c.model.body, MasbBody.moon);
      for (var i = 0; i < 3000; i++) {
        c.model.step(1 / 60);
      }
      final eqMoon = -0.1 * 1.6 / c.model.spring.springConstant;
      expect(c.model.spring.displacement, closeTo(eqMoon, 0.04));
      c.dispose();
    });

    test('setBody Jupiter then custom via slider', () {
      final c = MasbController(autoTick: false);
      c.setBody(MasbBody.jupiter);
      expect(c.model.gravity, MasbConstants.jupiterGravity);
      c.setGravity(11.1);
      expect(c.model.body, MasbBody.custom);
      c.dispose();
    });

    test('gravity change mid-flight stays finite', () {
      final m = MasbModel(damping: 0);
      final mass = m.masses.firstWhere((e) => e.massKg == 0.100);
      m.attachMassToSpring(mass, m.firstSpring);
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
      }
      m.setGravity(24.8);
      m.step(1 / 60);
      expect(m.spring.displacement.isFinite, isTrue);
      expect(mass.verticalVelocity.isFinite, isTrue);
    });
  });

  group('M3 Line options + reset', () {
    test('toggles and reset restore defaults', () {
      final c = MasbController(autoTick: false);
      c.setNaturalLengthVisible(true);
      c.setEquilibriumPositionVisible(true);
      c.setMovableLineVisible(true);
      c.setGravity(20);
      c.setSpringConstant(10);
      c.pause();
      c.reset();
      expect(c.model.naturalLengthVisible, isFalse);
      expect(c.model.equilibriumPositionVisible, isFalse);
      expect(c.model.movableLineVisible, isFalse);
      expect(c.model.gravity, MasbConstants.earthGravity);
      expect(c.model.body, MasbBody.earth);
      expect(c.model.spring.springConstant, MasbConstants.springConstantDefault);
      expect(c.model.playing, isTrue);
      c.dispose();
    });
  });
}
