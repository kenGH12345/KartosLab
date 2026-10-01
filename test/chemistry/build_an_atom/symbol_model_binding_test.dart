import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/charge_notation.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/baa_symbol_node.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/charge_meter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSymbol(WidgetTester tester, NumberAtom atom) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BaaSymbolNode(atom: atom, scale: 0.41),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('Symbol model binding matrix', () {
    final cases = <(NumberAtom, String, String, String)>[
      // atom, symbol, mass text, charge text
      (const NumberAtom(0, 0, 0), '-', '0', '0'),
      (const NumberAtom(1, 0, 1), 'H', '1', '0'),
      (const NumberAtom(1, 1, 1), 'H', '2', '0'),
      (const NumberAtom(1, 0, 0), 'H', '1', '1+'),
      (const NumberAtom(1, 0, 2), 'H', '1', '1\u2212'),
      (const NumberAtom(2, 2, 2), 'He', '4', '0'),
      (const NumberAtom(6, 6, 6), 'C', '12', '0'),
      (const NumberAtom(6, 6, 5), 'C', '12', '1+'),
      (const NumberAtom(6, 6, 7), 'C', '12', '1\u2212'),
    ];

    for (final c in cases) {
      final atom = c.$1;
      testWidgets(
        '${atom.protons}p/${atom.neutrons}n/${atom.electrons}e → ${c.$2}',
        (tester) async {
          await pumpSymbol(tester, atom);
          expect(find.text(c.$2), findsWidgets);
          // Mass / Z / charge may share digit strings (e.g. empty → three '0's).
          expect(find.text(c.$3), findsWidgets);
          expect(find.text(c.$4), findsWidgets);
          expect(find.byType(ChargeMeter), findsOneWidget);
          expect(find.byType(Image), findsOneWidget); // scale.png
        },
      );
    }

    test('BAAModel.numberAtom drives same values', () {
      final m = BAAModel();
      m.setAtomConfiguration(const NumberAtom(6, 6, 5));
      final a = m.numberAtom;
      expect(a.symbol, 'C');
      expect(a.massNumber, 12);
      expect(a.atomicNumber, 6);
      expect(a.charge, 1);
      expect(formatChargeDisplay(a.charge), '1+');
    });
  });
}
