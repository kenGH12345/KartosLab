import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_constants.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_model.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_property.dart';

/// Oracle suite locked to PhET Resistance in a Wire 1.8.0-dev.0.
void main() {
  group('riaw_model_defaults_test', () {
    test('default ρ/L/A and derived R + formatted readout', () {
      final model = ResistanceInAWireModel();
      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      expect(model.resistance, closeTo(0.5 * 10.0 / 7.5, 1e-12));
      expect(model.getFormattedResistanceValue(), '0.667');
      expect(model.getFormattedSliderValue(model.resistivity), '0.50');
      expect(model.getFormattedSliderValue(model.length), '10.00');
      expect(model.getFormattedSliderValue(model.area), '7.50');
      model.dispose();
    });

    test('default_resistance_test: 0.5 * 10 / 7.5', () {
      expect(
        ResistanceInAWireModel.computeResistance(0.5, 10, 7.5),
        closeTo(2.0 / 3.0, 1e-12),
      );
    });
  });

  group('riaw_range_defaults_test', () {
    test('ranges match source RangeWithValue', () {
      expect(ResistanceInAWireConstants.resistivityRange.min, 0.01);
      expect(ResistanceInAWireConstants.resistivityRange.max, 1.00);
      expect(ResistanceInAWireConstants.resistivityRange.defaultValue, 0.5);

      expect(ResistanceInAWireConstants.lengthRange.min, 0.1);
      expect(ResistanceInAWireConstants.lengthRange.max, 20.0);
      expect(ResistanceInAWireConstants.lengthRange.defaultValue, 10.0);

      expect(ResistanceInAWireConstants.areaRange.min, 0.01);
      expect(ResistanceInAWireConstants.areaRange.max, 15.0);
      expect(ResistanceInAWireConstants.areaRange.defaultValue, 7.5);

      final model = ResistanceInAWireModel();
      expect(model.resistivityProperty.range.min, 0.01);
      expect(model.lengthProperty.range.max, 20.0);
      expect(model.areaProperty.range.defaultValue, 7.5);
      model.dispose();
    });

    test('RESISTANCE_RANGE from formula corners', () {
      final range = ResistanceInAWireConstants.resistanceRange;
      expect(range.min, closeTo(ResistanceInAWireModel.getMinResistance(), 1e-15));
      expect(range.max, closeTo(ResistanceInAWireModel.getMaxResistance(), 1e-15));
      expect(range.min, closeTo(0.01 * 0.1 / 15.0, 1e-15));
      expect(range.max, 1.0 * 20.0 / 0.01); // 2000
    });
  });

  group('riaw_formula_oracle_test', () {
    test('R = ρ·L/A oracle matrix', () {
      const cases = <(double rho, double l, double a, double r)>[
        (0.5, 10.0, 7.5, 2.0 / 3.0), // default
        (0.01, 0.1, 15.0, 0.01 * 0.1 / 15.0), // min R
        (1.0, 20.0, 0.01, 2000.0), // max R
        (1.0, 20.0, 15.0, 20.0 / 15.0), // 1.333…
        (0.5, 10.0, 0.01, 500.0),
        (0.25, 5.0, 5.0, 0.25),
        (0.01, 0.1, 0.01, 0.1),
        (0.75, 12.0, 3.0, 3.0),
      ];
      for (final (rho, l, a, expected) in cases) {
        expect(
          ResistanceInAWireModel.computeResistance(rho, l, a),
          closeTo(expected, 1e-12),
          reason: 'ρ=$rho L=$l A=$a',
        );
        final model = ResistanceInAWireModel()
          ..resistivity = rho
          ..length = l
          ..area = a;
        expect(model.resistance, closeTo(expected, 1e-12), reason: 'model');
        model.dispose();
      }
    });

    test('must not invert formula (A in numerator)', () {
      // Wrong: ρ*A/L at defaults ≈ 0.375 — must NOT equal resistance.
      expect(0.5 * 7.5 / 10.0, 0.375);
      expect(
        ResistanceInAWireModel.computeResistance(0.5, 10, 7.5),
        isNot(0.375),
      );
      expect(
        ResistanceInAWireModel.computeResistance(0.5, 10, 7.5),
        closeTo(2.0 / 3.0, 1e-12),
      );
    });
  });

  group('riaw_formatted_resistance_test', () {
    test('getResistanceDecimals thresholds', () {
      expect(ResistanceInAWireConstants.getResistanceDecimals(100), 0);
      expect(ResistanceInAWireConstants.getResistanceDecimals(99.9), 1);
      expect(ResistanceInAWireConstants.getResistanceDecimals(10), 1);
      expect(ResistanceInAWireConstants.getResistanceDecimals(9.99), 2);
      expect(ResistanceInAWireConstants.getResistanceDecimals(1.0), 2);
      expect(ResistanceInAWireConstants.getResistanceDecimals(0.999), 3);
      expect(ResistanceInAWireConstants.getResistanceDecimals(0.001), 3);
      expect(ResistanceInAWireConstants.getResistanceDecimals(0.0009), 4);
    });

    test('formatted oracle strings from contract', () {
      final model = ResistanceInAWireModel();

      expect(model.getFormattedResistanceValue(), '0.667');

      model
        ..resistivity = 0.01
        ..length = 0.1
        ..area = 15.0;
      expect(model.getFormattedResistanceValue(), '0.0001');

      model
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 0.01;
      expect(model.getFormattedResistanceValue(), '2000');

      model
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 15.0;
      // 1 ≤ R < 10 → 2 decimals (source comment: "like 8.35"), not 3.
      expect(model.getFormattedResistanceValue(), '1.33');

      model
        ..resistivity = 0.5
        ..length = 10.0
        ..area = 0.01;
      expect(model.getFormattedResistanceValue(), '500');

      model
        ..resistivity = 0.25
        ..length = 5.0
        ..area = 5.0;
      expect(model.getFormattedResistanceValue(), '0.250');

      model.dispose();
    });
  });

  group('riaw_reactivity_test', () {
    test('resistivity change updates R', () {
      final model = ResistanceInAWireModel();
      final samples = <double>[];
      model.resistanceProperty.addListener(samples.add);

      model.resistivity = 1.0;
      expect(model.resistance, closeTo(1.0 * 10.0 / 7.5, 1e-12));
      expect(samples, isNotEmpty);
      model.dispose();
    });

    test('length change updates R', () {
      final model = ResistanceInAWireModel();
      model.length = 20.0;
      expect(model.resistance, closeTo(0.5 * 20.0 / 7.5, 1e-12));
      model.dispose();
    });

    test('area change updates R', () {
      final model = ResistanceInAWireModel();
      model.area = 15.0;
      expect(model.resistance, closeTo(0.5 * 10.0 / 15.0, 1e-12));
      model.dispose();
    });

    test('combined ρ/L/A — no stale resistance', () {
      final model = ResistanceInAWireModel();
      model.resistivity = 0.25;
      expect(model.resistance, closeTo(0.25 * 10.0 / 7.5, 1e-12));
      model.length = 5.0;
      expect(model.resistance, closeTo(0.25 * 5.0 / 7.5, 1e-12));
      model.area = 5.0;
      expect(model.resistance, closeTo(0.25, 1e-12));
      model.dispose();
    });
  });

  group('riaw_reset_test', () {
    test('reset restores ρ/L/A and derived R', () {
      final model = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 0.01;
      expect(model.resistance, 2000.0);
      model.reset();
      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      expect(model.resistance, closeTo(2.0 / 3.0, 1e-12));
      expect(model.getFormattedResistanceValue(), '0.667');
      model.dispose();
    });

    test('repeated reset is idempotent', () {
      final model = ResistanceInAWireModel();
      for (var i = 0; i < 4; i++) {
        model
          ..resistivity = 1.0
          ..length = 20.0
          ..area = 0.01;
        model.reset();
      }
      expect(model.resistivity, 0.5);
      expect(model.length, 10.0);
      expect(model.area, 7.5);
      expect(model.resistivityProperty.listenerCount, 1);
      expect(model.lengthProperty.listenerCount, 1);
      expect(model.areaProperty.listenerCount, 1);
      model.dispose();
    });
  });

  group('riaw_boundaries_test', () {
    test('inclusive bounds for ρ/L/A', () {
      final model = ResistanceInAWireModel();
      model.resistivity = 0.01;
      expect(model.resistivity, 0.01);
      model.resistivity = 1.0;
      expect(model.resistivity, 1.0);

      model.length = 0.1;
      expect(model.length, 0.1);
      model.length = 20.0;
      expect(model.length, 20.0);

      model.area = 0.01;
      expect(model.area, 0.01);
      model.area = 15.0;
      expect(model.area, 15.0);
      expect(model.resistance.isFinite, isTrue);
      model.dispose();
    });

    test('out of range constrains (Range.constrainValue)', () {
      final model = ResistanceInAWireModel();
      model.resistivity = 0.0;
      expect(model.resistivity, 0.01);
      model.resistivity = 5.0;
      expect(model.resistivity, 1.0);

      model.length = -1;
      expect(model.length, 0.1);
      model.length = 100;
      expect(model.length, 20.0);

      model.area = 0;
      expect(model.area, 0.01);
      model.area = 99;
      expect(model.area, 15.0);
      expect(model.resistance.isFinite, isTrue);
      expect(model.resistance.isNaN, isFalse);
      model.dispose();
    });

    test('all range corners yield finite non-NaN R', () {
      final model = ResistanceInAWireModel();
      for (final rho in [0.01, 0.5, 1.0]) {
        for (final l in [0.1, 10.0, 20.0]) {
          for (final a in [0.01, 7.5, 15.0]) {
            model
              ..resistivity = rho
              ..length = l
              ..area = a;
            expect(model.resistance.isFinite, isTrue, reason: 'ρ=$rho L=$l A=$a');
            expect(model.resistance.isNaN, isFalse);
            expect(model.resistance, greaterThan(0));
          }
        }
      }
      model.dispose();
    });
  });

  group('riaw_formula_scale_vd02_test', () {
    test('default scaleMagnitude is 8 for all letters', () {
      final model = ResistanceInAWireModel();
      final rhoScale = model.formulaScaleMagnitude(
        model.resistivity,
        ResistanceInAWireConstants.resistivityRange.defaultValue,
      );
      final lScale = model.formulaScaleMagnitude(
        model.length,
        ResistanceInAWireConstants.lengthRange.defaultValue,
      );
      final aScale = model.formulaScaleMagnitude(
        model.area,
        ResistanceInAWireConstants.areaRange.defaultValue,
      );
      final r0 = ResistanceInAWireModel.computeResistance(0.5, 10, 7.5);
      final rScale = model.formulaScaleMagnitude(model.resistance, r0);

      expect(rhoScale, 8.0);
      expect(lScale, 8.0);
      expect(aScale, 8.0);
      expect(rScale, closeTo(8.0, 1e-12));
      model.dispose();
    });

    test('VD-02: R scale is uncapped (no artificial max)', () {
      final model = ResistanceInAWireModel()
        ..resistivity = 1.0
        ..length = 20.0
        ..area = 0.01;
      final r0 = ResistanceInAWireModel.computeResistance(0.5, 10, 7.5);
      final scale = model.formulaScaleMagnitude(model.resistance, r0);
      // At R=2000: (7/r0)*2000 + 1 ≈ 10.5*2000 + 1 ≫ any historical cap
      expect(scale, greaterThan(1000));
      expect(scale, closeTo(7.0 / r0 * 2000.0 + 1.0, 1e-9));
      model.dispose();
    });
  });

  group('riaw_model_lifecycle_test', () {
    test('dispose clears listeners; recreate is fresh', () {
      final model = ResistanceInAWireModel();
      var ticks = 0;
      model.resistanceProperty.addListener((_) => ticks++);
      model.resistivity = 0.8;
      expect(ticks, 1);
      model.dispose();

      final model2 = ResistanceInAWireModel();
      expect(model2.resistivity, 0.5);
      expect(model2.getFormattedResistanceValue(), '0.667');
      expect(model2.resistivityProperty.listenerCount, 1);
      model2.dispose();
    });

    test('repeated changes without listener duplication', () {
      final model = ResistanceInAWireModel();
      final observed = <double>[];
      model.resistanceProperty.addListener(observed.add);
      for (var i = 0; i < 20; i++) {
        model.resistivity = 0.01 + (i % 10) * 0.05;
      }
      expect(model.resistivityProperty.listenerCount, 1);
      expect(observed, isNotEmpty);
      expect(
        model.resistance,
        ResistanceInAWireModel.computeResistance(
          model.resistivity,
          model.length,
          model.area,
        ),
      );
      model.dispose();
    });
  });

  group('riaw_toFixed_helpers_test', () {
    test('toFixed / toFixedNumber for slider and R display', () {
      expect(toFixed(0.5, 2), '0.50');
      expect(toFixed(10.0, 2), '10.00');
      expect(toFixed(7.5, 2), '7.50');
      expect(toFixed(2.0 / 3.0, 3), '0.667');
      expect(toFixedNumber(2.0 / 3.0, 3), closeTo(0.667, 1e-12));
      expect(toFixed(2000.0, 0), '2000');
    });

    test('slider constrain path uses 2 decimals', () {
      expect(toFixedNumber(0.505, 2), 0.51);
      expect(toFixedNumber(7.504, 2), 7.50);
    });
  });

  group('riaw_static_extremes_test', () {
    test('getMinResistance / getMaxResistance', () {
      expect(
        ResistanceInAWireModel.getMinResistance(),
        closeTo(0.01 * 0.1 / 15.0, 1e-15),
      );
      expect(ResistanceInAWireModel.getMaxResistance(), 2000.0);
    });
  });
}
