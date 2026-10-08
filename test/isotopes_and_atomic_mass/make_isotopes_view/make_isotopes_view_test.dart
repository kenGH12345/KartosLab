import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/controller/make_isotopes_controller.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/screens/make_isotopes_screen.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/widgets/expanded_periodic_table.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/iaam_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MakeIsotopesController buildController() {
    final c = MakeIsotopesController();
    // Don't attach clock in widget tests (no TickerProvider reliably).
    return c;
  }

  group('Make Isotopes View', () {
    testWidgets('periodic table renders H..Ne symbols', (tester) async {
      final c = buildController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandedPeriodicTable(
              selectedZ: c.model.protonCount,
              interactiveMax: 10,
              onSelect: c.selectElement,
            ),
          ),
        ),
      );
      expect(find.text('H'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('Ne'), findsOneWidget);
      expect(find.text('Periodic Table'), findsOneWidget);
    });

    testWidgets('element selection updates model', (tester) async {
      final c = buildController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: c,
              builder: (_, _) => ExpandedPeriodicTable(
                selectedZ: c.model.protonCount,
                interactiveMax: 10,
                onSelect: c.selectElement,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(c.model.protonCount, 6);
      expect(c.model.neutronCount, 6);
      expect(c.model.massNumber, 12);
    });

    testWidgets('same element reselect does not reset neutrons', (tester) async {
      final c = buildController();
      c.selectElement(6);
      c.model.addNeutron();
      expect(c.model.neutronCount, 7);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: c,
              builder: (_, _) => ExpandedPeriodicTable(
                selectedZ: c.model.protonCount,
                interactiveMax: 10,
                onSelect: c.selectElement,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(c.model.neutronCount, 7);
    });

    testWidgets('screen shows mass / abundance / reset', (tester) async {
      final c = buildController();
      await tester.pumpWidget(
        MaterialApp(
          home: MakeIsotopesScreen(
            controller: c,
            embedded: true,
            tickOnClock: false,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Mass Number'), findsOneWidget);
      expect(find.text(IaamStrings.atomicMass), findsOneWidget);
      expect(find.text('Symbol'), findsOneWidget);
      expect(find.text('Abundance in Nature'), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('Stable'), findsOneWidget);
      expect(find.textContaining('Hydrogen'), findsWidgets);
    });

    testWidgets('reset restores Hydrogen after Carbon', (tester) async {
      final c = buildController();
      await tester.pumpWidget(
        MaterialApp(
          home: MakeIsotopesScreen(
            controller: c,
            embedded: true,
            tickOnClock: false,
          ),
        ),
      );
      await tester.pump();
      c.selectElement(6);
      c.model.addNeutron();
      await tester.pump();
      await tester.tap(find.byType(KratosResetAllButton));
      await tester.pump();
      expect(c.model.protonCount, 1);
      expect(c.model.neutronCount, 0);
      expect(c.model.bucketNeutronCount, 4);
    });

    testWidgets('drag contract via controller updates counts', (tester) async {
      final c = buildController();
      final id = c.model.bucketNeutrons.first.id;
      expect(c.beginDrag(id, 0, 0), isTrue);
      expect(c.model.isDragging, isTrue);
      c.updateDrag(0, 0);
      expect(c.endDrag(), isTrue);
      expect(c.model.neutronCount, 1);
      expect(c.model.massNumber, 2);
    });
  });
}
