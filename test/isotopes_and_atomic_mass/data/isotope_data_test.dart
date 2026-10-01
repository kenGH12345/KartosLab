import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/data.dart';

void main() {
  final elements = ElementRepository.instance;
  final isotopes = IsotopeRepository.instance;

  group('ElementRepository Z=1..18', () {
    test('all 18 elements are queryable with correct Z/symbol', () {
      const expected = {
        1: 'H',
        2: 'He',
        3: 'Li',
        4: 'Be',
        5: 'B',
        6: 'C',
        7: 'N',
        8: 'O',
        9: 'F',
        10: 'Ne',
        11: 'Na',
        12: 'Mg',
        13: 'Al',
        14: 'Si',
        15: 'P',
        16: 'S',
        17: 'Cl',
        18: 'Ar',
      };

      final all = elements.getAll();
      expect(all.length, 18);
      for (final e in all) {
        expect(expected[e.atomicNumber], e.symbol);
        expect(e.protonCount, e.atomicNumber);
        expect(e.stableNeutronCounts, isNotEmpty);
        expect(e.standardAtomicMass, greaterThan(0));
      }
    });

    test('unknown Z returns null (no Hydrogen fallback)', () {
      expect(elements.getByAtomicNumber(0), isNull);
      expect(elements.getByAtomicNumber(19), isNull);
      expect(elements.getByAtomicNumber(-1), isNull);
    });
  });

  group('Default isotope (most common)', () {
    test('Hydrogen defaults to H-1 (0 neutrons), not H-2', () {
      final iso = elements.getDefaultIsotope(1)!;
      expect(iso.massNumber, 1);
      expect(iso.neutronCount, 0);
      expect(iso.symbol, 'H');
    });

    test('Helium defaults to He-4 (2 neutrons)', () {
      final iso = elements.getDefaultIsotope(2)!;
      expect(iso.massNumber, 4);
      expect(iso.neutronCount, 2);
    });

    test('Carbon defaults to C-12', () {
      final iso = elements.getDefaultIsotope(6)!;
      expect(iso.massNumber, 12);
      expect(iso.neutronCount, 6);
    });
  });

  group('Special isotopes H/C', () {
    test('H-1 / H-2 / H-3', () {
      final h1 = isotopes.find(1, 1)!;
      expect(h1.atomicMass, 1.00782503207);
      expect(h1.naturalAbundance, 0.999885);
      expect(h1.stable, isTrue);

      final h2 = isotopes.find(1, 2)!;
      expect(h2.atomicMass, 2.0141017778);
      expect(h2.naturalAbundance, 0.000115);
      expect(h2.stable, isTrue);

      final h3 = isotopes.find(1, 3)!;
      expect(h3.atomicMass, 3.0160492777);
      expect(h3.naturalAbundance, kTraceAbundance);
      expect(h3.isTraceAbundance, isTrue);
      expect(h3.stable, isFalse);
    });

    test('C-12 / C-13 / C-14', () {
      final c12 = isotopes.find(6, 12)!;
      expect(c12.atomicMass, 12.0);
      expect(c12.naturalAbundance, 0.9893);
      expect(c12.stable, isTrue);

      final c13 = isotopes.find(6, 13)!;
      expect(c13.atomicMass, 13.0033548378);
      expect(c13.naturalAbundance, 0.0107);
      expect(c13.stable, isTrue);

      final c14 = isotopes.find(6, 14)!;
      expect(c14.atomicMass, 14.003241989);
      expect(c14.naturalAbundance, kTraceAbundance);
      expect(c14.stable, isFalse);
    });
  });

  group('Stable isotope queries', () {
    test('stable list for H is H-1 and H-2 only', () {
      final stable = isotopes.getStableIsotopes(1);
      expect(stable.map((e) => e.massNumber).toList(), [1, 2]);
    });

    test('stable list for C is C-12 and C-13 only', () {
      final stable = isotopes.getStableIsotopes(6);
      expect(stable.map((e) => e.massNumber).toList(), [12, 13]);
    });

    test('Mixtures mass-sorted order for H', () {
      final sorted = isotopes.getStableIsotopesSortedByMass(1);
      expect(sorted.first.massNumber, 1);
      expect(sorted.last.massNumber, 2);
      expect(sorted.first.atomicMass, lessThan(sorted.last.atomicMass));
    });

    test('AtomInfoUtils.isStable matches table', () {
      expect(AtomInfoUtils.isStable(1, 0), isTrue);
      expect(AtomInfoUtils.isStable(1, 1), isTrue);
      expect(AtomInfoUtils.isStable(1, 2), isFalse);
      expect(AtomInfoUtils.isStable(6, 6), isTrue);
      expect(AtomInfoUtils.isStable(6, 8), isFalse);
    });
  });

  group('Natural abundance', () {
    test('raw abundances are non-negative', () {
      for (final entry in kIsotopeInfoTable) {
        expect(entry.abundance, greaterThanOrEqualTo(0));
      }
    });

    test('getNaturalAbundance rounds with toFixedNumber', () {
      // H-1 abundance 0.999885, 4 places → 0.9999
      final a4 = AtomInfoUtils.getNaturalAbundance(
        protonCount: 1,
        massNumber: 1,
        numDecimalPlaces: 4,
      );
      expect(a4, toFixedNumber(0.999885, 4));

      // Missing isotope → 0
      expect(
        AtomInfoUtils.getNaturalAbundance(
          protonCount: 1,
          massNumber: 99,
          numDecimalPlaces: 4,
        ),
        0,
      );
    });

    test('existsInTraceAmounts for H-3 and C-14', () {
      expect(
        AtomInfoUtils.existsInTraceAmounts(protonCount: 1, massNumber: 3),
        isTrue,
      );
      expect(
        AtomInfoUtils.existsInTraceAmounts(protonCount: 6, massNumber: 14),
        isTrue,
      );
      expect(
        AtomInfoUtils.existsInTraceAmounts(protonCount: 1, massNumber: 1),
        isFalse,
      );
    });
  });

  group('Standard atomic mass', () {
    test('H C O Cl Ar match shred standardMassTable', () {
      expect(AtomInfoUtils.getStandardAtomicMass(1), 1.00794);
      expect(AtomInfoUtils.getStandardAtomicMass(6), 12.0107);
      expect(AtomInfoUtils.getStandardAtomicMass(8), 15.9994);
      expect(AtomInfoUtils.getStandardAtomicMass(17), 35.453);
      expect(AtomInfoUtils.getStandardAtomicMass(18), 39.948);
    });

    test('out-of-range throws', () {
      expect(() => AtomInfoUtils.getStandardAtomicMass(99), throwsRangeError);
    });
  });

  group('Atomic mass vs mass number', () {
    test('atomicMass is never massNumber.toDouble()', () {
      final o16 = isotopes.find(8, 16)!;
      expect(o16.atomicMass, isNot(equals(16.0)));
      expect(o16.atomicMass, 15.99491461956);
    });

    test('unknown isotope mass returns -1', () {
      expect(AtomInfoUtils.getIsotopeAtomicMass(1, 99), -1);
      expect(AtomInfoUtils.getIsotopeAtomicMass(0, 0), -1);
    });
  });

  group('IsotopeId uniqueness', () {
    test('C-12 and C-13 are distinct', () {
      const c12 = IsotopeId(6, 12);
      const c13 = IsotopeId(6, 13);
      expect(c12 == c13, isFalse);
      expect(c12.neutronCount, 6);
      expect(c13.neutronCount, 7);
    });
  });

  group('Make + Mix element coverage', () {
    test('Make range Z<=10 all have default isotopes', () {
      for (var z = 1; z <= 10; z++) {
        expect(elements.getDefaultIsotope(z), isNotNull, reason: 'Z=$z');
      }
    });

    test('Mix range Z<=18 all have at least one stable isotope', () {
      for (var z = 1; z <= 18; z++) {
        expect(
          isotopes.getStableIsotopes(z),
          isNotEmpty,
          reason: 'Z=$z',
        );
      }
    });
  });

  group('Lookup unknown isotope', () {
    test('find returns null', () {
      expect(isotopes.find(6, 99), isNull);
      expect(isotopes.find(99, 12), isNull);
    });
  });
}
