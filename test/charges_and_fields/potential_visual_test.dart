import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/charges_and_fields/caf_colors.dart';
import 'package:kratos/charges_and_fields/caf_constants.dart';
import 'package:kratos/charges_and_fields/model/charges_and_fields_model.dart';
import 'package:kratos/charges_and_fields/model/vec2.dart';
import 'package:kratos/charges_and_fields/painters/potential_visual.dart';

void main() {
  group('CafPotentialColors', () {
    test('V=0 → black field color', () {
      final c = CafPotentialColors.forField(0);
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
      expect((c.a * 255).round(), 255);
    });

    test('V=+40 → saturated positive', () {
      final c = CafPotentialColors.forField(40);
      final e = CafColors.electricPotentialGridSaturationPositive;
      expect((c.r * 255).round(), (e.r * 255).round());
      expect((c.g * 255).round(), (e.g * 255).round());
      expect((c.b * 255).round(), (e.b * 255).round());
    });

    test('V=-40 → saturated negative', () {
      final c = CafPotentialColors.forField(-40);
      final e = CafColors.electricPotentialGridSaturationNegative;
      expect((c.r * 255).round(), (e.r * 255).round());
      expect((c.g * 255).round(), (e.g * 255).round());
      expect((c.b * 255).round(), (e.b * 255).round());
    });

    test('circle transparency 0.5 at V=0', () {
      final c = CafPotentialColors.forCircle(0, 0.5);
      expect((c.a * 255).round(), 128);
      expect((c.r * 255).round(), 0);
    });

    test('V=+20 → mid lerp toward positive (continuous float)', () {
      final c = CafPotentialColors.forField(20);
      final e = CafColors.electricPotentialGridSaturationPositive;
      // |V|/40 = 0.5 → half of extreme
      expect((c.r * 255).round(), ((e.r * 255).round() * 0.5).round());
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('potentialSampleSpacing denser than Canvas 0.1 m at scale 128', () {
      final s = potentialSampleSpacing(128);
      expect(s, lessThan(CafConstants.electricPotentialSensorSpacing));
      expect(s, closeTo(2.0 / 128, 1e-12));
    });

    test('samplePotential skips zero distance (no infinity)', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);
      final atCharge = CafPotentialColors.samplePotential(model, CafVec2.zero);
      expect(atCharge.isFinite, isTrue);
      expect(atCharge, 0); // only that charge, skipped
      final nearby =
          CafPotentialColors.samplePotential(model, const CafVec2(1, 0));
      expect(nearby, closeTo(CafConstants.kConstant, 1e-9));
    });
  });

  group('decimalAdjust', () {
    test('matches source examples for maxDecimalPlaces=3', () {
      expect(EquipotentialLinesPainter.decimalAdjust(9.11111), '9.111');
      expect(EquipotentialLinesPainter.decimalAdjust(99.1111), '99.11');
      expect(EquipotentialLinesPainter.decimalAdjust(999.111), '999.1');
      expect(EquipotentialLinesPainter.decimalAdjust(9999.11), '9999');
    });
  });

  group('voltmeter readout chain', () {
    test('sensor V equals Potential Model at tip', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);
      model.electricPotentialSensor.isActive = true;
      model.electricPotentialSensor.setPosition(const CafVec2(2, 0));
      expect(
        model.electricPotentialSensor.electricPotential,
        closeTo(model.getElectricPotential(const CafVec2(2, 0)), 1e-12),
      );
      expect(model.electricPotentialSensor.electricPotential, closeTo(4.5, 1e-9));
    });
  });
}
