import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_keyboard_actions.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';

void main() {
  group('Ruler keyboard', () {
    test('nudge X/Y and fine step amounts', () {
      final m = GravityForceLabModel();
      final f0 = m.force;
      final x1 = m.mass1.positionX;

      expect(GravityForceConstants.rulerKeyboardStep, 0.2);
      expect(GravityForceConstants.rulerShiftKeyboardStep, 0.1);

      GflKeyboardActions.nudgeRuler(m, dx: 0.2, dy: 0.2);
      expect(m.ruler.positionX, closeTo(0.2, 1e-9));
      expect(m.ruler.positionY, closeTo(-0.8, 1e-9));
      expect(m.force, f0);
      expect(m.mass1.positionX, x1);

      m.setRulerPosition(-100, 100);
      expect(m.ruler.positionX, greaterThanOrEqualTo(m.ruler.dragMinX));
      expect(m.ruler.positionY, lessThanOrEqualTo(m.ruler.dragMaxY));
      m.dispose();
    });

    testWidgets('grab then arrows / WASD move; J+C / J+H', (tester) async {
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

      await tester.tap(
        find.bySemanticsLabel(GflA11yStrings.measureDistanceRuler),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      final x0 = model.ruler.positionX;
      final y0 = model.ruler.positionY;
      final f0 = model.force;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(model.ruler.positionX, closeTo(x0 + 0.2, 1e-9));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(model.ruler.positionY, closeTo(y0 + 0.2, 1e-9));

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(model.ruler.positionX, closeTo(x0, 1e-9));

      expect(model.force, f0);
      expect(model.mass1.value, 100);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      expect(model.ruler.positionX, 0);
      expect(model.ruler.positionY, -1);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      expect(
        model.ruler.positionX,
        closeTo(
          model.mass1.positionX + GravityForceConstants.rulerHalfWidthModel,
          1e-9,
        ),
      );
      expect(model.force, f0);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });

    testWidgets('without grab, arrows do not move ruler', (tester) async {
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

      await tester.tap(
        find.bySemanticsLabel(GflA11yStrings.measureDistanceRuler),
      );
      await tester.pump();

      final x0 = model.ruler.positionX;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(model.ruler.positionX, x0);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });
}
