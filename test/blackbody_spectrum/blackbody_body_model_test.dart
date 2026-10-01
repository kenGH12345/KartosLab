import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/blackbody_spectrum/blackbody_spectrum_constants.dart';
import 'package:kratos/blackbody_spectrum/model/blackbody_body_model.dart';

void main() {
  group('BlackbodyBodyModel - Planck spectral power density', () {
    test('returns 0 for wavelength=0', () {
      final body = BlackbodyBodyModel(5800);
      expect(body.getSpectralPowerDensityAt(0), equals(0));
    });

    test('returns 0 for null temperature', () {
      final body = BlackbodyBodyModel(null);
      expect(body.getSpectralPowerDensityAt(550), equals(0));
    });

    test('returns positive value for valid wavelength and temperature', () {
      final body = BlackbodyBodyModel(5800);
      final spd = body.getSpectralPowerDensityAt(550);
      expect(spd, greaterThan(0));
    });

    test('returns 0 for extremely short wavelength (overflow guard)', () {
      final body = BlackbodyBodyModel(200);
      expect(body.getSpectralPowerDensityAt(0.001), equals(0));
    });
  });

  group('BlackbodyBodyModel - Wien peak wavelength', () {
    test('Sun (5800K) peak ≈ 500 nm', () {
      final body = BlackbodyBodyModel(5800);
      final peak = body.peakWavelength;
      expect(peak, closeTo(500, 10));
    });

    test('Earth (250K) peak in infrared', () {
      final body = BlackbodyBodyModel(250);
      final peak = body.peakWavelength;
      expect(peak, greaterThan(10000));
    });

    test('returns 0 for null temperature', () {
      final body = BlackbodyBodyModel(null);
      expect(body.peakWavelength, equals(0));
    });
  });

  group('BlackbodyBodyModel - Stefan-Boltzmann total intensity', () {
    test('Sun (5800K) intensity is large positive', () {
      final body = BlackbodyBodyModel(5800);
      final intensity = body.totalIntensity;
      expect(intensity, greaterThan(1e6));
    });

    test('Earth (250K) intensity is small', () {
      final body = BlackbodyBodyModel(250);
      final intensity = body.totalIntensity;
      expect(intensity, lessThan(300));
    });
  });

  group('BlackbodyBodyModel - Renormalized temperature', () {
    test('is 0 at draper point (798K)', () {
      final body = BlackbodyBodyModel(798);
      expect(body.renormalizedTemperature, closeTo(0, 0.01));
    });

    test('increases with temperature', () {
      final low = BlackbodyBodyModel(1000);
      final high = BlackbodyBodyModel(5000);
      expect(high.renormalizedTemperature,
          greaterThan(low.renormalizedTemperature));
    });
  });

  group('BlackbodyBodyModel - RGB colors', () {
    test('all channels are 0 at draper point', () {
      final body = BlackbodyBodyModel(798);
      expect(body.redColor.red, equals(0));
      expect(body.greenColor.green, equals(0));
      expect(body.blueColor.blue, equals(0));
    });

    test('star color has non-zero channels at high temperature', () {
      final body = BlackbodyBodyModel(5800);
      expect(body.starColor.red + body.starColor.green + body.starColor.blue,
          greaterThan(0));
    });
  });

  group('BlackbodyBodyModel - Halo', () {
    test('halo radius is minimum (5px) at draper point', () {
      final body = BlackbodyBodyModel(798);
      expect(body.glowingStarHaloRadius, closeTo(5, 0.1));
    });

    test('halo radius increases with temperature', () {
      final low = BlackbodyBodyModel(2000);
      final high = BlackbodyBodyModel(6000);
      expect(high.glowingStarHaloRadius,
          greaterThan(low.glowingStarHaloRadius));
    });
  });

  group('BlackbodyBodyModel - Temperature bounds', () {
    test('min temperature is 200', () {
      expect(BlackbodySpectrumConstants.minTemperature, equals(200));
    });

    test('max temperature is 11000', () {
      expect(BlackbodySpectrumConstants.maxTemperature, equals(11000));
    });
  });
}
