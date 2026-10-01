import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/blackbody_spectrum/blackbody_spectrum_constants.dart';
import 'package:kratos/blackbody_spectrum/model/blackbody_spectrum_model.dart';

void main() {
  group('BlackbodySpectrumModel - Initial state', () {
    test('main body temperature is sun (5800K)', () {
      final model = BlackbodySpectrumModel();
      expect(model.temperature, equals(5800));
    });

    test('saved bodies are null initially', () {
      final model = BlackbodySpectrumModel();
      expect(model.savedBodyOne.temperature, isNull);
      expect(model.savedBodyTwo.temperature, isNull);
    });

    test('visibility flags are false initially', () {
      final model = BlackbodySpectrumModel();
      expect(model.graphValuesVisible, isFalse);
      expect(model.intensityVisible, isFalse);
      expect(model.labelsVisible, isFalse);
    });

    test('wavelengthMax is 3000 initially', () {
      final model = BlackbodySpectrumModel();
      expect(model.wavelengthMax, equals(3000));
    });
  });

  group('BlackbodySpectrumModel - Temperature', () {
    test('set temperature clamps to valid range', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 50;
      expect(model.temperature, equals(200));

      model.temperature = 99999;
      expect(model.temperature, equals(11000));
    });

    test('set temperature notifies listeners', () {
      final model = BlackbodySpectrumModel();
      var notified = false;
      model.addListener(() => notified = true);
      model.temperature = 3000;
      expect(notified, isTrue);
    });
  });

  group('BlackbodySpectrumModel - Save / Erase', () {
    test('saveMainBody stores temperature in savedBodyOne', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 3000;
      model.saveMainBody();
      expect(model.savedBodyOne.temperature, equals(3000));
      expect(model.savedBodyTwo.temperature, isNull);
    });

    test('saveMainBody twice uses FIFO (body1→body2, new→body1)', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 3000;
      model.saveMainBody();
      model.temperature = 5000;
      model.saveMainBody();
      expect(model.savedBodyOne.temperature, equals(5000));
      expect(model.savedBodyTwo.temperature, equals(3000));
    });

    test('clearSavedGraphs sets both to null', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 3000;
      model.saveMainBody();
      model.clearSavedGraphs();
      expect(model.savedBodyOne.temperature, isNull);
      expect(model.savedBodyTwo.temperature, isNull);
    });
  });

  group('BlackbodySpectrumModel - Zoom', () {
    test('zoomHorizontalIn halves wavelengthMax', () {
      final model = BlackbodySpectrumModel();
      final initial = model.wavelengthMax;
      model.zoomHorizontalIn();
      expect(model.wavelengthMax, equals(initial / 2));
    });

    test('zoomHorizontalOut doubles wavelengthMax', () {
      final model = BlackbodySpectrumModel();
      final initial = model.wavelengthMax;
      model.zoomHorizontalOut();
      expect(model.wavelengthMax, equals(initial * 2));
    });

    test('zoom clamps to bounds', () {
      final model = BlackbodySpectrumModel();
      // Zoom in many times
      for (var i = 0; i < 20; i++) {
        model.zoomHorizontalIn();
      }
      expect(model.wavelengthMax,
          equals(BlackbodySpectrumConstants.minHorizontalZoom));

      // Reset and zoom out many times
      model.reset();
      for (var i = 0; i < 20; i++) {
        model.zoomHorizontalOut();
      }
      expect(model.wavelengthMax,
          equals(BlackbodySpectrumConstants.maxHorizontalZoom));
    });
  });

  group('BlackbodySpectrumModel - Reset', () {
    test('reset restores all defaults', () {
      final model = BlackbodySpectrumModel();
      model.temperature = 3000;
      model.saveMainBody();
      model.setGraphValuesVisible(true);
      model.zoomHorizontalOut();

      model.reset();

      expect(model.temperature, equals(5800));
      expect(model.savedBodyOne.temperature, isNull);
      expect(model.savedBodyTwo.temperature, isNull);
      expect(model.graphValuesVisible, isFalse);
      expect(model.wavelengthMax, equals(3000));
    });
  });
}
