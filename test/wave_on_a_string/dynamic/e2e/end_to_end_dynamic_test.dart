import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/view/woas_string_painter.dart';
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

  testWidgets('E2E-A Manual displace → step → propagation in view',
      (tester) async {
    final model = WoasModel()..setDamping(0);
    await tester.pumpWidget(_harness(model));
    model.setManualDisplacement(40);
    for (var i = 0; i < 12; i++) {
      model.manualStep(frameDuration);
      model.nextLeftY = 40;
    }
    await tester.pump();
    expect(woasBeadDisplayYs(model)[0], closeTo(40, 1e-6));
    var energy = 0.0;
    for (final y in woasBeadDisplayYs(model)) {
      energy += y.abs();
    }
    expect(energy, greaterThan(40));
  });

  testWidgets('E2E-B Oscillate + amp/freq live update', (tester) async {
    final model = WoasModel();
    await tester.pumpWidget(_harness(model));
    await tester.tap(find.text('Oscillate'));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      model.manualStep(frameDuration);
    }
    model.setAmplitudeCm(1.2);
    model.setFrequencyHz(2.0);
    await tester.pump();
    expect(model.amplitudeCm, 1.2);
    expect(model.frequencyHz, 2.0);
    expect(model.yNowAt(0), isNot(0));
  });

  testWidgets('E2E-C Pulse trigger propagates', (tester) async {
    final model = WoasModel()..setDamping(0);
    await tester.pumpWidget(_harness(model));
    await tester.tap(find.text('Pulse'));
    await tester.pump();
    model.triggerPulse();
    for (var i = 0; i < 60; i++) {
      model.manualStep(frameDuration);
    }
    await tester.pump();
    var energy = 0.0;
    for (var i = 1; i < numberOfBeads; i++) {
      energy += model.yNowAt(i).abs();
    }
    expect(energy, greaterThan(0));
  });

  testWidgets('E2E-D Fixed → Loose → No End', (tester) async {
    final model = WoasModel();
    await tester.pumpWidget(_harness(model));
    await tester.tap(find.text('Loose End'));
    await tester.pump();
    expect(model.stringEndType, WoasEndType.looseEnd);
    await tester.tap(find.text('No End'));
    await tester.pump();
    expect(model.stringEndType, WoasEndType.noEnd);
    await tester.tap(find.text('Fixed End'));
    await tester.pump();
    expect(model.stringEndType, WoasEndType.fixedEnd);
  });

  testWidgets('E2E-E Pause → Step → Play', (tester) async {
    final model = WoasModel()..setWaveMode(WoasMode.oscillate);
    await tester.pumpWidget(_harness(model));
    for (var i = 0; i < 5; i++) {
      model.manualStep(frameDuration);
    }
    await tester.tap(find.byKey(const Key('play_pause_button')));
    await tester.pump();
    expect(model.isPlaying, isFalse);
    final a0 = model.angle;
    await tester.tap(find.byKey(const Key('step_button')));
    await tester.pump();
    expect(model.angle, isNot(a0));
    await tester.tap(find.byKey(const Key('play_pause_button')));
    await tester.pump();
    expect(model.isPlaying, isTrue);
  });

  testWidgets('E2E-F Slow → Normal', (tester) async {
    final model = WoasModel()..setWaveMode(WoasMode.oscillate);
    await tester.pumpWidget(_harness(model));
    await tester.tap(find.text('Slow Motion'));
    await tester.pump();
    expect(model.timeSpeed, WoasTimeSpeed.slow);
    await tester.tap(find.text('Normal'));
    await tester.pump();
    expect(model.timeSpeed, WoasTimeSpeed.normal);
  });

  testWidgets('E2E-G Restart keeps parameters', (tester) async {
    final model = WoasModel()
      ..setWaveMode(WoasMode.oscillate)
      ..setAmplitudeCm(1.1)
      ..setDamping(0.6);
    await tester.pumpWidget(_harness(model));
    for (var i = 0; i < 15; i++) {
      model.manualStep(frameDuration);
    }
    await tester.tap(find.byKey(const Key('restart_button')));
    await tester.pump();
    expect(model.amplitudeCm, 1.1);
    expect(model.damping, 0.6);
    expect(model.waveMode, WoasMode.oscillate);
    expect(model.yNowAt(5), 0);
  });

  testWidgets('E2E-H Reset All restores defaults', (tester) async {
    final model = WoasModel()
      ..setWaveMode(WoasMode.pulse)
      ..setAmplitudeCm(1.2)
      ..setDamping(0.9)
      ..setPlaying(false)
      ..setTimeSpeed(WoasTimeSpeed.slow)
      ..setRulersVisible(true);
    await tester.pumpWidget(_harness(model));
    await tester.tap(find.byKey(const Key('reset_all_button')));
    await tester.pump();
    expect(model.waveMode, WoasMode.manual);
    expect(model.amplitudeCm, closeTo(0.75, 1e-12));
    expect(model.damping, closeTo(0.2, 1e-12));
    expect(model.isPlaying, isTrue);
    expect(model.timeSpeed, WoasTimeSpeed.normal);
    expect(model.rulersVisible, isFalse);
  });
}
