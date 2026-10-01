import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/view/woas_string_painter.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WoasPlayArea core', () {
    testWidgets('renders play area with 61 bead display Ys', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();

      final ys = woasBeadDisplayYs(model);
      expect(ys.length, 61);
      expect(model.drawPositions.length, 61);
      expect(find.byType(WoasPlayArea), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('model notify updates bead display after manual seed',
        (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );

      model.setManualDisplacement(40);
      model.manualStep(frameDuration);
      await tester.pump();

      expect(woasBeadDisplayYs(model)[0], closeTo(40, 1e-6));
      expect(model.nextLeftY, closeTo(40, 1e-6));
    });

    testWidgets('boundary visual modes switch without crash', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );

      for (final end in WoasEndType.values) {
        model.setStringEndType(end);
        await tester.pump();
        expect(find.byType(WoasPlayArea), findsOneWidget);
      }
    });

    testWidgets('drive modes switch without crash', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );

      for (final mode in WoasMode.values) {
        model.setWaveMode(mode);
        await tester.pump();
        expect(find.byType(WoasPlayArea), findsOneWidget);
      }
    });

    testWidgets('paused model does not advance when clock ticks via step',
        (tester) async {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setPlaying(false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );

      final a0 = model.angle;
      model.step(0.1);
      expect(model.angle, a0);
    });
  });

  group('manual drag → model', () {
    testWidgets('vertical drag updates nextLeftY', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1024,
              height: 618,
              child: WoasPlayArea(model: model, autoStartClock: false),
            ),
          ),
        ),
      );
      await tester.pump();

      // Drag near wrench / left origin.
      final center = tester.getCenter(find.byType(WoasPlayArea));
      final start = Offset(center.dx - 300, center.dy);
      await tester.dragFrom(start, const Offset(0, -40));
      await tester.pump();

      expect(model.nextLeftY, isNot(0));
      expect(model.isPlaying, isTrue);
    });
  });

  group('tools overlays', () {
    testWidgets('rulers and stopwatch appear when visible', (tester) async {
      final model = WoasModel()
        ..setRulersVisible(true)
        ..setStopwatchVisible(true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('cm'), findsWidgets);
      expect(find.textContaining('00.'), findsOneWidget);
    });
  });
}
