import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

import 'dynamic_test_helpers.dart';

void main() {
  group('coil configuration dynamics', () {
    test('1 coil does not step top coil EMF', () {
      final model = FaradaysLawModel();
      expect(model.topCoilVisible, isFalse);
      model.setMagnetPositionForTest(const Offset(500, 110));
      model.topCoil.reset();
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(422, 110));
      model.step(0.05);
      expect(model.topCoil.emf, 0);
      expect(model.bottomCoil.emf, isNot(0));
    });

    test('2 coil steps top coil and changes combined signal', () {
      final single = FaradaysLawModel();
      single.setMagnetPositionForTest(const Offset(500, 200));
      single.bottomCoil.reset();
      single.topCoil.reset();
      single.setMagnetPositionForTest(const Offset(448, 200));
      single.step(0.05);

      final dual = FaradaysLawModel();
      dual.setTopCoilVisible(true);
      dual.setMagnetPositionForTest(const Offset(500, 200));
      dual.bottomCoil.reset();
      dual.topCoil.reset();
      dual.setMagnetPositionForTest(const Offset(448, 200));
      dual.step(0.05);

      expect(dual.topCoil.emf.abs(), greaterThan(0));
      expect(dual.voltmeter.signal, isNot(single.voltmeter.signal));
      expect(
        dual.voltmeter.signal,
        closeTo(
          FaradaysLawConstants.emfToSignalScale *
              (dual.bottomCoil.emf + dual.topCoil.emf),
          1e-9,
        ),
      );
    });

    test('switching 2→1 coil does not reset magnet/polarity/field lines', () {
      final model = FaradaysLawModel();
      model.setTopCoilVisible(true);
      model.setFieldLinesVisible(true);
      model.flipPolarity();
      model.setMagnetPositionForTest(const Offset(500, 250));

      model.setTopCoilVisible(false);

      expect(model.magnet.position, const Offset(500, 250));
      expect(model.magnet.orientation, MagnetOrientation.sn);
      expect(model.magnet.fieldLinesVisible, isTrue);
      expect(model.topCoilVisible, isFalse);
    });

    test('coil switch does not clear voltage by itself', () {
      final model = FaradaysLawModel();
      runTrajectory(model, approachCoilTrajectory(steps: 4));
      for (var i = 0; i < 15; i++) {
        model.step(1 / 60);
      }
      final v = model.voltage;
      expect(v.abs(), greaterThan(0));

      model.setTopCoilVisible(true);
      expect(model.voltage, v);
    });
  });

  group('control must not reset physics', () {
    test('Field Lines toggle does not change B/EMF/voltage', () {
      final model = FaradaysLawModel();
      runTrajectory(model, approachCoilTrajectory(steps: 4));
      final b = model.bottomCoil.magneticField;
      final emf = model.bottomCoil.emf;
      final v = model.voltage;

      model.setFieldLinesVisible(true);
      model.setFieldLinesVisible(false);

      expect(model.bottomCoil.magneticField, b);
      expect(model.bottomCoil.emf, emf);
      expect(model.voltage, v);
    });

    test('Voltmeter toggle does not reset Model voltage', () {
      final model = FaradaysLawModel();
      runTrajectory(model, approachCoilTrajectory(steps: 4));
      for (var i = 0; i < 20; i++) {
        model.step(1 / 60);
      }
      final v = model.voltage;
      expect(v.abs(), greaterThan(0));

      model.setVoltmeterVisible(true);
      model.setVoltmeterVisible(false);
      model.setVoltmeterVisible(true);

      expect(model.voltage, v);
    });

    test('Flip Magnet changes polarity without clearing position', () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(500, 250));
      model.flipPolarity();
      expect(model.magnet.position, const Offset(500, 250));
      expect(model.magnet.orientation, MagnetOrientation.sn);
    });
  });
}
