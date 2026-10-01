import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('Flip Magnet toggles NS <-> SN and field-line arrow flag',
      (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();
    expect(model.magnet.orientation, MagnetOrientation.ns);

    await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
    await tester.pump();
    expect(model.magnet.orientation, MagnetOrientation.sn);
    expect(model.fieldLines.geometry.arrowDirectionFlipped, isTrue);

    await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
    await tester.pump();
    expect(model.magnet.orientation, MagnetOrientation.ns);
    expect(model.fieldLines.geometry.arrowDirectionFlipped, isFalse);
  });

  testWidgets('Flip reverses EMF sign for same magnet motion', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();

    double emfForOrientation() {
      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);
      return model.bottomCoil.emf;
    }

    final ns = emfForOrientation();
    await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
    await tester.pump();
    final sn = emfForOrientation();
    expect(sn, closeTo(-ns, 1e-9));
  });
}
