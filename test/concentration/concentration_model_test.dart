import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/probe_region.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';

void main() {
  const eps = 1e-9;

  ConcentrationModel fresh({int seed = 1}) =>
      ConcentrationModel(random: math.Random(seed));

  group('Solute definitions', () {
    test('exactly 9 solutes in ROYGBIV order', () {
      expect(SoluteDefinitions.all.length, 9);
      expect(SoluteDefinitions.all.map((s) => s.id).toList(), [
        'drinkMix',
        'cobaltIINitrate',
        'cobaltChloride',
        'potassiumDichromate',
        'potassiumChromate',
        'nickelIIChloride',
        'copperSulfate',
        'potassiumPermanganate',
        'sodiumChloride',
      ]);
    });

    test('source stock / molarMass / maxConcentration', () {
      expect(SoluteDefinitions.drinkMix.stockSolutionConcentration, 5.5);
      expect(SoluteDefinitions.drinkMix.molarMass, 342.296);
      expect(SoluteDefinitions.drinkMix.saturatedConcentration, 5.96);

      expect(SoluteDefinitions.cobaltChloride.stockSolutionConcentration, 4.0);
      expect(SoluteDefinitions.cobaltChloride.molarMass, 129.839);
      expect(SoluteDefinitions.cobaltChloride.saturatedConcentration, 4.33);

      expect(SoluteDefinitions.potassiumPermanganate.particleFill, isNotNull);
      expect(
        SoluteDefinitions.sodiumChloride.stockSolutionConcentration,
        5.50,
      );
      expect(SoluteDefinitions.copperSulfate.saturatedConcentration, 1.38);
    });

    test('default particlesPerMole is 200', () {
      for (final s in SoluteDefinitions.all) {
        expect(s.particlesPerMole, 200);
      }
    });
  });

  group('Initial state', () {
    test('matches source defaults', () {
      final m = fresh();
      expect(m.solute.id, 'drinkMix');
      expect(m.soluteForm, SoluteForm.solid);
      expect(m.soluteMoles, 0);
      expect(m.solutionVolume, 0.5);
      expect(m.concentration, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.meter.value, isNull);
      expect(m.meter.region, ProbeRegion.none);
      expect(m.shaker.isVisible(m.soluteForm), isTrue);
      expect(m.dropper.isVisible(m.soluteForm), isFalse);
      expect(m.removeSoluteEnabled, isFalse);
    });
  });

  group('Solution / concentration / saturation', () {
    test('concentration = moles/volume when unsaturated', () {
      final m = fresh();
      m.addSoluteAmount(0.25); // 0.25 / 0.5 = 0.5 M
      expect(m.concentration, closeTo(0.5, eps));
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
    });

    test('concentration capped and precipitate forms when saturated', () {
      final m = fresh();
      // Drink mix sat = 5.96; at 0.5 L need > 2.98 mol to saturate
      m.addSoluteAmount(3.5);
      expect(m.concentration, closeTo(5.96, eps));
      expect(m.precipitateMoles, closeTo(3.5 - 0.5 * 5.96, eps));
      expect(m.isSaturated, isTrue);
      expect(m.precipitateParticles.count, greaterThan(0));
    });

    test('continue adding after saturation increases precipitate only', () {
      final m = fresh();
      m.addSoluteAmount(3.5);
      final c0 = m.concentration;
      final p0 = m.precipitateMoles;
      m.addSoluteAmount(0.5);
      expect(m.concentration, closeTo(c0, eps));
      expect(m.precipitateMoles, closeTo(p0 + 0.5, eps));
    });

    test('volume == 0 → concentration 0 (no division by zero)', () {
      final m = fresh();
      m.addSoluteAmount(1.0);
      m.setVolumeDirect(0);
      expect(m.concentration, 0);
      expect(m.concentration.isFinite, isTrue);
    });

    test('solute moles clamped to 7', () {
      final m = fresh();
      m.addSoluteAmount(10);
      expect(m.soluteMoles, ConcentrationConstants.soluteAmountMax);
      expect(m.shaker.isEmpty, isTrue);
    });
  });

  group('Solute switching', () {
    test('switching solute clears moles', () {
      final m = fresh();
      m.addSoluteAmount(1.0);
      expect(m.soluteMoles, greaterThan(0));
      m.setSolute(SoluteDefinitions.sodiumChloride);
      expect(m.solute.id, 'sodiumChloride');
      expect(m.soluteMoles, 0);
      expect(m.concentration, 0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateMoles, 0);
      expect(m.shakerParticles.count, 0);
    });
  });

  group('Water faucet', () {
    test('rate 0.25 L/s for 0.1 s → volume 0.525', () {
      final m = fresh();
      m.setSolventFlowRate(0.25);
      m.step(0.1);
      expect(m.solutionVolume, closeTo(0.525, eps));
      expect(m.soluteMoles, 0);
    });

    test('does not exceed 1.0 L', () {
      final m = fresh();
      m.setVolumeDirect(0.95);
      m.setSolventFlowRate(0.25);
      m.step(1.0);
      expect(m.solutionVolume, ConcentrationConstants.solutionVolumeMax);
      expect(m.solventFaucet.enabled, isFalse);
      expect(m.solventFaucet.flowRate, 0);
    });

    test('dilutes concentration; moles unchanged', () {
      final m = fresh();
      m.addSoluteAmount(0.5); // 1.0 M at 0.5 L
      expect(m.concentration, closeTo(1.0, eps));
      m.setSolventFlowRate(0.25);
      m.step(0.4); // +0.1 L → 0.6 L
      expect(m.soluteMoles, closeTo(0.5, eps));
      expect(m.solutionVolume, closeTo(0.6, eps));
      expect(m.concentration, closeTo(0.5 / 0.6, eps));
    });
  });

  group('Drain', () {
    test('removes solute proportional to concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.5); // c = 1.0 at 0.5 L
      final cBefore = m.concentration;
      m.setDrainFlowRate(0.25);
      m.step(0.4); // remove 0.1 L
      expect(m.solutionVolume, closeTo(0.4, eps));
      expect(m.soluteMoles, closeTo(0.5 - cBefore * 0.1, eps));
      expect(m.concentration, closeTo(cBefore, 1e-12));
    });

    test('drain to empty', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setDrainFlowRate(0.25);
      m.step(3.0);
      expect(m.solutionVolume, 0);
      expect(m.soluteMoles, closeTo(0, 1e-12));
      expect(m.concentration, 0);
      expect(m.drainFaucet.enabled, isFalse);
    });
  });

  group('Evaporation', () {
    test('reduces volume, conserves solute, raises concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.2); // 0.4 M
      m.setEvaporationRate(0.25);
      m.step(0.4); // -0.1 L
      expect(m.solutionVolume, closeTo(0.4, eps));
      expect(m.soluteMoles, closeTo(0.2, eps));
      expect(m.concentration, closeTo(0.5, eps));
    });

    test('release snaps rate to 0', () {
      final m = fresh();
      m.setEvaporationRate(0.25);
      expect(m.evaporator.evaporationRate, 0.25);
      m.releaseEvaporation();
      expect(m.evaporator.evaporationRate, 0);
    });

    test('can drive solution to saturation', () {
      final m = fresh();
      // copper sulfate sat 1.38; 0.6 mol in 0.5 L = 1.2 M unsaturated
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.6);
      expect(m.isSaturated, isFalse);
      m.setEvaporationRate(0.25);
      m.step(0.4); // volume → 0.4; c = 0.6/0.4 = 1.5 > 1.38
      expect(m.soluteMoles, closeTo(0.6, eps));
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.isSaturated, isTrue);
      expect(m.precipitateMoles, greaterThan(0));
    });
  });

  group('Dropper', () {
    test('adds volume and solute at stock concentration', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      expect(m.dropper.flowRate, ConcentrationConstants.dropperFlowRate);
      m.step(0.2); // 0.05 * 0.2 = 0.01 L
      expect(m.solutionVolume, closeTo(0.51, eps));
      expect(
        m.soluteMoles,
        closeTo(5.5 * 0.01, eps), // drink mix stock
      );
    });

    test('disabled at max volume', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setVolumeDirect(1.0);
      expect(m.dropper.enabled, isFalse);
      m.setDropperDispensing(true);
      expect(m.dropper.isDispensing, isFalse);
      expect(m.dropper.flowRate, 0);
    });

    test('shaker and dropper differ: shaker does not add volume', () {
      final m = fresh();
      final v0 = m.solutionVolume;
      // Direct mole add mimics shaker delivery without volume change
      m.addSoluteAmount(0.1);
      expect(m.solutionVolume, v0);

      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.step(0.2);
      expect(m.solutionVolume, greaterThan(v0));
    });
  });

  group('Shaker', () {
    test('motion sets dispensingRate; stillness clears it', () {
      final m = fresh();
      expect(m.shaker.dispensingRate, 0);
      m.setShakerPosition(const Offset(360, 170));
      m.step(0.016); // createShakerParticles → step sees movement
      expect(m.shaker.dispensingRate, ConcentrationConstants.shakerMaxDispensingRate);
      m.step(0.016); // same position → rate 0
      expect(m.shaker.dispensingRate, 0);
    });

    test('particles spawn while dispensing and deliver moles', () {
      final m = fresh(seed: 42);
      m.setShakerPosition(const Offset(360, 180));
      m.step(0.05); // sets rate, may spawn on next frame
      m.setShakerPosition(const Offset(370, 180));
      // Keep moving for several frames so particles fall into liquid
      for (var i = 0; i < 80; i++) {
        m.setShakerPosition(Offset(360 + (i % 5).toDouble(), 180));
        m.step(0.05);
      }
      expect(m.soluteMoles, greaterThan(0));
      // Each particle = 1/200 mol
      final particlesWorth = m.soluteMoles * 200;
      expect(particlesWorth, closeTo(particlesWorth.roundToDouble(), 1e-6));
    });

    test('empty at max solute stops dispensing', () {
      final m = fresh();
      m.addSoluteAmount(7);
      expect(m.shaker.isEmpty, isTrue);
      m.setShakerPosition(const Offset(400, 170));
      m.step(0.05);
      expect(m.shaker.dispensingRate, 0);
    });
  });

  group('Remove solute', () {
    test('clears moles and precipitate; keeps volume', () {
      final m = fresh();
      m.addSoluteAmount(3.5);
      final v = m.solutionVolume;
      expect(m.removeSoluteEnabled, isTrue);
      m.removeSolute();
      expect(m.soluteMoles, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.solutionVolume, v);
      expect(m.shakerParticles.count, 0);
      expect(m.removeSoluteEnabled, isFalse);
    });
  });

  group('Probe', () {
    test('outside → null (not 0)', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbeRegion(ProbeRegion.none);
      expect(m.meter.value, isNull);
    });

    test('solution → concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbeRegion(ProbeRegion.solution);
      expect(m.meter.value, closeTo(1.0, eps));
    });

    test('water stream → 0', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbeRegion(ProbeRegion.waterStream);
      expect(m.meter.value, 0);
    });

    test('stock stream → stock concentration', () {
      final m = fresh();
      m.setProbeRegion(ProbeRegion.stockSolution);
      expect(m.meter.value, SoluteDefinitions.drinkMix.stockSolutionConcentration);
    });

    test('drain stream → solution concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setProbeRegion(ProbeRegion.drainStream);
      expect(m.meter.value, closeTo(m.concentration, eps));
    });

    test('probe drag clamped to bounds', () {
      final m = fresh();
      m.setProbePosition(const Offset(-100, -100));
      expect(m.meter.probePosition.dx, ConcentrationConstants.probeDragBounds.left);
      expect(m.meter.probePosition.dy, ConcentrationConstants.probeDragBounds.top);
      m.setProbePosition(const Offset(9999, 9999));
      expect(m.meter.probePosition.dx, ConcentrationConstants.probeDragBounds.right);
      expect(m.meter.probePosition.dy, ConcentrationConstants.probeDragBounds.bottom);
    });

    test('jump cycles positions', () {
      final m = fresh();
      final p0 = m.jumpProbeToNext();
      final p1 = m.jumpProbeToNext();
      expect(p0, isNot(equals(p1)));
      m.resetProbeJumpIndex();
      expect(m.probeJump.index, 0);
    });

    test('percent units use mass percent', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setMeterUnits(ConcentrationMeterUnits.percent);
      m.setProbeRegion(ProbeRegion.solution);
      expect(m.meter.value, closeTo(m.solution.percentConcentration, eps));
      expect(m.meter.value, greaterThan(0));
      expect(m.meter.value, lessThan(100));
    });
  });

  group('Step ordering / simultaneous controls', () {
    test('water then drain in same dt follows source order', () {
      final m = fresh();
      m.addSoluteAmount(0.5); // 1 M @ 0.5 L
      m.setSolventFlowRate(0.25);
      m.setDrainFlowRate(0.25);
      // Same rates: water adds first, then drain removes at new concentration
      m.step(0.2); // +0.05 then drain 0.05 at c' = 0.5/0.55
      expect(m.solutionVolume, closeTo(0.5, 1e-12));
      final expectedMoles = 0.5 - (0.5 / 0.55) * 0.05;
      expect(m.soluteMoles, closeTo(expectedMoles, 1e-12));
    });

    test('dropper then evaporation in same dt', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setEvaporationRate(0.05);
      m.step(0.2);
      // dropper +0.01 L and +0.055 mol, then evaporate -0.01 L
      expect(m.solutionVolume, closeTo(0.5, 1e-12));
      expect(m.soluteMoles, closeTo(5.5 * 0.01, eps));
    });
  });

  group('Reset', () {
    test('full reset matches fresh model', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(2);
      m.setVolumeDirect(0.8);
      m.setSolventFlowRate(0.1);
      m.setDrainFlowRate(0.1);
      m.setEvaporationRate(0.1);
      m.setProbeRegion(ProbeRegion.solution);
      m.setShakerPosition(const Offset(400, 160));
      m.reset();

      final n = fresh();
      expect(m.solute.id, n.solute.id);
      expect(m.soluteForm, n.soluteForm);
      expect(m.soluteMoles, n.soluteMoles);
      expect(m.solutionVolume, n.solutionVolume);
      expect(m.concentration, n.concentration);
      expect(m.isSaturated, n.isSaturated);
      expect(m.meter.value, n.meter.value);
      expect(m.shaker.position, n.shaker.position);
      expect(m.shakerParticles.count, 0);
      expect(m.solventFaucet.flowRate, 0);
      expect(m.drainFaucet.flowRate, 0);
      expect(m.evaporator.evaporationRate, 0);
      expect(m.probeJump.index, 0);
    });

    test('repeated reset ×3 has no accumulation', () {
      final m = fresh();
      for (var i = 0; i < 3; i++) {
        m.addSoluteAmount(1.0);
        m.setVolumeDirect(0.7);
        m.setShakerPosition(Offset(300 + i * 10.0, 170));
        for (var j = 0; j < 10; j++) {
          m.setShakerPosition(Offset(310 + j.toDouble(), 175));
          m.step(0.05);
        }
        m.reset();
        expect(m.soluteMoles, 0);
        expect(m.solutionVolume, 0.5);
        expect(m.shakerParticles.count, 0);
        expect(m.precipitateParticles.count, 0);
      }
    });
  });

  group('Percent concentration formula', () {
    test('matches source mass percent', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      final soluteGrams =
          SoluteDefinitions.drinkMix.molarMass * 0.5; // no precipitate
      final solventGrams = 0.5 * 1000;
      final expected = 100 * soluteGrams / (soluteGrams + solventGrams);
      expect(m.solution.percentConcentration, closeTo(expected, eps));
    });
  });
}
