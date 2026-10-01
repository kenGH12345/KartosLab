import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/screens/energy_forms_and_changes_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen lists Energy Forms and Changes card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text(EfacStrings.title), findsOneWidget);
  });

  testWidgets('EnergyFormsAndChangesHome opens Intro tab', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EnergyFormsAndChangesHome()),
    );
    await tester.pump(); // allow first frame
    expect(find.text(EfacStrings.title), findsWidgets);
    expect(find.text(EfacStrings.intro), findsOneWidget);
    expect(find.text(EfacStrings.systems), findsOneWidget);
    expect(find.text(EfacStrings.energySymbols), findsWidgets);
  });
}
