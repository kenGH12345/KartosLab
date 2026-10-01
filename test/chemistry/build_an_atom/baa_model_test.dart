import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/electron_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('BAAModel', () {
    test('initial state empty atom, full buckets', () {
      final m = BAAModel();
      expect(m.protonCount, 0);
      expect(m.neutronCount, 0);
      expect(m.electronCount, 0);
      expect(m.protonBucket.count, BAAConstants.maxProtons);
      expect(m.neutronBucket.count, BAAConstants.maxNeutrons);
      expect(m.electronBucket.count, BAAConstants.maxElectrons);
      expect(m.electronModel.type, ElectronModelType.shells);
    });

    test('particle limits locked', () {
      expect(BAAConstants.maxProtons, 10);
      expect(BAAConstants.maxNeutrons, 13);
      expect(BAAConstants.maxElectrons, 10);
    });

    test('addFromBucket updates derived quantities', () {
      final m = BAAModel();
      expect(m.addFromBucket(BaaParticleType.proton), isTrue);
      expect(m.protonCount, 1);
      expect(m.atomicNumber, 1);
      expect(m.massNumber, 1);
      expect(m.charge, 1);
      expect(m.protonBucket.count, BAAConstants.maxProtons - 1);

      m.addFromBucket(BaaParticleType.electron);
      expect(m.charge, 0);
      expect(m.electronCount, 1);
    });

    test('empty nucleus with electrons allowed', () {
      final m = BAAModel();
      m.addFromBucket(BaaParticleType.electron);
      m.addFromBucket(BaaParticleType.electron);
      expect(m.protonCount, 0);
      expect(m.electronCount, 2);
      expect(m.charge, -2);
      expect(m.nucleusStable, isTrue);
    });

    test('cannot exceed max protons', () {
      final m = BAAModel();
      for (var i = 0; i < BAAConstants.maxProtons; i++) {
        expect(m.addFromBucket(BaaParticleType.proton), isTrue);
      }
      expect(m.addFromBucket(BaaParticleType.proton), isFalse);
      expect(m.protonCount, BAAConstants.maxProtons);
    });

    test('drag ownership exclusive', () {
      final m = BAAModel();
      final p = m.protonBucket.particles.first;
      m.beginDrag(p);
      expect(m.protonBucket.contains(p), isFalse);
      expect(m.atom.contains(p), isFalse);
      expect(p.container, isNull);
      m.endDrag(p, 0, 0); // near nucleus
      expect(m.atom.contains(p), isTrue);
      expect(p.container, BaaParticleContainer.atom);
    });

    test('drag far returns to bucket', () {
      final m = BAAModel();
      final p = m.protonBucket.particles.first;
      m.beginDrag(p);
      m.endDrag(p, 500, 500);
      expect(m.atom.contains(p), isFalse);
      expect(m.protonBucket.contains(p), isTrue);
    });

    test('electron model switch keeps counts', () {
      final m = BAAModel();
      m.addFromBucket(BaaParticleType.proton);
      m.addFromBucket(BaaParticleType.electron);
      m.setElectronModel(ElectronModelType.cloud);
      expect(m.electronCount, 1);
      expect(m.protonCount, 1);
      m.setElectronModel(ElectronModelType.shells);
      expect(m.electronCount, 1);
    });

    test('reset restores empty atom and full buckets', () {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(3, 4, 2));
      m.setElectronModel(ElectronModelType.cloud);
      m.reset();
      expect(m.protonCount, 0);
      expect(m.neutronCount, 0);
      expect(m.electronCount, 0);
      expect(m.protonBucket.count, BAAConstants.maxProtons);
      expect(m.neutronBucket.count, BAAConstants.maxNeutrons);
      expect(m.electronBucket.count, BAAConstants.maxElectrons);
      expect(m.electronModel.type, ElectronModelType.shells);
    });

    test('setAtomConfiguration', () {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(2, 2, 2));
      expect(m.numberAtom, const NumberAtom(2, 2, 2));
    });

    test('inner shell refill when removing inner electron', () {
      final m = BAAModel();
      // Fill inner (2) + one outer
      for (var i = 0; i < 3; i++) {
        m.addFromBucket(BaaParticleType.electron);
      }
      expect(m.electronCount, 3);
      final inner = m.atom.electrons.firstWhere(
        (e) => e.electronShellIndex != null && e.electronShellIndex! < 2,
      );
      m.removeToBucket(inner);
      expect(m.electronCount, 2);
      // Remaining electrons should occupy inner shell (indices 0,1)
      final indices = m.atom.electrons.map((e) => e.electronShellIndex).toSet();
      expect(indices.every((i) => i != null && i < 2), isTrue);
    });
  });
}
