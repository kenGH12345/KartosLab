import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab/widgets/gfl_keyboard_help.dart';

void main() {
  group('Accessible identities', () {
    testWidgets('Mass 1 / Mass 2 / Ruler / controls labels present',
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

      expect(find.bySemanticsLabel(GflA11yStrings.mass1), findsOneWidget);
      expect(find.bySemanticsLabel(GflA11yStrings.mass2), findsOneWidget);
      expect(
        find.bySemanticsLabel(GflA11yStrings.measureDistanceRuler),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(GflA11yStrings.forceValues), findsWidgets);
      expect(
        find.bySemanticsLabel(GflA11yStrings.decimalNotation),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(GflA11yStrings.scientificNotation),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(GflA11yStrings.hidden), findsOneWidget);
      expect(
        find.bySemanticsLabel(GflA11yStrings.constantSize),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(GflA11yStrings.resetAll), findsOneWidget);
      expect(
        find.bySemanticsLabel(GflA11yStrings.moveObject('m1')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(GflA11yStrings.moveObject('m2')),
        findsOneWidget,
      );

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });

    test('mass value semantics strings from Model', () {
      expect(GflA11yStrings.massAndUnit(100), '100 kilograms');
      expect(GflA11yStrings.massAndUnit(400), '400 kilograms');
      expect(GflA11yStrings.massAndUnit(10), '10 kilograms');
      expect(GflA11yStrings.massAndUnit(1000), '1000 kilograms');
    });
  });

  group('Force / Constant Size / Reset semantics', () {
    testWidgets('Force Values radio group updates Model', (tester) async {
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

      await tester.tap(find.text('Scientific Notation'));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.scientific);

      await tester.tap(find.text('Hidden'));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.hidden);

      await tester.tap(find.text('Decimal Notation'));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.decimal);

      await audio.dispose();
      model.dispose();
    });

    testWidgets('Constant Size toggles Model', (tester) async {
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

      expect(model.constantRadius, isFalse);
      await tester.tap(find.text('Constant Size'));
      await tester.pump();
      expect(model.constantRadius, isTrue);
      expect(model.mass1.radius, 0.5);

      await tester.tap(find.text('Constant Size'));
      await tester.pump();
      expect(model.constantRadius, isFalse);

      await audio.dispose();
      model.dispose();
    });

    testWidgets('Reset semantics activates model.reset', (tester) async {
      final semantics = tester.ensureSemantics();
      final model = GravityForceLabModel();
      model.setMassValue(1, 700);
      model.setRulerPosition(2, 1);
      final audio = GflAudio(playEnabled: false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflScreenBody(model: model, audio: audio),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel(GflA11yStrings.resetAll));
      await tester.pump();
      expect(model.mass1.value, 100);
      expect(model.ruler.positionX, 0);

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });

  group('Keyboard Help', () {
    testWidgets('opens Full help (not Basics up/down mass)', (tester) async {
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
        find.bySemanticsLabel(GflA11yStrings.keyboardHelpButton),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(GflA11yStrings.keyboardHelp), findsOneWidget);
      expect(find.text(GflA11yStrings.moveSpheresHeading), findsOneWidget);
      expect(find.text(GflA11yStrings.changeMassHeading), findsOneWidget);
      expect(find.textContaining('J + C'), findsOneWidget);
      expect(find.textContaining('J + H'), findsOneWidget);
      expect(find.byType(GflKeyboardHelpDialog), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });

  group('Semantic grouping', () {
    testWidgets('screen and sphere group exist; paints excluded',
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

      expect(find.bySemanticsLabel(GflA11yStrings.screen), findsWidgets);
      expect(
        find.bySemanticsLabel(GflA11yStrings.spherePositionsGroup),
        findsOneWidget,
      );

      await audio.dispose();
      model.dispose();
      semantics.dispose();
    });
  });
}
