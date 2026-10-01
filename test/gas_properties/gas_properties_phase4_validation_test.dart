import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gas_properties/gas_properties.dart';

/// Phase 4 physics / functional validation against PhET forensics.
void main() {
  group('V4 Ideal Gas Law trends', () {
    test('PV ≈ NkT within conversion scale', () {
      const n = 100;
      const t = 300.0;
      const w = 10000.0;
      final v = w * GasPropertiesConstants.height * GasPropertiesConstants.depth;
      final p = GasLawSolver.pressureKpa(n: n, temperatureK: t, volumePm3: v);
      final expected =
          (n * GasPropertiesConstants.boltzmann * t / v) *
              GasPropertiesConstants.pressureConversionScale;
      expect(p, closeTo(expected, expected * 1e-12));
    });

    test('Ideal wall adjust does not impart leftWallVelocity', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.ideal,
        random: RandomSource(20),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.setNumberHeavy(20);
      m.beginWidthAdjust();
      expect(m.isPlaying, false);
      final ke0 = m.particleSystem.heavyParticles
          .fold<double>(0, (s, p) => s + p.kineticEnergy);
      m.setWidthDuringAdjust(8000);
      m.endWidthAdjust();
      expect(m.container.leftWallVelocityX, 0);
      final ke1 = m.particleSystem.heavyParticles
          .fold<double>(0, (s, p) => s + p.kineticEnergy);
      // redistribute preserves speeds; KE sum within float
      expect(ke1, closeTo(ke0, ke0 * 1e-9 + 1e-6));
    });

    test('Explore moving wall changes KE (work)', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.explore,
        random: RandomSource(21),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.particleCollisionsEnabled = false;
      m.setNumberHeavy(1);
      final p = m.particleSystem.heavyParticles.single;
      p.x = m.container.left + p.radius + 10;
      p.y = 4000;
      p.setVelocity(-400, 0);
      final ke0 = p.kineticEnergy;
      expect(m.container.leftWallDoesWork, isTrue);
      m.container.setDesiredWidth(7000);
      var maxAbsWallVx = 0.0;
      var maxKe = ke0;
      var leftHitsWhileMoving = 0;
      for (var i = 0; i < 50; i++) {
        final wallBefore = m.container.leftWallVelocityX;
        final vxBefore = p.vx;
        m.advance(0.2);
        final wallVx = m.container.leftWallVelocityX;
        if (wallVx.abs() > maxAbsWallVx) maxAbsWallVx = wallVx.abs();
        if (p.kineticEnergy > maxKe) maxKe = p.kineticEnergy;
        // Detect left-wall bounce while wall is/was moving this step.
        if (wallVx.abs() > 1 && vxBefore < 0 && p.vx > 0) {
          leftHitsWhileMoving++;
        }
        // ignore unused
        wallBefore;
      }
      expect(maxAbsWallVx, greaterThan(1),
          reason: 'Explore wall must report nonzero velocity while compressing');
      expect(m.container.width, lessThan(GasPropertiesConstants.widthDefault));
      expect(
        maxKe,
        greaterThan(ke0),
        reason:
            'hits=$leftHitsWhileMoving wallVxMax=$maxAbsWallVx vx=${p.vx} ke0=$ke0 maxKe=$maxKe',
      );
    });
  });

  group('V4 Lid', () {
    test('setLidWidth opens escape path; blowLidOff respects threshold', () {
      final c = ContainerState();
      expect(c.isOpen, false);
      c.setLidWidth(c.minLidWidth);
      expect(c.isOpen, true);
      expect(c.getOpeningWidth(), greaterThan(GasPropertiesConstants.openingWidthThreshold));

      // Wide opening → blowLidOff should NOT remove lid
      c.lidIsOn = true;
      c.setLidWidth(c.minLidWidth);
      c.blowLidOff();
      expect(c.lidIsOn, true);

      // Closed → blowLidOff removes lid
      c.returnLid();
      expect(c.isOpen, false);
      c.blowLidOff();
      expect(c.lidIsOn, false);
    });

    test('escapeParticles removes through opening when open', () {
      final m = IdealGasLawModel(
        random: RandomSource(22),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.setNumberHeavy(5);
      m.container.setLidWidth(m.container.minLidWidth);
      final openL = m.container.getOpeningLeft();
      final openR = m.container.getOpeningRight();
      final p = m.particleSystem.heavyParticles.first;
      p.x = (openL + openR) / 2;
      p.y = m.container.top + p.radius + 10;
      p.prevY = m.container.top - 10;
      final n0 = m.numberOfParticles;
      m.particleSystem.escapeParticles();
      expect(m.numberOfParticles, lessThan(n0));
    });
  });

  group('V4 Pressure gauge', () {
    test('does not refresh every tiny dt', () {
      final rng = RandomSource(30);
      final p = PressureSolver(pressureNoiseEnabled: true, random: rng);
      p.updatePressureEnabled = true;
      p.pressureKpa = 500;
      p.stepGauge(
        dt: 0.1,
        holdConstant: HoldConstant.nothing,
        temperatureK: 300,
      );
      expect(p.displayedPressureKpa, 0);
      p.stepGauge(
        dt: 0.1,
        holdConstant: HoldConstant.nothing,
        temperatureK: 300,
      );
      expect(p.displayedPressureKpa, 0);
      p.stepGauge(
        dt: 0.6,
        holdConstant: HoldConstant.nothing,
        temperatureK: 300,
      );
      expect(p.displayedPressureKpa, isNot(0));
    });

    test('noise disabled when Hold pressure*', () {
      final rng = RandomSource(31);
      final p = PressureSolver(pressureNoiseEnabled: true, random: rng);
      p.updatePressureEnabled = true;
      p.pressureKpa = 800;
      p.stepGauge(
        dt: 1.0,
        holdConstant: HoldConstant.pressureV,
        temperatureK: 300,
      );
      expect(p.displayedPressureKpa, closeTo(800, 1e-9));
    });
  });

  group('V4 Energy sampling', () {
    test('zoom has 7 levels; bins stay 19', () {
      final e = EnergySamplingState();
      final start = e.zoomLevelIndex;
      for (var i = 0; i < 10; i++) {
        e.zoomIn();
      }
      expect(e.zoomLevelIndex, GasPropertiesConstants.histogramZoomYMax.length - 1);
      for (var i = 0; i < 20; i++) {
        e.zoomOut();
      }
      expect(e.zoomLevelIndex, 0);
      expect(start, GasPropertiesConstants.defaultHistogramZoomIndex);
      expect(e.heavySpeedBins.length, 19);
      expect(e.heavyKeBins.length, 19);
    });

    test('sampling accumulates over 1 ps when playing', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.energy,
        random: RandomSource(32),
        pressureNoiseEnabled: false,
      );
      m.setNumberHeavy(10);
      m.play();
      final e = m.energySampling!;
      e.heavyAverageSpeed = null;
      // advance less than 1 ps via sampling step path
      e.step(
        dt: 0.5,
        isPlaying: true,
        heavy: m.particleSystem.heavyParticles,
        light: m.particleSystem.lightParticles,
      );
      // may or may not have updated depending on internal accumulator;
      e.step(
        dt: 0.6,
        isPlaying: true,
        heavy: m.particleSystem.heavyParticles,
        light: m.particleSystem.lightParticles,
      );
      expect(e.heavyAverageSpeed, isNotNull);
    });
  });

  group('V4 Diffusion flow / Normal Slow', () {
    test('flow rate uses 300-sample window constant', () {
      expect(GasPropertiesConstants.flowRateSampleCount, 300);
    });

    test('Normal vs Slow model dt differs', () {
      final d = DiffusionModel(random: RandomSource(33));
      d.setSlow(false);
      final normalDt = d.clock.toModelDt(1.0);
      d.setSlow(true);
      final slowDt = d.clock.toModelDt(1.0);
      expect(normalDt, GasPropertiesConstants.normalPsPerSecond);
      expect(slowDt, GasPropertiesConstants.slowPsPerSecond);
      expect(slowDt, lessThan(normalDt));
    });
  });

  group('V4 Boundaries', () {
    test('N=0 and N=1000 no NaN', () {
      final m = IdealGasLawModel(
        random: RandomSource(40),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.setNumberHeavy(0);
      m.setNumberLight(0);
      m.advance(0.2);
      expect(m.pressureKpa.isFinite, true);
      expect(m.temperatureKelvin, isNull);

      m.setNumberHeavy(500);
      m.setNumberLight(500);
      expect(m.numberOfParticles, 1000);
      for (var i = 0; i < 10; i++) {
        m.advance(0.2);
      }
      expect(m.pressureKpa.isFinite, true);
      expect(m.temperatureKelvin!.isFinite, true);
      for (final p in m.particleSystem.heavyParticles) {
        expect(p.vx.isFinite && p.vy.isFinite, true);
      }
    });

    test('volume min/max clamp', () {
      final m = IdealGasLawModel(random: RandomSource(41));
      m.setWidthImmediate(1);
      expect(m.container.width, GasPropertiesConstants.widthMin);
      m.setWidthImmediate(999999);
      expect(m.container.width, GasPropertiesConstants.widthMax);
    });
  });

  group('V4 Performance smoke', () {
    test('1000 particles 50 steps completes under budget', () {
      final m = IdealGasLawModel(
        random: RandomSource(50),
        pressureNoiseEnabled: false,
      );
      m.setNumberHeavy(500);
      m.setNumberLight(500);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        m.advance(0.2);
      }
      sw.stop();
      // CI-friendly budget: 50 * 0.2 ps of 1000 particles should finish quickly.
      expect(sw.elapsedMilliseconds, lessThan(15000));
      // Report for PHASE_4 doc via print
      // ignore: avoid_print
      print(
        'PERF 1000p×50steps: ${sw.elapsedMilliseconds} ms '
        '(${(sw.elapsedMicroseconds / 50).toStringAsFixed(0)} µs/step)',
      );
    });

    test('500 particles 50 steps', () {
      final m = IdealGasLawModel(
        random: RandomSource(51),
        pressureNoiseEnabled: false,
      );
      m.setNumberHeavy(250);
      m.setNumberLight(250);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        m.advance(0.2);
      }
      sw.stop();
      // ignore: avoid_print
      print(
        'PERF 500p×50steps: ${sw.elapsedMilliseconds} ms '
        '(${(sw.elapsedMicroseconds / 50).toStringAsFixed(0)} µs/step)',
      );
      expect(sw.elapsedMilliseconds, lessThan(8000));
    });

    test('100 particles 50 steps', () {
      final m = IdealGasLawModel(
        random: RandomSource(52),
        pressureNoiseEnabled: false,
      );
      m.setNumberHeavy(50);
      m.setNumberLight(50);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        m.advance(0.2);
      }
      sw.stop();
      // ignore: avoid_print
      print(
        'PERF 100p×50steps: ${sw.elapsedMilliseconds} ms '
        '(${(sw.elapsedMicroseconds / 50).toStringAsFixed(0)} µs/step)',
      );
      expect(sw.elapsedMilliseconds, lessThan(3000));
    });
  });

  group('V4 Mass-speed relation', () {
    test('same T: light mean speed > heavy', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.energy,
        random: RandomSource(60),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.setNumberHeavy(80);
      m.setNumberLight(80);
      m.energySampling!.step(
        dt: 1.0,
        isPlaying: false,
        heavy: m.particleSystem.heavyParticles,
        light: m.particleSystem.lightParticles,
      );
      expect(
        m.energySampling!.lightAverageSpeed!,
        greaterThan(m.energySampling!.heavyAverageSpeed!),
      );
      final ratio = m.energySampling!.lightAverageSpeed! /
          m.energySampling!.heavyAverageSpeed!;
      final expected = math.sqrt(
        GasPropertiesConstants.heavyMass / GasPropertiesConstants.lightMass,
      );
      expect(ratio, closeTo(expected, expected * 0.05));
    });
  });
}
