import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';

/// Phase 5 Atom Screen goldens — fixed 768×464 + AppBar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAtom(WidgetTester tester, BAAModel model) async {
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
          child: BuildAnAtomAtomScreen(model: model),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
  }

  Future<void> golden(WidgetTester tester, String name, BAAModel model) async {
    await pumpAtom(tester, model);
    await expectLater(
      find.byType(BuildAnAtomAtomScreen),
      matchesGoldenFile('golden/$name.png'),
    );
  }

  group('Atom goldens', () {
    testWidgets('atom_empty', (t) async {
      await golden(t, 'atom_empty', BAAModel());
    });

    testWidgets('atom_hydrogen', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 1));
      await golden(t, 'atom_hydrogen', m);
    });

    testWidgets('atom_helium', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(2, 2, 2));
      await golden(t, 'atom_helium', m);
    });

    testWidgets('atom_isotope', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 1, 1));
      await golden(t, 'atom_isotope', m);
    });

    testWidgets('atom_positive_ion', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 0));
      await golden(t, 'atom_positive_ion', m);
    });

    testWidgets('atom_negative_ion', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 2));
      await golden(t, 'atom_negative_ion', m);
    });

    testWidgets('atom_unstable', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 2, 1));
      await golden(t, 'atom_unstable', m);
    });

    testWidgets('atom_shell', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 1));
      await golden(t, 'atom_shell', m);
    });

    testWidgets('atom_cloud', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 1));
      await pumpAtom(t, m);
      await t.tap(find.text('Cloud'));
      await t.pump();
      await expectLater(
        find.byType(BuildAnAtomAtomScreen),
        matchesGoldenFile('golden/atom_cloud.png'),
      );
    });

    testWidgets('atom_periodic_table', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(6, 6, 6));
      await golden(t, 'atom_periodic_table', m);
    });

    testWidgets('atom_net_charge', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(3, 4, 2));
      await pumpAtom(t, m);
      await t.tap(find.text('Net Charge'));
      await t.pump();
      await expectLater(
        find.byType(BuildAnAtomAtomScreen),
        matchesGoldenFile('golden/atom_net_charge.png'),
      );
    });

    testWidgets('atom_mass_number', (t) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(6, 6, 6));
      await pumpAtom(t, m);
      await t.tap(find.text('Mass Number'));
      await t.pump();
      await expectLater(
        find.byType(BuildAnAtomAtomScreen),
        matchesGoldenFile('golden/atom_mass_number.png'),
      );
    });
  });
}
