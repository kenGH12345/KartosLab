import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/coil.dart';
import 'package:kratos/faradays_law/model/magnet.dart';
import 'package:kratos/faradays_law/model/voltmeter_model.dart';

void main() {
  group('VoltmeterModel', () {
    Coil bottom(Magnet m) => Coil(
          position: FaradaysLawConstants.bottomCoilPosition,
          numberOfSpirals: 4,
          magnet: m,
        );
    Coil top(Magnet m) => Coil(
          position: FaradaysLawConstants.topCoilPosition,
          numberOfSpirals: 2,
          magnet: m,
        );

    test('initial zero', () {
      final v = VoltmeterModel();
      expect(v.voltage, 0);
      expect(v.needleAngle, 0);
      expect(v.signal, 0);
    });

    test('signal = 0.2 * (bottomEmf + topEmf)', () {
      final magnet = Magnet();
      final b = bottom(magnet);
      final t = top(magnet);
      b.emf = 10;
      t.emf = -2;
      final v = VoltmeterModel();
      v.step(bottomCoil: b, topCoil: t, dt: 0.01);
      expect(v.signal, closeTo(0.2 * (10 - 2), 1e-12));
    });

    test('positive EMF drives voltage positive over time', () {
      final magnet = Magnet();
      final b = bottom(magnet)..emf = 5;
      final t = top(magnet)..emf = 0;
      final v = VoltmeterModel();
      for (var i = 0; i < 120; i++) {
        v.step(bottomCoil: b, topCoil: t, dt: 1 / 60);
      }
      expect(v.voltage, greaterThan(0));
      expect(v.needleAngle, greaterThan(0));
    });

    test('negative EMF drives voltage negative', () {
      final magnet = Magnet();
      final b = bottom(magnet)..emf = -5;
      final t = top(magnet)..emf = 0;
      final v = VoltmeterModel();
      for (var i = 0; i < 120; i++) {
        v.step(bottomCoil: b, topCoil: t, dt: 1 / 60);
      }
      expect(v.voltage, lessThan(0));
    });

    test('zero EMF settles toward zero', () {
      final magnet = Magnet();
      final b = bottom(magnet)..emf = 0;
      final t = top(magnet)..emf = 0;
      final v = VoltmeterModel()..voltage = 0.5;
      for (var i = 0; i < 300; i++) {
        v.step(bottomCoil: b, topCoil: t, dt: 1 / 60);
      }
      expect(v.voltage.abs(), lessThan(0.05));
    });

    test('clampedNeedleAngle stays within ±π/2', () {
      final v = VoltmeterModel()..voltage = 10;
      expect(v.clampedNeedleAngle, FaradaysLawConstants.needleMaxAngle);
      v.voltage = -10;
      expect(v.clampedNeedleAngle, FaradaysLawConstants.needleMinAngle);
    });

    test('reset clears needle dynamics', () {
      final v = VoltmeterModel()
        ..voltage = 1
        ..needleAngularVelocity = 2
        ..signal = 3;
      v.reset();
      expect(v.voltage, 0);
      expect(v.needleAngularVelocity, 0);
      expect(v.signal, 0);
    });

    test('motion through coil produces non-zero voltage via EMF chain', () {
      final magnet = Magnet()..setPosition(const Offset(600, 310));
      final b = bottom(magnet);
      final t = top(magnet);
      final v = VoltmeterModel();

      magnet.setPosition(const Offset(448, 310));
      b.step(0.05);
      t.step(0.05);
      v.step(bottomCoil: b, topCoil: t, dt: 0.05);

      expect(b.emf.abs(), greaterThan(0));
      expect(v.signal.abs(), greaterThan(0));
      // After one step voltage may be small but signal drives it
      expect(v.signal, closeTo(0.2 * (b.emf + t.emf), 1e-9));
    });
  });
}
