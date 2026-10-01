import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/interactivity_mode.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/mix_particle.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/mixtures_constants.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/mixtures_model.dart';

void main() {
  MixturesModel seeded() => MixturesModel(random: Random(42));

  group('Bucket spatial', () {
    test('initial bucket has 10 unique particles per isotope with stack slots',
        () {
      final m = seeded();
      expect(m.bucketParticles, hasLength(20)); // H-1 + H-2
      expect(m.getBucketCount(1), 10);
      expect(m.getBucketCount(2), 10);
      final ids = m.bucketParticles.map((p) => p.id).toSet();
      expect(ids, hasLength(20));
      for (final p in m.bucketParticles) {
        expect(p.container, MixParticleContainer.bucket);
        expect(p.radius, kLargeIsotopeRadius);
      }
      // Deterministic layout with same seed / firstOpen
      final m2 = seeded();
      for (var i = 0; i < m.bucketParticles.length; i++) {
        expect(m.bucketParticles[i].x, m2.bucketParticles[i].x);
        expect(m.bucketParticles[i].y, m2.bucketParticles[i].y);
      }
    });

    test('bucket → chamber preserves identity', () {
      final m = seeded();
      final id = m.bucketParticles.firstWhere((p) => p.massNumber == 1).id;
      expect(m.beginDrag(id, 0, 0), isTrue);
      expect(m.endDrag(), isTrue); // over chamber origin
      expect(m.chamberParticles.single.id, id);
      expect(m.chamberParticles.single.container, MixParticleContainer.chamber);
      expect(m.getIsotopeCount(1), 1);
      expect(m.getBucketCount(1), 9);
    });
  });

  group('Drag / drop', () {
    test('grab offset is 0; invalid drop returns to bucket', () {
      final m = seeded();
      final id = m.bucketParticles.first.id;
      final mass = m.bucketParticles.first.massNumber;
      m.beginDrag(id, 10, 20);
      expect(m.grabOffsetX, 0);
      expect(m.grabOffsetY, 0);
      m.updateDrag(500, 500); // outside chamber
      expect(m.endDrag(), isFalse);
      expect(m.getIsotopeCount(mass), 0);
      expect(m.bucketParticles.any((p) => p.id == id), isTrue);
    });

    test('chamber boundary: inside vs outside', () {
      final m = seeded();
      expect(m.isPositionInChamber(0, 0), isTrue);
      expect(m.isPositionInChamber(kTestChamberMaxX, 0), isTrue);
      expect(m.isPositionInChamber(kTestChamberMaxX + 1, 0), isFalse);
      expect(m.isPositionInChamber(0, kTestChamberMinY - 1), isFalse);
    });

    test('counts unchanged during updateDrag', () {
      final m = seeded();
      final id = m.bucketParticles.first.id;
      m.beginDrag(id, 0, 0);
      expect(m.totalIsotopeCount, 0);
      m.updateDrag(50, 50);
      expect(m.totalIsotopeCount, 0);
      m.endDrag();
      expect(m.totalIsotopeCount, 1);
    });
  });

  group('Mode switch spatial', () {
    test('bucket↔slider keep separate saved particle lists', () {
      final m = seeded();
      m.moveBucketToChamber(1);
      m.moveBucketToChamber(1);
      expect(m.getIsotopeCount(1), 2);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      expect(m.totalIsotopeCount, 0); // no prior slider save (PhET)
      expect(m.bucketParticles, isEmpty);
      m.setIsotopeQuantity(1, 5);
      expect(m.chamberParticles, hasLength(5));
      for (final p in m.chamberParticles) {
        expect(p.radius, kSmallIsotopeRadius);
      }
      m.setInteractivityMode(InteractivityMode.bucketsAndLargeAtoms);
      expect(m.getIsotopeCount(1), 2); // restored bucket mix
      expect(m.getBucketCount(1), 8);
      m.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      expect(m.getIsotopeCount(1), 5); // restored slider mix
    });
  });

  group('Nature spatial', () {
    test('generates particles matching Phase 5 counts; positions in chamber',
        () {
      final m = seeded()..setShowingNaturesMix(true);
      expect(m.chamberParticles, isNotEmpty);
      expect(m.bucketParticles, isEmpty);
      expect(m.totalIsotopeCount, m.chamberParticles.length);
      for (final p in m.chamberParticles) {
        expect(m.isPositionInChamber(p.x, p.y), isTrue);
        expect(p.radius, kSmallIsotopeRadius);
      }
    });

    test('My Mix ↔ Nature restores chamber particles', () {
      final m = seeded();
      m.moveBucketToChamber(1);
      final id = m.chamberParticles.single.id;
      m.setShowingNaturesMix(true);
      expect(m.chamberParticles.any((p) => p.id == id), isFalse);
      m.setShowingNaturesMix(false);
      expect(m.getIsotopeCount(1), 1);
      // New id after restore (PhET reuses same objects; we recreate from save)
      expect(m.chamberParticles, hasLength(1));
    });
  });

  group('Clear / Reset / Element / Drag lifecycle', () {
    test('clear empties chamber and refills buckets', () {
      final m = seeded();
      m.moveBucketToChamber(1);
      m.clearTestChamber();
      expect(m.chamberParticles, isEmpty);
      expect(m.getBucketCount(1), 10);
      expect(m.isDragging, isFalse);
    });

    test('reset clears drag and restores initial spatial', () {
      final m = seeded();
      final id = m.bucketParticles.first.id;
      m.beginDrag(id, 0, 0);
      m.selectElement(6);
      m.setIsotopeQuantity(12, 5);
      m.setShowingNaturesMix(true);
      m.reset();
      expect(m.selectedAtomicNumber, 1);
      expect(m.chamberParticles, isEmpty);
      expect(m.bucketParticles, hasLength(20));
      expect(m.isDragging, isFalse);
    });

    test('element switch cancels drag and clears C particles', () {
      final m = seeded()..selectElement(6);
      final id = m.bucketParticles.first.id;
      m.beginDrag(id, 0, 0);
      m.selectElement(8);
      expect(m.isDragging, isFalse);
      expect(m.chamberParticles, isEmpty);
      expect(
        m.bucketParticles.every((p) => p.massNumber == 16 ||
            p.massNumber == 17 ||
            p.massNumber == 18),
        isTrue,
      );
    });

    test('same Z reselect preserves chamber particles', () {
      final m = seeded();
      m.moveBucketToChamber(1);
      final id = m.chamberParticles.single.id;
      m.selectElement(1);
      expect(m.chamberParticles.single.id, id);
    });
  });

  group('Slider quantity spatial', () {
    test('increase/decrease adds/removes particles', () {
      final m = seeded()
        ..setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      m.setIsotopeQuantity(1, 3);
      expect(m.chamberParticles, hasLength(3));
      m.setIsotopeQuantity(1, 1);
      expect(m.chamberParticles, hasLength(1));
      m.setIsotopeQuantity(1, 0);
      expect(m.chamberParticles, isEmpty);
    });
  });
}
