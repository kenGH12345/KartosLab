import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('NumberAtom', () {
    test('0/0/0 empty atom', () {
      const a = NumberAtom(0, 0, 0);
      expect(a.atomicNumber, 0);
      expect(a.massNumber, 0);
      expect(a.charge, 0);
      expect(a.nucleusStable, isTrue);
      expect(a.symbol, '-');
      expect(a.elementNameEnglish, '');
      expect(a.element, isNull);
    });

    test('Hydrogen 1/0/1', () {
      const a = NumberAtom(1, 0, 1);
      expect(a.atomicNumber, 1);
      expect(a.massNumber, 1);
      expect(a.charge, 0);
      expect(a.nucleusStable, isTrue);
      expect(a.symbol, 'H');
      expect(a.elementDisplayName, 'Hydrogen');
    });

    test('Helium 2/2/2', () {
      const a = NumberAtom(2, 2, 2);
      expect(a.massNumber, 4);
      expect(a.charge, 0);
      expect(a.symbol, 'He');
    });

    test('Carbon 6/6/6', () {
      const a = NumberAtom(6, 6, 6);
      expect(a.atomicNumber, 6);
      expect(a.massNumber, 12);
      expect(a.charge, 0);
    });

    test('ion charge = p - e', () {
      const a = NumberAtom(1, 0, 0);
      expect(a.charge, 1);
      const b = NumberAtom(1, 0, 2);
      expect(b.charge, -1);
    });

    test('empty nucleus with electrons is legal', () {
      const a = NumberAtom(0, 0, 2);
      expect(a.atomicNumber, 0);
      expect(a.charge, -2);
      expect(a.nucleusStable, isTrue);
    });
  });
}
