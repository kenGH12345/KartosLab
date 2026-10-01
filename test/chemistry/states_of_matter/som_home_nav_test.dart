import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/states_of_matter/screens/atomic_interactions_screen.dart';
import 'package:kratos/chemistry/states_of_matter/screens/phase_changes_screen.dart';
import 'package:kratos/chemistry/states_of_matter/screens/states_of_matter_home.dart';
import 'package:kratos/chemistry/states_of_matter/screens/states_screen.dart';
import 'package:kratos/chemistry/states_of_matter/som_strings.dart';
import 'package:kratos/chemistry/states_of_matter/widgets/som_reset_button.dart';
import 'package:kratos/chemistry/states_of_matter/widgets/som_time_control.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → 化学 → 物态 → States of Matter → tabs / pause / reset → back → reopen.
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

  Future<void> openSom(WidgetTester tester) async {
    final card = find.text('States of Matter');
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(StatesOfMatterHome), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(StatesOfMatterHome), findsNothing);
  }

  testWidgets('Home shows 物态 / States of Matter entry', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);

    expect(find.text('物态'), findsOneWidget);
    expect(find.text('States of Matter'), findsOneWidget);
    expect(
      find.text('States · Phase Changes · Interaction'),
      findsOneWidget,
    );
  });

  testWidgets('open → switch screens → pause/reset → back → reopen',
      (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await openSom(tester);

    expect(find.byType(StatesScreen), findsOneWidget);
    expect(find.text(SomStrings.neon), findsWidgets);

    // Tabbed home keeps all screens mounted — use visible States controls.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SomTimeControl), findsWidgets);
    await tester.tap(find.byType(SomTimeControl).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(SomTimeControl).first);
    await tester.pump();
    await tester.tap(find.byType(SomResetButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text(SomStrings.phaseChanges).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(PhaseChangesScreen), findsOneWidget);

    await tester.tap(find.text(SomStrings.interaction).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(AtomicInteractionsScreen), findsOneWidget);

    await tester.tap(find.text(SomStrings.states).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(StatesScreen), findsOneWidget);

    await backToHome(tester);
    // After dispose: no leaked exceptions while home idles.
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(SomTimeControl), findsNothing);

    await openSom(tester);
    expect(find.byType(StatesScreen), findsOneWidget);
    expect(find.byType(StatesOfMatterHome), findsOneWidget);
    expect(find.byType(SomTimeControl), findsWidgets);

    await backToHome(tester);
  });
}
