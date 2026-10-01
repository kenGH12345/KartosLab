import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('magnet drag updates model position via moveMagnetToPosition',
      (tester) async {
    final model = FaradaysLawModel();
    final start = model.magnet.position;

    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: false),
      ),
    );
    await tester.pump();

    final gestureFinder = find.byKey(const Key('faradays_law_magnet_gesture'));
    expect(gestureFinder, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(gestureFinder));
    await tester.pump();
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(model.magnet.position.dx, lessThan(start.dx));
    expect(model.magnetArrowsVisible, isFalse);
    // Stays inside layout
    expect(model.magnet.bounds.left, greaterThanOrEqualTo(0));
    expect(model.magnet.bounds.right, lessThanOrEqualTo(834));
  });

  testWidgets('drag then step produces EMF from model chain', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: false),
      ),
    );
    await tester.pump();

    // Sync B at start
    model.bottomCoil.reset();
    final before = model.magnet.position;
    model.moveMagnetToPosition(
      Offset(before.dx - 120, FaradaysLawConstants.bottomCoilPosition.dy),
    );
    model.step(1 / 60);

    expect(model.bottomCoil.emf.abs(), greaterThan(0));
  });

  testWidgets('play area dispose detaches without crash', (tester) async {
    final model = FaradaysLawModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FaradaysLawScreen(model: model, autoStartClock: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // Model still usable after view dispose
    model.step(1 / 60);
    expect(model.voltage, isA<double>());
  });
}
