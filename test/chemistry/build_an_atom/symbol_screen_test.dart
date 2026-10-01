import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/electron_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/baa_symbol_node.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/charge_meter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSymbol(WidgetTester tester, {BAAModel? model}) async {
    await tester.pumpWidget(
      MaterialApp(home: BuildAnAtomSymbolScreen(model: model)),
    );
    await tester.pump();
  }

  group('Symbol Screen', () {
    testWidgets('enters empty state', (tester) async {
      await pumpSymbol(tester);
      expect(find.text('Symbol'), findsWidgets);
      expect(find.text('Periodic Table'), findsOneWidget);
      expect(find.byType(BaaSymbolNode), findsOneWidget);
      expect(find.text('Net Charge'), findsNothing);
      expect(find.text('Mass Number'), findsNothing);
      expect(find.text('Protons:'), findsOneWidget);
      expect(find.text('Model:'), findsOneWidget);
    });

    testWidgets('normal user path', (tester) async {
      final m = BAAModel();
      await pumpSymbol(tester, model: m);

      m.addFromBucket(BaaParticleType.proton);
      await tester.pump();
      expect(find.text('H'), findsWidgets);

      m.addFromBucket(BaaParticleType.neutron);
      await tester.pump();
      expect(m.massNumber, 2);

      m.addFromBucket(BaaParticleType.electron);
      await tester.pump();
      expect(m.charge, 0);
      expect(find.text('Hydrogen'), findsOneWidget);

      // isotope already (1n); create positive ion
      final e = m.atom.electrons.first;
      m.removeToBucket(e);
      await tester.pump();
      expect(m.charge, 1);
      expect(find.text('1+'), findsOneWidget);

      // negative ion
      m.addFromBucket(BaaParticleType.electron);
      m.addFromBucket(BaaParticleType.electron);
      await tester.pump();
      expect(m.charge, -1);
      expect(find.text('1\u2212'), findsOneWidget);

      // accordion toggle (keyed — AppBar also says "Symbol")
      // Note: do not pumpAndSettle — screen ticker never settles.
      final symbolAccordion = find.byKey(const Key('baaSymbolAccordion'));
      await tester.tap(
        find.descendant(of: symbolAccordion, matching: find.byType(InkWell)),
      );
      await tester.pump();
      expect(find.byType(BaaSymbolNode), findsNothing);
      await tester.tap(
        find.descendant(of: symbolAccordion, matching: find.byType(InkWell)),
      );
      await tester.pump();
      expect(find.byType(BaaSymbolNode), findsOneWidget);

      m.reset();
      await tester.pump();
      expect(m.protonCount, 0);
    });

    testWidgets('edge configurations', (tester) async {
      final m = BAAModel();
      await pumpSymbol(tester, model: m);

      m.setAtomConfiguration(const NumberAtom(0, 0, 0));
      await tester.pump();
      expect(find.text('-'), findsWidgets);

      m.setAtomConfiguration(const NumberAtom(1, 0, 0));
      await tester.pump();
      expect(find.text('H'), findsWidgets);

      m.setAtomConfiguration(const NumberAtom(1, 2, 1));
      await tester.pump();
      expect(m.atomicNumber, 1);
      expect(m.massNumber, 3);

      m.setAtomConfiguration(
        NumberAtom(
          BAAConstants.maxProtons,
          BAAConstants.maxNeutrons,
          BAAConstants.maxElectrons,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(ChargeMeter), findsOneWidget);
    });

    testWidgets('drag bucket → atom → bucket syncs symbol', (tester) async {
      final m = BAAModel();
      await pumpSymbol(tester, model: m);
      final p = m.protonBucket.particles.first;

      m.beginDrag(p, modelX: 0, modelY: 0);
      m.endDrag(p, 0, 0);
      await tester.pump();
      expect(m.atom.contains(p), isTrue);
      expect(find.text('H'), findsWidgets);

      m.beginDrag(p, modelX: 0, modelY: 0);
      m.endDrag(p, 400, 400);
      await tester.pump();
      expect(m.protonBucket.contains(p), isTrue);
      expect(find.text('-'), findsWidgets);
    });

    testWidgets('rapid accordion / shell / reset', (tester) async {
      final m = BAAModel();
      await pumpSymbol(tester, model: m);
      m.setAtomConfiguration(const NumberAtom(2, 2, 2));
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text(i.isEven ? 'Cloud' : 'Shells'));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(m.electronCount, 2);

      final symbolAccordion = find.byKey(const Key('baaSymbolAccordion'));
      for (var i = 0; i < 4; i++) {
        await tester.tap(
          find.descendant(of: symbolAccordion, matching: find.byType(InkWell)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }

      for (var i = 0; i < 3; i++) {
        m.addFromBucket(BaaParticleType.proton);
        m.removeToBucket(m.atom.protons.last);
        await tester.pump(const Duration(milliseconds: 8));
      }

      final buttons = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('KratosResetAllButton'),
      );
      await tester.tap(buttons);
      await tester.pump();
      expect(m.protonCount, 0);
      expect(m.electronModel.type, ElectronModelType.shells);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not show Atom-only panels', (tester) async {
      await pumpSymbol(tester);
      expect(find.text('Net Charge'), findsNothing);
      expect(find.text('Mass Number'), findsNothing);
    });
  });
}
