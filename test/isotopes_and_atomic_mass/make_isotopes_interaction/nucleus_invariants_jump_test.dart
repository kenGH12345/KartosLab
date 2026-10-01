import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/make_isotopes_model.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/nucleon_particle.dart';

void main() {
  group('Nucleus reconfigure', () {
    test('H / He / C / O proton+neutron counts match particles', () {
      void check(MakeIsotopesModel m) {
        expect(m.protons, hasLength(m.protonCount));
        expect(m.nucleusNeutrons, hasLength(m.neutronCount));
        expect(m.massNumber, m.protonCount + m.neutronCount);
        for (final p in m.protons) {
          expect(p.kind, NucleonKind.proton);
        }
      }

      final h = MakeIsotopesModel();
      check(h);
      expect(h.protons, hasLength(1));
      expect(h.nucleusNeutrons, isEmpty);

      final he = MakeIsotopesModel()..selectElement(2);
      check(he);
      expect(he.protons, hasLength(2));
      expect(he.nucleusNeutrons, hasLength(2));

      final c = MakeIsotopesModel()..selectElement(6);
      check(c);
      expect(c.protons, hasLength(6));
      expect(c.nucleusNeutrons, hasLength(6));

      final o = MakeIsotopesModel()..selectElement(8);
      check(o);
      expect(o.protons, hasLength(8));
      expect(o.nucleusNeutrons, hasLength(8));
    });

    test('N=0..several positions are deterministic', () {
      final m = MakeIsotopesModel()..selectElement(6);
      // Remove all nucleus neutrons then re-add
      while (m.removeNeutron()) {}
      expect(m.neutronCount, 0);
      final snap0 = _posSnap(m);

      m.addNeutron();
      final snap1 = _posSnap(m);
      m.addNeutron();
      final snap2 = _posSnap(m);

      final m2 = MakeIsotopesModel()..selectElement(6);
      while (m2.removeNeutron()) {}
      expect(_posSnap(m2), snap0);
      m2.addNeutron();
      expect(_posSnap(m2), snap1);
      m2.addNeutron();
      expect(_posSnap(m2), snap2);
    });

    test('reconfigure updates all nucleus destinations', () {
      final m = MakeIsotopesModel()..selectElement(6);
      final before = m.nucleusNeutrons.map((n) => n.id).toList();
      m.addNeutron();
      expect(m.nucleusNeutrons, hasLength(7));
      // Existing IDs still present (identity preserved for old nucleons)
      for (final id in before) {
        expect(m.nucleusNeutrons.any((n) => n.id == id), isTrue);
      }
      // All have finite positions near atom
      for (final n in [...m.protons, ...m.nucleusNeutrons]) {
        expect(n.x.isFinite, isTrue);
        expect(n.y.isFinite, isTrue);
        final d = math.sqrt(n.x * n.x + n.y * n.y);
        expect(d, lessThan(200));
      }
    });
  });

  group('Particle invariants', () {
    test('bucket + nucleus (+drag) = constant after init', () {
      final m = MakeIsotopesModel()..selectElement(6);
      final total = m.totalNeutronCount; // 6+4
      expect(total, 10);

      m.addNeutron();
      expect(m.totalNeutronCount, total);
      m.removeNeutron();
      expect(m.totalNeutronCount, total);

      final id = m.bucketNeutrons.first.id;
      m.beginDrag(id, 0, 0);
      expect(m.totalNeutronCount, total);
      m.updateDrag(50, 0);
      expect(m.totalNeutronCount, total);
      m.endDrag();
      expect(m.totalNeutronCount, total);

      m.beginDrag(m.nucleusNeutrons.first.id, 0, 0);
      m.updateDrag(500, 0);
      m.endDrag();
      expect(m.totalNeutronCount, total);
    });

    test('protonCount == protons.length always', () {
      final m = MakeIsotopesModel();
      for (final z in [1, 2, 6, 8, 10]) {
        m.selectElement(z);
        expect(m.protons, hasLength(z));
        expect(m.protonCount, z);
      }
    });

    test('element switch rebuilds particles', () {
      final m = MakeIsotopesModel();
      m.addNeutron();
      final oldProtonIds = m.protons.map((p) => p.id).toSet();
      final oldNeutronIds = {
        ...m.nucleusNeutrons.map((n) => n.id),
        ...m.bucketNeutrons.map((n) => n.id),
      };
      m.selectElement(6);
      final newProtonIds = m.protons.map((p) => p.id).toSet();
      final newNeutronIds = {
        ...m.nucleusNeutrons.map((n) => n.id),
        ...m.bucketNeutrons.map((n) => n.id),
      };
      expect(oldProtonIds.intersection(newProtonIds), isEmpty);
      expect(oldNeutronIds.intersection(newNeutronIds), isEmpty);
      expect(m.protons, hasLength(6));
      expect(m.nucleusNeutrons, hasLength(6));
      expect(m.bucketNeutrons, hasLength(4));
    });

    test('same-element reselect preserves particles', () {
      final m = MakeIsotopesModel()..selectElement(6);
      m.addNeutron();
      final neutronIds = m.nucleusNeutrons.map((n) => n.id).toList();
      final positions = _posSnap(m);
      m.selectElement(6);
      expect(m.nucleusNeutrons.map((n) => n.id).toList(), neutronIds);
      expect(_posSnap(m), positions);
      expect(m.neutronCount, 7);
    });
  });

  group('Unstable jump spatial', () {
    test('stable step does not move nucleons', () {
      final m = MakeIsotopesModel()..selectElement(6);
      final before = _posSnap(m);
      m.step(1.0);
      expect(m.nucleusOffsetX, 0);
      expect(m.nucleusOffsetY, 0);
      expect(_posSnap(m), before);
    });

    test('unstable step translates nucleus particles by offset delta', () {
      final m = MakeIsotopesModel();
      m.addNeutron();
      m.addNeutron(); // H-3 unstable
      expect(m.isUnstable, isTrue);

      final before = _posSnap(m);
      m.step(0.1);
      expect(m.nucleusOffsetX != 0 || m.nucleusOffsetY != 0, isTrue);

      final dx = m.nucleusOffsetX;
      final dy = m.nucleusOffsetY;
      final after = _posSnap(m);
      expect(after, hasLength(before.length));
      for (var i = 0; i < before.length; i++) {
        expect(after[i].x, closeTo(before[i].x + dx, 1e-9));
        expect(after[i].y, closeTo(before[i].y + dy, 1e-9));
      }

      // Next jump returns to zero → particles back
      m.step(0.1);
      expect(m.nucleusOffsetX, 0);
      expect(m.nucleusOffsetY, 0);
      expect(_posSnap(m), before);
    });

    test('becoming stable clears offset and restores base layout', () {
      final m = MakeIsotopesModel();
      m.addNeutron();
      m.addNeutron();
      m.step(0.1);
      expect(m.nucleusOffsetX != 0 || m.nucleusOffsetY != 0, isTrue);
      m.removeNeutron(); // H-2 stable
      expect(m.isStable, isTrue);
      expect(m.nucleusOffsetX, 0);
      expect(m.nucleusOffsetY, 0);
    });
  });

  group('Reset spatial', () {
    test('mutate drag jump then reset restores initial spatial state', () {
      final initial = MakeIsotopesModel();
      final initBucket = _bucketSnap(initial);
      final initProtons = _posSnap(initial);

      final m = MakeIsotopesModel();
      m.selectElement(6);
      m.addNeutron();
      final id = m.bucketNeutrons.first.id;
      m.beginDrag(id, 0, 0);
      m.updateDrag(30, 40);
      m.endDrag();
      m.addNeutron();
      m.addNeutron(); // may be unstable
      m.step(0.1);
      m.reset();

      expect(m.protonCount, 1);
      expect(m.neutronCount, 0);
      expect(m.bucketNeutronCount, 4);
      expect(m.nucleusOffsetX, 0);
      expect(m.nucleusOffsetY, 0);
      expect(m.isDragging, isFalse);
      expect(_bucketSnap(m), initBucket);
      expect(_posSnap(m), initProtons);
    });
  });
}

List<({double x, double y})> _posSnap(MakeIsotopesModel m) {
  return [
    for (final p in m.protons) (x: p.x, y: p.y),
    for (final n in m.nucleusNeutrons) (x: n.x, y: n.y),
  ];
}

List<({double x, double y})> _bucketSnap(MakeIsotopesModel m) {
  return [for (final n in m.bucketNeutrons) (x: n.x, y: n.y)];
}
