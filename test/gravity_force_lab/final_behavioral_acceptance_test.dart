import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_keyboard_actions.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/force_notation.dart';
import 'package:kratos/gravity_force_lab/model/force_solver.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';

/// PHASE 6 — Final Behavioral Acceptance
///
/// USER ACTION → MODEL → derived → View/Animation/Audio/A11y chain.
void main() {
  const builder = GflRenderBuilder();

  void expectFinitePhysics(GravityForceLabModel m) {
    expect(m.force.isFinite, isTrue);
    expect(m.forceMagnitude.isFinite, isTrue);
    expect(m.distance.isFinite, isTrue);
    expect(m.mass1.value.isNaN, isFalse);
    expect(m.mass2.value.isNaN, isFalse);
    expect(m.mass1.positionX.isNaN, isFalse);
    expect(m.mass2.positionX.isNaN, isFalse);
    expect(m.mass1.radius.isFinite, isTrue);
    expect(m.mass2.radius.isFinite, isTrue);
  }

  void expectNoCrossing(GravityForceLabModel m) {
    expect(m.mass1.positionX, lessThan(m.mass2.positionX));
    final minCenters = m.mass1.radius +
        m.mass2.radius +
        GravityForceConstants.minSeparationBetweenObjects;
    expect(
      m.distance + 1e-6,
      greaterThanOrEqualTo(minCenters - 0.05),
    );
  }

  void expectDefaults(GravityForceLabModel m) {
    expect(m.mass1.value, 100);
    expect(m.mass2.value, 400);
    expect(m.mass1.positionX, -3);
    expect(m.mass2.positionX, 1);
    expect(m.distance, 4);
    expect(m.constantRadius, GravityForceConstants.defaultConstantRadius);
    expect(m.forceValuesDisplay, ForceValuesDisplay.decimal);
    expect(m.ruler.positionX, 0);
    expect(m.ruler.positionY, -1);
    expect(m.force, closeTo(1.66852e-7, 1e-15));
  }

  group('1. Default full state', () {
    test('defaults + render chain', () {
      expect(GravityForceConstants.gravitationalConstant, 6.67408e-11);
      final m = GravityForceLabModel();
      expectDefaults(m);

      final r = builder.build(m);
      expect(r.force, m.forceMagnitude);
      expect(r.mass1RadiusView, closeTo(m.mass1.radius * 50, 1e-6));
      expect(r.mass2RadiusView, closeTo(m.mass2.radius * 50, 1e-6));
      expect(r.arrow1TipDx.sign, -r.arrow2TipDx.sign);
      expect(r.puller1Frame, r.puller2Frame);
      expect(r.puller1Frame, inInclusiveRange(0, 30));
      expect(r.forceLabel1, contains('N'));
      expect(r.rulerCenterView.dx, closeTo(384, 1)); // MVT center x for 0
      expect(r.showForceValues, isTrue);
      m.dispose();
    });
  });

  group('2. Mass + radius combination', () {
    test('m1 100→500→1000 syncs radius/force/arrow/puller', () {
      final m = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(m);

      var prevForce = m.forceMagnitude;
      var prevFrame = builder.build(m).puller1Frame;
      var prevRadius = m.mass1.radius;

      for (final mass in [500.0, 1000.0]) {
        m.setMassValue(1, mass);
        expect(m.mass1.value, mass);
        expect(m.mass1.radius, greaterThan(prevRadius));
        expect(m.forceMagnitude, greaterThan(prevForce));
        final r = builder.build(m);
        expect(r.force, m.forceMagnitude);
        expect(r.arrow1TipDx.abs(), greaterThan(0));
        expect(r.puller1Frame, greaterThanOrEqualTo(prevFrame));
        expect(r.puller1Frame, r.puller2Frame);
        expectFinitePhysics(m);
        expectNoCrossing(m);
        prevForce = m.forceMagnitude;
        prevFrame = r.puller1Frame;
        prevRadius = m.mass1.radius;
      }

      expect(audio.forceUpdateCount, greaterThan(0));
      audio.dispose();
      m.dispose();
    });
  });

  group('3. Constant Size + mass', () {
    test('ON keeps 0.5 m; OFF restores density radius', () {
      final m = GravityForceLabModel();
      final densityR = m.mass1.radius;

      m.setConstantRadius(true);
      expect(m.mass1.radius, 0.5);
      expect(m.mass2.radius, 0.5);

      final f0 = m.forceMagnitude;
      final frame0 = builder.build(m).puller1Frame;
      m.setMassValue(1, 800);
      expect(m.mass1.radius, 0.5);
      expect(m.forceMagnitude, greaterThan(f0));
      final rOn = builder.build(m);
      expect(rOn.force, m.forceMagnitude);
      expect(rOn.puller1Frame, greaterThanOrEqualTo(frame0));

      m.setConstantRadius(false);
      expect(m.mass1.radius, isNot(0.5));
      expect(m.mass1.radius, greaterThan(densityR));
      expectFinitePhysics(m);
      m.dispose();
    });
  });

  group('4. Minimum separation + high mass', () {
    test('approach + high mass push keeps legal separation', () {
      final m = GravityForceLabModel();
      m.beginDrag(1);
      for (var i = 0; i < 50; i++) {
        m.setPositionWhileDragging(1, -0.5 + i * 0.05);
      }
      m.endDrag(1);
      expectNoCrossing(m);

      m.setMassValue(1, 1000);
      m.setMassValue(2, 1000);
      expectNoCrossing(m);
      expectFinitePhysics(m);

      // Rapid approach both sides
      for (var i = 0; i < 20; i++) {
        GflKeyboardActions.applyPositionStep(m, 1, increase: true, page: true);
        GflKeyboardActions.applyPositionStep(m, 2, increase: false, page: true);
        expectNoCrossing(m);
        expectFinitePhysics(m);
      }
      m.dispose();
    });
  });

  group('5. Force low / mid / high', () {
    test('arrow + label + puller + audio track force', () {
      final m = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(m);

      // LOW: masses far / small
      m.setMassValue(1, 10);
      m.setMassValue(2, 10);
      m.setPosition(1, -5);
      m.setPosition(2, 5);
      final low = builder.build(m);
      final fLow = m.forceMagnitude;
      final tipLow = low.arrow1TipDx.abs();
      final frameLow = low.puller1Frame;

      // MID: defaults-ish
      m.reset();
      builder.build(m);
      final fMid = m.forceMagnitude;
      expect(fMid, greaterThan(fLow));

      // HIGH: close + heavy
      m.setConstantRadius(true);
      m.setMassValue(1, 1000);
      m.setMassValue(2, 1000);
      m.setPosition(1, -0.6);
      m.setPosition(2, 0.6);
      final high = builder.build(m);
      final fHigh = m.forceMagnitude;
      expect(fHigh, greaterThan(fMid));
      expect(high.arrow1TipDx.abs(), greaterThan(tipLow));
      expect(high.puller1Frame, greaterThanOrEqualTo(frameLow));
      expect(high.force, fHigh);
      expect(high.forceLabel1.contains('N') || high.forceLabel1.isNotEmpty, isTrue);
      expect(audio.isForcePlaying || audio.forceUpdateCount > 0, isTrue);
      expect(audio.lastForcePlaybackRate, greaterThan(0));

      audio.dispose();
      m.dispose();
    });
  });

  group('6. Force display matrix under changed force', () {
    test('DECIMAL / SCIENTIFIC / HIDDEN preserve physics', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 700);
      final f = m.forceMagnitude;
      final frame = builder.build(m).puller1Frame;

      m.setForceValuesDisplay(ForceValuesDisplay.decimal);
      var r = builder.build(m);
      expect(r.showForceValues, isTrue);
      expect(r.forceLabel1, contains('='));
      expect(r.forceLabel1, contains('N'));
      expect(m.forceMagnitude, f);
      expect(r.puller1Frame, frame);

      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      r = builder.build(m);
      expect(r.showForceValues, isTrue);
      expect(r.forceLabel1, contains('×'));
      expect(r.forceLabel1, contains('10'));
      expect(m.forceMagnitude, f);
      expect(r.puller1Frame, frame); // notation must not reset puller

      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      r = builder.build(m);
      expect(r.showForceValues, isFalse);
      expect(r.forceLabel1.contains('='), isFalse);
      expect(r.arrow1TipDx.abs(), greaterThan(0)); // arrows remain
      expect(m.forceMagnitude, f);
      expect(r.puller1Frame, frame);

      m.setForceValuesDisplay(ForceValuesDisplay.decimal);
      expect(m.forceMagnitude, f);
      expect(builder.build(m).puller1Frame, frame);
      m.dispose();
    });
  });

  group('7. Ruler + mass mixed', () {
    test('sphere move does not jump ruler; mass change does not jump ruler', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(2.0, 0.5);
      final rx = m.ruler.positionX;
      final ry = m.ruler.positionY;

      m.setPosition(1, -4);
      expect(m.ruler.positionX, rx);
      expect(m.ruler.positionY, ry);

      m.setMassValue(2, 800);
      expect(m.ruler.positionX, rx);
      expect(m.ruler.positionY, ry);
      expect(m.force.isFinite, isTrue);

      m.reset();
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);
      m.dispose();
    });
  });

  group('8. Ruler + keyboard mixed', () {
    test('pointer nudge + keyboard + J+C + J+H; physics untouched', () {
      final m = GravityForceLabModel();
      final f0 = m.force;
      final x1 = m.mass1.positionX;

      m.setRulerPosition(1.0, 0.0);
      GflKeyboardActions.nudgeRuler(m, dx: 0.2, dy: -0.2);
      expect(m.ruler.positionX, closeTo(1.2, 1e-9));

      m.jumpRulerZeroToMass1Center();
      expect(
        m.ruler.positionX,
        closeTo(x1 + GravityForceConstants.rulerHalfWidthModel, 1e-9),
      );

      m.setRulerPosition(3, 1);
      m.jumpRulerHome();
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);

      expect(m.force, f0);
      expect(m.mass1.positionX, x1);
      m.dispose();
    });
  });

  group('9. Pointer + keyboard mixed', () {
    test('shared Model for mass value and position', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 200);
      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: false);
      expect(m.mass1.value, 250);

      m.setPosition(1, -2.0);
      GflKeyboardActions.applyPositionStep(m, 1, increase: true, page: false);
      expect(m.mass1.positionX, closeTo(-1.5, 1e-9));

      m.beginDrag(2);
      m.setPositionWhileDragging(2, 2.5);
      m.endDrag(2);
      GflKeyboardActions.applyPositionStep(m, 2, increase: false, page: false);
      expect(m.mass2.positionX, closeTo(2.0, 1e-9));
      expectNoCrossing(m);
      expectFinitePhysics(m);
      m.dispose();
    });
  });

  group('10. Animation + UI changes', () {
    test('notation / constant size do not scramble puller vs force', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 600);
      final f = m.forceMagnitude;
      final frame = builder.build(m).puller1Frame;

      for (final d in ForceValuesDisplay.values) {
        m.setForceValuesDisplay(d);
        final r = builder.build(m);
        expect(r.force, f);
        expect(r.puller1Frame, frame);
        expect(r.puller1Frame, r.puller2Frame);
      }

      m.setConstantRadius(true);
      final f2 = m.forceMagnitude;
      final frame2 = builder.build(m).puller1Frame;
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      final r2 = builder.build(m);
      expect(r2.force, f2);
      expect(r2.puller1Frame, frame2);
      m.dispose();
    });
  });

  group('11. Audio + rapid interaction', () {
    test('force loop + mass extra + boundary + ruler lifecycle', () async {
      final m = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(m);

      m.setPosition(1, -4.0);
      expect(audio.forceActivationCount, 1);
      expect(audio.isForcePlaying, isTrue);

      audio.onMassValueChanged(1, 200, 100);
      expect(audio.massExtraCount, 1);

      m.beginDrag(1);
      m.setPositionWhileDragging(1, m.mass1EnabledMin);
      expect(audio.boundaryCount, greaterThanOrEqualTo(1));
      m.endDrag(1);

      audio.onRulerGrab();
      m.setRulerPosition(1.0, 0);
      audio.onRulerMove();
      audio.onRulerRelease();
      expect(audio.rulerGrabCount, 1);
      expect(audio.rulerReleaseCount, 1);

      // Rapid force updates — single continuous activation stream
      for (var i = 0; i < 40; i++) {
        m.setPosition(1, -4.5 + (i % 5) * 0.2);
      }
      expect(audio.forceActivationCount, 1);
      expect(audio.forceUpdateCount, greaterThan(1));

      audio.beginReset();
      m.reset();
      audio.endReset();
      expect(audio.isForcePlaying, isFalse);
      expect(audio.isRulerGrabbed, isFalse);

      m.setPosition(2, 2.0);
      expect(audio.isForcePlaying, isTrue);

      await audio.dispose();
      m.dispose();
    });
  });

  group('12. Full reset', () {
    test('all mutated state restores to defaults', () {
      final m = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(m);

      m.setMassValue(1, 900);
      m.setMassValue(2, 50);
      m.setPosition(1, -1.5);
      m.setPosition(2, 3.0);
      m.setConstantRadius(true);
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      m.setRulerPosition(4, 1);
      m.jumpRulerZeroToMass1Center();
      m.jumpRulerHome();
      m.setRulerPosition(2, 0.5);
      for (var i = 0; i < 10; i++) {
        GflKeyboardActions.applyMassStep(m, 1, increase: true, page: false);
        GflKeyboardActions.nudgeRuler(m, dx: 0.2, dy: 0.1);
      }

      audio.beginReset();
      m.reset();
      audio.endReset();

      expectDefaults(m);
      final r = builder.build(m);
      expect(r.force, closeTo(1.66852e-7, 1e-15));
      final expected = GravityForceLabModel();
      expect(r.puller1Frame, builder.build(expected).puller1Frame);
      expected.dispose();
      expect(audio.isForcePlaying, isFalse);
      expect(audio.isRulerGrabbed, isFalse);

      audio.dispose();
      m.dispose();
    });
  });

  group('13. Reset immediate reinteraction', () {
    test('reset then interact without re-enter', () async {
      final m = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(m);

      m.setMassValue(1, 800);
      audio.beginReset();
      m.reset();
      audio.endReset();

      m.setPosition(1, -4.0);
      expect(audio.isForcePlaying, isTrue);
      m.setMassValue(2, 500);
      // x1=-4, x2=+1 → d=5; F = G·100·500 / 25
      expect(
        m.forceMagnitude,
        closeTo(6.67408e-11 * 100 * 500 / 25, 1e-15),
      );
      m.setPosition(1, -2.0); // closer → force rises
      expect(m.forceMagnitude, greaterThan(1.66852e-7));
      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      expect(m.showForceValues, isFalse);
      m.setRulerPosition(1.5, 0.2);
      expect(m.ruler.positionX, 1.5);

      final r = builder.build(m);
      expect(r.force, m.forceMagnitude);
      expect(r.puller1Frame, inInclusiveRange(0, 30));

      await audio.dispose();
      m.dispose();
    });
  });

  group('14. Lifecycle re-entry', () {
    testWidgets('leave / re-enter then mass+ruler+reset work', (tester) async {
      final semantics = tester.ensureSemantics();
      final audio = GflAudio(playEnabled: false);

      await tester.pumpWidget(
        MaterialApp(home: GravityForceLabScreen(audio: audio)),
      );
      await tester.pump();

      final state1 = tester.state<GravityForceLabScreenState>(
        find.byType(GravityForceLabScreen),
      );
      state1.model.setMassValue(1, 300);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(home: GravityForceLabScreen(audio: audio)),
      );
      await tester.pump();

      final state2 = tester.state<GravityForceLabScreenState>(
        find.byType(GravityForceLabScreen),
      );
      expect(state2.model.mass1.value, 100); // fresh model

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.mass1));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(state2.model.mass1.value, 150);

      await tester.tap(
        find.bySemanticsLabel(GflA11yStrings.measureDistanceRuler),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(state2.model.ruler.positionX, closeTo(0.2, 1e-9));

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.resetAll));
      await tester.pump();
      expect(state2.model.mass1.value, 100);
      expect(state2.model.ruler.positionX, 0);

      expect(audio.attachCount, lessThanOrEqualTo(2));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await audio.dispose();
      semantics.dispose();
    });
  });

  group('15. Rapid full regression', () {
    test('combined stress: mass/ruler/notation/constant/keyboard/reset', () {
      final m = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(m);

      for (var round = 0; round < 8; round++) {
        m.beginDrag(1);
        for (var i = 0; i < 15; i++) {
          m.setPositionWhileDragging(1, -4.5 + (i % 6) * 0.4);
        }
        m.endDrag(1);

        m.setMassValue(1, 100.0 + round * 50);
        m.setMassValue(2, 400.0 - round * 20);
        GflKeyboardActions.applyMassStep(m, 1, increase: true, page: true);
        GflKeyboardActions.applyPositionStep(
          m,
          2,
          increase: round.isEven,
          page: false,
        );

        m.setForceValuesDisplay(
          ForceValuesDisplay.values[round % ForceValuesDisplay.values.length],
        );
        m.setConstantRadius(round.isEven);

        m.setRulerPosition(round * 0.3, round.isEven ? 0.5 : -0.5);
        GflKeyboardActions.nudgeRuler(m, dx: 0.2, dy: -0.1);
        if (round.isOdd) {
          m.jumpRulerZeroToMass1Center();
        } else {
          m.jumpRulerHome();
        }

        final r = builder.build(m);
        expect(r.force, m.forceMagnitude);
        expect(r.puller1Frame, r.puller2Frame);
        expect(r.puller1Frame, inInclusiveRange(0, 30));
        expect(r.arrow1TipDx.isFinite, isTrue);
        expectNoCrossing(m);
        expectFinitePhysics(m);
      }

      expect(audio.forceActivationCount, lessThanOrEqualTo(2));
      expect(audio.attachCount, 1);

      audio.beginReset();
      m.reset();
      audio.endReset();
      expectDefaults(m);

      // Immediate reinteraction after stress+reset
      m.setPosition(1, -4);
      expect(audio.isForcePlaying, isTrue);
      expectFinitePhysics(m);

      audio.dispose();
      m.dispose();
    });

    testWidgets('widget path rapid: screen body survives stress', (tester) async {
      final semantics = tester.ensureSemantics();
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GflScreenBody(model: model, audio: audio)),
        ),
      );
      await tester.pump();

      for (var i = 0; i < 5; i++) {
        model.setMassValue(1, 150.0 + i * 10);
        model.setForceValuesDisplay(
          ForceValuesDisplay.values[i % ForceValuesDisplay.values.length],
        );
        model.setConstantRadius(i.isEven);
        model.setRulerPosition(i * 0.5, 0);
        await tester.pump();
        expectFinitePhysics(model);
      }

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.resetAll));
      await tester.pump();
      expectDefaults(model);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });

  group('Source force formula sanity', () {
    test('default force matches G*m1*m2/r²', () {
      expect(
        ForceSolver.calculateForce(100, 400, 4),
        closeTo(1.66852e-7, 1e-15),
      );
      expect(
        ForceNotationFormatter.formatForceLabel(
          forceAbs: 1.66852e-7,
          display: ForceValuesDisplay.decimal,
          thisObject: 'm1',
          otherObject: 'm2',
        ),
        isNotEmpty,
      );
    });
  });
}
