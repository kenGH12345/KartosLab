import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/controller/mixtures_controller.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/interactivity_mode.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/screens/mix_isotopes_screen.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/widgets/expanded_periodic_table.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MixturesController buildController() => MixturesController();

  group('Mix Isotopes View', () {
    testWidgets('screen renders chamber controls and reset', (tester) async {
      final c = buildController();
      await tester.pumpWidget(
        MaterialApp(
          home: MixIsotopesScreen(
            controller: c,
            embedded: true,
            tickOnClock: false,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Periodic Table'), findsOneWidget);
      expect(find.text('Percent Composition'), findsOneWidget);
      expect(find.text('Average Atomic Mass'), findsOneWidget);
      expect(find.text('My Mix'), findsOneWidget);
      expect(find.textContaining('Nature'), findsOneWidget);
      expect(find.textContaining('Isotope Mixture'), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
    });

    testWidgets('element selection updates model Z<=18', (tester) async {
      final c = buildController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: c,
              builder: (_, _) => ExpandedPeriodicTable(
                selectedZ: c.model.selectedAtomicNumber,
                interactiveMax: 18,
                onSelect: c.selectElement,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Ar'), findsOneWidget);
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(c.model.selectedAtomicNumber, 6);
    });

    testWidgets('controller drag bucket→chamber', (tester) async {
      final c = buildController();
      final id = c.model.bucketParticles.first.id;
      expect(c.beginDrag(id, 0, 0), isTrue);
      c.updateDrag(0, 0);
      expect(c.endDrag(), isTrue);
      expect(c.model.totalIsotopeCount, 1);
    });

    testWidgets('invalid drop returns to bucket', (tester) async {
      final c = buildController();
      final id = c.model.bucketParticles.first.id;
      final mass = c.model.bucketParticles.first.massNumber;
      c.beginDrag(id, 0, 0);
      c.updateDrag(500, 500);
      expect(c.endDrag(), isFalse);
      expect(c.model.getIsotopeCount(mass), 0);
      expect(c.model.bucketParticles.any((p) => p.id == id), isTrue);
    });

    testWidgets('Nature mix uses chamber particles without widgets explosion',
        (tester) async {
      final c = buildController();
      c.setShowingNaturesMix(true);
      expect(c.model.chamberParticles.length, greaterThan(900));
      await tester.pumpWidget(
        MaterialApp(
          home: MixIsotopesScreen(
            controller: c,
            embedded: true,
            tickOnClock: false,
          ),
        ),
      );
      await tester.pump();
      // Single screen, no per-particle widgets for Nature.
      expect(find.byType(MixIsotopesScreen), findsOneWidget);
      expect(c.model.showingNaturesMix, isTrue);
    });

    testWidgets('clear and reset via controller', (tester) async {
      final c = buildController();
      c.model.moveBucketToChamber(1);
      expect(c.model.totalIsotopeCount, 1);
      c.clear();
      expect(c.model.totalIsotopeCount, 0);
      c.selectElement(6);
      c.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      c.setIsotopeQuantity(12, 10);
      c.reset();
      expect(c.model.selectedAtomicNumber, 1);
      expect(c.model.interactivityMode, InteractivityMode.bucketsAndLargeAtoms);
      expect(c.model.totalIsotopeCount, 0);
    });

    testWidgets('mode switch keeps separate mixes', (tester) async {
      final c = buildController();
      c.model.moveBucketToChamber(1);
      c.model.moveBucketToChamber(1);
      c.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
      expect(c.model.totalIsotopeCount, 0);
      c.setIsotopeQuantity(1, 40);
      c.setInteractivityMode(InteractivityMode.bucketsAndLargeAtoms);
      expect(c.model.getIsotopeCount(1), 2);
    });
  });
}
