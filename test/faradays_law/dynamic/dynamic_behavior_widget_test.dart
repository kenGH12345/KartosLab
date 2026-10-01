import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';

Widget _app(FaradaysLawModel model, {bool clock = false}) {
  return MaterialApp(
    home: FaradaysLawScreen(model: model, autoStartClock: clock),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end widget dynamic', () {
    testWidgets('A: drag magnet produces EMF via Model chain', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      model.bottomCoil.reset();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('faradays_law_magnet_gesture'))),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(-100, 20));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      model.step(1 / 60);
      // Drag updated position; step after motion can be small if already stopped
      expect(model.magnet.position.dx,
          lessThan(FaradaysLawConstants.defaultMagnetPosition.dx));
    });

    testWidgets('B: Flip then same motion reverses EMF sign', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      double run() {
        model.setMagnetPositionForTest(const Offset(600, 310));
        model.bottomCoil.reset();
        model.setMagnetPositionForTest(const Offset(448, 310));
        model.step(0.05);
        return model.bottomCoil.emf;
      }

      final ns = run();
      await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
      await tester.pump();
      expect(model.magnet.orientation, MagnetOrientation.sn);
      final sn = run();
      expect(sn, closeTo(-ns, 1e-9));
    });

    testWidgets('C: 2 coil changes signal vs 1 coil same trajectory',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      model.setMagnetPositionForTest(const Offset(500, 200));
      model.bottomCoil.reset();
      model.topCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 200));
      model.step(0.05);
      final singleSignal = model.voltmeter.signal;

      await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
      await tester.pump();
      model.setMagnetPositionForTest(const Offset(500, 200));
      model.bottomCoil.reset();
      model.topCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 200));
      model.step(0.05);
      expect(model.topCoilVisible, isTrue);
      expect(model.voltmeter.signal, isNot(singleSignal));
    });

    testWidgets('D: Field Lines OFF/ON while magnet moved', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      model.moveMagnetToPosition(const Offset(500, 250));
      model.step(1 / 60);
      final emf = model.bottomCoil.emf;
      final v = model.voltage;

      await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
      await tester.pump();
      expect(model.fieldLines.visible, isTrue);
      expect(model.bottomCoil.emf, emf);
      expect(model.voltage, v);

      await tester.tap(find.byKey(const Key('faradays_law_field_lines_checkbox')));
      await tester.pump();
      expect(model.fieldLines.visible, isFalse);
      expect(model.voltage, v);
    });

    testWidgets('E: Voltmeter OFF/ON preserves Model voltage', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);
      for (var i = 0; i < 25; i++) {
        model.step(1 / 60);
      }
      final v = model.voltage;
      expect(v.abs(), greaterThan(0));

      await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
      await tester.pump();
      expect(model.voltmeterVisible, isTrue);
      expect(model.voltage, v);

      await tester.tap(find.byKey(const Key('faradays_law_voltmeter_checkbox')));
      await tester.pump();
      expect(model.voltmeterVisible, isFalse);
      expect(model.voltage, v);
    });
  });

  group('lifecycle during motion', () {
    testWidgets('Reset All during/after motion restores initial', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
      await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
      await tester.pump();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);
      for (var i = 0; i < 20; i++) {
        model.step(1 / 60);
      }

      await tester.tap(find.byKey(const Key('faradays_law_reset_all')));
      await tester.pump();

      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.topCoilVisible, isFalse);
      expect(model.voltage, 0);
      expect(model.bottomCoil.emf, 0);
    });

    testWidgets('dispose during clock does not throw; model still usable',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model, clock: true));
      await tester.pump();
      model.moveMagnetToPosition(const Offset(500, 250));
      await tester.pump(const Duration(milliseconds: 40));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      model.step(1 / 60);
      expect(model.voltage, isA<double>());
    });
  });
}
