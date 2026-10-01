import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('polarity flip updates magnet orientation state for view',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: false),
      ),
    );
    await tester.pump();
    expect(model.magnet.orientation, MagnetOrientation.ns);

    model.flipPolarity();
    await tester.pump();
    expect(model.magnet.orientation, MagnetOrientation.sn);
    expect(model.fieldLines.geometry.arrowDirectionFlipped, isTrue);
  });

  testWidgets('field lines visibility toggles via model API', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: false),
      ),
    );
    await tester.pump();
    expect(model.fieldLines.visible, isFalse);

    model.setFieldLinesVisible(true);
    await tester.pump();
    expect(model.fieldLines.visible, isTrue);
  });

  testWidgets('voltage change updates bulb brightness from model',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: false),
      ),
    );
    await tester.pump();
    expect(model.bulb.brightness, 0);

    model.voltmeter.voltage = 0.5;
    model.notifyListeners();
    await tester.pump();
    expect(model.bulb.brightness, greaterThan(0));

    model.voltmeter.voltage = -0.5;
    model.notifyListeners();
    await tester.pump();
    expect(model.bulb.brightness, greaterThan(0));
  });

  testWidgets('model.reset restores visual-driving initial state',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: false),
      ),
    );
    await tester.pump();

    model
      ..setVoltmeterVisible(true)
      ..setFieldLinesVisible(true)
      ..setTopCoilVisible(true)
      ..flipPolarity()
      ..setMagnetPositionForTest(const Offset(448, 310));
    model.step(0.05);
    await tester.pump();

    model.reset();
    await tester.pump();

    expect(model.voltmeterVisible, isFalse);
    expect(model.magnet.fieldLinesVisible, isFalse);
    expect(model.topCoilVisible, isFalse);
    expect(model.magnet.orientation, MagnetOrientation.ns);
    expect(model.voltage, 0);
    expect(model.magnetArrowsVisible, isTrue);
  });
}
