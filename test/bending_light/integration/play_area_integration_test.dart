import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/screens/intro_screen.dart';
import 'package:kratos/bending_light/screens/more_tools_screen.dart';
import 'package:kratos/bending_light/screens/prisms_screen.dart';
import 'package:kratos/bending_light/bl_strings.dart';

void main() {
  testWidgets('IntroScreen pumps with laser toggle and reset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: IntroScreen()));
    await tester.pump();

    expect(find.text(BlStrings.titleIntro), findsOneWidget);
    expect(find.byTooltip(BlStrings.resetAll), findsOneWidget);

    await tester.tap(find.text(BlStrings.wave));
    await tester.pump();
    await tester.tap(find.byTooltip(BlStrings.resetAll));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('PrismsScreen pumps without exceptions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrismsScreen()));
    await tester.pump();

    expect(find.text(BlStrings.titlePrisms), findsOneWidget);
    expect(find.bySemanticsLabel('square'), findsOneWidget);
    expect(find.byTooltip(BlStrings.resetAll), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('square'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('MoreToolsScreen pumps without exceptions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreToolsScreen()));
    await tester.pump();
    expect(find.textContaining(BlStrings.moreTools), findsOneWidget);
    expect(find.bySemanticsLabel(BlStrings.velocity), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(BlStrings.velocity));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
