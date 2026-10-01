import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';

import 'dynamic_test_helpers.dart';

void main() {
  group('voltmeter dynamics', () {
    test('positive EMF drives voltage positive; negative drives negative', () {
      final pos = FaradaysLawModel();
      pos.bottomCoil.emf = 4;
      pos.topCoil.emf = 0;
      for (var i = 0; i < 90; i++) {
        pos.voltmeter.step(
          bottomCoil: pos.bottomCoil,
          topCoil: pos.topCoil,
          dt: 1 / 60,
        );
      }
      expect(pos.voltage, greaterThan(0));
      expect(pos.voltmeter.needleAngle, greaterThan(0));

      final neg = FaradaysLawModel();
      neg.bottomCoil.emf = -4;
      neg.topCoil.emf = 0;
      for (var i = 0; i < 90; i++) {
        neg.voltmeter.step(
          bottomCoil: neg.bottomCoil,
          topCoil: neg.topCoil,
          dt: 1 / 60,
        );
      }
      expect(neg.voltage, lessThan(0));
    });

    test('clamped needle stays within ±π/2', () {
      final model = FaradaysLawModel();
      model.voltmeter.voltage = 10;
      expect(
        model.voltmeter.clampedNeedleAngle,
        FaradaysLawConstants.needleMaxAngle,
      );
      model.voltmeter.voltage = -10;
      expect(
        model.voltmeter.clampedNeedleAngle,
        FaradaysLawConstants.needleMinAngle,
      );
    });

    test('signal uses 0.2 calibration from both coils', () {
      final model = FaradaysLawModel();
      model.bottomCoil.emf = 3;
      model.topCoil.emf = 2;
      model.voltmeter.step(
        bottomCoil: model.bottomCoil,
        topCoil: model.topCoil,
        dt: 0.01,
      );
      expect(model.voltmeter.signal, closeTo(1.0, 1e-12));
    });
  });

  group('bulb dynamics', () {
    test('+V and -V same magnitude → same brightness', () {
      final model = FaradaysLawModel();
      model.voltmeter.voltage = 0.4;
      final pos = model.bulb.brightness;
      final posHalo = model.bulb.haloScale;
      model.voltmeter.voltage = -0.4;
      expect(model.bulb.brightness, pos);
      expect(model.bulb.haloScale, posHalo);
    });

    test('brightness uses |voltage|; near-zero hides halo', () {
      final model = FaradaysLawModel();
      model.voltmeter.voltage = 0;
      expect(model.bulb.haloVisible, isFalse);
      model.voltmeter.voltage = 0.004;
      expect(model.bulb.haloVisible, isFalse);
      model.voltmeter.voltage = 0.2;
      expect(model.bulb.haloVisible, isTrue);
      expect(
        model.bulb.haloScale,
        closeTo(20 * 0.2, 1e-12),
      );
    });

    test('larger |voltage| → larger brightness after motion', () {
      final mild = FaradaysLawModel();
      mild.setMagnetPositionForTest(const Offset(550, 310));
      mild.bottomCoil.reset();
      mild.setMagnetPositionForTest(const Offset(500, 310));
      mild.step(0.05);
      for (var i = 0; i < 30; i++) {
        mild.step(1 / 60);
      }

      final strong = FaradaysLawModel();
      strong.setMagnetPositionForTest(const Offset(600, 310));
      strong.bottomCoil.reset();
      strong.setMagnetPositionForTest(const Offset(448, 310));
      strong.step(0.02);
      for (var i = 0; i < 30; i++) {
        strong.step(1 / 60);
      }

      expect(strong.voltage.abs(), greaterThan(mild.voltage.abs()));
      expect(strong.bulb.haloScale, greaterThan(mild.bulb.haloScale));
    });
  });

  group('field lines dynamic', () {
    test('geometry tracks magnet position and polarity', () {
      final model = FaradaysLawModel();
      model.setFieldLinesVisible(true);
      expect(model.fieldLines.geometry.visible, isTrue);

      model.setMagnetPositionForTest(const Offset(400, 220));
      expect(model.fieldLines.geometry.magnetPosition, const Offset(400, 220));

      model.flipPolarity();
      expect(model.fieldLines.geometry.arrowDirectionFlipped, isTrue);

      model.setFieldLinesVisible(false);
      expect(model.fieldLines.geometry.visible, isFalse);
    });

    test('field lines visibility does not alter trajectory EMF', () {
      final off = FaradaysLawModel();
      runTrajectory(off, approachCoilTrajectory(steps: 5));

      final on = FaradaysLawModel();
      on.setFieldLinesVisible(true);
      runTrajectory(on, approachCoilTrajectory(steps: 5));

      expect(on.bottomCoil.emf, closeTo(off.bottomCoil.emf, 1e-12));
    });
  });
}
