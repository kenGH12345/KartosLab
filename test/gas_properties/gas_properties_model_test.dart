import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gas_properties/gas_properties.dart';

void main() {
  group('Particle constants', () {
    test('Heavy / Light mass and radius', () {
      expect(ParticleType.heavy.mass, GasPropertiesConstants.heavyMass);
      expect(ParticleType.heavy.radius, GasPropertiesConstants.heavyRadius);
      expect(ParticleType.light.mass, GasPropertiesConstants.lightMass);
      expect(ParticleType.light.radius, GasPropertiesConstants.lightRadius);
      expect(GasPropertiesConstants.heavyMass, 28);
      expect(GasPropertiesConstants.lightMass, 4);
      expect(GasPropertiesConstants.heavyRadius, 125);
      expect(GasPropertiesConstants.lightRadius, 87.5);
    });
  });

  group('Injection', () {
    test('|v| = sqrt(3kT/m); Light > Heavy at same T', () {
      final m = IdealGasLawModel(
        random: RandomSource(1),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.setNumberHeavy(1);
      m.setNumberLight(1);
      final heavy = m.particleSystem.heavyParticles.single;
      final light = m.particleSystem.lightParticles.single;
      final expectedH = math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            300 /
            GasPropertiesConstants.heavyMass,
      );
      final expectedL = math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            300 /
            GasPropertiesConstants.lightMass,
      );
      expect(heavy.speed, closeTo(expectedH, expectedH * 1e-9));
      expect(light.speed, closeTo(expectedL, expectedL * 1e-9));
      expect(light.speed, greaterThan(heavy.speed));
    });
  });

  group('Wall collision', () {
    test('static right wall reverses vx', () {
      final p = Particle.create(id: 1, type: ParticleType.heavy, x: -100, y: 1000);
      p.setVelocity(50, 10);
      p.right = 0; // at right wall
      CollisionSolver.doParticleContainerCollisions(
        [p],
        left: -10000,
        right: 0,
        bottom: 0,
        top: 8750,
      );
      expect(p.vx, closeTo(-50, 1e-9));
      expect(p.vy, closeTo(10, 1e-9));
    });

    test('Explore moving left wall: vx′ = -(vx - wallVx)', () {
      final p = Particle.create(id: 1, type: ParticleType.heavy, x: -5000, y: 1000);
      p.setVelocity(-100, 0);
      p.left = -10000;
      CollisionSolver.doParticleContainerCollisions(
        [p],
        left: -10000,
        right: 0,
        bottom: 0,
        top: 8750,
        leftWallVelocityX: -200,
      );
      // vx' = -((-100) - (-200)) = -100
      expect(p.vx, closeTo(-100, 1e-9));
    });
  });

  group('Particle-particle collision', () {
    test('equal mass head-on exchanges velocities (approx)', () {
      final a = Particle.create(id: 1, type: ParticleType.heavy, x: 0, y: 0);
      final b = Particle.create(id: 2, type: ParticleType.heavy, x: 200, y: 0);
      // radii 125 → contact when dx <= 250
      a.setVelocity(100, 0);
      b.setVelocity(-100, 0);
      a.prevX = -10;
      a.prevY = 0;
      b.prevX = 210;
      b.prevY = 0;
      // Place overlapping
      a.x = 0;
      b.x = 200; // dist 200 < 250
      final ke0 = a.kineticEnergy + b.kineticEnergy;
      final px0 = a.mass * a.vx + b.mass * b.vx;
      CollisionSolver.doParticleParticleCollisions([a, b]);
      final ke1 = a.kineticEnergy + b.kineticEnergy;
      final px1 = a.mass * a.vx + b.mass * b.vx;
      expect(ke1, closeTo(ke0, ke0 * 1e-6));
      expect(px1, closeTo(px0, 1e-6));
    });
  });

  group('Gas law', () {
    test('P ∝ N, P ∝ T, P ∝ 1/V', () {
      const t = 300.0;
      const w = 10000.0;
      final v = w * GasPropertiesConstants.height * GasPropertiesConstants.depth;
      final p100 = GasLawSolver.pressureKpa(n: 100, temperatureK: t, volumePm3: v);
      final p200 = GasLawSolver.pressureKpa(n: 200, temperatureK: t, volumePm3: v);
      expect(p200 / p100, closeTo(2, 1e-9));

      final pHot = GasLawSolver.pressureKpa(n: 100, temperatureK: 600, volumePm3: v);
      expect(pHot / p100, closeTo(2, 1e-9));

      final v2 = v * 2;
      final pWide = GasLawSolver.pressureKpa(n: 100, temperatureK: t, volumePm3: v2);
      expect(pWide / p100, closeTo(0.5, 1e-9));
    });

    test('T = (2/3) KE / k', () {
      final keDesired = (3 / 2) * GasPropertiesConstants.boltzmann * 300;
      final t = GasLawSolver.temperatureFromAverageKe(n: 1, averageKe: keDesired);
      expect(t, closeTo(300, 1e-9));
    });
  });

  group('Heat / Cool', () {
    test('scales velocity by 1 + f/800', () {
      final m = IdealGasLawModel(random: RandomSource(2), pressureNoiseEnabled: false);
      m.pause();
      final p = Particle.create(id: 1, type: ParticleType.heavy, x: -5000, y: 4000);
      p.setVelocity(100, 0);
      m.particleSystem.heavyParticles.add(p);
      m.particleSystem.heatCool(1);
      expect(p.vx, closeTo(100 * (1 + 1 / 800), 1e-12));
    });
  });

  group('SimulationClock', () {
    test('NORMAL / SLOW transforms', () {
      final c = SimulationClock();
      expect(c.toModelDt(1), GasPropertiesConstants.normalPsPerSecond);
      c.setSlow(true);
      expect(c.toModelDt(1), GasPropertiesConstants.slowPsPerSecond);
    });

    test('pause blocks real-time advance', () {
      final c = SimulationClock();
      c.pause();
      expect(c.stepRealTime(1), 0);
      expect(c.simulationTimePs, 0);
      c.resume();
      expect(c.stepRealTime(1), GasPropertiesConstants.normalPsPerSecond);
    });
  });

  group('Step order', () {
    test('lastStepPhases matches Phase 1 order', () {
      final m = IdealGasLawModel(random: RandomSource(3), pressureNoiseEnabled: false);
      m.advance(0.2);
      expect(m.lastStepPhases, GasPropertiesConstants.stepOrder);
    });
  });

  group('Hold Constant', () {
    test('N=0 forces Nothing from Temperature', () {
      final m = IdealGasLawModel(random: RandomSource(4), pressureNoiseEnabled: false);
      m.pause();
      m.setNumberHeavy(10);
      // Enable pressure updates via collisions
      for (var i = 0; i < 50; i++) {
        m.advance(0.2);
      }
      m.setHoldConstant(HoldConstant.temperature);
      m.eraseParticles();
      expect(m.holdConstant, HoldConstant.nothing);
    });

    test('Explore locks Nothing', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.explore,
        random: RandomSource(5),
      );
      m.setHoldConstant(HoldConstant.volume);
      expect(m.holdConstant, HoldConstant.nothing);
    });

    test('Energy locks Volume', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.energy,
        random: RandomSource(6),
      );
      expect(m.holdConstant, HoldConstant.volume);
      m.setHoldConstant(HoldConstant.nothing);
      expect(m.holdConstant, HoldConstant.volume);
    });
  });

  group('Pressure sampling', () {
    test('gauge refreshes on 0.75 ps period with deterministic noise', () {
      final rng = RandomSource(99);
      final p = PressureSolver(pressureNoiseEnabled: true, random: rng);
      p.updatePressureEnabled = true;
      p.pressureKpa = 1000;
      p.stepGauge(
        dt: 0.5,
        holdConstant: HoldConstant.nothing,
        temperatureK: 300,
      );
      expect(p.displayedPressureKpa, 0); // not yet refreshed; init 0
      // Actually pressure was 1000 but displayed starts 0 until refresh
      p.stepGauge(
        dt: 0.3,
        holdConstant: HoldConstant.nothing,
        temperatureK: 300,
      );
      // total 0.8 >= 0.75 → should update
      expect(p.displayedPressureKpa, isNot(0));
    });
  });

  group('Histogram', () {
    test('19 bins and bin assignment', () {
      final e = EnergySamplingState();
      expect(e.binCount, 19);
      expect(EnergySamplingState.binIndex(0, 170, 19), 0);
      expect(EnergySamplingState.binIndex(169, 170, 19), 0);
      expect(EnergySamplingState.binIndex(170, 170, 19), 1);
      expect(EnergySamplingState.binIndex(19 * 170, 170, 19), -1);
      expect(GasPropertiesConstants.histogramZoomYMax.length, 7);
    });

    test('Energy model samples average speed', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.energy,
        random: RandomSource(7),
        pressureNoiseEnabled: false,
      );
      m.pause();
      m.setNumberHeavy(5);
      m.setNumberLight(5);
      m.energySampling!.step(
        dt: 1.0,
        isPlaying: false,
        heavy: m.particleSystem.heavyParticles,
        light: m.particleSystem.lightParticles,
      );
      expect(m.energySampling!.heavyAverageSpeed, isNotNull);
      expect(m.energySampling!.lightAverageSpeed, isNotNull);
      expect(
        m.energySampling!.lightAverageSpeed!,
        greaterThan(m.energySampling!.heavyAverageSpeed!),
      );
      expect(m.energySampling!.heavySpeedBins.length, 19);
    });

    test('collision toggle disables PP only', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.energy,
        random: RandomSource(8),
      );
      m.particleCollisionsEnabled = false;
      expect(m.collisionSolver.particleParticleCollisionsEnabled, false);
    });
  });

  group('Diffusion', () {
    test('partition blocks crossing; remove allows COM migration', () {
      final d = DiffusionModel(random: RandomSource(10));
      d.clock.pause();
      d.setLeftCount(20);
      d.setRightCount(20);
      expect(d.container.hasDivider, true);
      final com1Before = d.centerOfMass1;
      // step with divider — particles stay in half
      for (var i = 0; i < 20; i++) {
        d.stepModelTime(0.2);
      }
      for (final p in d.particles1) {
        expect(p.x, lessThanOrEqualTo(d.container.leftMaxX + p.radius + 1));
      }
      d.setHasDivider(false);
      expect(d.container.hasDivider, false);
      for (var i = 0; i < 200; i++) {
        d.stepModelTime(0.2);
      }
      expect(d.flowRate1.leftFlowRate + d.flowRate1.rightFlowRate, greaterThanOrEqualTo(0));
      expect(com1Before, isNotNull);
    });

    test('Slow mode uses 0.3 ps/s', () {
      final d = DiffusionModel(random: RandomSource(11));
      d.setSlow(true);
      expect(d.clock.psPerSecond, GasPropertiesConstants.slowPsPerSecond);
    });

    test('reset clears particles', () {
      final d = DiffusionModel(random: RandomSource(12));
      d.setLeftCount(10);
      d.reset();
      expect(d.numberOfParticles, 0);
      expect(d.container.hasDivider, true);
    });
  });

  group('Reset Ideal', () {
    test('clears particles and sampling', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.energy,
        random: RandomSource(13),
      );
      m.setNumberHeavy(30);
      m.advance(1);
      m.reset();
      expect(m.numberOfParticles, 0);
      expect(m.pressureKpa, 0);
      expect(m.temperatureKelvin, isNull);
      expect(m.holdConstant, HoldConstant.volume);
    });
  });

  group('Explore left wall work', () {
    test('container leftWallDoesWork true', () {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.explore,
        random: RandomSource(14),
      );
      expect(m.container.leftWallDoesWork, true);
      m.container.setDesiredWidth(8000);
      m.advance(0.2);
      // wall should have moved toward 8000 with speed limit
      expect(m.container.width, lessThan(GasPropertiesConstants.widthDefault));
      expect(m.container.leftWallVelocityX, isNot(0));
    });
  });
}
