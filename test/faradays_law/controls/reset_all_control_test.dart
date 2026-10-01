import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';

Widget _app(FaradaysLawModel model) {
  return MaterialApp(
    home: FaradaysLawScreen(model: model, autoStartClock: false),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Reset All restores source initial state after mutations',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();

    await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
    await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
    await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
    await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
    await tester.pump();

    model.setMagnetPositionForTest(const Offset(448, 310));
    model.step(0.05);
    for (var i = 0; i < 20; i++) {
      model.step(1 / 60);
    }
    await tester.pump();

    expect(model.voltmeterVisible, isTrue);
    expect(model.magnet.fieldLinesVisible, isTrue);
    expect(model.topCoilVisible, isTrue);
    expect(model.magnet.orientation, MagnetOrientation.sn);

    await tester.tap(find.byKey(const Key('faradays_law_reset_all')));
    await tester.pump();

    expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
    expect(model.magnet.orientation, MagnetOrientation.ns);
    expect(model.topCoilVisible, isFalse);
    expect(model.voltmeterVisible, isFalse);
    expect(model.magnet.fieldLinesVisible, isFalse);
    expect(model.magnetArrowsVisible, isTrue);
    expect(model.voltage, 0);
    expect(model.bottomCoil.emf, 0);
    expect(model.bulb.brightness, 0);
  });
}
