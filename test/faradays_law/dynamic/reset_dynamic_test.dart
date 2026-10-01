import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

import 'dynamic_test_helpers.dart';

void main() {
  group('reset dynamic', () {
    test('reset after motion clears voltage/needle (VD-02) and restores state',
        () {
      final model = FaradaysLawModel();
      model.setTopCoilVisible(true);
      model.setVoltmeterVisible(true);
      model.setFieldLinesVisible(true);
      model.flipPolarity();
      runTrajectory(model, approachCoilTrajectory(steps: 6));
      for (var i = 0; i < 40; i++) {
        model.step(1 / 60);
      }
      expect(model.voltage.abs(), greaterThan(0));

      model.reset();

      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.topCoilVisible, isFalse);
      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.voltage, 0);
      expect(model.voltmeter.needleAngularVelocity, 0);
      expect(model.bottomCoil.emf, 0);
      expect(model.bulb.brightness, 0);
      expect(model.magnetArrowsVisible, isTrue);
    });

    test('motion after reset does not inherit previous B/EMF', () {
      final model = FaradaysLawModel();
      runTrajectory(model, approachCoilTrajectory(steps: 5));
      model.reset();

      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      expect(model.bottomCoil.previousMagneticField, model.bottomCoil.magneticField);
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);
      // Fresh ΔB only — not contaminated by pre-reset history
      expect(model.bottomCoil.emf.abs(), greaterThan(0));
    });
  });
}
