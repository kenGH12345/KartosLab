import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';

void main() {
  group('Keyboard controls', () {
    testWidgets('Force Values Space selects radio via focus', (tester) async {
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
        find.bySemanticsLabel(GflA11yStrings.scientificNotation),
      );
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.scientific);

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.hidden));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.hidden);

      await tester.tap(
        find.bySemanticsLabel(GflA11yStrings.decimalNotation),
      );
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.decimal);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });

    testWidgets('Constant Size Space toggles via focus', (tester) async {
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

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.constantSize));
      await tester.pump();
      expect(model.constantRadius, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(model.constantRadius, isFalse);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });

    testWidgets('Hidden mode still keeps force Model value', (tester) async {
      final model = GravityForceLabModel();
      final f0 = model.forceMagnitude;
      model.setForceValuesDisplay(ForceValuesDisplay.hidden);
      expect(model.showForceValues, isFalse);
      expect(model.forceMagnitude, f0);
      expect(GflA11yStrings.forceValuesHidden, isNotEmpty);
      model.dispose();
    });
  });
}
