import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_keyboard_actions.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';

void main() {
  const builder = GflRenderBuilder();

  group('Mass keyboard (MassControl Full left/right)', () {
    test('increment / decrement / clamp / page / shift via actions', () {
      final m = GravityForceLabModel();
      expect(m.mass1.value, 100);

      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: false);
      expect(m.mass1.value, 150);

      GflKeyboardActions.applyMassStep(m, 1, increase: false, page: false);
      expect(m.mass1.value, 100);

      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: true);
      expect(m.mass1.value, 200);

      GflKeyboardActions.jumpMassMin(m, 1);
      expect(m.mass1.value, 10);
      GflKeyboardActions.applyMassStep(m, 1, increase: false, page: false);
      expect(m.mass1.value, 10);

      GflKeyboardActions.jumpMassMax(m, 1);
      expect(m.mass1.value, 1000);
      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: false);
      expect(m.mass1.value, 1000);

      expect(GravityForceConstants.massShiftKeyboardStep, 10);
      expect(GravityForceConstants.massKeyboardStep, 50);
      expect(GravityForceConstants.massPageKeyboardStep, 100);
      m.dispose();
    });

    test('mass keyboard updates force / radius / puller frame', () {
      final m = GravityForceLabModel();
      final f0 = m.forceMagnitude;
      final r0 = builder.build(m);
      final radius0 = m.mass1.radius;

      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: true);
      final r1 = builder.build(m);
      expect(m.forceMagnitude, greaterThan(f0));
      expect(m.mass1.radius, greaterThan(radius0));
      expect(r1.puller1Frame, greaterThanOrEqualTo(r0.puller1Frame));

      m.setConstantRadius(true);
      final rad = m.mass1.radius;
      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: false);
      expect(m.mass1.radius, rad);
      expect(m.mass1.radius, 0.5);
      m.dispose();
    });

    testWidgets('Mass 1 Focus left/right keys update Model', (tester) async {
      final semantics = tester.ensureSemantics();
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflScreenBody(model: model, audio: audio),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.mass1));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(model.mass1.value, 150);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(model.mass1.value, 100);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(model.mass1.value, 200);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(model.mass1.value, 10);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(model.mass1.value, 1000);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });

  group('Mass position keyboard (AccessibleSlider)', () {
    test('left/right step 0.5; fine 0.1; page 1.0; home/end', () {
      final m = GravityForceLabModel();
      final x0 = m.mass1.positionX;

      GflKeyboardActions.applyPositionStep(m, 1, increase: true, page: false);
      expect(m.mass1.positionX, closeTo(x0 + 0.5, 1e-9));

      GflKeyboardActions.applyPositionStep(m, 1, increase: false, page: true);
      expect(m.mass1.positionX, closeTo(x0 + 0.5 - 1.0, 1e-9));

      GflKeyboardActions.jumpPositionMin(m, 1);
      expect(m.mass1.positionX, m.mass1EnabledMin);

      GflKeyboardActions.jumpPositionMax(m, 1);
      expect(m.mass1.positionX, m.mass1EnabledMax);
      m.dispose();
    });

    test('surface gap and no-crossing under keyboard', () {
      final m = GravityForceLabModel();
      for (var i = 0; i < 40; i++) {
        GflKeyboardActions.applyPositionStep(m, 1, increase: true, page: true);
      }
      expect(m.mass1.positionX, lessThan(m.mass2.positionX));
      expect(m.mass1.positionX, lessThanOrEqualTo(m.mass1EnabledMax + 1e-9));
      // Centers respect enabled ranges (snap may make surface gap ≈ 0.1).
      final minCenters = m.mass1.radius +
          m.mass2.radius +
          GravityForceConstants.minSeparationBetweenObjects;
      expect(
        m.mass2.positionX - m.mass1.positionX + 1e-6,
        greaterThanOrEqualTo(minCenters - 0.05),
      );

      for (var i = 0; i < 40; i++) {
        GflKeyboardActions.applyPositionStep(m, 2, increase: false, page: true);
      }
      expect(m.mass2.positionX, greaterThan(m.mass1.positionX));
      m.dispose();
    });

    testWidgets('sphere Move m1 keyboard updates position', (tester) async {
      final semantics = tester.ensureSemantics();
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflScreenBody(model: model, audio: audio),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.moveObject('m1')));
      await tester.pump();

      final x0 = model.mass1.positionX;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(model.mass1.positionX, closeTo(x0 + 0.5, 1e-9));

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });
}
