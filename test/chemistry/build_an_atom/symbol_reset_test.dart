import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/electron_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/view/symbol_view_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reset clears ion/isotope and re-expands Symbol accordion',
      (tester) async {
    final m = BAAModel();
    m.setAtomConfiguration(const NumberAtom(6, 7, 5));
    m.setElectronModel(ElectronModelType.cloud);

    await tester.pumpWidget(
      MaterialApp(home: BuildAnAtomSymbolScreen(model: m)),
    );
    await tester.pump();

    // Collapse Symbol accordion (AppBar also says Symbol)
    final symbolAccordion = find.byKey(const Key('baaSymbolAccordion'));
    await tester.tap(
      find.descendant(of: symbolAccordion, matching: find.byType(InkWell)),
    );
    await tester.pump(); // ticker never settles

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
    // Symbol accordion content visible again (expanded) — element dash
    expect(find.text('-'), findsWidgets);
  });

  test('SymbolViewState.reset expands accordion', () {
    final m = BAAModel();
    final v = SymbolViewState(m);
    v.setSymbolExpanded(false);
    expect(v.symbolExpanded, isFalse);
    v.reset();
    expect(v.symbolExpanded, isTrue);
  });
}
