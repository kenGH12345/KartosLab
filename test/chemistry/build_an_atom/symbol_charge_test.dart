import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/charge_notation.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('Charge notation (signLast default)', () {
    test('zero / positive / negative', () {
      expect(formatChargeDisplay(0), '0');
      expect(formatChargeDisplay(1), '1+');
      expect(formatChargeDisplay(-1), '1\u2212');
      expect(formatChargeDisplay(2), '2+');
      expect(formatChargeDisplay(-2), '2\u2212');
    });

    test('signFirst alternative', () {
      expect(
        formatChargeDisplay(1, notation: ChargeNotation.signFirst),
        '+1',
      );
      expect(
        formatChargeDisplay(-1, notation: ChargeNotation.signFirst),
        '\u22121',
      );
    });

    test('ion charges from NumberAtom', () {
      expect(const NumberAtom(3, 0, 4).charge, -1);
      expect(formatChargeDisplay(const NumberAtom(3, 0, 4).charge), '1\u2212');
      expect(const NumberAtom(3, 0, 3).charge, 0);
      expect(formatChargeDisplay(const NumberAtom(3, 0, 3).charge), '0');
      expect(const NumberAtom(3, 0, 2).charge, 1);
      expect(formatChargeDisplay(const NumberAtom(3, 0, 2).charge), '1+');
    });

    test('charge text colors', () {
      expect(chargeTextColorValue(1), 0xFFD14600);
      expect(chargeTextColorValue(-1), 0xFF0000FF);
      expect(chargeTextColorValue(0), 0xFF000000);
    });
  });
}
