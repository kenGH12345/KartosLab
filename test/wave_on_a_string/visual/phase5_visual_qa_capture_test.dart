import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/view/woas_layout.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/view/woas_string_painter.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Phase 5 Final Visual QA — capture matrix (not golden pixel gate).
///
/// Output: `requirements/req-wave-on-a-string/visual-qa/screenshots/`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outDir = 'requirements/req-wave-on-a-string/visual-qa/screenshots';
  const viewport = Size(woasLayoutWidth, woasLayoutHeight);

  Future<void> capture(
    WidgetTester tester,
    String name,
    WoasModel model, {
    Future<void> Function(WoasModel)? prepare,
  }) async {
    Directory(outDir).createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    if (prepare != null) {
      await prepare(model);
    }

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(woasBackgroundArgb),
          body: Center(
            child: SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: RepaintBoundary(
                key: key,
                child: WoasPlayArea(model: model, autoStartClock: false),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    // Structural asserts (visual presentation of Model state).
    expect(model.drawPositions.length, 61);
    expect(woasBeadDisplayYs(model).length, 61);

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$outDir/$name.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      File('$outDir/$name.meta.txt').writeAsStringSync(
        'name=$name\n'
        'viewport=${viewport.width.toInt()}x${viewport.height.toInt()}\n'
        'mode=${model.waveMode.name}\n'
        'end=${model.stringEndType.name}\n'
        'amp=${model.amplitudeCm}\n'
        'freq=${model.frequencyHz}\n'
        'pulse=${model.pulseWidthS}\n'
        'damping=${model.damping}\n'
        'tension=${model.tension}\n'
        'playing=${model.isPlaying}\n'
        'speed=${model.timeSpeed.name}\n'
        'rulers=${model.rulersVisible}\n'
        'timer=${model.stopwatch.isVisible}\n'
        'refLine=${model.referenceLineVisible}\n'
        'beads=${model.beadCount}\n'
        'bytes=${file.lengthSync()}\n',
      );
      // ignore: avoid_print
      print('CAPTURED $name (${file.lengthSync()} bytes)');
    });
  }

  void evolveN(WoasModel m, int n) {
    for (var i = 0; i < n; i++) {
      m.manualStep(frameDuration);
    }
  }

  testWidgets('01 Initial', (t) async {
    await capture(t, '01_initial', WoasModel());
  });

  testWidgets('02 Manual high', (t) async {
    await capture(t, '02_manual_high', WoasModel(), prepare: (m) async {
      m.setManualDisplacement(maxStartAmplitudeCm * modelUnitsPerCm * 0.9);
      evolveN(m, 8);
      m.nextLeftY = maxStartAmplitudeCm * modelUnitsPerCm * 0.9;
    });
  });

  testWidgets('03 Manual low', (t) async {
    await capture(t, '03_manual_low', WoasModel(), prepare: (m) async {
      m.setManualDisplacement(15);
      evolveN(m, 6);
      m.nextLeftY = 15;
    });
  });

  testWidgets('04 Oscillate', (t) async {
    await capture(t, '04_oscillate', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      evolveN(m, 35);
    });
  });

  testWidgets('05 Pulse mid', (t) async {
    await capture(t, '05_pulse', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.pulse);
      m.setDamping(0);
      m.triggerPulse();
      evolveN(m, 40);
    });
  });

  testWidgets('06 Fixed End', (t) async {
    await capture(t, '06_fixed', WoasModel()..setStringEndType(WoasEndType.fixedEnd));
  });

  testWidgets('07 Loose End', (t) async {
    await capture(t, '07_loose', WoasModel()..setStringEndType(WoasEndType.looseEnd));
  });

  testWidgets('08 No End', (t) async {
    await capture(t, '08_no_end', WoasModel()..setStringEndType(WoasEndType.noEnd));
  });

  testWidgets('09 Max Amplitude Oscillate', (t) async {
    await capture(t, '09_amp_max', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setAmplitudeCm(1.3);
      evolveN(m, 30);
    });
  });

  testWidgets('10 Min Frequency', (t) async {
    await capture(t, '10_freq_min', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setFrequencyHz(0);
      evolveN(m, 20);
    });
  });

  testWidgets('11 Max Frequency', (t) async {
    await capture(t, '11_freq_max', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setFrequencyHz(3);
      evolveN(m, 25);
    });
  });

  testWidgets('12 Max Damping', (t) async {
    await capture(t, '12_damp_max', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setDamping(1);
      evolveN(m, 40);
    });
  });

  testWidgets('13 Min Damping', (t) async {
    await capture(t, '13_damp_min', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setDamping(0);
      evolveN(m, 40);
    });
  });

  testWidgets('14 Min Tension', (t) async {
    await capture(t, '14_tension_min', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setTension(0.2);
      evolveN(m, 40);
    });
  });

  testWidgets('15 Max Tension', (t) async {
    await capture(t, '15_tension_max', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setTension(0.8);
      evolveN(m, 40);
    });
  });

  testWidgets('16 Ruler ON', (t) async {
    await capture(t, '16_ruler_on', WoasModel()..setRulersVisible(true));
  });

  testWidgets('17 Timer ON', (t) async {
    await capture(t, '17_timer_on', WoasModel(), prepare: (m) async {
      m.setStopwatchVisible(true);
      m.stopwatch.isRunning = true;
      evolveN(m, 25);
    });
  });

  testWidgets('18 Reference Line ON', (t) async {
    await capture(
      t,
      '18_reference_line_on',
      WoasModel()
        ..setReferenceLineVisible(true)
        ..setReferenceLineY(200),
    );
  });

  testWidgets('19 Pause', (t) async {
    await capture(t, '19_pause', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      evolveN(m, 20);
      m.setPlaying(false);
    });
  });

  testWidgets('20 Step after pause', (t) async {
    await capture(t, '20_step', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      evolveN(m, 15);
      m.setPlaying(false);
      m.manualStep();
    });
  });

  testWidgets('21 Slow', (t) async {
    await capture(
      t,
      '21_slow',
      WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setTimeSpeed(WoasTimeSpeed.slow),
      prepare: (m) async {
        evolveN(m, 20);
      },
    );
  });

  testWidgets('22 Restart result', (t) async {
    await capture(t, '22_restart', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setAmplitudeCm(1.2);
      m.setDamping(0.5);
      m.setRulersVisible(true);
      evolveN(m, 30);
      m.restart();
    });
  });

  testWidgets('23 Reset All result', (t) async {
    await capture(t, '23_reset_all', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.pulse);
      m.setStringEndType(WoasEndType.noEnd);
      m.setAmplitudeCm(1.2);
      m.setDamping(0.9);
      m.setTimeSpeed(WoasTimeSpeed.slow);
      m.setPlaying(false);
      m.setRulersVisible(true);
      m.setReferenceLineVisible(true);
      m.setStopwatchVisible(true);
      evolveN(m, 10);
      m.resetAll();
    });
  });

  testWidgets('24 Combined complex', (t) async {
    await capture(t, '24_combined', WoasModel(), prepare: (m) async {
      m.setWaveMode(WoasMode.oscillate);
      m.setStringEndType(WoasEndType.looseEnd);
      m.setAmplitudeCm(1.1);
      m.setFrequencyHz(2.0);
      m.setDamping(0.15);
      m.setTension(0.5);
      m.setRulersVisible(true);
      m.setStopwatchVisible(true);
      m.setReferenceLineVisible(true);
      m.stopwatch.isRunning = true;
      evolveN(m, 35);
    });
  });

  testWidgets('25 Pulse Width control visible', (t) async {
    await capture(t, '25_pulse_mode_controls', WoasModel()..setWaveMode(WoasMode.pulse));
  });

  testWidgets('26 Reference OFF keeps center dash', (t) async {
    await capture(t, '26_center_dash_ref_off', WoasModel());
  });
}
