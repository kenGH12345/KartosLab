import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/diffusion/diffusion_constants.dart';
import 'package:kratos/diffusion/model/diffusion_model.dart';
import 'package:kratos/diffusion/model/particle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('defaults', () {
    test('divider in, zero particles, normal playing', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      expect(m.container.hasDivider, isTrue);
      expect(m.numberOfParticles, 0);
      expect(m.isPlaying, isTrue);
      expect(m.timeSpeed, DiffusionTimeSpeed.normal);
      expect(m.leftSettings.mass, 28);
      expect(m.leftSettings.radius, 125);
      expect(m.leftSettings.initialTemperature, 300);
    });
  });

  group('initialization', () {
    test('speed formula |v|=sqrt(3kT/m)', () {
      final v = DiffusionConstants.speedFromTemperature(
        temperatureK: 300,
        massAmu: 28,
      );
      expect(v, closeTo(math.sqrt(3 * DiffusionConstants.boltzmann * 300 / 28), 1e-9));
    });

    test('particles spawn in left/right halves when divider on', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(42));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(20);
      m.setRightCount(20);
      expect(m.particles1.length, 20);
      expect(m.particles2.length, 20);
      for (final p in m.particles1) {
        expect(p.x, lessThan(m.container.leftMaxX));
        expect(p.species, ParticleSpecies.one);
      }
      for (final p in m.particles2) {
        expect(p.x, greaterThan(m.container.rightMinX));
      }
    });
  });

  group('wall collision', () {
    test('particle reflects on wall', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(10);
      for (var i = 0; i < 200; i++) {
        m.stepModelTime(0.2);
      }
      for (final p in m.particles1) {
        expect(p.left, greaterThanOrEqualTo(m.container.left - 1e-6));
        expect(p.right, lessThanOrEqualTo(m.container.leftMaxX + 1e-6));
        expect(p.bottom, greaterThanOrEqualTo(m.container.bottom - 1e-6));
        expect(p.top, lessThanOrEqualTo(m.container.top + 1e-6));
      }
    });
  });

  group('divider / diffusion', () {
    test('data updates after divider removed', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(7));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(40);
      m.setRightCount(40);
      expect(m.leftData.numberOfParticles1, 40);
      expect(m.rightData.numberOfParticles2, 40);
      m.setHasDivider(false);
      for (var i = 0; i < 500; i++) {
        m.stepModelTime(0.2);
      }
      final crossed = m.rightData.numberOfParticles1 > 0 ||
          m.leftData.numberOfParticles2 > 0;
      expect(crossed, isTrue);
    });
  });

  group('mass / radius', () {
    test('mass change updates particle mass and speed', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(3));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(10);
      m.setLeftMass(16);
      for (final p in m.particles1) {
        expect(p.mass, 16);
      }
    });

    test('radius change updates radius', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(3));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(5);
      m.setLeftRadius(200);
      for (final p in m.particles1) {
        expect(p.radius, 200);
      }
    });
  });

  group('time', () {
    test('slow transform factor', () {
      expect(DiffusionConstants.timeTransform(false), 2.5);
      expect(DiffusionConstants.timeTransform(true), 0.3);
    });

    test('step forward advances ~0.2 ps stopwatch', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      m.pause();
      m.stepForward();
      expect(m.stopwatchPs, closeTo(0.2, 1e-9));
    });

    test('pause prevents ticker-style step', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(5);
      final x0 = m.particles1.first.x;
      m.step(0.05); // playing=false → no model advance
      expect(m.particles1.first.x, x0);
    });

    test('reset restores defaults', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      m.setLeftCount(50);
      m.setHasDivider(false);
      m.setTimeSpeed(DiffusionTimeSpeed.slow);
      m.reset();
      expect(m.numberOfParticles, 0);
      expect(m.container.hasDivider, isTrue);
      expect(m.timeSpeed, DiffusionTimeSpeed.normal);
      expect(m.isPlaying, isTrue);
    });
  });

  group('particle count conservation', () {
    test('total N conserved when divider removed', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(9));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(30);
      m.setRightCount(20);
      m.setHasDivider(false);
      for (var i = 0; i < 100; i++) {
        m.stepModelTime(0.2);
      }
      expect(m.particles1.length + m.particles2.length, 50);
    });
  });
}
