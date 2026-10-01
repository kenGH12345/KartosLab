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

  group('visibility controls', () {
    testWidgets('Voltmeter checkbox toggles model + view state', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();
      expect(model.voltmeterVisible, isFalse);

      await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
      await tester.pump();
      expect(model.voltmeterVisible, isTrue);

      await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
      await tester.pump();
      expect(model.voltmeterVisible, isFalse);

      await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
      await tester.pump();
      expect(model.voltmeterVisible, isTrue);
    });

    testWidgets('Field Lines checkbox toggles model.fieldLines.visible',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();
      expect(model.fieldLines.visible, isFalse);

      await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
      await tester.pump();
      expect(model.fieldLines.visible, isTrue);
      expect(model.magnet.fieldLinesVisible, isTrue);

      await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
      await tester.pump();
      expect(model.fieldLines.visible, isFalse);
    });
  });
}
