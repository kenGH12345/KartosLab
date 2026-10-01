import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/model/beaker_solution.dart';
import 'package:kratos/chemistry/ph_scale/model/macro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/micro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/my_solution.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_chemistry.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_model.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_scale_constants.dart';
import 'package:kratos/chemistry/ph_scale/model/ratio_particle_counts.dart';
import 'package:kratos/chemistry/ph_scale/model/solute.dart';
import 'package:kratos/chemistry/ph_scale/model/solution_derived_properties.dart';
import 'package:kratos/chemistry/ph_scale/model/water.dart';

void main() {
  group('PhChemistry — pH / concentration (PHModel.ts)', () {
    test('neutral water: [H3O+]=[OH-]=1e-7, pH=7', () {
      expect(PhChemistry.pHToConcentrationH3O(7), closeTo(1e-7, 1e-20));
      expect(PhChemistry.pHToConcentrationOH(7), closeTo(1e-7, 1e-20));
      expect(PhChemistry.concentrationH3OToPH(1e-7), closeTo(7, 1e-12));
      expect(PhChemistry.concentrationOHToPH(1e-7), closeTo(7, 1e-12));
    });

    test('acidic: pH 1 → [H3O+]=0.1, [OH-]=1e-13', () {
      expect(PhChemistry.pHToConcentrationH3O(1), closeTo(0.1, 1e-12));
      expect(PhChemistry.pHToConcentrationOH(1), closeTo(1e-13, 1e-20));
    });

    test('basic: pH 13 → [H3O+]=1e-13, [OH-]=0.1', () {
      expect(PhChemistry.pHToConcentrationH3O(13), closeTo(1e-13, 1e-20));
      expect(PhChemistry.pHToConcentrationOH(13), closeTo(0.1, 1e-12));
    });

    test('extreme acidic pH=-1', () {
      expect(PhChemistry.pHToConcentrationH3O(-1), closeTo(10, 1e-9));
      expect(
        PhChemistry.concentrationH3OToPH(10),
        closeTo(-1, 1e-12),
      );
    });

    test('extreme basic pH=15', () {
      expect(PhChemistry.pHToConcentrationOH(15), closeTo(10, 1e-9));
      expect(PhChemistry.concentrationOHToPH(10), closeTo(15, 1e-12));
    });

    test('null / zero guards', () {
      expect(PhChemistry.pHToConcentrationH3O(null), isNull);
      expect(PhChemistry.concentrationH3OToPH(null), isNull);
      expect(PhChemistry.concentrationH3OToPH(0), isNull);
      expect(PhChemistry.volumeToConcentrationH2O(0), isNull);
      expect(PhChemistry.volumeToConcentrationH2O(0.5), Water.concentration);
    });

    test('Water.concentration is 55 (not 55.6)', () {
      expect(Water.concentration, 55);
      expect(Water.pH, 7);
    });

    test('Avogadro constant is 6.023e23', () {
      expect(PhChemistry.avogadrosNumber, 6.023e23);
    });

    test('particle count = c·V·N_A', () {
      // 1e-7 mol/L × 0.5 L × 6.023e23
      final n = PhChemistry.computeParticleCount(1e-7, 0.5);
      expect(n, closeTo(1e-7 * 0.5 * 6.023e23, 1e10));
    });

    test('moles = c·V', () {
      expect(PhChemistry.computeMoles(1e-7, 0.5), closeTo(5e-8, 1e-20));
    });
  });

  group('PhChemistry.computePH — dilution mixing', () {
    test('V=0 → null', () {
      expect(
        PhChemistry.computePH(
          solutePH: 1,
          soluteVolume: 0,
          waterVolume: 0,
        ),
        isNull,
      );
    });

    test('pure water volume → pH 7', () {
      expect(
        PhChemistry.computePH(
          solutePH: 1,
          soluteVolume: 0,
          waterVolume: 0.5,
        ),
        7,
      );
    });

    test('pure solute (no water) → stock pH', () {
      expect(
        PhChemistry.computePH(
          solutePH: 2,
          soluteVolume: 0.5,
          waterVolume: 0,
        ),
        2,
      );
    });

    test('acid dilution: battery acid 0.25 L + water 0.25 L', () {
      // Vs=Vw → pH = -log10( (10^-1 + 10^-7)/2 )
      final pH = PhChemistry.computePH(
        solutePH: 1,
        soluteVolume: 0.25,
        waterVolume: 0.25,
      )!;
      expect(pH, closeTo(1.30103, 1e-5));
    });

    test('base dilution: drain cleaner 0.25 L + water 0.25 L', () {
      // Vs=Vw → pH = 14 + log10( (10^-1 + 10^-7)/2 )
      final pH = PhChemistry.computePH(
        solutePH: 13,
        soluteVolume: 0.25,
        waterVolume: 0.25,
      )!;
      expect(pH, closeTo(12.69897, 1e-5));
    });

    test('autofill water 0.5 L → pH 7', () {
      expect(
        PhChemistry.computePH(
          solutePH: Water.pH,
          soluteVolume: 0.5,
          waterVolume: 0,
        ),
        7,
      );
    });
  });

  group('isEquivalentToWater / display precision', () {
    test('displayed 7.00 is water-equivalent', () {
      expect(PhChemistry.isEquivalentToWater(7.0), isTrue);
      expect(PhChemistry.isEquivalentToWater(7.001), isTrue); // → 7.00
      expect(PhChemistry.isEquivalentToWater(6.995), isTrue); // → 7.00
      expect(PhChemistry.isEquivalentToWater(6.994), isFalse); // → 6.99
      expect(PhChemistry.isEquivalentToWater(null), isFalse);
    });
  });

  group('BeakerSolution volume ops', () {
    test('addWater / addSolute respect maxVolume', () {
      final s = BeakerSolution(maxVolume: 1.0);
      s.addSolute(0.6);
      s.addWater(0.6);
      expect(s.totalVolume, closeTo(1.0, 1e-12));
      expect(s.soluteVolume, closeTo(0.6, 1e-12));
      expect(s.waterVolume, closeTo(0.4, 1e-12));
    });

    test('drainSolution removes proportional volumes', () {
      final s = BeakerSolution(
        solute: Solute.coffee,
        soluteVolume: 0.4,
        waterVolume: 0.4,
        maxVolume: 1.2,
      );
      s.drainSolution(0.4);
      expect(s.soluteVolume, closeTo(0.2, 1e-12));
      expect(s.waterVolume, closeTo(0.2, 1e-12));
    });

    test('drain below MIN_VOLUME clears', () {
      final s = BeakerSolution(soluteVolume: 0.02, waterVolume: 0.02);
      s.drainSolution(0.05);
      expect(s.totalVolume, 0);
    });

    test('setSolute resets volumes', () {
      final s = BeakerSolution(soluteVolume: 0.3, waterVolume: 0.2);
      s.setSolute(Solute.coffee);
      expect(s.solute, Solute.coffee);
      expect(s.totalVolume, 0);
    });
  });

  group('SolutionDerivedProperties', () {
    test('neutral 0.5 L water', () {
      final d = SolutionDerivedProperties(pH: 7, totalVolume: 0.5);
      expect(d.concentrationH2O, 55);
      expect(d.concentrationH3O, closeTo(1e-7, 1e-20));
      expect(d.concentrationOH, closeTo(1e-7, 1e-20));
      expect(d.quantityH3O, closeTo(5e-8, 1e-20));
      expect(d.h3oOhRatio, closeTo(1.0, 1e-12));
    });

    test('acid ratio >> 1', () {
      final d = SolutionDerivedProperties(pH: 3, totalVolume: 0.5);
      expect(d.h3oOhRatio!, greaterThan(1e7));
    });
  });

  group('RatioParticleCounts (visual scale)', () {
    test('pH 7 → 50 / 50', () {
      final c = RatioParticleCounts.displayCounts(7);
      expect(c.h3o, 50);
      expect(c.oh, 50);
    });

    test('empty → 0 / 0', () {
      final c = RatioParticleCounts.displayCounts(null);
      expect(c.h3o, 0);
      expect(c.oh, 0);
    });

    test('strong acid has more H3O than OH', () {
      final c = RatioParticleCounts.displayCounts(1);
      expect(c.h3o, greaterThan(c.oh));
      expect(c.oh, greaterThanOrEqualTo(RatioParticleCounts.minMinorityParticles));
    });

    test('strong base has more OH than H3O', () {
      final c = RatioParticleCounts.displayCounts(13);
      expect(c.oh, greaterThan(c.h3o));
      expect(c.h3o, greaterThanOrEqualTo(RatioParticleCounts.minMinorityParticles));
    });
  });

  group('PhModel autofill / reset', () {
    test('start → completeAutofill → 0.5 L water pH 7', () {
      final m = PhModel(autoFillEnabled: true);
      m.completeAutofillNow();
      expect(m.solution.totalVolume, closeTo(0.5, 1e-12));
      expect(m.solution.pH, 7);
      expect(m.solution.solute, Solute.water);
      m.dispose();
    });

    test('step autofill accumulates to 0.5 L', () {
      final m = PhModel(autoFillEnabled: true);
      expect(m.isAutofilling, isTrue);
      // 0.45 L/s → need ~1.12 s; step in chunks
      for (var i = 0; i < 20; i++) {
        m.step(0.1);
      }
      expect(m.solution.totalVolume, closeTo(0.5, 1e-9));
      expect(m.isAutofilling, isFalse);
      m.dispose();
    });

    test('selectSolute coffee → autofill stock coffee', () {
      final m = PhModel(autoFillEnabled: true);
      m.completeAutofillNow();
      m.selectSolute(Solute.coffee);
      m.completeAutofillNow();
      expect(m.solution.solute, Solute.coffee);
      expect(m.solution.totalVolume, closeTo(0.5, 1e-12));
      expect(m.solution.pH, closeTo(5, 1e-12));
      m.dispose();
    });

    test('reset restores water + triggers autofill', () {
      final m = PhModel(autoFillEnabled: true);
      m.completeAutofillNow();
      m.selectSolute(Solute.vomit);
      m.completeAutofillNow();
      m.waterFaucet.flowRate = 0.1;
      m.reset();
      m.completeAutofillNow();
      expect(m.solution.solute, Solute.water);
      expect(m.solution.totalVolume, closeTo(0.5, 1e-12));
      expect(m.solution.pH, 7);
      expect(m.waterFaucet.flowRate, 0);
      m.dispose();
    });

    test('faucet step adds water and dilutes acid', () {
      final m = PhModel(autoFillEnabled: false);
      m.solution.setSolute(Solute.batteryAcid, resetVolumes: false);
      m.solution.addSolute(0.25);
      final pHBefore = m.solution.pH!;
      m.waterFaucet.enabled = true;
      m.waterFaucet.flowRate = 0.25;
      m.step(1.0); // +0.25 L water
      expect(m.solution.waterVolume, closeTo(0.25, 1e-12));
      expect(m.solution.pH!, greaterThan(pHBefore));
      m.dispose();
    });
  });

  group('MacroModel / MicroModel / MySolution', () {
    test('Macro meter starts null; format null', () {
      final m = MacroModel(autoFillEnabled: true);
      m.completeAutofillNow();
      expect(m.meter.displayedPH, isNull);
      expect(m.formatDisplayedPH(), isNull);
      m.setProbeReading(m.solution.pH);
      expect(m.formatDisplayedPH(), '7.00');
      m.dispose();
    });

    test('Micro derived tracks solution', () {
      final m = MicroModel(autoFillEnabled: true);
      m.completeAutofillNow();
      expect(m.derived.concentrationH3O, closeTo(1e-7, 1e-20));
      expect(m.derived.particleCountH2O, closeTo(55 * 0.5 * 6.023e23, 1e16));
      m.dispose();
    });

    test('MySolution default + spinner + reset', () {
      final m = MySolutionModel();
      expect(m.solution.pH, 7);
      expect(m.solution.totalVolume, 0.5);
      m.solution.pH = 3.25;
      expect(
        m.solution.derived.concentrationH3O,
        closeTo(PhChemistry.pHToConcentrationH3O(3.25)!, 1e-12),
      );
      m.solution.setPHFromConcentrationH3O(1e-7);
      expect(m.solution.pH, closeTo(7, 1e-12));
      m.solution.pH = 10;
      m.reset();
      expect(m.solution.pH, 7);
      expect(m.solution.totalVolume, 0.5);
      m.dispose();
    });

    test('MySolution pH clamped to PH_RANGE', () {
      final s = MySolution();
      s.pH = -5;
      expect(s.pH, PhScaleConstants.phMin);
      s.pH = 20;
      expect(s.pH, PhScaleConstants.phMax);
      s.dispose();
    });
  });

  group('Solute table', () {
    test('12 solutes alphabetical; Water pH 7', () {
      expect(Solute.allAlphabetical.length, 12);
      expect(Solute.allAlphabetical.last, Solute.water);
      expect(Solute.batteryAcid.pH, 1);
      expect(Solute.drainCleaner.pH, 13);
      expect(Solute.blood.pH, 7.4);
    });
  });
}
