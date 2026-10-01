import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/ohms_law/model/current_units.dart';
import 'package:kratos/ohms_law/model/ohms_law_constants.dart';
import 'package:kratos/ohms_law/model/ohms_law_model.dart';
import 'package:kratos/ohms_law/model/ohms_law_property.dart';

/// Oracle suite locked to PhET Ohm's Law 1.5.0-dev.6 `OhmsLawModel.js`.
void main() {
  group('ohms_law_model_defaults_test', () {
    test('O1 default V/R/I and units', () {
      final model = OhmsLawModel();
      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.milliamps);
      expect(model.currentUnitsName, 'MILLIAMPS');
      expect(model.getFixedCurrent(), '9.0');
      model.dispose();
    });

    test('default_current_test: 1000 * 4.5 / 500 == 9.0', () {
      expect(OhmsLawModel.computeCurrent(4.5, 500), 9.0);
      final model = OhmsLawModel();
      expect(model.currentProperty.value, 9.0);
      model.dispose();
    });
  });

  group('ohms_law_voltage_range_test', () {
    test('range and default match source RangeWithValue(0.1, 9, 4.5)', () {
      expect(OhmsLawConstants.voltageRange.min, 0.1);
      expect(OhmsLawConstants.voltageRange.max, 9.0);
      expect(OhmsLawConstants.voltageRange.defaultValue, 4.5);
      final model = OhmsLawModel();
      expect(model.voltageProperty.range.min, 0.1);
      expect(model.voltageProperty.range.max, 9.0);
      model.dispose();
    });
  });

  group('ohms_law_resistance_range_test', () {
    test('range and default match source RangeWithValue(10, 1000, 500)', () {
      expect(OhmsLawConstants.resistanceRange.min, 10.0);
      expect(OhmsLawConstants.resistanceRange.max, 1000.0);
      expect(OhmsLawConstants.resistanceRange.defaultValue, 500.0);
      final model = OhmsLawModel();
      expect(model.resistanceProperty.range.min, 10.0);
      expect(model.resistanceProperty.range.max, 1000.0);
      model.dispose();
    });
  });

  group('ohms_law_current_formula_test', () {
    test('O2–O7 oracle matrix (mA = 1000*V/R)', () {
      const cases = <(double v, double r, double iMa)>[
        (4.5, 500, 9.0), // O1 / default
        (0.1, 1000, 0.1), // O2 low V + high R → min I
        (9.0, 10, 900.0), // O3/O4 high V + low R → max I
        (0.1, 10, 10.0), // O2 low V + low R
        (9.0, 1000, 9.0), // O3/O5 high V + high R
        (1.0, 100, 10.0), // O6
        (2.5, 250, 10.0), // O7
        (6.0, 200, 30.0),
        (3.0, 750, 4.0),
      ];
      for (final (v, r, expected) in cases) {
        expect(
          OhmsLawModel.computeCurrent(v, r),
          expected,
          reason: 'V=$v R=$r',
        );
        final model = OhmsLawModel()
          ..voltage = v
          ..resistance = r;
        expect(model.current, expected, reason: 'model V=$v R=$r');
        model.dispose();
      }
    });

    test('static min/max current', () {
      expect(OhmsLawModel.getMinCurrent(), 0.1);
      expect(OhmsLawModel.getMaxCurrent(), 900.0);
    });

    test('must not use bare V/R as mA', () {
      // Bare V/R at defaults is 0.009 A — must NOT equal currentProperty.
      expect(4.5 / 500, 0.009);
      expect(OhmsLawModel.computeCurrent(4.5, 500), isNot(0.009));
      expect(OhmsLawModel.computeCurrent(4.5, 500), 9.0);
    });
  });

  group('ohms_law_current_reactivity_test', () {
    test('voltage_reactivity_test', () {
      final model = OhmsLawModel();
      final baseline = model.current;
      expect(baseline, 9.0);

      final samples = <double>[];
      model.currentProperty.addListener((i) => samples.add(i));

      model.voltage = 9.0;
      expect(model.current, isNot(baseline));
      expect(model.current, 18.0); // 1000*9/500
      expect(samples, [18.0]);

      model.dispose();
    });

    test('resistance change updates current', () {
      final model = OhmsLawModel();
      model.resistance = 1000;
      expect(model.current, 4.5); // 1000*4.5/1000
      model.dispose();
    });
  });

  group('ohms_law_combined_v_r_reactivity_test', () {
    test('combined_v_r_reactivity_test — no stale current', () {
      final model = OhmsLawModel();
      model.voltage = 1.0;
      expect(model.current, closeTo(1000 * 1.0 / 500, 1e-12));
      model.resistance = 100;
      expect(model.current, 10.0); // 1000*1/100
      model.voltage = 2.0;
      expect(model.current, 20.0); // sync with latest V and R
      model.dispose();
    });
  });

  group('ohms_law_current_units_test', () {
    test('O8 mA mode default formatting', () {
      final model = OhmsLawModel();
      expect(model.currentUnits, CurrentUnit.milliamps);
      expect(model.getFixedCurrent(), '9.0');
      model.voltage = 9;
      model.resistance = 10;
      expect(model.current, 900.0);
      expect(model.getFixedCurrent(), '900.0');
      model.dispose();
    });

    test('O9 A mode formatting uses sigFigs=3', () {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      // VD-03: 9.0/100 = 0.09 → "0.090"
      expect(model.getFixedCurrent(), '0.090');
      model.dispose();
    });
  });

  group('ohms_law_units_do_not_change_physics_test', () {
    test('switching units does not rewrite currentProperty', () {
      final model = OhmsLawModel();
      expect(model.current, 9.0);
      model.currentUnits = CurrentUnit.amps;
      expect(model.current, 9.0); // still mA physics
      expect(model.currentProperty.value, 9.0);
      model.currentUnits = CurrentUnit.milliamps;
      expect(model.current, 9.0);
      model.dispose();
    });
  });

  group('ohms_law_reset_test', () {
    test('O10 reset restores V and R (and derived I)', () {
      final model = OhmsLawModel()
        ..voltage = 9
        ..resistance = 10;
      expect(model.current, 900.0);
      model.reset();
      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, 9.0);
      model.dispose();
    });
  });

  group('ohms_law_reset_preserves_units_test', () {
    test('O11 reset_does_not_reset_current_units_test', () {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      model.voltage = 1.0;
      model.resistance = 100;
      model.reset();
      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.amps); // NOT mA
      expect(model.getFixedCurrent(), '0.090');
      model.dispose();
    });
  });

  group('ohms_law_repeated_reset_test', () {
    test('O15 repeated reset is idempotent', () {
      final model = OhmsLawModel()..currentUnits = CurrentUnit.amps;
      for (var i = 0; i < 4; i++) {
        model
          ..voltage = 9
          ..resistance = 10;
        model.reset();
      }
      expect(model.voltage, 4.5);
      expect(model.resistance, 500.0);
      expect(model.current, 9.0);
      expect(model.currentUnits, CurrentUnit.amps);
      expect(model.voltageProperty.listenerCount, 1); // only DerivedProperty
      expect(model.resistanceProperty.listenerCount, 1);
      model.dispose();
    });
  });

  group('ohms_law_voltage_boundaries_test', () {
    test('O12 inclusive bounds', () {
      final model = OhmsLawModel();
      model.voltage = 0.1;
      expect(model.voltage, 0.1);
      expect(model.current.isFinite, isTrue);
      model.voltage = 9.0;
      expect(model.voltage, 9.0);
      expect(model.current.isFinite, isTrue);
      model.dispose();
    });

    test('out of range constrains (Range.constrainValue path)', () {
      final model = OhmsLawModel();
      model.voltage = 0.0;
      expect(model.voltage, 0.1);
      model.voltage = 100.0;
      expect(model.voltage, 9.0);
      model.dispose();
    });
  });

  group('ohms_law_resistance_boundaries_test', () {
    test('O13 inclusive bounds', () {
      final model = OhmsLawModel();
      model.resistance = 10;
      expect(model.resistance, 10.0);
      expect(model.current.isFinite, isTrue);
      model.resistance = 1000;
      expect(model.resistance, 1000.0);
      expect(model.current.isFinite, isTrue);
      model.dispose();
    });

    test('out of range constrains', () {
      final model = OhmsLawModel();
      model.resistance = 0;
      expect(model.resistance, 10.0);
      expect(model.current.isFinite, isTrue);
      expect(model.current.isNaN, isFalse);
      model.resistance = 5000;
      expect(model.resistance, 1000.0);
      model.dispose();
    });
  });

  group('ohms_law_finite_current_test', () {
    test('all range corners yield finite non-NaN current', () {
      final model = OhmsLawModel();
      for (final v in [0.1, 4.5, 9.0]) {
        for (final r in [10.0, 500.0, 1000.0]) {
          model
            ..voltage = v
            ..resistance = r;
          expect(model.current.isFinite, isTrue, reason: 'V=$v R=$r');
          expect(model.current.isNaN, isFalse);
          expect(model.current, greaterThan(0));
        }
      }
      model.dispose();
    });
  });

  group('ohms_law_vd03_source_behavior_test', () {
    test('vd03_source_behavior_test — AMPS uses /100 not /1000', () {
      final model = OhmsLawModel();

      // mA mode: raw mA with 1 decimal
      expect(model.currentUnits, CurrentUnit.milliamps);
      expect(model.getFixedCurrent(), '9.0');

      // A mode: source divides by 100 (VD-03 quirk)
      model.currentUnits = CurrentUnit.amps;
      final fixed = model.getFixedCurrent();
      expect(fixed, '0.090'); // 9.0/100 → toFixed(3)
      // Physical amperes would be 0.009 — must NOT match source string
      expect(fixed, isNot('0.009'));
      // Physics property unchanged
      expect(model.current, 9.0);

      // Max current corner: 900 mA → 900/100 = 9 → "9.000"
      model
        ..voltage = 9
        ..resistance = 10;
      expect(model.current, 900.0);
      expect(model.getFixedCurrent(), '9.000');

      // Min-ish: 0.1 mA → 0.1/100 = 0.001 → "0.001"
      model
        ..voltage = 0.1
        ..resistance = 1000;
      expect(model.current, 0.1);
      expect(model.getFixedCurrent(), '0.001');

      model.dispose();
    });
  });

  group('ohms_law_model_lifecycle_test', () {
    test('dispose clears listeners; recreate is fresh', () {
      final model = OhmsLawModel();
      var ticks = 0;
      model.currentProperty.addListener((_) => ticks++);
      model.voltage = 5;
      expect(ticks, 1);
      model.dispose();

      final model2 = OhmsLawModel();
      expect(model2.voltage, 4.5);
      expect(model2.current, 9.0);
      expect(model2.voltageProperty.listenerCount, 1);
      model2.dispose();
    });

    test('O14 repeated changes without listener duplication', () {
      final model = OhmsLawModel();
      final observed = <double>[];
      model.currentProperty.addListener(observed.add);
      for (var i = 0; i < 20; i++) {
        model.voltage = 0.1 + (i % 9) * 1.0;
      }
      expect(model.voltageProperty.listenerCount, 1);
      expect(observed, isNotEmpty);
      expect(model.current, OhmsLawModel.computeCurrent(model.voltage, model.resistance));
      model.dispose();
    });
  });

  group('normalized helpers', () {
    test('normalized V/R/I at defaults and extremes', () {
      final model = OhmsLawModel();
      expect(model.getNormalizedVoltage(), closeTo((4.5 - 0.1) / 8.9, 1e-12));
      expect(model.getNormalizedResistance(), closeTo((500 - 10) / 990, 1e-12));
      expect(
        model.getNormalizedCurrent(),
        closeTo((9.0 - 0.1) / (900.0 - 0.1), 1e-12),
      );

      model.voltage = 0.1;
      expect(model.getNormalizedVoltage(), 0.0);
      model.voltage = 9.0;
      expect(model.getNormalizedVoltage(), 1.0);

      model.resistance = 10;
      expect(model.getNormalizedResistance(), 0.0);
      model.resistance = 1000;
      expect(model.getNormalizedResistance(), 1.0);

      model
        ..voltage = 0.1
        ..resistance = 1000;
      expect(model.getNormalizedCurrent(), 0.0);
      model
        ..voltage = 9
        ..resistance = 10;
      expect(model.getNormalizedCurrent(), 1.0);
      model.dispose();
    });
  });

  group('toFixed helpers', () {
    test('toFixed / toFixedNumber match display contract', () {
      expect(toFixedNumber(9.05, 1), 9.1); // banker's? toStringAsFixed half-up
      expect(toFixed(9.0, 1), '9.0');
      expect(toFixed(0.09, 3), '0.090');
      expect(toFixed(900.0, 3), '900.000');
    });
  });

  group('amps current-range constant', () {
    test('OhmsLawConstants CURRENT_RANGE (amperes) from source', () {
      expect(OhmsLawConstants.currentRangeAmpsMin, closeTo(1e-4, 1e-15));
      expect(OhmsLawConstants.currentRangeAmpsMax, 0.9);
    });
  });
}
