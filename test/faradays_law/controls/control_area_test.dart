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

  testWidgets('control area renders all source controls', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(_app(model));
    await tester.pump();

    expect(find.byKey(const Key('faradays_law_voltmeter_checkbox')), findsOneWidget);
    expect(find.byKey(const Key('faradays_law_field_lines_checkbox')), findsOneWidget);
    expect(find.byKey(const Key('faradays_law_coil_single')), findsOneWidget);
    expect(find.byKey(const Key('faradays_law_coil_double')), findsOneWidget);
    expect(find.byKey(const Key('faradays_law_flip_magnet')), findsOneWidget);
    expect(find.byKey(const Key('faradays_law_reset_all')), findsOneWidget);
    expect(find.text('Voltmeter'), findsOneWidget);
    expect(find.text('Field Lines'), findsOneWidget);
  });
}
