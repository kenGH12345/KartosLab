import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/particle_atom.dart';

void main() {
  group('ParticleAtom', () {
    test('shell slot count is 10', () {
      final atom = ParticleAtom();
      expect(atom.electronShellSlots.length, BAAConstants.numElectronPositions);
    });

    test('derived quantities', () {
      final atom = ParticleAtom();
      atom.addParticle(BaaParticle(id: 1, type: BaaParticleType.proton));
      atom.addParticle(BaaParticle(id: 2, type: BaaParticleType.neutron));
      atom.addParticle(BaaParticle(id: 3, type: BaaParticleType.electron));
      expect(atom.atomicNumber, 1);
      expect(atom.massNumber, 2);
      expect(atom.charge, 0);
    });

    test('nucleus packing places nucleons at destinations', () {
      final atom = ParticleAtom();
      final p1 = BaaParticle(id: 1, type: BaaParticleType.proton);
      final p2 = BaaParticle(id: 2, type: BaaParticleType.proton);
      atom.addParticle(p1);
      atom.addParticle(p2);
      expect(p1.destX != 0 || p1.destY != 0 || p2.destX != 0 || p2.destY != 0,
          isTrue);
    });

    test('radii constants', () {
      expect(BAAConstants.nucleonRadius, 10);
      expect(BAAConstants.electronRadius, 8);
      expect(BAAConstants.outerElectronShellRadius, 130);
      expect(BAAConstants.electronCaptureRadius, closeTo(143, 0.001));
    });
  });
}
