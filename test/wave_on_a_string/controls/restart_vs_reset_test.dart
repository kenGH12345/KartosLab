import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/view/controls/woas_time_controls.dart';
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

  testWidgets('Restart clears wave, keeps controls', (tester) async {
    final model = WoasModel()
      ..setWaveMode(WoasMode.oscillate)
      ..setStringEndType(WoasEndType.looseEnd)
      ..setAmplitudeCm(1.2)
      ..setFrequencyHz(2.0)
      ..setDamping(0.5)
      ..setTension(0.4)
      ..setTimeSpeed(WoasTimeSpeed.slow)
      ..setPlaying(false)
      ..setRulersVisible(true);

    await tester.pumpWidget(_harness(model));
    for (var i = 0; i < 15; i++) {
      model.manualStep(frameDuration);
    }
    expect(model.yNowAt(0), isNot(0));

    await tester.tap(find.byKey(const Key('restart_button')));
    await tester.pump();

    for (var i = 0; i < numberOfBeads; i++) {
      expect(model.yNowAt(i), 0);
    }
    expect(model.waveMode, WoasMode.oscillate);
    expect(model.stringEndType, WoasEndType.looseEnd);
    expect(model.amplitudeCm, 1.2);
    expect(model.frequencyHz, 2.0);
    expect(model.damping, 0.5);
    expect(model.tension, 0.4);
    expect(model.timeSpeed, WoasTimeSpeed.slow);
    expect(model.isPlaying, isFalse);
    expect(model.rulersVisible, isTrue);
  });

  testWidgets('Reset All restores source defaults', (tester) async {
    final model = WoasModel()
      ..setWaveMode(WoasMode.pulse)
      ..setStringEndType(WoasEndType.noEnd)
      ..setAmplitudeCm(1.2)
      ..setFrequencyHz(2.5)
      ..setPulseWidthS(0.9)
      ..setDamping(0.9)
      ..setTension(0.3)
      ..setTimeSpeed(WoasTimeSpeed.slow)
      ..setPlaying(false)
      ..setRulersVisible(true)
      ..setStopwatchVisible(true)
      ..setReferenceLineVisible(true);

    await tester.pumpWidget(_harness(model));
    model.triggerPulse();
    for (var i = 0; i < 10; i++) {
      model.manualStep(frameDuration);
    }

    await tester.tap(find.byKey(const Key('reset_all_button')));
    await tester.pump();

    expect(model.waveMode, WoasMode.manual);
    expect(model.stringEndType, WoasEndType.fixedEnd);
    expect(model.amplitudeCm, closeTo(0.75, 1e-12));
    expect(model.frequencyHz, closeTo(1.50, 1e-12));
    expect(model.pulseWidthS, closeTo(0.5, 1e-12));
    expect(model.damping, closeTo(0.2, 1e-12));
    expect(model.tension, closeTo(0.8, 1e-12));
    expect(model.isPlaying, isTrue);
    expect(model.timeSpeed, WoasTimeSpeed.normal);
    expect(model.rulersVisible, isFalse);
    expect(model.stopwatch.isVisible, isFalse);
    expect(model.referenceLineVisible, isFalse);
    for (var i = 0; i < numberOfBeads; i++) {
      expect(model.yNowAt(i), 0);
    }
  });

  testWidgets('Restart ≠ ResetAll', (tester) async {
    final model = WoasModel()..setAmplitudeCm(1.0)..setDamping(0.7);
    await tester.pumpWidget(_harness(model));

    await tester.tap(find.byKey(const Key('restart_button')));
    await tester.pump();
    expect(model.amplitudeCm, 1.0);
    expect(model.damping, 0.7);

    await tester.tap(find.byKey(const Key('reset_all_button')));
    await tester.pump();
    expect(model.amplitudeCm, closeTo(0.75, 1e-12));
    expect(model.damping, closeTo(0.2, 1e-12));
  });

  testWidgets('Restart uses LIGHT_BLUE undo button not circular refresh',
      (tester) async {
    await tester.pumpWidget(_harness(WoasModel()));
    expect(find.byKey(const Key('restart_button')), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(WoasRestartButton), findsOneWidget);
    expect(WoasRestartButton.buttonSize, const Size(40, 40));
    expect(
      WoasRestartButton.lightBlue,
      const Color.fromARGB(255, 153, 206, 255),
    );
  });
}
