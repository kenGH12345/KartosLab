import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/data.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/interactivity_mode.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/mixtures_constants.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/mixtures_model.dart';

void main() {
  group('Initial state', () {
    test('defaults to Hydrogen, bucket mode, My Mix, empty chamber', () {
      final m = MixturesModel();
      expect(m.selectedAtomicNumber, 1);
      expect(m.selectedElement.symbol, 'H');
      expect(m.interactivityMode, InteractivityMode.bucketsAndLargeAtoms);
      expect(m.showingNaturesMix, isFalse);
      expect(m.totalIsotopeCount, 0);
      expect(m.chamberAverageAtomicMass, 0);
      expect(m.displayedAverageAtomicMass, 0);
      // H stable: H-1, H-2 sorted by mass
      expect(m.possibleIsotopes.map((i) => i.massNumber), [1, 2]);
      expect(m.getBucketCount(1), kNumLargeIsotopesPerBucket);
      expect(m.getBucketCount(2), kNumLargeIsotopesPerBucket);
    });
  });

  group('Element selection', () {
    test('C / O / Cl / Ar update stable isotope lists', () {
      final m = MixturesModel();

      m.selectElement(6);
      expect(m.possibleIsotopes.map((i) => i.massNumber), [12, 13]);

      m.selectElement(8);
      expect(m.possibleIsotopes.map((i) => i.massNumber), [16, 17, 18]);

      m.selectElement(17);
      expect(m.possibleIsotopes, isNotEmpty);
      expect(m.selectedAtomicNumber, 17);

      m.selectElement(18);
      expect(m.selectedAtomicNumber, 18);
    });

    test('Z out of Mix range throws', () {
      final m = MixturesModel();
      expect(() => m.selectElement(0), throwsRangeError);
      expect(() => m.selectElement(19), throwsRangeError);
    });

    test('same Z reselect is no-op (keeps mixture)', () {
      final m = MixturesModel();
      m.moveBucketToChamber(1);
      m.moveBucketToChamber(1);
      expect(m.getIsotopeCount(1), 2);
      m.selectElement(1);
      expect(m.getIsotopeCount(1), 2);
    });

    test('switching element saves and restores My Mix', () {
      final m = MixturesModel();
      m.moveBucketToChamber(1);
      m.moveBucketToChamber(1); // 2× H-1
      m.selectElement(6);
      expect(m.totalIsotopeCount, 0);
      m.moveBucketToChamber(12);
      expect(m.getIsotopeCount(12), 1);
      m.selectElement(1);
      expect(m.getIsotopeCount(1), 2);
      expect(m.getIsotopeCount(12), 0);
    });
  });

  group('Bucket mode counts', () {
    test('move bucket↔chamber respects max 10 stock', () {
      final m = MixturesModel();
      for (var i = 0; i < 10; i++) {
        expect(m.moveBucketToChamber(1), isTrue);
      }
      expect(m.getIsotopeCount(1), 10);
      expect(m.getBucketCount(1), 0);
      expect(m.moveBucketToChamber(1), isFalse);

      expect(m.moveChamberToBucket(1), isTrue);
      expect(m.getIsotopeCount(1), 9);
      expect(m.getBucketCount(1), 1);
    });
  });

  group('Slider mode', () {
    test('quantity 0..100; 101 clamps to 100', () {
      final m = MixturesModel();
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      expect(m.setIsotopeQuantity(1, 0), isTrue);
      expect(m.getIsotopeCount(1), 0);
      expect(m.setIsotopeQuantity(1, 1), isTrue);
      expect(m.getIsotopeCount(1), 1);
      expect(m.setIsotopeQuantity(1, 99), isTrue);
      expect(m.getIsotopeCount(1), 99);
      expect(m.setIsotopeQuantity(1, 100), isTrue);
      expect(m.getIsotopeCount(1), 100);
      expect(m.setIsotopeQuantity(1, 101), isTrue);
      expect(m.getIsotopeCount(1), 100);
    });

    test('bucket↔slider mode saves separate mixtures', () {
      final m = MixturesModel();
      m.moveBucketToChamber(1);
      m.moveBucketToChamber(1); // bucket mode: 2
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      expect(m.totalIsotopeCount, 0); // no prior slider save
      m.setIsotopeQuantity(1, 50);
      m.setInteractivityMode(InteractivityMode.bucketsAndLargeAtoms);
      expect(m.getIsotopeCount(1), 2); // restored bucket mix
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      expect(m.getIsotopeCount(1), 50);
    });
  });

  group('Percent composition', () {
    test('single / 50-50 / 1:3', () {
      final m = MixturesModel()..selectElement(6);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);

      m.setIsotopeQuantity(12, 10);
      expect(m.getIsotopeProportion(12), 1.0);
      expect(m.getIsotopeProportion(13), 0.0);

      m.setIsotopeQuantity(12, 5);
      m.setIsotopeQuantity(13, 5);
      expect(m.getIsotopeProportion(12), 0.5);
      expect(m.getIsotopeProportion(13), 0.5);

      m.setIsotopeQuantity(12, 1);
      m.setIsotopeQuantity(13, 3);
      expect(m.getIsotopeProportion(12), 0.25);
      expect(m.getIsotopeProportion(13), 0.75);
    });

    test('empty mixture proportions are 0', () {
      final m = MixturesModel();
      expect(m.getIsotopeProportion(1), 0);
    });
  });

  group('Average atomic mass', () {
    test('single isotope equals table mass', () {
      final m = MixturesModel()..selectElement(6);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      m.setIsotopeQuantity(12, 10);
      expect(m.chamberAverageAtomicMass, 12.0);
      expect(m.displayedAverageAtomicMass, 12.0);
    });

    test('two-isotope weighted average', () {
      final m = MixturesModel()..selectElement(6);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      final c12 = m.possibleIsotopes.firstWhere((i) => i.massNumber == 12);
      final c13 = m.possibleIsotopes.firstWhere((i) => i.massNumber == 13);
      m.setIsotopeQuantity(12, 1);
      m.setIsotopeQuantity(13, 1);
      final expected = (c12.atomicMass + c13.atomicMass) / 2;
      expect(m.chamberAverageAtomicMass, closeTo(expected, 1e-12));
    });

    test('empty chamber average is 0', () {
      expect(MixturesModel().chamberAverageAtomicMass, 0);
    });
  });

  group("Nature's Mix", () {
    test('activates counts with min-1 and uses standard mass for display', () {
      final m = MixturesModel();
      m.setShowingNaturesMix(true);
      expect(m.showingNaturesMix, isTrue);
      expect(m.totalIsotopeCount, greaterThan(0));
      // H: abundances ~0.999885 and 0.000115 → roundSymmetric
      final h1 = m.getIsotopeCount(1);
      final h2 = m.getIsotopeCount(2);
      expect(h1 + h2, greaterThanOrEqualTo(kNumNaturesMixAtoms));
      expect(h1, greaterThan(0));
      expect(h2, greaterThan(0));
      expect(
        m.displayedAverageAtomicMass,
        AtomInfoUtils.getStandardAtomicMass(1),
      );
      expect(m.displayedAverageAtomicMass, isNot(m.chamberAverageAtomicMass));
    });

    test('force min 1 for trace-ish isotopes (Cl has uneven abundances)', () {
      final m = MixturesModel()..selectElement(17);
      m.setShowingNaturesMix(true);
      for (final iso in m.possibleIsotopes) {
        expect(m.getIsotopeCount(iso.massNumber), greaterThanOrEqualTo(1));
      }
    });

    test('switching back restores My Mix', () {
      final m = MixturesModel();
      m.moveBucketToChamber(1);
      m.moveBucketToChamber(1);
      m.setShowingNaturesMix(true);
      expect(m.getIsotopeCount(1), isNot(2));
      m.setShowingNaturesMix(false);
      expect(m.getIsotopeCount(1), 2);
      expect(m.showingNaturesMix, isFalse);
    });

    test('clear throws while Nature showing', () {
      final m = MixturesModel()..setShowingNaturesMix(true);
      expect(m.clearTestChamber, throwsStateError);
    });
  });

  group('Clear / Reset', () {
    test('clear empties chamber and deletes saved state', () {
      final m = MixturesModel();
      m.moveBucketToChamber(1);
      m.clearTestChamber();
      expect(m.totalIsotopeCount, 0);
      expect(m.getBucketCount(1), 10);
      // Switch away and back — should not restore
      m.moveBucketToChamber(1);
      m.selectElement(6);
      m.selectElement(1);
      // After clear deleted save, then we added 1, then switched — that 1 was saved
      expect(m.getIsotopeCount(1), 1);
    });

    test('reset returns to initial Hydrogen My Mix', () {
      final initial = MixturesModel().snapshot();
      final m = MixturesModel();
      m.selectElement(8);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      m.setIsotopeQuantity(16, 40);
      m.setShowingNaturesMix(true);
      m.setShowingNaturesMix(false);
      m.reset();
      expect(m.snapshot(), initial);
    });
  });

  group('Invariants', () {
    test('chamber never holds isotopes of other elements', () {
      final m = MixturesModel()..selectElement(6);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      m.setIsotopeQuantity(12, 5);
      m.setIsotopeQuantity(16, 5); // not possible for C
      expect(m.getIsotopeCount(16), 0);
      expect(m.getIsotopeCount(12), 5);
    });
  });
}
