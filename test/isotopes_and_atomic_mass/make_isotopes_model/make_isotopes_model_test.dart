import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/data.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/make_isotopes_constants.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/make_isotopes_model.dart';

void main() {
  group('Initial state', () {
    test('defaults to Hydrogen-1 with 4 bucket neutrons', () {
      final m = MakeIsotopesModel();
      expect(m.protonCount, 1);
      expect(m.selectedElement.symbol, 'H');
      expect(m.neutronCount, 0); // most common for H
      expect(m.bucketNeutronCount, kDefaultNeutronsInBucket);
      expect(m.massNumber, 1);
      expect(m.electronCount, 1);
      expect(m.currentIsotope, isNotNull);
      expect(m.currentIsotope!.massNumber, 1);
      expect(m.atomicMass, 1.00782503207);
      expect(m.naturalAbundance, 0.999885);
      expect(m.isStable, isTrue);
      expect(m.totalNeutronCount, 4);
    });
  });

  group('Element selection', () {
    test('select C resets to C-12 and refills bucket', () {
      final m = MakeIsotopesModel();
      m.addNeutron();
      m.selectElement(6);
      expect(m.protonCount, 6);
      expect(m.neutronCount, 6); // most common
      expect(m.massNumber, 12);
      expect(m.bucketNeutronCount, 4);
      expect(m.currentIsotope!.symbol, 'C');
      expect(m.isStable, isTrue);
    });

    test('select He / O / Ne', () {
      final m = MakeIsotopesModel();

      m.selectElement(2);
      expect(m.neutronCount, 2);
      expect(m.massNumber, 4);

      m.selectElement(8);
      expect(m.neutronCount, 8);
      expect(m.massNumber, 16);

      m.selectElement(10);
      expect(m.neutronCount, 10);
      expect(m.massNumber, 20);
    });

    test('selecting same element does not reset neutrons', () {
      final m = MakeIsotopesModel();
      expect(m.addNeutron(), isTrue);
      expect(m.neutronCount, 1);
      m.selectElement(1);
      expect(m.neutronCount, 1);
      expect(m.bucketNeutronCount, 3);
    });

    test('Z out of Make range throws', () {
      final m = MakeIsotopesModel();
      expect(() => m.selectElement(0), throwsRangeError);
      expect(() => m.selectElement(11), throwsRangeError);
      expect(() => m.selectElement(18), throwsRangeError);
    });

    test('element change never leaves stale H isotope', () {
      final m = MakeIsotopesModel();
      m.selectElement(6);
      expect(m.currentIsotope!.atomicNumber, 6);
      expect(m.protonCount, 6);
    });
  });

  group('Neutron add / remove', () {
    test('add moves bucket → nucleus', () {
      final m = MakeIsotopesModel();
      expect(m.addNeutron(), isTrue); // H-1 → H-2
      expect(m.neutronCount, 1);
      expect(m.massNumber, 2);
      expect(m.bucketNeutronCount, 3);
      expect(m.totalNeutronCount, 4);
      expect(m.currentIsotope!.massNumber, 2);
      expect(m.isStable, isTrue);
    });

    test('add until bucket empty then fails', () {
      final m = MakeIsotopesModel();
      for (var i = 0; i < 4; i++) {
        expect(m.addNeutron(), isTrue);
      }
      expect(m.bucketNeutronCount, 0);
      expect(m.neutronCount, 4); // H with 4 neutrons = H-5 (not in table)
      expect(m.addNeutron(), isFalse);
      expect(m.massNumber, 5);
      expect(m.currentIsotope, isNull);
      expect(m.atomicMass, -1);
      expect(m.naturalAbundance, 0);
      expect(m.isStable, isFalse);
    });

    test('remove down to zero then fails', () {
      final m = MakeIsotopesModel();
      m.selectElement(6); // C-12, N=6
      for (var i = 0; i < 6; i++) {
        expect(m.removeNeutron(), isTrue);
      }
      expect(m.neutronCount, 0);
      expect(m.massNumber, 6);
      expect(m.removeNeutron(), isFalse);
      expect(m.bucketNeutronCount, 10); // 4 + 6
    });

    test('H-1 → H-2 → H-3 → unstable', () {
      final m = MakeIsotopesModel();
      m.addNeutron(); // H-2 stable
      expect(m.isStable, isTrue);
      m.addNeutron(); // H-3 unstable + trace
      expect(m.massNumber, 3);
      expect(m.isStable, isFalse);
      expect(m.existsInTraceAmounts, isTrue);
      expect(m.naturalAbundance, kTraceAbundance);
    });
  });

  group('Isotope resolution', () {
    test('C-12 / C-13 / C-14', () {
      final m = MakeIsotopesModel()..selectElement(6);
      expect(m.massNumber, 12);
      expect(m.atomicMass, 12.0);
      expect(m.isStable, isTrue);

      m.addNeutron(); // C-13
      expect(m.massNumber, 13);
      expect(m.atomicMass, 13.0033548378);
      expect(m.isStable, isTrue);

      m.addNeutron(); // C-14
      expect(m.massNumber, 14);
      expect(m.atomicMass, 14.003241989);
      expect(m.isStable, isFalse);
      expect(m.existsInTraceAmounts, isTrue);
    });

    test('invariants always hold', () {
      final m = MakeIsotopesModel();
      void check() {
        expect(m.protonCount, m.selectedElement.atomicNumber);
        expect(m.massNumber, m.protonCount + m.neutronCount);
        final iso = m.currentIsotope;
        if (iso != null) {
          expect(iso.atomicNumber, m.protonCount);
          expect(iso.massNumber, m.massNumber);
        }
      }

      check();
      m.selectElement(8);
      check();
      m.addNeutron();
      check();
      m.removeNeutron();
      check();
      m.selectElement(10);
      while (m.addNeutron()) {}
      check();
    });
  });

  group('Capture radius', () {
    test('distance < 100 captures; >= 100 does not', () {
      final m = MakeIsotopesModel();
      expect(m.canCaptureNeutronAtDistance(99.9), isTrue);
      expect(m.canCaptureNeutronAtDistance(100), isFalse);
      // 60²+80²=10000 → distance 100 → not captured (strict <)
      expect(m.canCaptureNeutronAtOffset(60, 80), isFalse);
      expect(m.canCaptureNeutronAtOffset(0, 0), isTrue);
      expect(m.canCaptureNeutronAtOffset(30, 40), isTrue); // distance 50
    });

    test('placeNeutronAtDistance after beginDragFromBucket', () {
      final m = MakeIsotopesModel();
      expect(m.beginDragFromBucket(), isTrue);
      expect(m.bucketNeutronCount, 3);
      expect(m.placeNeutronAtDistance(50), isTrue);
      expect(m.neutronCount, 1);
      expect(m.massNumber, 2);
    });

    test('place outside capture returns to bucket', () {
      final m = MakeIsotopesModel();
      expect(m.beginDragFromNucleus(), isFalse); // H has 0 nucleus neutrons
      m.addNeutron();
      expect(m.beginDragFromNucleus(), isTrue);
      expect(m.neutronCount, 0);
      expect(m.placeNeutronAtDistance(150), isFalse);
      expect(m.bucketNeutronCount, 4);
      expect(m.neutronCount, 0);
    });
  });

  group('Unstable jump', () {
    test('step moves offset when unstable; resets when becoming stable', () {
      final m = MakeIsotopesModel();
      m.addNeutron();
      m.addNeutron(); // H-3 unstable
      expect(m.isUnstable, isTrue);

      m.step(0.1);
      final jumped =
          m.nucleusOffsetX != 0 || m.nucleusOffsetY != 0;
      expect(jumped, isTrue);

      m.removeNeutron(); // back to H-2 stable
      expect(m.isStable, isTrue);
      expect(m.nucleusOffsetX, 0);
      expect(m.nucleusOffsetY, 0);
    });

    test('step is no-op when stable', () {
      final m = MakeIsotopesModel();
      m.step(1.0);
      expect(m.nucleusOffsetX, 0);
      expect(m.nucleusOffsetY, 0);
    });
  });

  group('Reset', () {
    test('heavy mutation then reset equals initial', () {
      final initial = MakeIsotopesModel().snapshot();
      final m = MakeIsotopesModel();
      m.selectElement(6);
      m.addNeutron();
      m.addNeutron();
      m.selectElement(8);
      while (m.addNeutron()) {}
      m.selectElement(10);
      m.removeNeutron();
      m.reset();
      expect(m.snapshot(), initial);
    });

    test('reset while still on Hydrogen restores most-common neutrons', () {
      final m = MakeIsotopesModel();
      while (m.addNeutron()) {}
      expect(m.neutronCount, 4);
      m.reset();
      expect(m.protonCount, 1);
      expect(m.neutronCount, 0);
      expect(m.bucketNeutronCount, 4);
    });
  });

  group('Atomic mass never equals massNumber.toDouble()', () {
    test('O-16', () {
      final m = MakeIsotopesModel()..selectElement(8);
      expect(m.massNumber, 16);
      expect(m.atomicMass, isNot(16.0));
      expect(m.atomicMass, 15.99491461956);
    });
  });

  group('Jump angle constants match PhET', () {
    test('PI multiples', () {
      expect(kJumpAngles[0], closeTo(math.pi * 0.1, 1e-12));
      expect(kJumpAngles[1], closeTo(math.pi * 1.6, 1e-12));
    });
  });
}
