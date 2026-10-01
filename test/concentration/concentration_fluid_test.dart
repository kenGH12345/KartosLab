import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solvent.dart';
import 'package:kratos/concentration/view/beaker_solution_nodes.dart';

void main() {
  const eps = 1e-12;

  ConcentrationModel fresh() => ConcentrationModel();

  group('Water faucet', () {
    test('flow rate 0.25 × dt 0.1 → volume 0.525', () {
      final m = fresh();
      expect(m.solutionVolume, 0.5);
      m.setSolventFlowRate(0.25);
      expect(m.solventFaucet.flowRate, 0.25);
      m.step(0.1);
      expect(m.solutionVolume, closeTo(0.525, eps));
    });

    test('ten steps accumulate without drift past source math', () {
      final m = fresh();
      m.setSolventFlowRate(0.25);
      for (var i = 0; i < 10; i++) {
        m.step(0.1);
      }
      // 0.5 + 10 * 0.025 = 0.75
      expect(m.solutionVolume, closeTo(0.75, eps));
      expect(m.solutionVolume.isFinite, isTrue);
    });

    test('volume boundaries enable / disable', () {
      final m = fresh();
      m.setVolumeDirect(0);
      m.step(0);
      expect(m.solventFaucet.enabled, isTrue);

      m.setVolumeDirect(0.5);
      m.step(0);
      expect(m.solventFaucet.enabled, isTrue);

      m.setVolumeDirect(0.99);
      m.step(0);
      expect(m.solventFaucet.enabled, isTrue);

      m.setVolumeDirect(1.0);
      m.step(0);
      expect(m.solventFaucet.enabled, isFalse);
      expect(m.solventFaucet.flowRate, 0);
    });

    test('volume 0.999 clamps to 1.0 then flow stops', () {
      final m = fresh();
      m.setVolumeDirect(0.999);
      m.setSolventFlowRate(0.25);
      m.step(0.1);
      expect(m.solutionVolume, ConcentrationConstants.solutionVolumeMax);
      expect(m.solventFaucet.enabled, isFalse);
      expect(m.solventFaucet.flowRate, 0);
    });

    test('dilutes: volume↑ solute unchanged concentration↓', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      final c0 = m.concentration;
      final n0 = m.soluteMoles;
      m.setSolventFlowRate(0.25);
      m.step(0.4); // +0.1 L
      expect(m.soluteMoles, closeTo(n0, eps));
      expect(m.solutionVolume, closeTo(0.6, eps));
      expect(m.concentration, lessThan(c0));
      expect(m.concentration, closeTo(0.5 / 0.6, eps));
    });

    test('water stream color source is solvent water not solution', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      expect(m.solution.color, isNot(equals(Solvent.water.color)));
      expect(m.solution.solvent.color, Solvent.water.color);
    });
  });

  group('Drain faucet', () {
    test('proportional solute removal preserves concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.5); // c = 1.0
      final cBefore = m.concentration;
      m.setDrainFlowRate(0.25);
      m.step(0.4); // ΔV = 0.1
      expect(m.solutionVolume, closeTo(0.4, eps));
      expect(m.soluteMoles, closeTo(0.4, eps));
      expect(m.concentration, closeTo(cBefore, 1e-12));
    });

    test('exact Δn = c × ΔV', () {
      final m = fresh();
      m.addSoluteAmount(0.25); // c = 0.5
      m.setDrainFlowRate(0.25);
      m.step(0.2); // ΔV = 0.05
      expect(m.solutionVolume, closeTo(0.45, eps));
      expect(m.soluteMoles, closeTo(0.25 - 0.5 * 0.05, eps));
    });

    test('at saturation: concentration stays capped; precipitate adjusts', () {
      final m = fresh();
      // drink mix sat = 5.96; use copper sulfate sat 1.38
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.0); // V=0.5 → c capped 1.38, precip = 1-0.69
      m.step(0);
      expect(m.isSaturated, isTrue);
      final precipBefore = m.precipitateMoles;
      final cBefore = m.concentration;
      m.setDrainFlowRate(0.25);
      m.step(0.4); // ΔV=0.1; remove c*0.1 from total moles
      expect(m.solutionVolume, closeTo(0.4, eps));
      expect(m.concentration, closeTo(cBefore, 1e-12));
      expect(m.isSaturated, isTrue);
      // Source: remove dissolved-concentration × ΔV from total moles.
      expect(m.soluteMoles, closeTo(1.0 - cBefore * 0.1, eps));
      expect(m.precipitateMoles, closeTo(precipBefore, 1e-9));
    });

    test('drain to empty: volume 0, moles 0, concentration 0, no NaN', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setDrainFlowRate(0.25);
      m.step(3.0);
      expect(m.solutionVolume, 0);
      expect(m.soluteMoles, closeTo(0, 1e-12));
      expect(m.concentration, 0);
      expect(m.concentration.isFinite, isTrue);
      expect(m.drainFaucet.enabled, isFalse);
      expect(m.drainFaucet.flowRate, 0);
    });

    test('volume=0 disables drain', () {
      final m = fresh();
      m.setVolumeDirect(0);
      m.step(0);
      expect(m.drainFaucet.enabled, isFalse);
      m.setDrainFlowRate(0.25);
      expect(m.drainFaucet.flowRate, 0);
    });
  });

  group('Evaporation', () {
    test('numerical: rate 0.25 × dt 0.1 → volume 0.475, solute conserved', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setEvaporationRate(0.25);
      m.step(0.1);
      expect(m.solutionVolume, closeTo(0.475, eps));
      expect(m.soluteMoles, closeTo(0.25, eps));
      expect(m.concentration, closeTo(0.25 / 0.475, eps));
    });

    test('release snaps rate to 0', () {
      final m = fresh();
      m.setEvaporationRate(0.2);
      expect(m.evaporator.evaporationRate, 0.2);
      m.releaseEvaporation();
      expect(m.evaporator.evaporationRate, 0);
    });

    test('evaporate to empty stops; no negative / NaN', () {
      final m = fresh();
      m.addSoluteAmount(0.1);
      m.setEvaporationRate(0.25);
      m.step(3.0);
      expect(m.solutionVolume, 0);
      expect(m.soluteMoles, closeTo(0.1, eps));
      expect(m.concentration, 0);
      expect(m.evaporator.enabled, isFalse);
      expect(m.evaporator.evaporationRate, 0);
      expect(m.solutionVolume, isNot(lessThan(0)));
    });

    test('drives unsaturated → saturated + precipitate', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.6); // 1.2 M < 1.38
      expect(m.isSaturated, isFalse);
      m.setEvaporationRate(0.25);
      m.step(0.4); // V→0.4; c=1.5 > 1.38
      expect(m.soluteMoles, closeTo(0.6, eps));
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.isSaturated, isTrue);
      expect(m.precipitateMoles, greaterThan(0));
      expect(m.precipitateParticles.count, greaterThan(0));
    });
  });

  group('Liquid level / color', () {
    test('liquid height follows volume with 5px min', () {
      final beaker = ConcentrationModel().beaker;
      expect(
        SolutionNode.liquidHeight(
          volume: 0.5,
          beakerVolume: beaker.volume,
          beakerHeight: beaker.size.height,
        ),
        closeTo(150, eps),
      );
      expect(
        SolutionNode.liquidHeight(
          volume: 0.001,
          beakerVolume: beaker.volume,
          beakerHeight: beaker.size.height,
        ),
        ConcentrationConstants.minNonzeroSolutionHeight,
      );
      expect(
        SolutionNode.liquidHeight(
          volume: 0,
          beakerVolume: beaker.volume,
          beakerHeight: beaker.size.height,
        ),
        0,
      );
    });

    test('add water lightens; evaporate darkens (color differs)', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.drinkMix);
      m.addSoluteAmount(0.5);
      final mid = m.solution.color;

      m.setSolventFlowRate(0.25);
      m.step(0.8); // +0.2 L
      final lighter = m.solution.color;
      expect(lighter, isNot(equals(mid)));

      m.releaseEvaporation();
      m.setSolventFlowRate(0);
      // Restore to concentrated via evaporation
      m.setEvaporationRate(0.25);
      m.step(1.2);
      m.releaseEvaporation();
      final darker = m.solution.color;
      expect(darker, isNot(equals(lighter)));
    });
  });

  group('Simultaneous controls (source step order)', () {
    test('water + drain in same dt', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setSolventFlowRate(0.25);
      m.setDrainFlowRate(0.25);
      // water first +0.025, then drain 0.025 at new c
      final v0 = m.solutionVolume;
      final n0 = m.soluteMoles;
      m.step(0.1);
      // After water: V=0.525, n=0.5, c=0.5/0.525
      // After drain: remove 0.025 L at that c
      final afterWaterV = v0 + 0.025;
      final cMid = n0 / afterWaterV;
      expect(m.solutionVolume, closeTo(afterWaterV - 0.025, eps));
      expect(m.soluteMoles, closeTo(n0 - cMid * 0.025, eps));
    });

    test('water + evaporation in same dt', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setSolventFlowRate(0.25);
      m.setEvaporationRate(0.25);
      m.step(0.1);
      // water +0.025 → 0.525; evaporate −0.025 → 0.5; solute unchanged
      expect(m.solutionVolume, closeTo(0.5, eps));
      expect(m.soluteMoles, closeTo(0.25, eps));
    });

    test('drain + evaporation in same dt', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setDrainFlowRate(0.25);
      m.setEvaporationRate(0.25);
      m.step(0.1);
      // drain first: V=0.475, n=0.5-1.0*0.025=0.475
      // evaporate: V=0.45, n=0.475
      expect(m.solutionVolume, closeTo(0.45, eps));
      expect(m.soluteMoles, closeTo(0.475, eps));
    });

    test('water + drain + evaporation simultaneous', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setSolventFlowRate(0.25);
      m.setDrainFlowRate(0.25);
      m.setEvaporationRate(0.25);
      m.step(0.1);
      // water: V=0.525 n=0.5 c=0.5/0.525
      // drain: dV=0.025 → V=0.5 n=0.5-c*0.025
      // evap: V=0.475 n unchanged
      final cAfterWater = 0.5 / 0.525;
      final nAfterDrain = 0.5 - cAfterWater * 0.025;
      expect(m.solutionVolume, closeTo(0.475, eps));
      expect(m.soluteMoles, closeTo(nAfterDrain, eps));
    });
  });

  group('Reset / lifecycle', () {
    test('reset clears water / drain / evaporation activity', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setSolventFlowRate(0.25);
      m.setDrainFlowRate(0.1);
      m.setEvaporationRate(0.2);
      m.step(0.1);
      m.reset();
      expect(m.solutionVolume, 0.5);
      expect(m.soluteMoles, 0);
      expect(m.solventFaucet.flowRate, 0);
      expect(m.drainFaucet.flowRate, 0);
      expect(m.evaporator.evaporationRate, 0);
      expect(m.isSaturated, isFalse);
    });

    test('repeated water → drain → evaporate → reset ×3', () {
      final m = fresh();
      for (var cycle = 0; cycle < 3; cycle++) {
        m.setSolventFlowRate(0.25);
        m.step(0.2);
        m.setSolventFlowRate(0);
        m.addSoluteAmount(0.2);
        m.setDrainFlowRate(0.25);
        m.step(0.1);
        m.setDrainFlowRate(0);
        m.setEvaporationRate(0.25);
        m.step(0.1);
        m.releaseEvaporation();
        m.reset();
        expect(m.solutionVolume, 0.5);
        expect(m.soluteMoles, 0);
        expect(m.solventFaucet.flowRate, 0);
        expect(m.drainFaucet.flowRate, 0);
        expect(m.evaporator.evaporationRate, 0);
      }
    });
  });

  group('Stream geometry constants', () {
    test('drain fluid height matches source 1000', () {
      expect(ConcentrationConstants.drainFluidHeight, 1000);
    });

    test('spout width 45; stream width ∝ flowRate/max', () {
      expect(ConcentrationConstants.faucetSpoutWidth, 45);
      const max = ConcentrationConstants.faucetMaxFlowRate;
      const spout = ConcentrationConstants.faucetSpoutWidth;
      expect(spout * (0.125 / max), closeTo(22.5, eps));
      expect(spout * (0 / max), 0);
    });

    test('solvent fluid height = beaker.y − faucet.y', () {
      final m = fresh();
      final h = m.beaker.position.dy - m.solventFaucet.position.dy;
      expect(h, closeTo(550 - 220, eps));
    });
  });
}
