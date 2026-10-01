import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_keyboard_actions.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';

void main() {
  group('Pointer / accessibility shared Model', () {
    test('pointer setMass and keyboard nudge share same Model', () {
      final m = GravityForceLabModel();
      m.setMassValue(1, 200);
      expect(m.mass1.value, 200);
      GflKeyboardActions.applyMassStep(m, 1, increase: true, page: false);
      expect(m.mass1.value, 250);
      m.setPosition(1, -2.0);
      GflKeyboardActions.applyPositionStep(m, 1, increase: false, page: false);
      expect(m.mass1.positionX, closeTo(-2.5, 1e-9));
      m.dispose();
    });
  });

  group('Rapid keyboard', () {
    test('rapid mass / position / notation / constant / reset', () {
      final m = GravityForceLabModel();
      for (var i = 0; i < 30; i++) {
        GflKeyboardActions.applyMassStep(m, 1, increase: i.isEven, page: false);
        GflKeyboardActions.applyMassStep(m, 2, increase: !i.isEven, page: true);
        GflKeyboardActions.applyPositionStep(
          m,
          1,
          increase: i.isEven,
          page: false,
        );
        GflKeyboardActions.applyPositionStep(
          m,
          2,
          increase: !i.isEven,
          page: false,
        );
        m.setForceValuesDisplay(
          ForceValuesDisplay.values[i % ForceValuesDisplay.values.length],
        );
        m.setConstantRadius(i.isEven);
        expect(m.force.isFinite, isTrue);
        expect(m.mass1.value.isFinite, isTrue);
        expect(m.mass1.positionX.isNaN, isFalse);
      }
      m.reset();
      expect(m.mass1.value, 100);
      expect(m.mass2.value, 400);
      expect(m.ruler.positionX, 0);
      m.dispose();
    });

    testWidgets('rapid WASD on grabbed ruler', (tester) async {
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
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      for (var i = 0; i < 20; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      }
      await tester.pump();
      expect(model.force.isFinite, isTrue);
      expect(model.mass1.value, 100);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });

  group('Lifecycle accessibility', () {
    testWidgets('leave / re-enter screen keeps a11y operable', (tester) async {
      final semantics = tester.ensureSemantics();
      final audio = GflAudio(playEnabled: false);
      await tester.pumpWidget(
        MaterialApp(home: GravityForceLabScreen(audio: audio)),
      );
      await tester.pump();
      expect(find.bySemanticsLabel(GflA11yStrings.mass1), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(home: GravityForceLabScreen(audio: audio)),
      );
      await tester.pump();

      expect(find.bySemanticsLabel(GflA11yStrings.mass1), findsOneWidget);
      expect(
        find.bySemanticsLabel(GflA11yStrings.measureDistanceRuler),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.mass1));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      final state = tester.state<GravityForceLabScreenState>(
        find.byType(GravityForceLabScreen),
      );
      expect(state.model.mass1.value, 150);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await audio.dispose();
      semantics.dispose();
    });

    testWidgets('no duplicate Mass 1 semantic nodes', (tester) async {
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
      expect(find.bySemanticsLabel(GflA11yStrings.mass1), findsOneWidget);
      expect(find.bySemanticsLabel(GflA11yStrings.mass2), findsOneWidget);
      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });
}
