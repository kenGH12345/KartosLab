import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/physics/dispersion_function.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  group('DispersionFunction', () {
    test('air at 650 nm matches reference', () {
      final d =
          DispersionFunction(1.000293, BendingLightConstants.wavelengthRed);
      expect(
        d.getIndexOfRefraction(BendingLightConstants.wavelengthRed),
        closeTo(1.000293, 1e-6),
      );
    });

    test('glass at 650 nm approx 1.5', () {
      final d = DispersionFunction(1.5, BendingLightConstants.wavelengthRed);
      expect(
        d.getIndexOfRefraction(BendingLightConstants.wavelengthRed),
        closeTo(1.5, 1e-6),
      );
    });

    test('wavelength unit mix produces different n', () {
      final d = DispersionFunction(1.5, BendingLightConstants.wavelengthRed);
      final n650 = d.getIndexOfRefraction(650e-9);
      final nWrong = d.getIndexOfRefraction(650);
      expect(n650, isNot(closeTo(nWrong, 0.01)));
    });

    test('glass n decreases with wavelength', () {
      final d = DispersionFunction(1.5, BendingLightConstants.wavelengthRed);
      final nBlue = d.getIndexOfRefraction(450e-9);
      final nRed = d.getIndexOfRefraction(650e-9);
      expect(nBlue, greaterThan(nRed));
    });

    test('min max laser wavelengths finite', () {
      final d = DispersionFunction(1.333, BendingLightConstants.wavelengthRed);
      final nMin = d.getIndexOfRefraction(
        BendingLightConstants.laserMinWavelengthNm * 1e-9,
      );
      final nMax = d.getIndexOfRefraction(
        BendingLightConstants.laserMaxWavelengthNm * 1e-9,
      );
      expect(nMin.isFinite, isTrue);
      expect(nMax.isFinite, isTrue);
      expect(nMin, greaterThan(1.0));
    });

    test('Substance presets', () {
      expect(Substance.air.indexForRed, 1.000293);
      expect(Substance.water.indexForRed, 1.333);
      expect(Substance.glass.indexForRed, 1.5);
      expect(Substance.mysteryA.indexForRed, 2.419);
      expect(Substance.mysteryA.mystery, isTrue);
    });

    test('Sellmeier value at 650nm greater than 1.5', () {
      final d = DispersionFunction(1.5, BendingLightConstants.wavelengthRed);
      final sell = d.getSellmeierValue(650e-9);
      expect(sell, greaterThan(1.5));
    });
  });
}
