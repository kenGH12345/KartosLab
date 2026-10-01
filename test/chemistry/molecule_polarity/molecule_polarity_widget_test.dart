import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molecule_polarity/controller/molecule_polarity_controller.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/molecule_polarity_home.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/two_atoms_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Two Atoms EN updates via controller', () {
    final controller = MoleculePolarityController.shared();
    expect(controller.twoAtoms.diatomic.atomA.electronegativity, 2);
    expect(controller.twoAtoms.diatomic.atomB.electronegativity, 3);

    controller.setAtomEN(controller.twoAtoms.diatomic.atomA, 3.4);
    expect(controller.twoAtoms.diatomic.atomA.electronegativity, 3.4);
    expect(controller.twoAtoms.diatomic.deltaEN, closeTo(-0.4, 1e-9));

    controller.resetTwoAtoms();
    expect(controller.twoAtoms.diatomic.atomA.electronegativity, 2);

    controller.dispose();
  });

  testWidgets('MoleculePolarityHome shows Three tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = MoleculePolarityController.shared();
    await tester.pumpWidget(
      MaterialApp(
        home: MoleculePolarityHome(controller: controller),
      ),
    );
    await tester.pump();
    // Allow FittedBox / tab layout
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Two Atoms'), findsWidgets);
    expect(find.textContaining('Three Atoms'), findsWidgets);
    expect(find.textContaining('Real Molecules'), findsWidgets);
    expect(find.byType(TwoAtomsScreenBody), findsOneWidget);

    controller.dispose();
  });
}
