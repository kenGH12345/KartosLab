import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gases_intro/gases_intro_constants.dart';
import 'package:kratos/gases_intro/model/hold_constant.dart';
import 'package:kratos/gases_intro/model/ideal_gas_law_model.dart';
import 'package:kratos/gases_intro/model/particle.dart';
import 'package:kratos/gases_intro/model/pressure_solver.dart';
import 'package:kratos/gases_intro/model/random_source.dart';
import 'package:kratos/gases_intro/model/temperature_solver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  IdealGasLawModel makeModel({bool hasHoldConstantControls = true}) {
    final m = IdealGasLawModel(
      autoTick: false,
      random: RandomSource(42),
      pressureNoiseEnabled: false,
      hasHoldConstantControls: hasHoldConstantControls,
    );
    addTearDown(m.dispose);
    return m;
  }

  test('1. N=0 → T null, P=0', () {
    final m = makeModel();
    m.pause();
    m.updateWhenPaused();
    expect(m.numberOfParticles, 0);
    expect(m.temperature, isNull);
    expect(m.temperatureK, isNull);
    expect(m.pressure, 0);
    expect(m.pressureKpa, 0);
  });

  test('2. temperature formula with crafted particle', () {
    final keDesired = (3 / 2) * GasesIntroConstants.boltzmann * 300;
    final speed = math.sqrt(2 * keDesired / GasesIntroConstants.heavyMass);
    final p = GasParticle.heavy(x: -5000, y: 4000);
    p.setVelocity(speed, 0);

    final t = TemperatureSolver.compute(
      numberOfParticles: 1,
      getAverageKineticEnergy: () => p.kineticEnergy,
    );
    expect(t, isNotNull);
    expect(t!, closeTo(300, 300 * 1e-6));
  });

  test('3. pressure formula', () {
    const n = 100;
    const t = 300.0;
    const w = 10000.0;
    final v = w * GasesIntroConstants.height * GasesIntroConstants.depth;
    final expected = (n * GasesIntroConstants.boltzmann * t / v) *
        GasesIntroConstants.pressureConversionScale;
    final p = PressureSolver.compute(
      numberOfParticles: n,
      temperatureK: t,
      volumePm3: v,
    );
    expect(p, closeTo(expected, expected * 1e-6));
  });

  test('4. volume = w·h·d', () {
    final m = makeModel();
    expect(
      m.volume,
      GasesIntroConstants.widthDefault *
          GasesIntroConstants.height *
          GasesIntroConstants.depth,
    );
    m.setWidthImmediate(8000);
    expect(
      m.volume,
      8000 * GasesIntroConstants.height * GasesIntroConstants.depth,
    );
  });

  test('5. heatCool scales velocity', () {
    final m = makeModel();
    m.pause();
    final p = GasParticle.heavy(x: -5000, y: 4000);
    p.setVelocity(100, 0);
    m.particleSystem.heavyParticles.add(p);
    m.particleSystem.heatCool(1);
    expect(p.vx, closeTo(100 * (1 + 1 / 800), 1e-12));
  });

  test('6. inject speed formula |v|=√(3kT/m)', () {
    final expected = math.sqrt(
      3 *
          GasesIntroConstants.boltzmann *
          300 /
          GasesIntroConstants.heavyMass,
    );
    final m = makeModel();
    m.pause();
    m.setNumberHeavy(1);
    expect(
      m.particleSystem.heavyParticles.single.speed,
      closeTo(expected, 1e-6),
    );
  });

  test('7. holdConstant pressureT adjusts temperature roughly', () {
    final m = makeModel();
    m.pause();
    m.setNumberHeavy(50);
    for (var i = 0; i < 40; i++) {
      m.stepOnce();
    }
    expect(m.pressure, greaterThan(0));
    final pHeld = m.pressure;

    m.setHoldConstant(HoldConstant.pressureT);
    m.setWidth(12000);
    for (var i = 0; i < 5; i++) {
      m.stepOnce();
    }
    expect(m.holdConstant, HoldConstant.pressureT);
    expect(m.pressure, closeTo(pHeld, pHeld * 0.15));
    expect(m.temperature, isNotNull);
  });

  test('8. reset clears particles', () {
    final m = makeModel();
    m.pump(50);
    expect(m.numberOfParticles, 50);
    m.reset();
    expect(m.numberOfParticles, 0);
    expect(m.temperature, isNull);
    expect(m.pressure, 0);
    expect(m.holdConstant, HoldConstant.nothing);
    expect(m.width, GasesIntroConstants.widthDefault);
  });

  test('9. stepOnce advances when paused', () {
    final m = makeModel();
    m.pause();
    m.setNumberHeavy(10);
    final t0 = m.stopwatchPs;
    final x0 = m.particleSystem.heavyParticles.first.x;
    m.stepOnce();
    expect(m.isPlaying, isFalse);
    expect(
      m.stopwatchPs,
      closeTo(t0 + GasesIntroConstants.modelTimeStepPs, 1e-9),
    );
    expect(m.particleSystem.heavyParticles.first.x, isNot(x0));
  });

  test('pump adds selected particle type', () {
    final m = makeModel();
    m.pumpParticleType = ParticleKind.light;
    m.pump();
    expect(m.particleSystem.numberOfLight, 50);
    expect(m.particleSystem.numberOfHeavy, 0);
  });

  test('10. Heat → KE↑ → T↑ → P↑ (source chain)', () {
    final m = makeModel();
    m.play();
    m.pump(80);
    for (var i = 0; i < 60; i++) {
      m.stepOnce();
    }
    expect(m.pressure, greaterThan(0));
    final t0 = m.temperature!;
    final p0 = m.pressure;
    final ke0 = m.particleSystem.averageKineticEnergy;
    m.setHeatCool(1);
    for (var i = 0; i < 20; i++) {
      m.stepOnce();
    }
    m.setHeatCool(0);
    expect(m.particleSystem.averageKineticEnergy, greaterThan(ke0));
    expect(m.temperature!, greaterThan(t0));
    expect(m.pressure, greaterThan(p0));
  });

  test('11. Cool → KE↓ → T↓ → P↓', () {
    final m = makeModel();
    m.play();
    m.pump(80);
    for (var i = 0; i < 60; i++) {
      m.stepOnce();
    }
    final t0 = m.temperature!;
    final p0 = m.pressure;
    m.setHeatCool(-1);
    for (var i = 0; i < 20; i++) {
      m.stepOnce();
    }
    m.setHeatCool(0);
    expect(m.temperature!, lessThan(t0));
    expect(m.pressure, lessThan(p0));
  });

  test('12. left-wall width change updates volume (Ideal redistribute)', () {
    final m = makeModel();
    m.pause();
    m.pump(40);
    final start = m.width;
    m.beginWidthAdjust();
    m.setWidth(7000);
    m.endWidthAdjust();
    expect(m.width, closeTo(7000, 1e-6));
    expect(m.volume, 7000 * GasesIntroConstants.height * GasesIntroConstants.depth);
    expect(m.numberOfParticles, 40);
    // Particles should still be inside new bounds after redistribute
    for (final p in m.particleSystem.heavyParticles) {
      expect(p.x, greaterThanOrEqualTo(m.container.left - 1e-6));
      expect(p.x, lessThanOrEqualTo(m.container.right + 1e-6));
    }
    expect(start, GasesIntroConstants.widthDefault);
  });

  test('13. heat disabled while paused (interaction semantics)', () {
    final m = makeModel();
    m.play();
    m.pump(20);
    m.pause();
    m.setHeatCool(1);
    expect(m.heatCoolFactor, 0);
  });

  test('14. DISPLAY pressure tracks MODEL when noise off', () {
    final m = makeModel();
    m.play();
    m.pump(60);
    for (var i = 0; i < 80; i++) {
      m.stepOnce();
    }
    expect(m.pressure, greaterThan(0));
    // After a full gauge refresh period of steps, displayed ≈ model
    expect(
      m.displayedPressure,
      closeTo(m.pressure, m.pressure * 0.05 + 1e-6),
    );
  });

  test('15. open lid: particle leaves through the notch and stays visible outside',
      () {
    final m = makeModel();
    m.pause();
    m.pump(1);
    m.container.lidWidth = m.container.minLidWidth;
    expect(m.container.isOpen, isTrue);

    final p = m.particleSystem.heavyParticles.first;
    final gapLeft = m.container.escapeOpeningLeft;
    final gapRight = m.container.escapeOpeningRight;
    p.x = (gapLeft + gapRight) / 2;
    p.y = m.container.top + p.radius + 40;
    p.setVelocity(0, 800);

    m.particleSystem.escapeParticles();
    expect(m.numberOfParticles, 0);
    expect(m.particleSystem.heavyOutside, isNotEmpty);
    expect(m.renderData.particles, isNotEmpty);

    m.stepModelTime(GasesIntroConstants.modelTimeStepPs);
    expect(m.particleSystem.heavyOutside.first.y, greaterThan(p.y - 1));
  });

  test('16. closed lid: particle at top bounces, does not escape', () {
    final m = makeModel();
    m.pause();
    m.pump(1);
    expect(m.container.isOpen, isFalse);
    final p = m.particleSystem.heavyParticles.first;
    p.x = -5000;
    p.y = m.container.top - p.radius + 20;
    p.setVelocity(0, 500);
    m.collisionSolver.update();
    expect(p.top, lessThanOrEqualTo(m.container.top + 1e-6));
    expect(p.vy, lessThan(0));
    m.particleSystem.escapeParticles();
    expect(m.particleSystem.heavyOutside, isEmpty);
    expect(m.numberOfParticles, 1);
  });
}
