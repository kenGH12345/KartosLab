import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/coil.dart';
import 'package:kratos/faradays_law/model/magnet.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

void main() {
  group('Coil', () {
    test('bottom coil N = spirals/2 = 2', () {
      final magnet = Magnet();
      final coil = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      );
      expect(coil.numberOfCoils, 2);
    });

    test('top coil N = spirals/2 = 1', () {
      final magnet = Magnet();
      final coil = Coil(
        position: FaradaysLawConstants.topCoilPosition,
        numberOfSpirals: 2,
        magnet: magnet,
      );
      expect(coil.numberOfCoils, 1);
    });

    test('stationary magnet yields EMF approx 0 after step', () {
      final magnet = Magnet();
      final coil = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      );
      coil.step(1 / 60);
      expect(coil.emf, closeTo(0, 1e-12));
    });

    test('moving magnet produces EMF = N * dB / dt', () {
      final magnet = Magnet();
      final coil = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      );
      final b0 = coil.magneticField;
      magnet.setPosition(const Offset(500, 310));
      const dt = 0.05;
      coil.step(dt);
      final expected = coil.numberOfCoils * (coil.magneticField - b0) / dt;
      expect(coil.emf, closeTo(expected, 1e-9));
      expect(coil.emf.abs(), greaterThan(0));
    });

    test('reverse motion reverses EMF sign', () {
      final magnet = Magnet()..setPosition(const Offset(600, 310));
      final coil = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      );
      magnet.setPosition(const Offset(500, 310));
      coil.step(0.05);
      final emfIn = coil.emf;

      coil.previousMagneticField = coil.magneticField;
      magnet.setPosition(const Offset(600, 310));
      coil.step(0.05);
      final emfOut = coil.emf;

      expect(emfIn.sign, isNot(emfOut.sign));
    });

    test('flip polarity flips EMF sign for same motion', () {
      double runEmf(MagnetOrientation orientation) {
        final magnet = Magnet()
          ..orientation = orientation
          ..setPosition(const Offset(600, 310));
        final coil = Coil(
          position: FaradaysLawConstants.bottomCoilPosition,
          numberOfSpirals: 4,
          magnet: magnet,
        );
        magnet.setPosition(const Offset(500, 310));
        coil.step(0.05);
        return coil.emf;
      }

      final ns = runEmf(MagnetOrientation.ns);
      final sn = runEmf(MagnetOrientation.sn);
      expect(sn, closeTo(-ns, 1e-9));
    });

    test('reset clears EMF and syncs previous B', () {
      final magnet = Magnet();
      final coil = Coil(
        position: FaradaysLawConstants.bottomCoilPosition,
        numberOfSpirals: 4,
        magnet: magnet,
      );
      magnet.setPosition(const Offset(500, 310));
      coil.step(0.05);
      expect(coil.emf.abs(), greaterThan(0));
      coil.reset();
      expect(coil.emf, 0);
      expect(coil.previousMagneticField, coil.magneticField);
    });
  });
}
