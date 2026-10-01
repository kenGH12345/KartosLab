import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/diffusion/model/diffusion_model.dart';

/// Control / time / divider fidelity — NumberSpinner semantics @ 7a52c48
/// (source uses GasPropertiesSpinner, not Slider).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('control defaults', () {
    test('default-state: divider on, N=0, data collapsed, stopwatch hidden', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      expect(m.container.hasDivider, isTrue);
      expect(m.settingsEnabled, isTrue);
      expect(m.dividerToggleEnabled, isFalse);
      expect(m.leftSettings.numberOfParticles, 0);
      expect(m.rightSettings.numberOfParticles, 0);
      expect(m.leftSettings.mass, 28);
      expect(m.rightSettings.mass, 28);
      expect(m.leftSettings.radius, 125);
      expect(m.rightSettings.radius, 125);
      expect(m.leftSettings.initialTemperature, 300);
      expect(m.dataExpanded, isFalse);
      expect(m.stopwatchVisible, isFalse);
      expect(m.stopwatchPs, 0);
      expect(m.stopwatchDisplay, '0.0 ps');
    });
  });

  group('left/right independence', () {
    test('left particle control does not change right', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(2));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(40);
      m.setRightCount(10);
      expect(m.particles1.length, 40);
      expect(m.particles2.length, 10);
      m.setLeftCount(20);
      expect(m.particles1.length, 20);
      expect(m.particles2.length, 10);
    });

    test('right particle control does not change left', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(3));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(30);
      m.setRightCount(50);
      m.setRightCount(20);
      expect(m.particles1.length, 30);
      expect(m.particles2.length, 20);
    });

    test('mass / radius / temperature left-right independent', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(4));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(10);
      m.setRightCount(10);
      m.setLeftMass(16);
      m.setRightMass(32);
      m.setLeftRadius(100);
      m.setRightRadius(200);
      m.setLeftTemperature(200);
      m.setRightTemperature(400);
      expect(m.leftSettings.mass, 16);
      expect(m.rightSettings.mass, 32);
      expect(m.leftSettings.radius, 100);
      expect(m.rightSettings.radius, 200);
      expect(m.leftSettings.initialTemperature, 200);
      expect(m.rightSettings.initialTemperature, 400);
      for (final p in m.particles1) {
        expect(p.mass, 16);
        expect(p.radius, 100);
      }
      for (final p in m.particles2) {
        expect(p.mass, 32);
        expect(p.radius, 200);
      }
    });
  });

  group('spinner deltas / ranges', () {
    test('particle count snaps to delta 10', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(5));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(23);
      expect(m.leftSettings.numberOfParticles % 10, 0);
      expect(m.leftSettings.numberOfParticles, inInclusiveRange(0, 200));
    });

    test('mass control range 4–32 delta 1', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(5));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(5);
      m.setLeftMass(4);
      expect(m.leftSettings.mass, 4);
      m.setLeftMass(32);
      expect(m.leftSettings.mass, 32);
      m.setLeftMass(100);
      expect(m.leftSettings.mass, 32);
    });

    test('radius control snaps to delta 5', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(5));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(5);
      m.setLeftRadius(127);
      expect(m.leftSettings.radius % 5, 0);
    });

    test('temperature control snaps to delta 50', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(5));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(5);
      m.setLeftTemperature(275);
      expect(m.leftSettings.initialTemperature % 50, 0);
    });
  });

  group('settings enabled with divider', () {
    test('settings disabled after remove divider', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(6));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(20);
      m.setRightCount(20);
      m.setHasDivider(false);
      expect(m.settingsEnabled, isFalse);
      final leftN = m.leftSettings.numberOfParticles;
      m.setLeftCount(50); // ignored
      expect(m.leftSettings.numberOfParticles, leftN);
      m.setLeftMass(4); // ignored
      expect(m.leftSettings.mass, 28);
    });
  });

  group('simulation time', () {
    test('play advances stopwatch from model clock', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(7));
      addTearDown(m.dispose);
      m.play();
      m.stepRealTime(1.0); // * 2.5 → 2.5 ps
      expect(m.stopwatchPs, closeTo(2.5, 1e-9));
      expect(m.stopwatchDisplay, '2.5 ps');
    });

    test('pause does not advance time via step()', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(7));
      addTearDown(m.dispose);
      m.pause();
      final t0 = m.stopwatchPs;
      m.step(0.5);
      expect(m.stopwatchPs, t0);
    });

    test('step advances exactly 0.2 ps', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(7));
      addTearDown(m.dispose);
      m.pause();
      m.stepForward();
      expect(m.stopwatchPs, closeTo(0.2, 1e-9));
      expect(m.stopwatchDisplay, '0.2 ps');
    });

    test('reset clears time and stopwatch visibility', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(7));
      addTearDown(m.dispose);
      m.setStopwatchVisible(true);
      m.stepForward();
      m.stepForward();
      m.reset();
      expect(m.stopwatchPs, 0);
      expect(m.stopwatchVisible, isFalse);
      expect(m.stopwatchDisplay, '0.0 ps');
    });

    test('slow transform scales model time', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(7));
      addTearDown(m.dispose);
      m.setTimeSpeed(DiffusionTimeSpeed.slow);
      m.stepRealTime(1.0); // * 0.3
      expect(m.stopwatchPs, closeTo(0.3, 1e-9));
    });
  });

  group('remove divider', () {
    test('toggle disabled when empty; enabled with particles', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(8));
      addTearDown(m.dispose);
      expect(m.dividerToggleEnabled, isFalse);
      m.pause();
      m.setLeftCount(10);
      expect(m.dividerToggleEnabled, isTrue);
    });

    test('remove then reset divider restores chambers', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(8));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(20);
      m.setRightCount(20);
      m.setHasDivider(false);
      expect(m.container.hasDivider, isFalse);
      for (var i = 0; i < 50; i++) {
        m.stepModelTime(0.2);
      }
      m.setHasDivider(true);
      expect(m.container.hasDivider, isTrue);
      expect(m.settingsEnabled, isTrue);
      expect(m.particles1.length, 20);
      expect(m.particles2.length, 20);
    });
  });

  group('data accordion', () {
    test('default collapsed; toggle expands', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(9));
      addTearDown(m.dispose);
      expect(m.dataExpanded, isFalse);
      m.setDataExpanded(true);
      expect(m.dataExpanded, isTrue);
      m.reset();
      expect(m.dataExpanded, isFalse);
    });
  });
}
