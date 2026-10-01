import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/charge_meter.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/phet_face_node.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ChargeMeter paints Plus/Minus symbols', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: ChargeMeter(charge: 2, showNumericalReadout: false)),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ChargeMeter), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PhetFaceNode smile and frown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              PhetFaceNode(headDiameter: 80, smiling: true),
              PhetFaceNode(headDiameter: 80, smiling: false),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(PhetFaceNode), findsNWidgets(2));
  });

  testWidgets('WASD shortcuts registered on Atom particles', (tester) async {
    final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 1));
    await tester.pumpWidget(MaterialApp(home: BuildAnAtomAtomScreen(model: m)));
    await tester.pump();
    // Send WASD — must not crash; focus navigation only.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    expect(m.protonCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cross-screen Atom→Symbol→Game→Atom', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomAtomScreen()));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomSymbolScreen()));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomGameScreen()));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomAtomScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
