import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/model/force_notation.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';

void main() {
  group('Force Values Display', () {
    test('default DECIMAL → showForceValues true', () {
      final m = GravityForceLabModel();
      expect(m.forceValuesDisplay, ForceValuesDisplay.decimal);
      expect(m.showForceValues, isTrue);
    });

    test('SCIENTIFIC → showForceValues true', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      expect(m.showForceValues, isTrue);
    });

    test('HIDDEN → showForceValues false; force unchanged', () {
      final m = GravityForceLabModel();
      final f = m.force;
      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      expect(m.showForceValues, isFalse);
      expect(m.force, f);
      expect(m.distance, 4);
    });

    test('decimal format: 12 places with spaced groups', () {
      final f = 1.66852e-7;
      final s = ForceNotationFormatter.formatDecimal(f);
      // toStringAsFixed(12) then group after first 3 decimals
      expect(s.contains('.'), isTrue);
      expect(s.contains(' '), isTrue);
      expect(s.startsWith('0.000'), isTrue);
    });

    test('scientific format: mantissa × 10^exp', () {
      final s = ForceNotationFormatter.formatScientific(1.66852e-7);
      expect(s.contains('×'), isTrue);
      expect(s.contains('10^'), isTrue);
      final notation =
          ForceNotationFormatter.toScientificNotation(1.66852e-7, mantissaDecimalPlaces: 2);
      expect(notation.mantissa, '1.67');
      expect(notation.exponent, '-7');
    });

    test('labels: decimal / scientific / hidden', () {
      const f = 1.66852e-7;
      final dec = ForceNotationFormatter.formatForceLabel(
        forceAbs: f,
        display: ForceValuesDisplay.decimal,
        thisObject: 'm1',
        otherObject: 'm2',
      );
      expect(dec.startsWith('Force on m1 by m2 = '), isTrue);
      expect(dec.endsWith(' N'), isTrue);

      final sci = ForceNotationFormatter.formatForceLabel(
        forceAbs: f,
        display: ForceValuesDisplay.scientific,
        thisObject: 'm1',
        otherObject: 'm2',
      );
      expect(sci.contains('× 10^'), isTrue);
      expect(sci.endsWith(' N'), isTrue);

      final hid = ForceNotationFormatter.formatForceLabel(
        forceAbs: f,
        display: ForceValuesDisplay.hidden,
        thisObject: 'm1',
        otherObject: 'm2',
      );
      expect(hid, 'Force on m1 by m2');
      expect(hid.contains('='), isFalse);
    });

    test('notation change does not alter physics', () {
      final m = GravityForceLabModel();
      final f0 = m.force;
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      m.setForceValuesDisplay(ForceValuesDisplay.decimal);
      expect(m.force, f0);
      expect(m.mass1.positionX, -3);
      expect(m.mass2.positionX, 1);
    });
  });
}
