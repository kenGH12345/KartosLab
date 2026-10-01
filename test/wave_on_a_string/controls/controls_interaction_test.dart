import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

Widget _harness(WoasModel model) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1024,
        height: 618,
        child: WoasPlayArea(model: model, autoStartClock: false),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('drive mode control', () {
    testWidgets('Manual → Oscillate → Pulse → Manual', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));

      expect(find.text('Damping'), findsOneWidget);
      expect(find.text('Frequency'), findsNothing);

      await tester.tap(find.text('Oscillate'));
      await tester.pump();
      expect(model.waveMode, WoasMode.oscillate);
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Amplitude'), findsOneWidget);
      expect(find.text('Pulse Width'), findsNothing);

      await tester.tap(find.text('Pulse'));
      await tester.pump();
      expect(model.waveMode, WoasMode.pulse);
      expect(find.text('Pulse Width'), findsOneWidget);
      expect(find.text('Frequency'), findsNothing);

      await tester.tap(find.text('Manual'));
      await tester.pump();
      expect(model.waveMode, WoasMode.manual);
      expect(find.text('Amplitude'), findsNothing);
    });

    testWidgets('mode switch restarts wave not ResetAll', (tester) async {
      final model = WoasModel()..setAmplitudeCm(1.1)..setDamping(0.6);
      await tester.pumpWidget(_harness(model));
      model.debugSeedBead(index: 8, yNow: 5, yLast: 5);
      await tester.tap(find.text('Oscillate'));
      await tester.pump();
      expect(model.yNowAt(8), 0);
      expect(model.amplitudeCm, 1.1);
      expect(model.damping, 0.6);
    });
  });

  group('boundary control', () {
    testWidgets('Fixed → Loose → No End', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));

      await tester.tap(find.text('Loose End'));
      await tester.pump();
      expect(model.stringEndType, WoasEndType.looseEnd);

      model.debugSeedBead(index: 10, yNow: 3, yLast: 3);
      await tester.tap(find.text('No End'));
      await tester.pump();
      expect(model.stringEndType, WoasEndType.noEnd);
      expect(model.yNowAt(10), 3); // no full restart

      await tester.tap(find.text('Fixed End'));
      await tester.pump();
      expect(model.stringEndType, WoasEndType.fixedEnd);
      expect(model.yNowAt(10), 3);
      expect(model.yNowAt(lastIndex), 0);
    });
  });

  group('parameter controls', () {
    testWidgets('amplitude / frequency / damping / tension arrows',
        (tester) async {
      final model = WoasModel()..setWaveMode(WoasMode.oscillate);
      await tester.pumpWidget(_harness(model));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('Amplitude_inc')));
      await tester.pump();
      expect(model.amplitudeCm, closeTo(0.76, 1e-9));

      await tester.tap(find.byKey(const ValueKey('Frequency_dec')));
      await tester.pump();
      expect(model.frequencyHz, closeTo(1.49, 1e-9));

      await tester.tap(find.byKey(const ValueKey('Damping_inc')));
      await tester.pump();
      expect(model.damping, closeTo(0.21, 1e-9));

      await tester.tap(find.byKey(const ValueKey('Tension_dec')));
      await tester.pump();
      expect(model.tension, closeTo(0.79, 1e-9));
    });

    testWidgets('pulse width only in Pulse mode', (tester) async {
      final model = WoasModel()..setWaveMode(WoasMode.pulse);
      await tester.pumpWidget(_harness(model));
      await tester.pump();
      expect(find.byKey(const Key('pulse_width_control')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('Pulse Width_inc')));
      await tester.pump();
      expect(model.pulseWidthS, closeTo(0.51, 1e-9));
    });
  });

  group('pause / speed', () {
    testWidgets('pause freezes model.step; step button advances',
        (tester) async {
      final model = WoasModel()..setWaveMode(WoasMode.oscillate);
      await tester.pumpWidget(_harness(model));

      await tester.tap(find.byKey(const Key('play_pause_button')));
      await tester.pump();
      expect(model.isPlaying, isFalse);
      final a = model.angle;
      model.step(0.1);
      expect(model.angle, a);

      await tester.tap(find.byKey(const Key('step_button')));
      await tester.pump();
      expect(model.angle, isNot(a));
    });

    testWidgets('Slow Motion sets speedMultiplier path', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));
      await tester.tap(find.byKey(const Key('speed_slow')));
      await tester.pump();
      expect(model.timeSpeed, WoasTimeSpeed.slow);
      await tester.tap(find.byKey(const Key('speed_normal')));
      await tester.pump();
      expect(model.timeSpeed, WoasTimeSpeed.normal);
    });
  });

  group('tools', () {
    testWidgets('Rulers / Stopwatch / Reference Line toggles', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));

      await tester.tap(find.byKey(const Key('rulers_checkbox')));
      await tester.pump();
      expect(model.rulersVisible, isTrue);
      expect(find.textContaining('cm'), findsWidgets);

      await tester.tap(find.byKey(const Key('stopwatch_checkbox')));
      await tester.pump();
      expect(model.stopwatch.isVisible, isTrue);

      await tester.tap(find.byKey(const Key('reference_line_checkbox')));
      await tester.pump();
      expect(model.referenceLineVisible, isTrue);
    });
  });
}
