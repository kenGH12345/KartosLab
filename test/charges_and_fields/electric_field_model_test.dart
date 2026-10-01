import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/charges_and_fields/caf_constants.dart';
import 'package:kratos/charges_and_fields/model/charges_and_fields_model.dart';
import 'package:kratos/charges_and_fields/model/vec2.dart';

void main() {
  group('Electric field / potential physics', () {
    test('single positive charge: E and V at known point', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);

      // At (1, 0): r=1, E = k*1/1² = 9 in +x, V = k*1/1 = 9
      final e = model.getElectricField(const CafVec2(1, 0));
      expect(e.x, closeTo(9.0, 1e-9));
      expect(e.y, closeTo(0.0, 1e-9));
      expect(model.getElectricPotential(const CafVec2(1, 0)), closeTo(9.0, 1e-9));
    });

    test('single negative charge: E points toward charge', () {
      final model = ChargesAndFieldsModel();
      final p = model.addNegativeCharge(CafVec2.zero);
      model.setParticleActive(p, true);

      final e = model.getElectricField(const CafVec2(1, 0));
      expect(e.x, closeTo(-9.0, 1e-9));
      expect(e.y, closeTo(0.0, 1e-9));
      expect(
        model.getElectricPotential(const CafVec2(1, 0)),
        closeTo(-9.0, 1e-9),
      );
    });

    test('two opposite charges: superposition', () {
      final model = ChargesAndFieldsModel();
      final pos = model.addPositiveCharge(const CafVec2(-1, 0));
      final neg = model.addNegativeCharge(const CafVec2(1, 0));
      model.setParticleActive(pos, true);
      model.setParticleActive(neg, true);

      // Midpoint (0,0): E from + at left points right, from - at right points right
      final e = model.getElectricField(CafVec2.zero);
      expect(e.x, greaterThan(0));
      expect(e.y, closeTo(0.0, 1e-9));
      // V: +9/1 + (-9)/1 = 0
      expect(model.getElectricPotential(CafVec2.zero), closeTo(0.0, 1e-9));
    });

    test('two equal positive charges: midpoint E cancels in x', () {
      final model = ChargesAndFieldsModel();
      final a = model.addPositiveCharge(const CafVec2(-1, 0));
      final b = model.addPositiveCharge(const CafVec2(1, 0));
      model.setParticleActive(a, true);
      model.setParticleActive(b, true);

      final e = model.getElectricField(CafVec2.zero);
      expect(e.x, closeTo(0.0, 1e-9));
      expect(e.y, closeTo(0.0, 1e-9));
      expect(model.getElectricPotential(CafVec2.zero), closeTo(18.0, 1e-9));
    });

    test('potential at charge site is infinity', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);
      expect(model.getElectricPotential(CafVec2.zero), double.infinity);
    });

    test('near-field clamp returns large magnitude along +x', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);
      final e = model.getElectricField(const CafVec2(1e-12, 0));
      expect(e.x, closeTo(10 * CafConstants.maxEFieldMagnitude, 1));
      expect(e.y, 0);
    });

    test('inactive charge does not contribute', () {
      final model = ChargesAndFieldsModel();
      model.addPositiveCharge(CafVec2.zero); // inactive
      expect(model.getElectricField(const CafVec2(1, 0)), CafVec2.zero);
      expect(model.getElectricPotential(const CafVec2(1, 0)), 0);
    });

    test('reset clears charges and restores visibility defaults', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(const CafVec2(0.5, 0.5));
      model.setParticleActive(p, true);
      model.isElectricFieldVisible = false;
      model.isGridVisible = true;
      model.addElectricPotentialLine(const CafVec2(1, 1));
      model.reset();
      expect(model.chargedParticles, isEmpty);
      expect(model.activeChargedParticles, isEmpty);
      expect(model.electricPotentialLines, isEmpty);
      expect(model.isElectricFieldVisible, isTrue);
      expect(model.isGridVisible, isFalse);
      expect(model.isPlayAreaCharged, isFalse);
    });

    test('field sensor updates when charge moves', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);
      final sensor = model.addElectricFieldSensor(const CafVec2(1, 0));
      sensor.isActive = true;
      sensor.update();
      expect(sensor.electricField.x, closeTo(9.0, 1e-9));

      p.position = const CafVec2(0.5, 0);
      model.clearElectricPotentialLines();
      model.updateAllSensors();
      expect(sensor.electricField.x, isNot(closeTo(9.0, 0.1)));
    });

    test('equipotential line generates points for single charge', () {
      final model = ChargesAndFieldsModel();
      final p = model.addPositiveCharge(CafVec2.zero);
      model.setParticleActive(p, true);
      final line = model.addElectricPotentialLine(const CafVec2(1, 0));
      expect(line, isNotNull);
      expect(line!.positionArray.length, greaterThan(10));
      expect(line.electricPotential, closeTo(9.0, 1e-6));
    });

    test('snap to minor grid 0.1 m', () {
      final model = ChargesAndFieldsModel()
        ..isGridVisible = true
        ..snapToGrid = true;
      final snapped = model.snapPosition(const CafVec2(0.14, -0.26));
      expect(snapped.x, closeTo(0.1, 1e-12));
      expect(snapped.y, closeTo(-0.3, 1e-12));
    });
  });
}
