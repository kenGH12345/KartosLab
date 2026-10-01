import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/screens/intro_screen.dart';
import 'package:kratos/bending_light/screens/more_tools_screen.dart';
import 'package:kratos/bending_light/screens/prisms_screen.dart';

void main() {
  testWidgets('IntroScreen pumps with laser toggle and reset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: IntroScreen()));
    await tester.pump();

    expect(find.text('Bending Light — Intro'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.bySemanticsLabel('Protractor'), findsOneWidget);
    expect(find.byTooltip('Reset All'), findsOneWidget);

    await tester.tap(find.text('Wave'));
    await tester.pump();
    await tester.tap(find.byTooltip('Reset All'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('PrismsScreen pumps without exceptions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrismsScreen()));
    await tester.pump();

    expect(find.text('Bending Light — Prisms'), findsOneWidget);
    expect(find.bySemanticsLabel('square'), findsOneWidget);
    expect(find.byTooltip('Reset All'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('square'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('MoreToolsScreen pumps without exceptions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreToolsScreen()));
    await tester.pump();
    expect(find.textContaining('More Tools'), findsOneWidget);
    expect(find.bySemanticsLabel('Velocity'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Velocity'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
