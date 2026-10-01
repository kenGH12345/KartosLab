import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molecule_polarity/screens/molecule_polarity_home.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/two_atoms_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → 化学 → Molecule Polarity → interact → back → reopen.
void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openMp(WidgetTester tester) async {
    final card = find.text(MoleculePolarityHome.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MoleculePolarityHome), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MoleculePolarityHome), findsNothing);
  }

  testWidgets('Home 出现分子极性入口', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);

    expect(find.text('分子极性'), findsOneWidget);
    expect(find.text(MoleculePolarityHome.title), findsOneWidget);
    expect(find.text('Two · Three · Real Molecules'), findsOneWidget);
  });

  testWidgets('open → interact → back → reopen', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await openMp(tester);

    expect(find.byType(TwoAtomsScreenBody), findsOneWidget);
    expect(find.textContaining('Two Atoms'), findsWidgets);

    await tester.tap(find.textContaining('Three Atoms').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await backToHome(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);

    await openMp(tester);
    expect(find.byType(TwoAtomsScreenBody), findsOneWidget);
    expect(find.byType(MoleculePolarityHome), findsOneWidget);

    await backToHome(tester);
  });
}
