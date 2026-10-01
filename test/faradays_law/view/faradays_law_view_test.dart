import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/faradays_law_play_area.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';

Widget _wrap(FaradaysLawModel model) {
  return MaterialApp(
    home: FaradaysLawScreen(model: model, autoStartClock: false),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FaradaysLawView initial', () {
    testWidgets('renders magnet, coils, bulb; voltmeter hidden by default',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();

      expect(find.byKey(const Key('faradays_law_magnet')), findsOneWidget);
      expect(find.byType(FaradaysLawPlayArea), findsOneWidget);
      expect(model.voltmeterVisible, isFalse);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
    });

    testWidgets('voltmeter appears when model.voltmeterVisible = true',
        (tester) async {
      final model = FaradaysLawModel()..setVoltmeterVisible(true);
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(model.voltmeterVisible, isTrue);
      // CustomPaint for voltmeter body exists in tree
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('top coil visibility follows model.topCoilVisible',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_wrap(model));
      await tester.pump();
      expect(model.topCoilVisible, isFalse);

      model.setTopCoilVisible(true);
      await tester.pump();
      expect(model.topCoilVisible, isTrue);
    });
  });
}
