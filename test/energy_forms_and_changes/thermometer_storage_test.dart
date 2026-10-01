import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/transform/efac_mvt.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/temperature_and_color_sensor_widget.dart';

void main() {
  group('Thermometer storage (EFACIntroScreenView.ts)', () {
    test('storage size = nodeW×2 by nodeH×1.15', () {
      final nodeW = TemperatureAndColorSensorWidget.nominalWidth;
      final nodeH = TemperatureAndColorSensorWidget.nominalHeight;
      final storage = thermometerStorageSize(
        Size(nodeW, nodeH),
      );
      expect(storage.width, closeTo(nodeW * 2, 1e-9));
      expect(storage.height, closeTo(nodeH * 1.15, 1e-9));
    });

    test('all 4 tips share one storage model position', () {
      // PhET sets the same thermometerPositionInStorageArea for every sensor.
      final mvt = EfacMvt.intro();
      final nodeW = TemperatureAndColorSensorWidget.nominalWidth;
      final nodeH = TemperatureAndColorSensorWidget.nominalHeight;
      final storage = thermometerStorageSize(Size(nodeW, nodeH));
      const edgeInset = EfacLayoutConstants.edgeInset;
      const offsetFromBottom = 25.0;
      final tipView = Offset(
        edgeInset + (storage.width - nodeW) / 2,
        edgeInset + storage.height - offsetFromBottom,
      );
      final tipModel = mvt.viewToModel(tipView);

      final positions = List<Offset>.filled(
        EfacIntroModel.thermometerCount,
        tipModel,
      );
      expect(positions.length, 4);
      for (final p in positions) {
        expect(p.dx, closeTo(tipModel.dx, 1e-12));
        expect(p.dy, closeTo(tipModel.dy, 1e-12));
      }

      // Tip sits 25px above storage bottom (empirically from source).
      expect(tipView.dy, closeTo(edgeInset + storage.height - 25, 1e-9));
    });

    test('tipFromTop places tip at triangle center', () {
      final tipY = TemperatureAndColorSensorWidget.tipFromTop;
      final expected = TemperatureAndColorSensorWidget.nominalHeight -
          TemperatureAndColorSensorWidget.bottomOffset -
          TemperatureAndColorSensorWidget.sideLength / 2;
      expect(tipY, closeTo(expected, 1e-9));
      expect(tipY, greaterThan(0));
      expect(tipY, lessThan(TemperatureAndColorSensorWidget.nominalHeight));
    });
  });
}
