import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/electron_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAtom(WidgetTester tester, {BAAModel? model}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BuildAnAtomAtomScreen(model: model),
      ),
    );
    await tester.pump(); // first frame
  }

  group('Atom Screen', () {
    testWidgets('enters empty state', (tester) async {
      await pumpAtom(tester);
      expect(find.text('Atom'), findsOneWidget);
      expect(find.text('Periodic Table'), findsOneWidget);
      expect(find.text('Protons:'), findsOneWidget);
      expect(find.text('Model:'), findsOneWidget);
      expect(find.text('Shells'), findsOneWidget);
    });

    testWidgets('normal user path via model + UI sync', (tester) async {
      final m = BAAModel();
      await pumpAtom(tester, model: m);

      m.addFromBucket(BaaParticleType.proton);
      m.addFromBucket(BaaParticleType.neutron);
      m.addFromBucket(BaaParticleType.electron);
      await tester.pump();

      expect(m.protonCount, 1);
      expect(m.neutronCount, 1);
      expect(m.electronCount, 1);
      expect(m.charge, 0);
      expect(m.massNumber, 2);
      expect(find.text('Hydrogen'), findsOneWidget);
      expect(find.text('Neutral Atom'), findsOneWidget);

      // Net Charge / Mass Number default open.
      expect(find.text('0'), findsWidgets); // charge + mass readouts

      // Shell → Cloud → Shell
      await tester.tap(find.text('Cloud'));
      await tester.pump();
      expect(m.electronModel.type, ElectronModelType.cloud);
      expect(m.electronCount, 1);
      await tester.tap(find.text('Shells'));
      await tester.pump();
      expect(m.electronModel.type, ElectronModelType.shells);
      expect(m.electronCount, 1);

      // Remove electron → ion
      final e = m.atom.electrons.first;
      m.removeToBucket(e);
      await tester.pump();
      expect(find.text('Ion'), findsOneWidget);

      // Reset
      // KratosResetAllButton — find by tooltip/type; tap bottom-right via model API mirror
      m.reset();
      // Also reset view via screen — pump and find reset by semantics if needed
      await tester.pump();
      expect(m.protonCount, 0);
      expect(m.electronCount, 0);
    });

    testWidgets('edge configurations', (tester) async {
      final m = BAAModel();
      await pumpAtom(tester, model: m);

      m.setAtomConfiguration(const NumberAtom(0, 0, 3));
      await tester.pump();
      expect(m.electronCount, 3);
      expect(m.nucleusStable, isTrue);

      m.setAtomConfiguration(const NumberAtom(1, 2, 1)); // tritium-like unstable
      await tester.pump();
      expect(m.nucleusStable, isFalse);

      await tester.tap(find.text('Nuclear Stability'));
      await tester.pump();
      expect(find.text('Unstable'), findsOneWidget);

      m.setAtomConfiguration(const NumberAtom(6, 6, 6));
      await tester.pump();
      expect(find.text('Carbon'), findsOneWidget);

      m.setAtomConfiguration(
        NumberAtom(
          BAAConstants.maxProtons,
          BAAConstants.maxNeutrons,
          BAAConstants.maxElectrons,
        ),
      );
      await tester.pump();
      expect(m.protonCount, BAAConstants.maxProtons);
      expect(m.neutronCount, BAAConstants.maxNeutrons);
      expect(m.electronCount, BAAConstants.maxElectrons);
    });

    testWidgets('drag bucket → atom → bucket', (tester) async {
      final m = BAAModel();
      await pumpAtom(tester, model: m);
      final p = m.protonBucket.particles.first;

      m.beginDrag(p, modelX: 0, modelY: 0);
      m.updateDrag(p, 10, 10);
      m.endDrag(p, 0, 0);
      await tester.pump();
      expect(m.atom.contains(p), isTrue);

      m.beginDrag(p, modelX: 0, modelY: 0);
      m.endDrag(p, 400, 400);
      await tester.pump();
      expect(m.atom.contains(p), isFalse);
      expect(m.protonBucket.contains(p), isTrue);
    });

    testWidgets('rapid shell/cloud and accordion', (tester) async {
      final m = BAAModel();
      await pumpAtom(tester, model: m);
      m.setAtomConfiguration(const NumberAtom(2, 2, 2));
      for (var i = 0; i < 8; i++) {
        await tester.tap(find.text(i.isEven ? 'Cloud' : 'Shells'));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(m.electronCount, 2);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Periodic Table'));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('lifecycle leave/return preserves model if injected', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(1, 0, 1));
      await pumpAtom(tester, model: m);
      expect(find.text('Hydrogen'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      await pumpAtom(tester, model: m);
      expect(m.protonCount, 1);
      expect(find.text('Hydrogen'), findsOneWidget);
    });

    testWidgets('reset all button clears atom', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(3, 4, 3));
      await pumpAtom(tester, model: m);
      await tester.pump();

      // Tap KratosResetAllButton (GestureDetector / InkWell descendant)
      final resetFinder = find.byType(BuildAnAtomAtomScreen);
      expect(resetFinder, findsOneWidget);
      // Invoke via state's reset path: find button by type name
      final buttons = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('KratosResetAllButton'),
      );
      expect(buttons, findsOneWidget);
      await tester.tap(buttons);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(m.protonCount, 0);
      expect(m.neutronCount, 0);
      expect(m.electronCount, 0);
      expect(m.electronModel.type, ElectronModelType.shells);
    });
  });
}
