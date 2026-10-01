import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';

Widget _app(FaradaysLawModel model) {
  return MaterialApp(
    home: FaradaysLawScreen(model: model, autoStartClock: false),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1 coil / 2 coil radios set topCoilVisible', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();
    expect(model.topCoilVisible, isFalse);

    await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
    await tester.pump();
    expect(model.topCoilVisible, isTrue);

    await tester.tap(find.byKey(const Key('faradays_law_coil_single')));
    await tester.pump();
    expect(model.topCoilVisible, isFalse);

    await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
    await tester.pump();
    expect(model.topCoilVisible, isTrue);

    await tester.tap(find.byKey(const Key('faradays_law_coil_single')));
    await tester.pump();
    expect(model.topCoilVisible, isFalse);
  });
}
