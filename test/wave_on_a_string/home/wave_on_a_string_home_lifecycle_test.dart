import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/screens/home_screen.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/view/woas_screen.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Phase 6 — Home entry / lifecycle / re-entry (Faraday peer pattern).
/// Clock may be running — avoid pumpAndSettle while sim is on the stack.
void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openWoas(WidgetTester tester) async {
    final card = find.text(WoasScreen.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WoasScreen), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(WoasScreen), findsNothing);
  }

  WoasModel screenModel(WidgetTester tester) {
    final state = tester.state<WoasScreenState>(find.byType(WoasScreen));
    return state.model;
  }

  void expectInitial(WoasModel m) {
    expect(m.waveMode, WoasMode.manual);
    expect(m.stringEndType, WoasEndType.fixedEnd);
    expect(m.amplitudeCm, closeTo(0.75, 1e-12));
    expect(m.frequencyHz, closeTo(1.50, 1e-12));
    expect(m.pulseWidthS, closeTo(0.5, 1e-12));
    expect(m.damping, closeTo(0.2, 1e-12));
    expect(m.tension, closeTo(0.8, 1e-12));
    expect(m.isPlaying, isTrue);
    expect(m.timeSpeed, WoasTimeSpeed.normal);
    expect(m.rulersVisible, isFalse);
    expect(m.referenceLineVisible, isFalse);
    expect(m.stopwatch.isVisible, isFalse);
    for (var i = 0; i < numberOfBeads; i++) {
      expect(m.yNowAt(i), 0);
    }
  }

  group('home entry', () {
    testWidgets('Home lists Wave on a String under 光学与波动', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('光学与波动'), findsOneWidget);
      expect(find.text(WoasScreen.title), findsOneWidget);
      expect(find.text(WoasScreen.subtitle), findsOneWidget);
    });

    testWidgets('tap card opens WoasScreen with AppBar', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(WoasScreen.title),
        ),
        findsOneWidget,
      );
      expect(find.byType(WoasPlayArea), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      final model = screenModel(tester);
      expectInitial(model);
    });
  });

  group('navigation / back', () {
    testWidgets('Back returns Home and disposes screen', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);
      await backToHome(tester);
      expect(find.text(WoasScreen.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  });

  group('lifecycle / re-entry', () {
    testWidgets('mutate then Back then re-enter → fresh initial', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      final a = screenModel(tester);
      a.setWaveMode(WoasMode.oscillate);
      a.setStringEndType(WoasEndType.looseEnd);
      a.setAmplitudeCm(1.2);
      a.setFrequencyHz(2.5);
      a.setDamping(0.7);
      a.setTension(0.3);
      a.setTimeSpeed(WoasTimeSpeed.slow);
      a.setPlaying(false);
      a.setRulersVisible(true);
      a.setReferenceLineVisible(true);
      a.setStopwatchVisible(true);
      for (var i = 0; i < 20; i++) {
        a.manualStep(frameDuration);
      }
      await tester.pump();
      expect(a.waveMode, WoasMode.oscillate);
      expect(a.yNowAt(0), isNot(0));

      await backToHome(tester);
      await openWoas(tester);

      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expectInitial(b);

      await backToHome(tester);
    });

    testWidgets('re-entry ×3 keeps independent fresh models', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      final models = <WoasModel>[];
      for (var i = 0; i < 3; i++) {
        await openWoas(tester);
        final m = screenModel(tester);
        models.add(m);
        expectInitial(m);
        m.setWaveMode(WoasMode.oscillate);
        m.setAmplitudeCm(0.8 + i * 0.1);
        for (var k = 0; k < 10; k++) {
          m.manualStep(frameDuration);
        }
        await tester.pump();
        await backToHome(tester);
      }

      expect(identical(models[0], models[1]), isFalse);
      expect(identical(models[1], models[2]), isFalse);
    });

    testWidgets('Back during Oscillate does not throw', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      final model = screenModel(tester);
      model.setWaveMode(WoasMode.oscillate);
      for (var i = 0; i < 15; i++) {
        model.manualStep(frameDuration);
      }
      await tester.pump(const Duration(milliseconds: 80));

      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.byType(WoasScreen), findsNothing);
    });

    testWidgets('Back during Pulse does not throw', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      final model = screenModel(tester);
      model.setWaveMode(WoasMode.pulse);
      model.triggerPulse();
      for (var i = 0; i < 10; i++) {
        model.manualStep(frameDuration);
      }
      await tester.pump(const Duration(milliseconds: 80));

      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Back during Manual drag does not throw', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      final model = screenModel(tester);
      model.setManualDisplacement(40);
      for (var i = 0; i < 5; i++) {
        model.manualStep(frameDuration);
        model.nextLeftY = 40;
      }
      await tester.pump();

      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Back with Timer ON does not throw', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      final model = screenModel(tester);
      model.setStopwatchVisible(true);
      model.stopwatch.isRunning = true;
      for (var i = 0; i < 10; i++) {
        model.manualStep(frameDuration);
      }
      await tester.pump();

      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('cross-sim: WOAS → Faraday → WOAS fresh', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      await openWoas(tester);
      screenModel(tester).setWaveMode(WoasMode.oscillate);
      await tester.pump();
      await backToHome(tester);

      final faradayCard = find.text("Faraday's Law");
      await tester.ensureVisible(faradayCard.first);
      await tester.tap(faradayCard.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      await openWoas(tester);
      expectInitial(screenModel(tester));
      await backToHome(tester);
    });
  });

  group('isolation without Home', () {
    test('instances A/B/C are independent', () {
      final a = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setAmplitudeCm(1.3)
        ..setStringEndType(WoasEndType.noEnd);
      for (var i = 0; i < 10; i++) {
        a.manualStep(frameDuration);
      }

      final b = WoasModel();
      expect(b.waveMode, WoasMode.manual);
      expect(b.amplitudeCm, closeTo(0.75, 1e-12));
      expect(b.stringEndType, WoasEndType.fixedEnd);
      expect(b.yNowAt(0), 0);

      b.setWaveMode(WoasMode.pulse);
      b.triggerPulse();
      for (var i = 0; i < 5; i++) {
        b.manualStep(frameDuration);
      }

      final c = WoasModel();
      expect(c.waveMode, WoasMode.manual);
      expect(c.isPulseActive, isFalse);
      expect(identical(a, b), isFalse);
      expect(identical(b, c), isFalse);
    });
  });

  group('embedded viewport chrome', () {
    testWidgets('single AppBar · PlayArea present · no double chrome',
        (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openWoas(tester);

      // Home remains under Navigator stack (MaterialPageRoute) — expected.
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(WoasPlayArea), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(WoasScreen.title),
        ),
        findsOneWidget,
      );

      await backToHome(tester);
      expect(find.byType(WoasScreen), findsNothing);
      expect(find.byType(AppBar), findsNothing);
    });
  });
}
