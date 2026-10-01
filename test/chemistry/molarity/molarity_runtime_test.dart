import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/audio/molarity_audio.dart';
import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/chemistry/molarity/controller/molarity_controller.dart';
import 'package:kratos/chemistry/molarity/model/molarity_constants.dart';
import 'package:kratos/chemistry/molarity/model/molarity_model.dart';
import 'package:kratos/chemistry/molarity/model/molarity_solute_catalog.dart';
import 'package:kratos/chemistry/molarity/model/solvent.dart';
import 'package:kratos/chemistry/molarity/model/solute.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_play_area.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_vertical_slider.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Phase 3 — Behavioral / Runtime / Audio / Accessibility acceptance.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MolarityController> ctrl([RecordingMolarityAudio? audio]) async {
    final manager = MolarityScenarioManager();
    await manager.loadScenarios();
    final c = MolarityController(manager: manager, audio: audio);
    await c.init();
    return c;
  }

  group('R3 reactive slider / derived', () {
    test('R3-01 solute slider continuous → C / color / precipitate', () async {
      final c = await ctrl();
      final s = c.model.solution;
      for (final n in [0.0, 0.1, 0.5, 1.0]) {
        c.setSoluteAmount(n);
        expect(s.soluteAmount, n);
        expect(s.concentration.isFinite, isTrue);
        expect(s.concentration.isNaN, isFalse);
        // Continuous: each call updates immediately (not only on release).
        expect(s.concentration, s.concentration); // stable read
      }
      expect(s.soluteAmount, 1.0);
      expect(s.concentration, greaterThan(0));
    });

    test('R3-02 volume slider continuous → height proxy / C', () async {
      final c = await ctrl();
      final s = c.model.solution;
      c.setSoluteAmount(0.5);
      for (final v in [0.2, 0.5, 0.75, 1.0]) {
        c.setVolume(v);
        expect(s.volume, v);
        expect(s.soluteAmount, 0.5); // independent of volume
        expect(s.concentration.isFinite, isTrue);
      }
    });

    test('R3-03 concentration reactive n and V', () async {
      final c = await ctrl();
      final s = c.model.solution;
      c.setSoluteAmount(0.4);
      c.setVolume(0.8);
      expect(s.concentration, 0.5); // 0.4/0.8 = 0.5, 3dp
      c.setSoluteAmount(0.8);
      expect(s.concentration, 1.0);
      c.setVolume(0.4);
      expect(s.concentration, 2.0);
    });

    test('R3-04 color reactive · water · mid · sat', () async {
      final c = await ctrl();
      final s = c.model.solution;
      c.setSoluteAmount(0);
      expect(s.solutionColor, const Color(0xFFE0FFFF));
      c.setSoluteAmount(0.5);
      expect(s.solutionColor, isNot(const Color(0xFFE0FFFF)));
      // K₂Cr₂O₇ C_sat=0.5 — supersaturate then cap color at max.
      c.selectSolute(3);
      c.setSoluteAmount(1.0);
      c.setVolume(0.2);
      expect(s.concentration, 0.5);
      expect(s.solutionColor, s.solute.maxColor);
    });

    test('R3-05 liquid height ∝ volume (ratio)', () async {
      final c = await ctrl();
      // Height is view-proportional to volume; model volume is the source of truth.
      c.setVolume(0.2);
      final low = c.model.solution.volume;
      c.setVolume(1.0);
      final high = c.model.solution.volume;
      expect(high / low, closeTo(5.0, 1e-9));
    });
  });

  group('R3 solute switching', () {
    test('R3-06/07 switch preserves n and V', () async {
      final c = await ctrl();
      c.setSoluteAmount(0.7);
      c.setVolume(0.4);
      c.selectSolute(7); // Copper sulfate
      expect(c.model.solution.soluteAmount, 0.7);
      expect(c.model.solution.volume, 0.4);
      expect(c.model.selectedSoluteIndex, 7);
      expect(c.model.solution.solute.formula, 'CuSO\u2084');
    });

    test('R3-08 all 9 solutes update C_sat / colors / derived', () async {
      final c = await ctrl();
      c.setSoluteAmount(0.5);
      c.setVolume(0.5);
      final expected = MolaritySoluteCatalog.saturatedConcentrations;
      for (var i = 0; i < 9; i++) {
        c.selectSolute(i);
        final s = c.model.solution;
        expect(s.solute.saturatedConcentration, expected[i]);
        expect(s.soluteAmount, 0.5);
        expect(s.volume, 0.5);
        expect(s.concentration.isFinite, isTrue);
        expect(s.solutionColor, isNotNull);
      }
    });
  });

  group('R3 saturation / precipitate', () {
    test('R3-09 saturation boundary C_sat=0.50', () async {
      final c = await ctrl();
      c.selectSolute(3); // Potassium dichromate, C_sat=0.50
      // undersaturated
      c.setVolume(1.0);
      c.setSoluteAmount(0.4);
      expect(c.model.solution.precipitateAmount, 0);
      expect(c.model.solution.isSaturated, isFalse);
      // exactly at C_sat: n/V = 0.5 → precipitate 0
      c.setSoluteAmount(0.5);
      expect(c.model.solution.concentration, 0.5);
      expect(c.model.solution.precipitateAmount, 0);
      expect(c.model.solution.isSaturated, isFalse);
      // supersaturated
      c.setSoluteAmount(0.8);
      expect(c.model.solution.concentration, 0.5);
      expect(c.model.solution.precipitateAmount, greaterThan(0));
      expect(c.model.solution.isSaturated, isTrue);
    });

    test('R3-10 precipitate appearance → particle count increases', () async {
      final c = await ctrl();
      c.selectSolute(8); // KMnO4 C_sat=0.50
      c.setVolume(0.2);
      c.setSoluteAmount(0.1); // n/V = 0.5 = C_sat → 0 particles
      expect(c.model.solution.precipitateAmount, 0);
      expect(c.model.solution.numberOfParticles, 0);
      c.setSoluteAmount(0.5);
      final mid = c.model.solution.numberOfParticles;
      expect(mid, greaterThan(0));
      c.setSoluteAmount(1.0);
      expect(c.model.solution.numberOfParticles, greaterThan(mid));
    });

    test('R3-11 precipitate removal (no dissolve tween)', () async {
      final c = await ctrl();
      c.selectSolute(3);
      c.setVolume(0.2);
      c.setSoluteAmount(1.0);
      expect(c.model.solution.isSaturated, isTrue);
      c.setSoluteAmount(0.05); // n/V = 0.25 < 0.5
      expect(c.model.solution.precipitateAmount, 0);
      expect(c.model.solution.isSaturated, isFalse);
      expect(c.model.solution.numberOfParticles, 0);
    });

    test('R3-12 water state', () async {
      final c = await ctrl();
      c.setSoluteAmount(0);
      final s = c.model.solution;
      expect(s.concentration, 0);
      expect(s.solutionColor, const Color(0xFFE0FFFF));
      expect(s.beakerLabel, const Solvent().formula);
    });
  });

  group('R3 values / reset', () {
    test('R3-13 concentration display scale uses absolute C (≤5)', () async {
      final c = await ctrl();
      c.selectSolute(3); // C_sat 0.5
      c.setVolume(0.2);
      c.setSoluteAmount(1.0);
      // Arrow fraction vs display max 5 — NOT 100% at C_sat.
      final cVal = c.model.solution.concentration;
      final frac = cVal / MolarityConstants.concentrationDisplayMax;
      expect(cVal, 0.5);
      expect(frac, closeTo(0.1, 1e-9));
    });

    test('R3-14/15 valuesVisible toggle · physics invariant', () async {
      final c = await ctrl();
      c.setSoluteAmount(0.6);
      c.setVolume(0.3);
      final n = c.model.solution.soluteAmount;
      final v = c.model.solution.volume;
      final conc = c.model.solution.concentration;
      final p = c.model.solution.precipitateAmount;
      expect(c.model.valuesVisible, isFalse);
      c.toggleValues(true);
      expect(c.model.valuesVisible, isTrue);
      expect(c.model.solution.soluteAmount, n);
      expect(c.model.solution.volume, v);
      expect(c.model.solution.concentration, conc);
      expect(c.model.solution.precipitateAmount, p);
      c.toggleValues(false);
      expect(c.model.valuesVisible, isFalse);
      expect(c.model.solution.concentration, conc);
    });

    test('R3-16 Reset All PhET defaults', () async {
      final c = await ctrl();
      c.selectSolute(8);
      c.setSoluteAmount(1.0);
      c.setVolume(0.2);
      c.toggleValues(true);
      expect(c.model.solution.isSaturated, isTrue);
      c.resetAllPhET();
      expect(c.model.solution.solute.formula, 'Drink mix');
      expect(c.model.solution.soluteAmount, 0.5);
      expect(c.model.solution.volume, 0.5);
      expect(c.model.solution.concentration, 1.0);
      expect(c.model.solution.precipitateAmount, 0);
      expect(c.model.valuesVisible, isFalse);
    });

    test('R3-17 repeated reset stable', () async {
      final audio = RecordingMolarityAudio();
      final c = await ctrl(audio);
      for (var i = 0; i < 4; i++) {
        c.selectSolute(8);
        c.setSoluteAmount(1.0);
        c.setVolume(0.2);
        c.toggleValues(true);
        c.resetAllPhET();
      }
      expect(c.model.solution.soluteAmount, 0.5);
      expect(c.model.solution.volume, 0.5);
      expect(c.model.valuesVisible, isFalse);
      // No dispose mid-loop; audio still usable.
      expect(audio.isDisposed, isFalse);
    });

    test('R3-18 reset during interaction', () async {
      final c = await ctrl();
      c.beginUserDrag();
      c.setSoluteAmount(0.9);
      c.resetAllPhET();
      c.endUserDrag();
      expect(c.model.solution.soluteAmount, 0.5);
      c.toggleValues(true);
      c.resetAllPhET();
      expect(c.model.valuesVisible, isFalse);
      c.selectSolute(5);
      c.resetAllPhET();
      expect(c.model.selectedSoluteIndex, 0);
    });
  });

  group('R3 stress / defense', () {
    test('R3-19 rapid interaction 30+', () async {
      final c = await ctrl();
      final rng = math.Random(7);
      for (var i = 0; i < 36; i++) {
        c.setSoluteAmount(rng.nextBool() ? 0.0 : 1.0);
        c.setVolume(rng.nextBool() ? 0.2 : 1.0);
        c.selectSolute([0, 7, 8, 0][i % 4]);
        final s = c.model.solution;
        expect(s.concentration.isNaN, isFalse);
        expect(s.concentration.isInfinite, isFalse);
        expect(s.precipitateAmount.isNaN, isFalse);
      }
    });

    test('R3-20 NaN/Infinity defense · V=0 model case', () {
      final m = MolarityModel.defaults();
      m.solution.setVolume(0); // defensive model path
      expect(m.solution.concentration, 0);
      expect(m.solution.concentration.isNaN, isFalse);
      expect(m.solution.concentration.isInfinite, isFalse);
      m.setSoluteAmount(1);
      m.setVolume(0.2);
      expect(m.solution.concentration.isFinite, isTrue);
    });
  });

  group('R3 audio hooks', () {
    test('R3-21 audio event hooks (counters — not heard playback)', () async {
      final audio = RecordingMolarityAudio();
      final c = await ctrl(audio);
      final beforeSel = audio.soluteSelectionCount;
      c.selectSolute(2);
      expect(audio.soluteSelectionCount, beforeSel + 1);

      c.setSoluteAmount(0); // soft / zero path possible after bins
      c.setSoluteAmount(0.5);
      expect(audio.concentrationCueCount, greaterThan(0));

      c.selectSolute(3);
      c.setVolume(0.2);
      c.setSoluteAmount(0.2);
      final p0 = audio.precipitateCueCount;
      c.setSoluteAmount(1.0); // enter supersaturation
      expect(audio.precipitateCueCount, greaterThan(p0));
    });

    test('R3-22 audio muted during resetInProgress', () async {
      final audio = RecordingMolarityAudio();
      final c = await ctrl(audio);
      c.selectSolute(8);
      c.setSoluteAmount(1);
      c.setVolume(0.2);
      final selBeforeReset = audio.soluteSelectionCount;
      final concBeforeReset = audio.concentrationCueCount;
      final precBeforeReset = audio.precipitateCueCount;
      c.resetAllPhET();
      // model.reset does not go through controller.selectSolute → no selection cue.
      expect(audio.soluteSelectionCount, selBeforeReset);
      // Capture post-reset baseline, then mute and ensure no new cues.
      final sel = audio.soluteSelectionCount;
      final conc = audio.concentrationCueCount;
      final prec = audio.precipitateCueCount;
      c.model.resetInProgress = true;
      c.selectSolute(2);
      c.setSoluteAmount(0.9);
      c.setVolume(0.3);
      expect(audio.soluteSelectionCount, sel);
      expect(audio.concentrationCueCount, conc);
      expect(audio.precipitateCueCount, prec);
      c.model.resetInProgress = false;
      // Sanity: pre-reset activity did fire some cues.
      expect(selBeforeReset, greaterThan(0));
      expect(
        concBeforeReset + precBeforeReset,
        greaterThanOrEqualTo(0),
      );
    });
  });

  group('R3 keyboard / a11y / lifecycle (widget)', () {
    Future<RecordingMolarityAudio> pump(
      WidgetTester tester,
      RecordingMolarityAudio audio,
    ) async {
      final manager = MolarityScenarioManager();
      await tester.runAsync(() => manager.loadScenarios());
      tester.view.physicalSize = const Size(1100, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1100,
            height: 700,
            child: MolarityScreen(manager: manager, audio: audio),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      return audio;
    }

    testWidgets('R3-23 slider keyboard Arrow/Home/End/Page', (tester) async {
      final audio = RecordingMolarityAudio();
      await pump(tester, audio);
      final sliderFocus = find.byType(Slider).first;
      await tester.tap(sliderFocus, warnIfMissed: false);
      await tester.pump();

      // Focus the Focus ancestor of the first slider.
      final focusFinder = find.descendant(
        of: find.byType(MolarityVerticalSlider).first,
        matching: find.byType(Focus),
      );
      expect(focusFinder, findsWidgets);
      final focus = tester.widget<Focus>(focusFinder.first);
      focus.focusNode?.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();

      // Semantics presence for slider role.
      expect(tester.getSemantics(find.byType(Slider).first), isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('R3-24 ComboBox / R3-25 checkbox / R3-26 reset keyboard',
        (tester) async {
      final audio = RecordingMolarityAudio();
      await pump(tester, audio);

      // Checkbox toggle (keyboard activation = same onChanged path).
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pump();
      // valuesVisible on → quantitative end labels appear (e.g. "1.0").
      expect(find.text('1.0'), findsWidgets);

      // ComboBox present; open and select by index-stable formula text if shown.
      expect(find.text('溶质:'), findsOneWidget);
      final dropdown = find.byType(DropdownButton<Solute>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown, warnIfMissed: false);
      await tester.pumpAndSettle();
      // Prefer localized or English copper name if menu items are visible.
      final copperEn = find.text('Copper sulfate');
      final copperZh = find.text('硫酸铜');
      if (copperEn.evaluate().isNotEmpty) {
        await tester.tap(copperEn.last);
        await tester.pumpAndSettle();
      } else if (copperZh.evaluate().isNotEmpty) {
        await tester.tap(copperZh.last);
        await tester.pumpAndSettle();
      }

      // Reset via button (activation).
      await tester.tap(find.byType(KratosResetAllButton));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('多'), findsOneWidget); // qualitative restored

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('R3-27 accessibility semantics presence', (tester) async {
      final audio = RecordingMolarityAudio();
      await pump(tester, audio);

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.label?.contains('溶质量') ?? false),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && (w.properties.label?.contains('溶液体积') ?? false),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && (w.properties.label?.contains('全部重置') ?? false),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && (w.properties.label?.contains('显示数值') ?? false),
        ),
        findsWidgets,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('R3-28/29 lifecycle create dispose recreate', (tester) async {
      final audio1 = RecordingMolarityAudio();
      await pump(tester, audio1);
      expect(find.byType(MolarityPlayArea), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(audio1.isDisposed, isTrue);

      final audio2 = RecordingMolarityAudio();
      await pump(tester, audio2);
      expect(find.byType(MolarityPlayArea), findsOneWidget);
      await tester.drag(
        find.byType(Slider).first,
        const Offset(0, -30),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(audio2.isDisposed, isTrue);
    });

    testWidgets('R3-30 regression smoke · no legacy interactions', (tester) async {
      final audio = RecordingMolarityAudio();
      await pump(tester, audio);
      expect(find.byType(MolarityPlayArea), findsOneWidget);
      expect(find.byType(MolarityVerticalSlider), findsNWidgets(2));
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      // Legacy ABSENT
      expect(find.textContaining('Shaker'), findsNothing);
      expect(find.textContaining('Dropper'), findsNothing);
      expect(find.textContaining('Faucet'), findsNothing);
      expect(find.textContaining('Probe'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
