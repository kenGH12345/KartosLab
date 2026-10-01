import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/atom_stability.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/atom_info_utils.dart';

void main() {
  group('AtomStability', () {
    test('empty nucleus is stable', () {
      expect(AtomStability.isNucleusStable(0, 0), isTrue);
    });

    test('stable isotopes match AtomInfoUtils', () {
      expect(AtomStability.isNucleusStable(1, 0), isTrue); // H-1
      expect(AtomStability.isNucleusStable(1, 1), isTrue); // H-2
      expect(AtomStability.isNucleusStable(2, 2), isTrue); // He-4
      expect(AtomStability.isNucleusStable(6, 6), isTrue); // C-12
    });

    test('unstable isotope', () {
      expect(AtomStability.isNucleusStable(1, 2), isFalse); // H-3 tritium
      expect(
        AtomStability.isNucleusStable(1, 2),
        AtomInfoUtils.isStable(1, 2),
      );
    });

    test('shared single source with IAAM', () {
      for (final z in [1, 2, 6, 8, 10]) {
        for (final n in [0, 1, 2, 6, 8, 10, 12]) {
          final a = AtomStability.isNucleusStable(z, n);
          final b = z + n == 0 ? true : AtomInfoUtils.isStable(z, n);
          expect(a, b, reason: 'Z=$z N=$n');
        }
      }
    });
  });
}
