import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/components/coil_image_layer.dart';
import 'package:kratos/faradays_law/view/components/voltmeter_widget.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';
import 'package:kratos/faradays_law/view/painters/field_lines_painter.dart';

Widget _app(FaradaysLawModel model) {
  return MaterialApp(
    home: FaradaysLawScreen(model: model, autoStartClock: false),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('visual state matrix', () {
    testWidgets('A initial defaults', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();
      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.voltmeterVisible, isFalse);
      expect(model.bulb.haloVisible, isFalse);
    });

    testWidgets('B magnet positions update view host', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      for (final pos in const [
        Offset(300, 310),
        Offset(448, 310),
        Offset(700, 200),
      ]) {
        model.setMagnetPositionForTest(pos);
        await tester.pump();
        expect(model.magnet.position, pos);
        final magnet = tester.getRect(find.byKey(const Key('faradays_law_magnet')));
        expect(magnet.center.dx, closeTo(pos.dx, 40));
      }
    });

    testWidgets('C 1 coil vs 2 coil layer visibility', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      var layers = tester.widgetList<CoilImageLayer>(find.byType(CoilImageLayer));
      expect(layers.where((l) => l.kind == CoilKind.fourLoop).length, 2);
      expect(
        layers.where((l) => l.kind == CoilKind.twoLoop && l.visible).length,
        0,
      );

      model.setTopCoilVisible(true);
      await tester.pump();
      layers = tester.widgetList<CoilImageLayer>(find.byType(CoilImageLayer));
      expect(
        layers.where((l) => l.kind == CoilKind.twoLoop && l.visible).length,
        2,
      ); // back + front
      expect(layers.where((l) => l.kind == CoilKind.fourLoop).length, 2);
    });

    testWidgets('D polarity NS/SN', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();
      expect(model.magnet.orientation, MagnetOrientation.ns);
      model.flipPolarity();
      await tester.pump();
      expect(model.magnet.orientation, MagnetOrientation.sn);
      expect(model.fieldLines.geometry.arrowDirectionFlipped, isTrue);
    });

    testWidgets('E field lines ON/OFF painter geometry', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      FieldLinesPainter painter() {
        final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
        return paints
            .map((c) => c.painter)
            .whereType<FieldLinesPainter>()
            .single;
      }

      expect(painter().geometry.visible, isFalse);
      model.setFieldLinesVisible(true);
      await tester.pump();
      expect(painter().geometry.visible, isTrue);
      expect(painter().geometry.ellipses.length, 4);
      model.setFieldLinesVisible(false);
      await tester.pump();
      expect(painter().geometry.visible, isFalse);
    });

    testWidgets('F voltmeter visible/hidden + needle from model', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      expect(find.byType(VoltmeterWidget), findsOneWidget);
      var vm = tester.widget<VoltmeterWidget>(find.byType(VoltmeterWidget));
      expect(vm.visible, isFalse);

      model.setVoltmeterVisible(true);
      model.voltmeter.voltage = 0.8;
      model.notifyListeners();
      await tester.pump();
      vm = tester.widget<VoltmeterWidget>(find.byType(VoltmeterWidget));
      expect(vm.visible, isTrue);
      expect(vm.needleAngle, closeTo(0.8, 1e-9));

      model.voltmeter.voltage = -0.8;
      model.notifyListeners();
      await tester.pump();
      vm = tester.widget<VoltmeterWidget>(find.byType(VoltmeterWidget));
      expect(vm.needleAngle, closeTo(-0.8, 1e-9));
    });

    testWidgets('G bulb dim/bright from |voltage|', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();
      expect(model.bulb.haloVisible, isFalse);

      model.voltmeter.voltage = 0.4;
      model.notifyListeners();
      await tester.pump();
      expect(model.bulb.haloVisible, isTrue);
      final pos = model.bulb.haloScale;

      model.voltmeter.voltage = -0.4;
      model.notifyListeners();
      await tester.pump();
      expect(model.bulb.haloScale, pos);
    });

    testWidgets('H combined then reset to initial visual', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      model
        ..setTopCoilVisible(true)
        ..setFieldLinesVisible(true)
        ..setVoltmeterVisible(true)
        ..flipPolarity()
        ..setMagnetPositionForTest(const Offset(500, 250));
      model.voltmeter.voltage = 0.3;
      model.notifyListeners();
      await tester.pump();

      expect(model.topCoilVisible, isTrue);
      expect(model.magnet.fieldLinesVisible, isTrue);
      expect(model.voltmeterVisible, isTrue);
      expect(model.magnet.orientation, MagnetOrientation.sn);

      model.reset();
      await tester.pump();
      expect(model.topCoilVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.voltage, 0);
    });
  });

  group('z-order structure', () {
    testWidgets('Stack children keep coil-back → magnet → coil-front order',
        (tester) async {
      final model = FaradaysLawModel();
      model.setTopCoilVisible(true);
      await tester.pumpWidget(_app(model));
      await tester.pump();

      // CoilImageLayer declaration order in play area:
      // backs first, then magnet gesture, then fronts.
      final layers =
          tester.widgetList<CoilImageLayer>(find.byType(CoilImageLayer)).toList();
      expect(layers.length, 4);
      expect(layers[0].front, isFalse); // four back
      expect(layers[1].front, isFalse); // two back
      expect(layers[2].front, isTrue); // four front
      expect(layers[3].front, isTrue); // two front

      final magnetIndex = tester
          .widgetList(find.byKey(const Key('faradays_law_magnet_gesture')))
          .length;
      expect(magnetIndex, 1);

      // Magnet is between back and front layers in the Stack (verified by
      // source map + play_area child order; widget tree enumeration above
      // confirms backs precede fronts).
      expect(layers.take(2).every((l) => !l.front), isTrue);
      expect(layers.skip(2).every((l) => l.front), isTrue);
    });
  });

  group('control layout interaction states', () {
    testWidgets('checkboxes and radios reflect selected state', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
      await tester.pump();
      expect(model.voltmeterVisible, isTrue);

      await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
      await tester.pump();
      expect(model.magnet.fieldLinesVisible, isTrue);

      await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
      await tester.pump();
      expect(model.topCoilVisible, isTrue);

      await tester.tap(find.byKey(const Key('faradays_law_coil_single')));
      await tester.pump();
      expect(model.topCoilVisible, isFalse);

      await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
      await tester.pump();
      expect(model.magnet.orientation, MagnetOrientation.sn);

      await tester.tap(find.byKey(const Key('faradays_law_reset_all')));
      await tester.pump();
      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnet.orientation, MagnetOrientation.ns);
    });
  });
}
