import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';

/// Phase 7 — same state → identical golden match (run ×2).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpDesign(
    WidgetTester tester,
    Widget home,
  ) async {
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
          child: home,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
  }

  testWidgets('Atom hydrogen golden match ×2', (tester) async {
    final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 1));
    await pumpDesign(tester, BuildAnAtomAtomScreen(model: m));
    await expectLater(
      find.byType(BuildAnAtomAtomScreen),
      matchesGoldenFile('golden/atom_hydrogen.png'),
    );
    await expectLater(
      find.byType(BuildAnAtomAtomScreen),
      matchesGoldenFile('golden/atom_hydrogen.png'),
    );
  });

  testWidgets('Symbol empty golden match ×2', (tester) async {
    await pumpDesign(tester, BuildAnAtomSymbolScreen(model: BAAModel()));
    await expectLater(
      find.byType(BuildAnAtomSymbolScreen),
      matchesGoldenFile('golden/symbol_empty.png'),
    );
    await expectLater(
      find.byType(BuildAnAtomSymbolScreen),
      matchesGoldenFile('golden/symbol_empty.png'),
    );
  });

  testWidgets('Game timer-off golden match ×2 (fixed seed, no live clock)',
      (tester) async {
    final g = GameModel(randomSeed: 1);
    expect(g.timerEnabled, isFalse);
    await pumpDesign(tester, BuildAnAtomGameScreen(model: g));
    await expectLater(
      find.byType(BuildAnAtomGameScreen),
      matchesGoldenFile('golden/game/game_timer_off.png'),
    );
    await expectLater(
      find.byType(BuildAnAtomGameScreen),
      matchesGoldenFile('golden/game/game_timer_off.png'),
    );
  });

  test('checked-in sim golden PNGs exist (34)', () {
    final dir = Directory('test/chemistry/build_an_atom/golden');
    final pngs = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        // Phase 8 Home goldens live under golden/home/ — not part of the 34 sim set.
        .where((f) => !f.uri.pathSegments.contains('home'))
        .toList();
    expect(pngs.length, 34);
  });
}
