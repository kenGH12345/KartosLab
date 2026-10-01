// Temperature drag interaction tests for M1.
//
// Verifies the coordinate mapping used by the thermometer drag handler:
//   phetY → temperature (via _yPosToTemperature)
//   temperature → phetY (via _temperatureToYPos + tube geometry)
//
// These tests directly exercise the model + coordinate transform layer
// that the GestureDetector in ScreenBody relies on.
//
// [来源: BlackbodySpectrumThermometer.js:91-108 (DragListener)]
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/blackbody_spectrum/blackbody_spectrum_constants.dart';
import 'package:kratos/blackbody_spectrum/model/blackbody_spectrum_model.dart';
import 'package:kratos/blackbody_spectrum/model/blackbody_body_model.dart';

// Mirror of the private helpers in ScreenBodyState. Kept in sync here so
// tests can exercise the exact math the drag handler uses.
const _thermTop = 60.0;
const _tubeH = 400.0;

double _temperatureToYPos(double temp) {
  return ((temp - BlackbodySpectrumConstants.minTemperature) /
          (BlackbodySpectrumConstants.maxTemperature -
              BlackbodySpectrumConstants.minTemperature)) *
      _tubeH;
}

double _yPosToTemperature(double phetY) {
  final yFromBottom = (_thermTop + _tubeH) - phetY;
  final ratio = yFromBottom / _tubeH;
  final clampedRatio = ratio.clamp(0.0, 1.0);
  final temp = BlackbodySpectrumConstants.minTemperature +
      clampedRatio *
          (BlackbodySpectrumConstants.maxTemperature -
              BlackbodySpectrumConstants.minTemperature);
  return (temp / 50).round() * 50.0;
}

