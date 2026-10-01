import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('Mass number binding', () {
    test('A = protons + neutrons for matrix values', () {
      final cases = <NumberAtom>[
        const NumberAtom(0, 0, 0),
        const NumberAtom(1, 0, 1),
        const NumberAtom(1, 1, 1),
        const NumberAtom(2, 2, 2),
        const NumberAtom(6, 6, 6),
        NumberAtom(
          BAAConstants.maxProtons,
          BAAConstants.maxNeutrons,
          BAAConstants.maxElectrons,
        ),
      ];
      for (final a in cases) {
        expect(a.massNumber, a.protons + a.neutrons);
      }
    });

    test('model updates mass immediately on particle change', () {
      final m = BAAModel();
      expect(m.massNumber, 0);
      m.addFromBucket(BaaParticleType.proton);
      expect(m.massNumber, 1);
      m.addFromBucket(BaaParticleType.neutron);
      expect(m.massNumber, 2);
      m.addFromBucket(BaaParticleType.electron);
      expect(m.massNumber, 2); // electrons do not change A
    });

    test('neutron-only changes A not Z', () {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(1, 0, 1));
      expect(m.atomicNumber, 1);
      expect(m.massNumber, 1);
      m.addFromBucket(BaaParticleType.neutron);
      expect(m.atomicNumber, 1);
      expect(m.massNumber, 2);
    });
  });
}
