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

  testWidgets('compound: 2 coil + toggles + flip + move + Reset', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();

    await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
    await tester.pump();
    expect(model.fieldLines.visible, isTrue);
    await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
    await tester.pump();
    expect(model.fieldLines.visible, isFalse);
    expect(model.topCoilVisible, isTrue);

    await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
    await tester.pump();
    model.moveMagnetToPosition(const Offset(500, 250));
    model.step(1 / 60);
    await tester.pump();

    await tester.tap(find.byKey(const Key('faradays_law_reset_all')));
    await tester.pump();

    expect(model.topCoilVisible, isFalse);
    expect(model.magnet.orientation, MagnetOrientation.ns);
    expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
    expect(model.voltmeterVisible, isFalse);
    expect(model.magnet.fieldLinesVisible, isFalse);
  });

  testWidgets('compound: 1 coil + Field ON + Voltmeter ON + move + Flip',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();

    expect(model.topCoilVisible, isFalse);
    await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
    await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
    await tester.pump();
    expect(model.fieldLines.visible, isTrue);
    expect(model.voltmeterVisible, isTrue);

    final before = model.magnet.orientation;
    model.setMagnetPositionForTest(const Offset(600, 310));
    model.bottomCoil.reset();
    model.setMagnetPositionForTest(const Offset(448, 310));
    model.step(0.05);
    final emfBeforeFlip = model.bottomCoil.emf;

    await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
    await tester.pump();
    expect(model.magnet.orientation, isNot(before));

    model.setMagnetPositionForTest(const Offset(600, 310));
    model.bottomCoil.reset();
    model.setMagnetPositionForTest(const Offset(448, 310));
    model.step(0.05);
    expect(model.bottomCoil.emf, closeTo(-emfBeforeFlip, 1e-9));

    // No state leak: visibility still on
    expect(model.voltmeterVisible, isTrue);
    expect(model.fieldLines.visible, isTrue);
    expect(model.topCoilVisible, isFalse);
  });

  testWidgets('control state sync: Model API reflects in control bindings',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();

    model.setVoltmeterVisible(true);
    model.setFieldLinesVisible(true);
    model.setTopCoilVisible(true);
    await tester.pump();

    expect(model.voltmeterVisible, isTrue);
    expect(model.magnet.fieldLinesVisible, isTrue);
    expect(model.topCoilVisible, isTrue);

    // Tapping single coil clears top
    await tester.tap(find.byKey(const Key('faradays_law_coil_single')));
    await tester.pump();
    expect(model.topCoilVisible, isFalse);
  });
}
