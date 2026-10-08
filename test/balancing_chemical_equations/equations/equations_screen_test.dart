import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_model.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_screen.dart';
import 'package:kratos/balancing_chemical_equations/model/bce_molecule.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/views/balance_scales_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bar_charts_node.dart';
import 'package:kratos/balancing_chemical_equations/views/particles_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';

void main() {
  group('EquationsModel defaults', () {
    test('default reaction type is synthesis', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      expect(m.reactionType, ReactionType.synthesis);
      expect(m.selectedId, 'equations.synthesis.equation0');
      expect(m.viewMode, ViewMode.particles);
      expect(m.reactantsExpanded, isTrue);
      expect(m.productsExpanded, isTrue);
      expect(m.allEquations.length, 12);
    });

    test('reaction type ordering matches source', () {
      expect(ReactionType.values, [
        ReactionType.synthesis,
        ReactionType.decomposition,
        ReactionType.combustion,
      ]);
    });

    test('synthesis dataset identities and balanced coeffs', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      final eqs = m.synthesisEquations;
      expect(eqs.length, 4);
      expect(eqs.first.id, 'equations.synthesis.equation0');
      expect(eqs.first.reactants[0].molecule, BceMolecule.c);
      expect(eqs.first.reactants[0].balancedCoefficient, 2);
      expect(eqs.first.reactants[1].molecule, BceMolecule.o2);
      expect(eqs.first.products[0].molecule, BceMolecule.co);
      expect(eqs.last.id, 'equations.synthesis.equation3');
      expect(eqs.last.products.first.molecule, BceMolecule.c2h6);
      expect(eqs[1].id, 'equations.synthesis.equation1');
      expect(eqs[2].id, 'equations.synthesis.equation2');
    });

    test('decomposition first/middle/last', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      final eqs = m.decompositionEquations;
      expect(eqs.first.reactants.first.molecule, BceMolecule.ch3Oh);
      expect(eqs[1].reactants.first.molecule, BceMolecule.no2);
      expect(eqs.last.reactants.first.molecule, BceMolecule.h2o2);
    });

    test('combustion first/middle/last', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      final eqs = m.combustionEquations;
      expect(eqs.first.reactants.first.molecule, BceMolecule.c2h4);
      expect(eqs[1].reactants.first.molecule, BceMolecule.c2h5Oh);
      expect(eqs[2].reactants.first.molecule, BceMolecule.ch3Oh);
      expect(eqs.last.reactants.first.molecule, BceMolecule.c2h2);
    });

    test('switching reaction type preserves per-type equation + coeffs', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      m.selectEquation(m.synthesisEquations[2]);
      m.selectedEquation.reactants.first.coefficient = 4;
      final synthSel = m.selectedEquation;

      m.setReactionType(ReactionType.decomposition);
      expect(m.reactionType, ReactionType.decomposition);
      expect(m.selectedId, 'equations.decomposition.equation0');
      expect(synthSel.reactants.first.coefficient, 4);

      m.setReactionType(ReactionType.synthesis);
      expect(identical(m.selectedEquation, synthSel), isTrue);
      expect(m.selectedEquation.reactants.first.coefficient, 4);
    });

    test('view mode change does not reset equation or coeffs', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      m.selectedEquation.reactants.first.coefficient = 3;
      final id = m.selectedId;
      m.setViewMode(ViewMode.barCharts);
      expect(m.selectedId, id);
      expect(m.selectedEquation.reactants.first.coefficient, 3);
      m.setViewMode(ViewMode.none);
      expect(m.selectedId, id);
      expect(m.selectedEquation.reactants.first.coefficient, 3);
    });

    test('coefficient boundaries 0..6', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      final term = m.selectedEquation.reactants.first;
      term.coefficient = -1;
      expect(term.coefficient, 0);
      term.coefficient = 99;
      expect(term.coefficient, 6);
    });

    test('balance / simplified via model', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      final eq = m.selectedEquation; // 2C + O2 → 2CO
      expect(eq.isBalanced, isFalse);
      eq.balance();
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isTrue);
      for (final t in eq.terms) {
        t.coefficient = t.balancedCoefficient * 2;
      }
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isFalse);
    });

    test('Reset All restores source initial state', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      m.setReactionType(ReactionType.combustion);
      m.selectEquation(m.combustionEquations.last);
      m.selectedEquation.reactants.first.coefficient = 5;
      m.setViewMode(ViewMode.none);
      m.setReactantsExpanded(false);
      m.setProductsExpanded(false);
      m.reset();
      expect(m.reactionType, ReactionType.synthesis);
      expect(m.selectedId, 'equations.synthesis.equation0');
      expect(m.viewMode, ViewMode.particles);
      expect(m.reactantsExpanded, isTrue);
      expect(m.productsExpanded, isTrue);
      expect(m.selectedEquation.reactants.first.coefficient, 1);
      expect(m.combustionEquations.last.reactants.first.coefficient, 1);
    });
  });

  group('EquationsScreen widget', () {
    Future<void> pumpEq(WidgetTester tester, EquationsModel model) async {
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 768,
                height: 504,
                child: EquationsScreen(model: model),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('builds with reaction chrome', (tester) async {
      final model = EquationsModel();
      addTearDown(model.dispose);
      await pumpEq(tester, model);
      expect(find.text('Synthesis'), findsOneWidget);
      expect(find.text('Decomposition'), findsOneWidget);
      expect(find.text('Combustion'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.byType(ParticlesNode), findsOneWidget);
    });

    testWidgets('switch reaction type via radio', (tester) async {
      final model = EquationsModel();
      addTearDown(model.dispose);
      await pumpEq(tester, model);
      await tester.tap(find.text('Decomposition'));
      await tester.pump();
      expect(model.reactionType, ReactionType.decomposition);
      expect(model.selectedId, 'equations.decomposition.equation0');

      await tester.tap(find.text('Combustion'));
      await tester.pump();
      expect(model.reactionType, ReactionType.combustion);
      expect(model.selectedId, 'equations.combustion.equation0');
    });

    testWidgets('view mode switches visualizations', (tester) async {
      final model = EquationsModel();
      addTearDown(model.dispose);
      await pumpEq(tester, model);
      expect(find.byType(ParticlesNode), findsOneWidget);

      model.setViewMode(ViewMode.balanceScales);
      await tester.pump();
      expect(find.byType(BalanceScalesNode), findsOneWidget);

      model.setViewMode(ViewMode.barCharts);
      await tester.pump();
      expect(find.byType(BarChartsNode), findsOneWidget);

      model.setViewMode(ViewMode.none);
      await tester.pump();
      expect(find.byType(ParticlesNode), findsNothing);
      expect(find.byType(BalanceScalesNode), findsNothing);
      expect(find.byType(BarChartsNode), findsNothing);
      expect(find.text('Synthesis'), findsOneWidget);
    });

    testWidgets('accordion toggles', (tester) async {
      final model = EquationsModel();
      addTearDown(model.dispose);
      await pumpEq(tester, model);
      model.toggleReactants();
      await tester.pump();
      expect(model.reactantsExpanded, isFalse);
      expect(find.text(BceStrings.reactants), findsOneWidget);
      model.toggleProducts();
      await tester.pump();
      expect(model.productsExpanded, isFalse);
      expect(find.text(BceStrings.products), findsOneWidget);
    });

    testWidgets('Reset All from modified UI state', (tester) async {
      final model = EquationsModel();
      addTearDown(model.dispose);
      await pumpEq(tester, model);
      model.setReactionType(ReactionType.combustion);
      model.selectEquation(model.combustionEquations[1]);
      model.setViewMode(ViewMode.none);
      model.selectedEquation.reactants.first.coefficient = 2;
      await tester.pump();
      await tester.tap(find.byType(KratosResetAllButton));
      await tester.pumpAndSettle();
      expect(model.reactionType, ReactionType.synthesis);
      expect(model.selectedId, 'equations.synthesis.equation0');
      expect(model.viewMode, ViewMode.particles);
      expect(model.selectedEquation.reactants.first.coefficient, 1);
    });

    testWidgets('equation selection by identity', (tester) async {
      final model = EquationsModel();
      addTearDown(model.dispose);
      await pumpEq(tester, model);
      model.selectEquation(model.synthesisEquations.last);
      await tester.pump();
      expect(model.selectedId, 'equations.synthesis.equation3');
      expect(
        model.selectedEquation.products.first.molecule,
        BceMolecule.c2h6,
      );
    });
  });
}
