import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';

void main() {
  group('Focus traversal', () {
    testWidgets('ordered focusables exist; paints not focus targets',
        (tester) async {
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

      expect(
        find.bySemanticsLabel(GflA11yStrings.moveObject('m1')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(GflA11yStrings.moveObject('m2')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(GflA11yStrings.measureDistanceRuler),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(GflA11yStrings.mass1), findsOneWidget);
      expect(find.bySemanticsLabel(GflA11yStrings.mass2), findsOneWidget);
      expect(find.bySemanticsLabel(GflA11yStrings.resetAll), findsOneWidget);
      expect(
        find.bySemanticsLabel(GflA11yStrings.keyboardHelpButton),
        findsOneWidget,
      );

      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });

    testWidgets('FocusTraversalGroup present', (tester) async {
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
      expect(find.byType(FocusTraversalGroup), findsWidgets);
      await audio.dispose();
      model.dispose();
    });
  });
}
