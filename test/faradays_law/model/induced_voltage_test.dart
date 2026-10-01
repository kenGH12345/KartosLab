import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/coil.dart';
import 'package:kratos/faradays_law/model/magnet.dart';
import 'package:kratos/faradays_law/model/voltmeter_model.dart';

/// Induced voltage chain regression: EMF → signal = 0.2·Σemf → voltage dynamics.
void main() {
  group('Induced voltage chain', () {
    test('EMF formula regression with fixed positions and dt', () {
      final magnet = Magnet()..setPosition(const Offset(600, 310));
      final coil = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      );
      final bPrev = coil.magneticField;
      magnet.setPosition(const Offset(500, 310));
      const dt = 0.05;
      coil.step(dt);
      final deltaB = coil.magneticField - bPrev;
      expect(coil.emf, closeTo(2 * deltaB / dt, 1e-12));
    });

    test('calibration 0.2 is applied to combined EMF', () {
      final magnet = Magnet();
      final bottom = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      )..emf = 3.5;
      final top = Coil(
        position: FaradaysLawConstants.topCoilPosition,
        numberOfSpirals: 2,
        magnet: magnet,
      )..emf = 1.5;
      final voltmeter = VoltmeterModel();
      voltmeter.step(bottomCoil: bottom, topCoil: top, dt: 0.01);
      expect(voltmeter.signal, closeTo(0.2 * 5.0, 1e-12));
    });
  });
}
