import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('Element symbol from shared tables', () {
    test('Z mapping', () {
      expect(const NumberAtom(0, 0, 0).symbol, '-');
      expect(const NumberAtom(1, 0, 1).symbol, 'H');
      expect(const NumberAtom(2, 2, 2).symbol, 'He');
      expect(const NumberAtom(6, 6, 6).symbol, 'C');
      expect(const NumberAtom(8, 8, 8).symbol, 'O');
    });

    test('neutrons/electrons do not change symbol', () {
      expect(const NumberAtom(1, 0, 0).symbol, 'H');
      expect(const NumberAtom(1, 2, 0).symbol, 'H');
      expect(const NumberAtom(1, 0, 2).symbol, 'H');
    });

    test('atomic number = proton count', () {
      for (final z in [0, 1, 2, 6, 10]) {
        expect(NumberAtom(z, 0, 0).atomicNumber, z);
      }
    });
  });
}