void main() {
  group('Thermometer drag - direction', () {
    test('drag up (smaller phetY) increases temperature', () {
      // At tube bottom (phetY = 460) → min temp
      // At tube top (phetY = 60) → max temp
      final tempAtBottom = _yPosToTemperature(_thermTop + _tubeH); // 460
      final tempAtTop = _yPosToTemperature(_thermTop); // 60
      expect(tempAtBottom, lessThan(tempAtTop),
          reason: 'higher position (smaller Y) must yield higher temperature');
    });

    test('drag down (larger phetY) decreases temperature', () {
      final tempMid = _yPosToTemperature(_thermTop + _tubeH / 2); // 260
      final tempLower = _yPosToTemperature(_thermTop + _tubeH * 0.75); // 360
      expect(tempLower, lessThan(tempMid),
          reason: 'lower position (larger Y) must yield lower temperature');
    });

    test('top of tube = max temperature', () {
      final t = _yPosToTemperature(_thermTop);
      expect(t, equals(BlackbodySpectrumConstants.maxTemperature));
    });

    test('bottom of tube = min temperature', () {
      final t = _yPosToTemperature(_thermTop + _tubeH);
      expect(t, equals(BlackbodySpectrumConstants.minTemperature));
    });
  });

  group('Thermometer drag - clamp', () {
    test('above tube top clamps to max temperature', () {
      final t = _yPosToTemperature(_thermTop - 100);
      expect(t, equals(BlackbodySpectrumConstants.maxTemperature));
    });

    test('below tube bottom clamps to min temperature', () {
      final t = _yPosToTemperature(_thermTop + _tubeH + 100);
      expect(t, equals(BlackbodySpectrumConstants.minTemperature));
    });
  });

  group('Thermometer drag - snap', () {
    test('temperature snaps to 50K interval', () {
      // Pick a phetY that would produce a non-50-multiple
      // temp = 200 + ratio * 10800, ratio = (460 - 200) / 400 = 0.65
      // temp = 200 + 0.65 * 10800 = 7220 → not multiple of 50
      final t = _yPosToTemperature(200);
      expect(t % 50, equals(0.0));
    });
  });

  group('Thermometer drag - model update', () {
    test('setting temperature updates model and notifies listeners', () {
      final model = BlackbodySpectrumModel();
      var notified = 0;
      model.addListener(() => notified++);

      model.temperature = 3000;
      expect(model.temperature, equals(3000));
      expect(notified, greaterThan(0));
    });

    test('setting same temperature does not notify', () {
      final model = BlackbodySpectrumModel();
      var notified = 0;
      model.addListener(() => notified++);

      final current = model.temperature;
      model.temperature = current; // same value
      expect(notified, equals(0));
    });

    test('model clamps temperature to bounds', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 50000;
      expect(model.temperature, equals(BlackbodySpectrumConstants.maxTemperature));

      model.temperature = -1000;
      expect(model.temperature, equals(BlackbodySpectrumConstants.minTemperature));
    });
  });

  group('Thermometer drag - spectrum update', () {
    test('higher temperature → shorter peak wavelength (Wien)', () {
      final body = BlackbodyBodyModel(5800);
      final peak5800 = body.peakWavelength;

      body.temperature = 9950;
      final peak9950 = body.peakWavelength;

      expect(peak9950, lessThan(peak5800),
          reason: 'Wien: higher T → shorter λ_peak');
    });

    test('lower temperature → longer peak wavelength (Wien)', () {
      final body = BlackbodyBodyModel(5800);
      final peak5800 = body.peakWavelength;

      body.temperature = 3000;
      final peak3000 = body.peakWavelength;

      expect(peak3000, greaterThan(peak5800),
          reason: 'Wien: lower T → longer λ_peak');
    });

    test('temperature change → SPD curve changes shape', () {
      final body = BlackbodyBodyModel(5800);
      final spdAt500nm_5800 = body.getSpectralPowerDensityAt(500);

      body.temperature = 3000;
      final spdAt500nm_3000 = body.getSpectralPowerDensityAt(500);

      expect(spdAt500nm_3000, isNot(equals(spdAt500nm_5800)),
          reason: 'SPD at any fixed wavelength must change when T changes');
    });

    test('temperature change → star color changes', () {
      final body = BlackbodyBodyModel(5800);
      final color5800 = body.starColor;

      body.temperature = 9950;
      final color9950 = body.starColor;

      expect(color9950, isNot(equals(color5800)),
          reason: 'star color must change with temperature');
    });

    test('temperature change → total intensity changes (Stefan-Boltzmann)', () {
      final body = BlackbodyBodyModel(5800);
      final intensity5800 = body.totalIntensity;

      body.temperature = 3000;
      final intensity3000 = body.totalIntensity;

      expect(intensity3000, lessThan(intensity5800),
          reason: 'Stefan-Boltzmann: lower T → much lower total intensity');
    });
  });

  group('Thermometer drag - reset', () {
    test('reset restores temperature to 5800K', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 3000;
      expect(model.temperature, equals(3000));

      model.reset();
      expect(model.temperature, equals(5800));
    });

    test('reset restores all draggable state', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 9950;
      model.wavelengthMax = 1000;
      model.verticalZoom = 5;

      model.reset();

      expect(model.temperature, equals(5800));
      expect(model.wavelengthMax,
          equals(BlackbodySpectrumConstants.defaultHorizontalZoom));
      expect(model.verticalZoom,
          equals(BlackbodySpectrumConstants.defaultVerticalZoom));
    });
  });

  group('Thermometer drag - round trip consistency', () {
    test('temperature → Y → temperature is identity (within snap)', () {
      for (final temp in [200.0, 5800.0, 9950.0, 11000.0]) {
        final y = _thermTop + _tubeH - _temperatureToYPos(temp);
        final back = _yPosToTemperature(y);
        expect(back, equals(temp),
            reason: 'round-trip failed for T=$temp');
      }
    });

    test('Sun (5800K) thumb position is above midpoint', () {
      // 5800K is above the middle of [200, 11000], so thumb should be
      // in the upper half of the tube (Y < midpoint)
      final thumbY = _thermTop + _tubeH - _temperatureToYPos(5800);
      final midpoint = _thermTop + _tubeH / 2;
      expect(thumbY, lessThan(midpoint),
          reason: '5800K is above midpoint of range, thumb should be in upper half');
    });
  });
}
