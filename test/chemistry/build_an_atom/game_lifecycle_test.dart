import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Game → Atom → Symbol → Game lifecycle', (tester) async {
    final g = GameModel(randomSeed: 90);
    g.startLevel(1);
    final c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));

    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
    expect(g.score, 2);

    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomAtomScreen()));
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomSymbolScreen()));
    await tester.pump();

    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
    expect(g.score, 2); // preserved injected model
    expect(tester.takeException(), isNull);
  });

  testWidgets('leave/return preserves game model', (tester) async {
    final g = GameModel(randomSeed: 91);
    g.startLevel(2);
    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
    expect(g.levelNumber, 2);
    expect(tester.takeException(), isNull);
  });
}
