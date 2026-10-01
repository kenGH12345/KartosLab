import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_math.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/strong_acid.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/strong_base.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/water.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/weak_acid.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/weak_base.dart';

/// Oracle A–E: chemistry from PhET TypeScript + `doc/model.md`.
void main() {
  group('Oracle A — Water', () {
    late Water water;

    setUp(() => water = Water());

    test('[H3O+] = sqrt(Kw) = 1e-7', () {
      expect(water.getH3OConcentration(), closeTo(1e-7, 1e-20));
    });

    test('[OH-] = [H3O+]', () {
      expect(
        water.getOHConcentration(),
        closeTo(water.getH3OConcentration(), 1e-20),
      );
    });

    test('[H2O] = W = 55.6', () {
      expect(water.getH2OConcentration(), AbsConstants.waterConcentration);
      expect(water.concentration, 55.6);
    });

    test('solute and product are 0', () {
      expect(water.getSoluteConcentration(), 0);
      expect(water.getProductConcentration(), 0);
    });

    test('pH = 7.00 after source rounding', () {
      expect(water.pH, 7);
    });

    test('strength is constant 0', () {
      expect(water.strength, 0);
      water.strength = 5;
      expect(water.strength, 0); // constrained to constant range
    });
  });

  group('Oracle B — Strong Acid', () {
    StrongAcid acidAt(double c) {
      final a = StrongAcid()..concentration = c;
      return a;
    }

    for (final c in [1e-3, 1e-2, 1e-1, 1.0]) {
      test('C=$c → [H3O+]=C, [A-]=C, [HA]=0', () {
        final a = acidAt(c);
        expect(a.getH3OConcentration(), closeTo(c, 1e-15));
        expect(a.getProductConcentration(), closeTo(c, 1e-15));
        expect(a.getSoluteConcentration(), 0);
        expect(
          a.getOHConcentration(),
          closeTo(AbsConstants.waterEquilibriumConstant / c, 1e-20),
        );
        expect(
          a.getH2OConcentration(),
          closeTo(AbsConstants.waterConcentration - c, 1e-12),
        );
      });
    }

    test('pH values match -log10(C) with source rounding', () {
      expect(acidAt(1e-3).pH, 3);
      expect(acidAt(1e-2).pH, 2);
      expect(acidAt(1e-1).pH, 1);
      expect(acidAt(1.0).pH, 0);
    });

    test('strength marker is 101 (constant)', () {
      final a = StrongAcid();
      expect(a.strength, AbsConstants.strongStrength);
      a.strength = 1e-7;
      expect(a.strength, AbsConstants.strongStrength);
    });
  });

  group('Oracle C — Strong Base', () {
    StrongBase baseAt(double c) {
      final b = StrongBase()..concentration = c;
      return b;
    }

    for (final c in [1e-3, 1e-2, 1e-1, 1.0]) {
      test('C=$c → [OH-]=C, [M+]=C, [MOH]=0', () {
        final b = baseAt(c);
        expect(b.getOHConcentration(), closeTo(c, 1e-15));
        expect(b.getProductConcentration(), closeTo(c, 1e-15));
        expect(b.getSoluteConcentration(), 0);
        expect(
          b.getH3OConcentration(),
          closeTo(AbsConstants.waterEquilibriumConstant / c, 1e-20),
        );
        expect(b.getH2OConcentration(), AbsConstants.waterConcentration);
      });
    }

    test('pH values', () {
      expect(baseAt(1e-3).pH, 11);
      expect(baseAt(1e-2).pH, 12);
      expect(baseAt(1e-1).pH, 13);
      expect(baseAt(1.0).pH, 14);
    });
  });

  group('Oracle D — Weak Acid quadratic', () {
    test('default Ka=1e-7, C=0.01 → pH=4.5', () {
      final a = WeakAcid();
      expect(a.strength, 1e-7);
      expect(a.concentration, 1e-2);
      final h3o = a.getH3OConcentration();
      final ka = 1e-7;
      final c = 1e-2;
      final expected = (-ka + math.sqrt(ka * ka + 4 * ka * c)) / 2;
      expect(h3o, closeTo(expected, 1e-18));
      expect(a.getProductConcentration(), closeTo(h3o, 1e-18));
      expect(a.getSoluteConcentration(), closeTo(c - h3o, 1e-18));
      expect(a.pH, 4.5);
    });

    test('low C / high Ka / boundary strengths', () {
      final a = WeakAcid()
        ..concentration = 1e-3
        ..strength = 1e-10;
      expect(a.getH3OConcentration(), greaterThan(0));
      expect(a.pH, inInclusiveRange(0, 14));

      a.concentration = 1;
      a.strength = 1e2;
      expect(a.getH3OConcentration(), greaterThan(0));
      expect(a.pH, inInclusiveRange(0, 14));
    });

    test('[OH-] = Kw / [H3O+]', () {
      final a = WeakAcid();
      expect(
        a.getOHConcentration(),
        closeTo(
          AbsConstants.waterEquilibriumConstant / a.getH3OConcentration(),
          1e-20,
        ),
      );
    });

    test('not the sqrt(Ka*C) approximation', () {
      final a = WeakAcid();
      final approx = math.sqrt(a.strength * a.concentration);
      expect(a.getH3OConcentration(), isNot(closeTo(approx, 1e-8)));
    });
  });

  group('Oracle E — Weak Base quadratic', () {
    test('default Kb=1e-7, C=0.01 → pH=9.5', () {
      final b = WeakBase();
      final kb = 1e-7;
      final c = 1e-2;
      final bh = (-kb + math.sqrt(kb * kb + 4 * kb * c)) / 2;
      expect(b.getProductConcentration(), closeTo(bh, 1e-18));
      expect(b.getOHConcentration(), closeTo(bh, 1e-18));
      expect(b.getSoluteConcentration(), closeTo(c - bh, 1e-18));
      expect(b.pH, 9.5);
    });

    test('strength and concentration sweeps stay in pH range', () {
      final b = WeakBase();
      for (final c in [1e-3, 1e-2, 0.5, 1.0]) {
        for (final k in [1e-10, 1e-7, 1e-3, 1e2]) {
          b.concentration = c;
          b.strength = k;
          expect(b.pH, inInclusiveRange(0, 14));
          expect(b.getOHConcentration(), greaterThan(0));
        }
      }
    });
  });

  group('pH rounding — AbsMath.pHFromH3O', () {
    test('exact powers of ten', () {
      expect(AbsMath.pHFromH3O(1), 0);
      expect(AbsMath.pHFromH3O(1e-7), 7);
      expect(AbsMath.pHFromH3O(1e-14), 14);
    });

    test('roundSymmetric half-away-from-zero', () {
      expect(AbsMath.roundSymmetric(1.5), 2);
      expect(AbsMath.roundSymmetric(2.5), 3);
      expect(AbsMath.roundSymmetric(-1.5), -2);
      expect(AbsMath.roundSymmetric(-2.5), -3);
    });
  });
}
