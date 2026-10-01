import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/view/symbol_view_state.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/baa_symbol_node.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/charge_meter.dart';

/// Phase 3 Symbol Screen goldens — 768×464 design viewport.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSymbolScreen(
    WidgetTester tester,
    BAAModel model, {
    bool symbolExpanded = true,
  }) async {
    await tester.binding.setSurfaceSize(
      const Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: BuildAnAtomSymbolScreen(model: model),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    if (!symbolExpanded) {
      final symbolAccordion = find.byKey(const Key('baaSymbolAccordion'));
      await tester.tap(
        find.descendant(of: symbolAccordion, matching: find.byType(InkWell)),
      );
      await tester.pump(); // ticker never settles
    }
  }

  Future<void> pumpSymbolNode(WidgetTester tester, NumberAtom atom) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: BuildAnAtomSymbolScreen.backgroundColor,
          body: Center(
            child: BaaSymbolNode(atom: atom, scale: 0.41),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('Symbol goldens', () {
    testWidgets('symbol_empty', (tester) async {
      final m = BAAModel();
      await pumpSymbolScreen(tester, m);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_empty.png'),
      );
    });

    testWidgets('symbol_hydrogen', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(1, 0, 1));
      await pumpSymbolScreen(tester, m);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_hydrogen.png'),
      );
    });

    testWidgets('symbol_isotope', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(1, 1, 1));
      await pumpSymbolScreen(tester, m);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_isotope.png'),
      );
    });

    testWidgets('symbol_positive_ion', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(1, 0, 0));
      await pumpSymbolScreen(tester, m);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_positive_ion.png'),
      );
    });

    testWidgets('symbol_negative_ion', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(1, 0, 2));
      await pumpSymbolScreen(tester, m);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_negative_ion.png'),
      );
    });

    testWidgets('symbol_carbon', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(6, 6, 6));
      await pumpSymbolScreen(tester, m);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_carbon.png'),
      );
    });

    testWidgets('symbol_accordion_open', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(2, 2, 2));
      await pumpSymbolScreen(tester, m, symbolExpanded: true);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_accordion_open.png'),
      );
    });

    testWidgets('symbol_accordion_closed', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(2, 2, 2));
      await pumpSymbolScreen(tester, m, symbolExpanded: false);
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_accordion_closed.png'),
      );
    });

    testWidgets('symbol_charge_meter', (tester) async {
      await tester.binding.setSurfaceSize(const Size(200, 120));
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Transform.scale(
                scale: 1.6,
                child: const ChargeMeter(
                  charge: 3,
                  width: 70,
                  showNumericalReadout: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(ChargeMeter),
        matchesGoldenFile('golden/symbol_charge_meter.png'),
      );
    });

    testWidgets('symbol_reset', (tester) async {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(6, 6, 5));
      await pumpSymbolScreen(tester, m);
      m.reset();
      // Mirror view reset accordion
      final sv = SymbolViewState(m)..reset();
      expect(sv.symbolExpanded, isTrue);
      await tester.pump();
      await expectLater(
        find.byType(BuildAnAtomSymbolScreen),
        matchesGoldenFile('golden/symbol_reset.png'),
      );
    });

    testWidgets('node-only smoke for empty glyph layout', (tester) async {
      await pumpSymbolNode(tester, const NumberAtom(0, 0, 0));
      expect(find.text('-'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
