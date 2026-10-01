import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

void main() {
  group('FaradaysLawModel', () {
    test('initial state matches source', () {
      final model = FaradaysLawModel();
      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnetArrowsVisible, isTrue);
      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.voltage, 0);
      expect(model.bulb.brightness, 0);
      expect(model.bottomCoil.numberOfSpirals, 4);
      expect(model.topCoil.numberOfSpirals, 2);
      expect(model.bottomCoil.emf, 0);
      expect(model.topCoil.emf, 0);
    });

    test('stationary magnet → EMF and voltage stay ~0', () {
      final model = FaradaysLawModel();
      for (var i = 0; i < 60; i++) {
        model.step(1 / 60);
      }
      expect(model.bottomCoil.emf.abs(), lessThan(1e-9));
      expect(model.voltage.abs(), lessThan(1e-3));
      expect(model.bulb.brightness, 0);
    });

    test('magnet motion → B → EMF → voltage → bulb chain', () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(600, 310));
      // Sync previous B without producing EMF
      model.bottomCoil.reset();

      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);

      expect(model.bottomCoil.emf.abs(), greaterThan(0));
      expect(model.voltmeter.signal.abs(), greaterThan(0));
      expect(
        model.voltmeter.signal,
        closeTo(0.2 * model.bottomCoil.emf, 1e-9),
      );
    });

    test('faster motion → larger |EMF| for same displacement', () {
      double emfForDt(double dt) {
        final model = FaradaysLawModel();
        model.setMagnetPositionForTest(const Offset(600, 310));
        model.bottomCoil.reset();
        model.setMagnetPositionForTest(const Offset(448, 310));
        model.step(dt);
        return model.bottomCoil.emf.abs();
      }

      final slow = emfForDt(0.1);
      final fast = emfForDt(0.02);
      expect(fast, greaterThan(slow));
    });

    test('+x vs -x motion reverse EMF sign', () {
      final into = FaradaysLawModel();
      into.setMagnetPositionForTest(const Offset(600, 310));
      into.bottomCoil.reset();
      into.setMagnetPositionForTest(const Offset(448, 310));
      into.step(0.05);

      final out = FaradaysLawModel();
      out.setMagnetPositionForTest(const Offset(448, 310));
      out.bottomCoil.reset();
      out.setMagnetPositionForTest(const Offset(600, 310));
      out.step(0.05);

      expect(into.bottomCoil.emf.sign, isNot(out.bottomCoil.emf.sign));
    });

    test('flip polarity reverses EMF sign for same motion', () {
      double run(MagnetOrientation o) {
        final model = FaradaysLawModel();
        model.magnet.orientation = o;
        model.setMagnetPositionForTest(const Offset(600, 310));
        model.bottomCoil.reset();
        model.setMagnetPositionForTest(const Offset(448, 310));
        model.step(0.05);
        return model.bottomCoil.emf;
      }

      expect(run(MagnetOrientation.sn), closeTo(-run(MagnetOrientation.ns), 1e-9));
    });

    test('topCoilVisible false → only bottom coil steps', () {
      final model = FaradaysLawModel();
      expect(model.topCoilVisible, isFalse);
      model.setMagnetPositionForTest(const Offset(422, 110));
      model.topCoil.reset();
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(422, 200));
      model.step(0.05);
      // Top coil not stepped — emf remains 0 after reset sync
      expect(model.topCoil.emf, 0);
      expect(model.bottomCoil.emf, isNot(0));
    });

    test('topCoilVisible true → both coils contribute to signal', () {
      final single = FaradaysLawModel();
      single.setMagnetPositionForTest(const Offset(500, 200));
      single.bottomCoil.reset();
      single.topCoil.reset();
      single.setMagnetPositionForTest(const Offset(448, 200));
      single.step(0.05);
      final singleSignal = single.voltmeter.signal.abs();

      final dual = FaradaysLawModel();
      dual.setTopCoilVisible(true);
      dual.setMagnetPositionForTest(const Offset(500, 200));
      dual.bottomCoil.reset();
      dual.topCoil.reset();
      dual.setMagnetPositionForTest(const Offset(448, 200));
      dual.step(0.05);
      final dualSignal = dual.voltmeter.signal.abs();

      // Dual mode: top coil also steps; magnitudes follow source N (not assumed larger)
      expect(dual.topCoil.emf.abs(), greaterThan(0));
      expect(dualSignal, isNot(singleSignal));
    });

    test('field lines visibility and geometry follow magnet', () {
      final model = FaradaysLawModel();
      expect(model.fieldLines.visible, isFalse);
      model.setFieldLinesVisible(true);
      expect(model.fieldLines.geometry.visible, isTrue);
      model.moveMagnetToPosition(const Offset(500, 200));
      expect(model.fieldLines.geometry.magnetPosition, model.magnet.position);
      model.flipPolarity();
      expect(model.fieldLines.geometry.arrowDirectionFlipped, isTrue);
    });

    test('dt <= 0 is no-op', () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0);
      model.step(-0.01);
      expect(model.bottomCoil.emf, 0);
    });

    test('dt > maxDT is clamped to 0.1', () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      final b0 = model.bottomCoil.magneticField;
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(1.0); // should clamp to 0.1
      final expected =
          model.bottomCoil.numberOfCoils *
          (model.bottomCoil.magneticField - b0) /
          FaradaysLawConstants.maxDt;
      expect(model.bottomCoil.emf, closeTo(expected, 1e-9));
    });

    test('moveMagnetToPosition stays inside layout bounds', () {
      final model = FaradaysLawModel();
      model.moveMagnetToPosition(const Offset(-1000, -1000));
      expect(model.magnet.bounds.left, greaterThanOrEqualTo(0));
      expect(model.magnet.bounds.top, greaterThanOrEqualTo(0));
      model.moveMagnetToPosition(const Offset(5000, 5000));
      expect(model.magnet.bounds.right, lessThanOrEqualTo(834));
      expect(model.magnet.bounds.bottom, lessThanOrEqualTo(504));
    });

    test('reset restores full initial state including voltage', () {
      final model = FaradaysLawModel();
      model.setTopCoilVisible(true);
      model.setVoltmeterVisible(true);
      model.setFieldLinesVisible(true);
      model.flipPolarity();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);
      for (var i = 0; i < 30; i++) {
        model.step(1 / 60);
      }
      expect(model.voltage.abs() + model.bottomCoil.emf.abs(), greaterThan(0));

      model.reset();

      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnetArrowsVisible, isTrue);
      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.voltage, 0);
      expect(model.voltmeter.needleAngularVelocity, 0);
      expect(model.bottomCoil.emf, 0);
      expect(model.topCoil.emf, 0);
      expect(model.bulb.brightness, 0);
    });

    test('positive and negative voltage yield same bulb brightness', () {
      final model = FaradaysLawModel();
      model.voltmeter.voltage = 0.4;
      final pos = model.bulb.brightness;
      model.voltmeter.voltage = -0.4;
      expect(model.bulb.brightness, pos);
    });
  });
}
