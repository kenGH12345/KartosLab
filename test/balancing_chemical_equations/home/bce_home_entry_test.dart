import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_screen.dart';
import 'package:kratos/balancing_chemical_equations/screens/balancing_chemical_equations_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('Home lists BCE under 化学 / 配平化学方程式', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('化学').first);
    expect(find.text('化学'), findsWidgets);
    await tester.ensureVisible(find.text(BceStrings.homeSubjectGroup).first);
    expect(find.text(BceStrings.homeSubjectGroup), findsOneWidget);
    await tester.ensureVisible(
      find.text(BalancingChemicalEquationsHome.title).first,
    );
    expect(find.text(BalancingChemicalEquationsHome.title), findsOneWidget);
    expect(find.text(BalancingChemicalEquationsHome.subtitle), findsOneWidget);
    expect(find.byIcon(Icons.balance_outlined), findsOneWidget);
  });

  testWidgets('tap BCE card opens production BalancingChemicalEquationsHome',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.ensureVisible(
      find.text(BalancingChemicalEquationsHome.title).first,
    );
    await tester.tap(find.text(BalancingChemicalEquationsHome.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BalancingChemicalEquationsHome), findsOneWidget);
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.text(BceStrings.screenIntro), findsWidgets);
    // Not a QA / demo harness
    expect(find.textContaining('QA'), findsNothing);
    expect(find.textContaining('Demo'), findsNothing);
  });
}
