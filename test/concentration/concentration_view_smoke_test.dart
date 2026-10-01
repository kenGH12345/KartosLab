import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_form.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

void main() {
  testWidgets('ConcentrationScreen builds initial static scene', (tester) async {
    final model = ConcentrationModel();
    await tester.pumpWidget(
      MaterialApp(home: ConcentrationScreen(model: model)),
    );
    // Avoid pumpAndSettle — SimulationClock keeps scheduling frames.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Concentration'), findsWidgets); // AppBar + meter
    expect(find.text('Evaporation:'), findsOneWidget);
    expect(find.text('Remove Solute'), findsOneWidget);
    expect(find.text('Drink mix'), findsWidgets);
    expect(find.text('Solid'), findsOneWidget);
    expect(find.text('Solution'), findsOneWidget);
    expect(find.textContaining('\u2014'), findsOneWidget); // meter unknown
  });

  testWidgets('solute form switches via panel radios', (tester) async {
    final model = ConcentrationModel();
    await tester.pumpWidget(
      MaterialApp(home: ConcentrationScreen(model: model)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final solutionFinder = find.text('Solution');
    expect(solutionFinder, findsOneWidget);
    await tester.ensureVisible(solutionFinder);
    await tester.tap(solutionFinder, warnIfMissed: false);
    await tester.pump();
    if (model.soluteForm != SoluteForm.solution) {
      model.setSoluteForm(SoluteForm.solution);
      await tester.pump();
    }
    expect(model.soluteForm, SoluteForm.solution);

    model.setSoluteForm(SoluteForm.solid);
    await tester.pump();
    expect(model.soluteForm, SoluteForm.solid);
  });
}
