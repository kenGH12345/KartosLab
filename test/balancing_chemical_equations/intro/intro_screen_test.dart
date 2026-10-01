import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_model.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_screen.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/views/balance_scales_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bar_charts_node.dart';
import 'package:kratos/balancing_chemical_equations/views/particles_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  group('IntroModel defaults', () {
    test('default equation is Make Ammonia', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      expect(m.selectedId, 'intro.makeAmmonia');
      expect(m.viewMode, ViewMode.particles);
      expect(m.reactantsExpanded, isTrue);
      expect(m.productsExpanded, isTrue);
      expect(m.equations.length, 3);
    });

    test('default coefficients are 1', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      for (final t in m.selectedEquation.terms) {
        expect(t.coefficient, 1);
      }
    });

    test('switching equation preserves coefficients', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      m.selectedEquation.reactants.first.coefficient = 3;
      final ammonia = m.selectedEquation;
      m.selectById('intro.separateWater');
      expect(m.selectedId, 'intro.separateWater');
      expect(ammonia.reactants.first.coefficient, 3);
      m.selectById('intro.makeAmmonia');
      expect(ammonia.reactants.first.coefficient, 3);
    });

    test('view mode is mutually exclusive single enum', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      m.setViewMode(ViewMode.balanceScales);
      expect(m.viewMode, ViewMode.balanceScales);
      m.setViewMode(ViewMode.barCharts);
      expect(m.viewMode, ViewMode.barCharts);
      m.setViewMode(ViewMode.none);
      expect(m.viewMode, ViewMode.none);
      m.setViewMode(ViewMode.particles);
      expect(m.viewMode, ViewMode.particles);
    });

    test('view mode change does not reset coefficients', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      m.selectedEquation.reactants.first.coefficient = 2;
      m.setViewMode(ViewMode.barCharts);
      expect(m.selectedEquation.reactants.first.coefficient, 2);
      expect(m.selectedId, 'intro.makeAmmonia');
    });

    test('Reset All restores source initial state', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      m.selectById('intro.combustMethane');
      m.selectedEquation.reactants.first.coefficient = 3;
      m.setViewMode(ViewMode.none);
      m.setReactantsExpanded(false);
      m.setProductsExpanded(false);
      m.reset();
      expect(m.selectedId, 'intro.makeAmmonia');
      expect(m.viewMode, ViewMode.particles);
      expect(m.reactantsExpanded, isTrue);
      expect(m.productsExpanded, isTrue);
      for (final eq in m.equations) {
        for (final t in eq.terms) {
          expect(t.coefficient, 1);
        }
      }
    });

    test('coefficient boundaries 0..3', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      final t = m.selectedEquation.reactants.first;
      t.coefficient = -5;
      expect(t.coefficient, 0);
      t.coefficient = 99;
      expect(t.coefficient, 3);
    });

    test('balance transition uses model truth', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      final eq = m.selectedEquation; // ammonia 1:3:2
      expect(eq.isBalanced, isFalse); // defaults 1,1,1
      eq.reactants[0].coefficient = 1;
      eq.reactants[1].coefficient = 3;
      eq.products[0].coefficient = 2;
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isTrue);
    });
  });

  group('IntroScreen widget', () {
    Future<void> pumpIntro(WidgetTester tester, IntroModel model) async {
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 768,
                height: 504,
                child: IntroScreen(model: model),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('builds with default chrome', (tester) async {
      final model = IntroModel();
      addTearDown(model.dispose);
      await pumpIntro(tester, model);
      expect(find.text('Make Ammonia'), findsOneWidget);
      expect(find.text('Separate Water'), findsOneWidget);
      expect(find.text('Combust Methane'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.byType(ParticlesNode), findsOneWidget);
    });

    testWidgets('select equation by radio', (tester) async {
      final model = IntroModel();
      addTearDown(model.dispose);
      await pumpIntro(tester, model);
      await tester.tap(find.text('Separate Water'));
      await tester.pump();
      expect(model.selectedId, 'intro.separateWater');
    });

    testWidgets('view mode switches visualizations', (tester) async {
      final model = IntroModel();
      addTearDown(model.dispose);
      await pumpIntro(tester, model);
      expect(find.byType(ParticlesNode), findsOneWidget);

      model.setViewMode(ViewMode.balanceScales);
      await tester.pump();
      expect(find.byType(ParticlesNode), findsNothing);
      expect(find.byType(BalanceScalesNode), findsOneWidget);

      model.setViewMode(ViewMode.barCharts);
      await tester.pump();
      expect(find.byType(BarChartsNode), findsOneWidget);

      model.setViewMode(ViewMode.none);
      await tester.pump();
      expect(find.byType(ParticlesNode), findsNothing);
      expect(find.byType(BalanceScalesNode), findsNothing);
      expect(find.byType(BarChartsNode), findsNothing);
      expect(find.text('Make Ammonia'), findsOneWidget);
    });

    testWidgets('Reset All from modified UI state', (tester) async {
      final model = IntroModel();
      addTearDown(model.dispose);
      await pumpIntro(tester, model);
      model.selectById('intro.combustMethane');
      model.setViewMode(ViewMode.none);
      model.selectedEquation.reactants.first.coefficient = 2;
      await tester.pump();
      await tester.tap(find.byType(KratosResetAllButton));
      await tester.pumpAndSettle();
      expect(model.selectedId, 'intro.makeAmmonia');
      expect(model.viewMode, ViewMode.particles);
      expect(model.selectedEquation.reactants.first.coefficient, 1);
    });

    testWidgets('accordion toggle reactants', (tester) async {
      final model = IntroModel();
      addTearDown(model.dispose);
      await pumpIntro(tester, model);
      expect(model.reactantsExpanded, isTrue);
      model.toggleReactants();
      await tester.pump();
      expect(model.reactantsExpanded, isFalse);
      expect(find.text('Reactants'), findsOneWidget);
      model.toggleProducts();
      await tester.pump();
      expect(model.productsExpanded, isFalse);
      expect(find.text('Products'), findsOneWidget);
    });
  });
}
