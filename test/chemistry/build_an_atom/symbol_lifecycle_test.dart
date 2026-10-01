import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/baa_symbol_node.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSymbol(WidgetTester tester, {BAAModel? model}) async {
    await tester.pumpWidget(
      MaterialApp(home: BuildAnAtomSymbolScreen(model: model)),
    );
    await tester.pump();
  }

  testWidgets('leave/return preserves injected model', (tester) async {
    final m = BAAModel();
    m.setAtomConfiguration(const NumberAtom(1, 1, 1));
    await pumpSymbol(tester, model: m);
    expect(find.byType(BaaSymbolNode), findsOneWidget);
    expect(find.text('H'), findsWidgets); // PT cell + SymbolNode

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();

    await pumpSymbol(tester, model: m);
    expect(m.protonCount, 1);
    expect(m.neutronCount, 1);
    expect(m.electronCount, 1);
    expect(find.text('H'), findsWidgets);
    expect(find.text('2'), findsWidgets); // mass
    expect(tester.takeException(), isNull);
  });

  testWidgets('rebuild after reset stays clean', (tester) async {
    final m = BAAModel();
    m.setAtomConfiguration(const NumberAtom(2, 2, 2));
    await pumpSymbol(tester, model: m);
    m.reset();
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    await pumpSymbol(tester, model: m);
    expect(m.protonCount, 0);
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
