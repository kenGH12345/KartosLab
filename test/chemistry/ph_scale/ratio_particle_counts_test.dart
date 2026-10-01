import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_chemistry.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_model.dart';
import 'package:kratos/chemistry/ph_scale/model/ratio_particle_counts.dart';
import 'package:kratos/chemistry/ph_scale/model/solute.dart';
import 'package:kratos/chemistry/ph_scale/model/solution_derived_properties.dart';
import 'package:kratos/chemistry/ph_scale/view/scientific_notation.dart';

void main() {
  group('Ratio ≠ Particle Counts (Phase 3 separation)', () {
    test('neutral 0.5 L: Ratio 50/50 but Particle Counts ~1.5e16', () {
      final ratio = RatioParticleCounts.displayCounts(7);
      expect(ratio.h3o, 50);
      expect(ratio.oh, 50);

      final real = SolutionDerivedProperties(pH: 7, totalVolume: 0.5);
      // N = 1e-7 * 0.5 * 6.023e23 = 3.0115e16
      expect(real.particleCountH3O, closeTo(3.0115e16, 1e12));
      expect(real.particleCountOH, closeTo(3.0115e16, 1e12));
      expect(real.particleCountH2O, closeTo(55 * 0.5 * 6.023e23, 1e16));

      // Must not conflate
      expect(ratio.h3o.toDouble(), isNot(closeTo(real.particleCountH3O, 1e10)));
    });
  });

  group('RatioParticleCounts — source extremes (RatioNode.ts)', () {
    test('strong acid pH=1: H3O >> OH, minority ≥ 5', () {
      final c = RatioParticleCounts.displayCounts(1);
      expect(c.h3o, greaterThan(c.oh));
      expect(c.oh, greaterThanOrEqualTo(5));
      expect(c.h3o, lessThanOrEqualTo(RatioParticleCounts.maxMajorityParticles));
    });

    test('weak acid pH=6: log range', () {
      final c = RatioParticleCounts.displayCounts(6);
      expect(c.h3o, greaterThan(c.oh));
      expect(c.h3o, greaterThanOrEqualTo(5));
      expect(c.oh, greaterThanOrEqualTo(5));
    });

    test('neutral pH=7: 50/50', () {
      final c = RatioParticleCounts.displayCounts(7);
      expect(c.h3o, 50);
      expect(c.oh, 50);
    });

    test('weak base pH=8: log range', () {
      final c = RatioParticleCounts.displayCounts(8);
      expect(c.oh, greaterThan(c.h3o));
      expect(c.h3o, greaterThanOrEqualTo(5));
    });

    test('strong base pH=13: OH >> H3O', () {
      final c = RatioParticleCounts.displayCounts(13);
      expect(c.oh, greaterThan(c.h3o));
      expect(c.h3o, greaterThanOrEqualTo(5));
    });

    test('uses displayed pH (2 dp) — 6.994 → 6.99 acid side', () {
      // toFixedNumber(6.994,2)=6.99 → still in log? 6.99 in [6,8]
      final a = RatioParticleCounts.displayCounts(6.994);
      final b = RatioParticleCounts.displayCounts(6.99);
      expect(a.h3o, b.h3o);
      expect(a.oh, b.oh);
    });

    test('formula: computeNumberOfH3O(7)=50 from concentration', () {
      expect(RatioParticleCounts.computeNumberOfH3O(7), 50);
      expect(RatioParticleCounts.computeNumberOfOH(7), 50);
      // pH 6: [H3O]=1e-6 → round(1e-6 * 50 / 1e-7) = 500
      expect(RatioParticleCounts.computeNumberOfH3O(6), 500);
      expect(RatioParticleCounts.computeNumberOfOH(6), 5);
    });
  });

  group('Particle Counts — Avogadro + scientific notation', () {
    test('H2O uses fixed exponent 25', () {
      // 0.5 L water: N = 55*0.5*6.023e23 = 1.656325e25
      final n = PhChemistry.computeParticleCount(55, 0.5);
      final sn = ScientificNotation.from(n, mantissaDecimalPlaces: 2, fixedExponent: 25);
      expect(sn.exponent, '25');
      expect(double.parse(sn.mantissa), closeTo(1.66, 0.01));
    });

    test('H3O at pH7 0.5L uses computed exponent', () {
      final n = PhChemistry.computeParticleCount(1e-7, 0.5);
      final sn = ScientificNotation.from(n, mantissaDecimalPlaces: 2);
      expect(sn.display, contains('× 10'));
      // ~3.01 × 10¹⁶
      expect(sn.exponent, '16');
      expect(double.parse(sn.mantissa), closeTo(3.01, 0.05));
    });

    test('dilution changes Ratio via pH; acid moles of H3O roughly conserved', () {
      final acid = Solute.batteryAcid;
      final m = PhModel(autoFillEnabled: false);
      m.solution.setSolute(acid, resetVolumes: false);
      m.solution.addSolute(0.5);
      final pH1 = m.solution.pH!;
      final ratio1 = RatioParticleCounts.displayCounts(pH1);
      final count1 = PhChemistry.computeParticleCount(
        PhChemistry.pHToConcentrationH3O(pH1),
        0.5,
      );

      m.solution.addWater(0.5);
      final pH2 = m.solution.pH!;
      final ratio2 = RatioParticleCounts.displayCounts(pH2);
      final count2 = PhChemistry.computeParticleCount(
        PhChemistry.pHToConcentrationH3O(pH2),
        1.0,
      );

      // Dilution raises pH → Ratio visual H3O decreases
      expect(pH2, greaterThan(pH1));
      expect(ratio2.h3o, lessThan(ratio1.h3o));
      // Strong-acid equal-volume dilution: moles (hence N) ≈ conserved
      expect(count2, closeTo(count1, count1 * 0.01));
      // H2O particle count scales with volume at fixed [H2O]=55
      final h2o1 = PhChemistry.computeParticleCount(55, 0.5);
      final h2o2 = PhChemistry.computeParticleCount(55, 1.0);
      expect(h2o2, closeTo(h2o1 * 2, 1e10));
      m.dispose();
    });

    test('volume change alone does not change Ratio counts (same pH)', () {
      // Pure water autofill: any volume of pure water → pH 7 → Ratio 50/50
      expect(RatioParticleCounts.displayCounts(7).h3o, 50);
      final dSmall = SolutionDerivedProperties(pH: 7, totalVolume: 0.2);
      final dLarge = SolutionDerivedProperties(pH: 7, totalVolume: 1.0);
      expect(dLarge.particleCountH2O, greaterThan(dSmall.particleCountH2O));
    });
  });
}
