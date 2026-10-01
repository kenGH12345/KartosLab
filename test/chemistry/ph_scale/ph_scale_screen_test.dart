import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/ph_scale_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhScaleScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('PhScaleScreen launches with 3 tabs + graph chrome', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Macro'), findsWidgets);
    expect(find.text('Micro'), findsWidgets);
    expect(find.text('My Solution'), findsWidgets);

    await tester.tap(find.text('My Solution'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('7.00'), findsOneWidget);
    expect(find.textContaining('Concentration'), findsWidgets);
    expect(find.text('Particle Counts'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Macro has no Graph chrome', (tester) async {
    await pumpScreen(tester);
    // Default tab is Macro — Graph control labels absent
    expect(find.textContaining('Concentration'), findsNothing);
    expect(find.textContaining('Quantity'), findsNothing);
  });

  testWidgets('Micro Graph: Concentration + Logarithmic/Linear present', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Micro'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Concentration'), findsWidgets);
    expect(find.text('Logarithmic'), findsOneWidget);
    expect(find.text('Linear'), findsOneWidget);
    expect(find.text('Particle Counts'), findsOneWidget);
  });

  testWidgets('My Solution Graph: no Linear switch (log-only)', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('My Solution'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Concentration'), findsWidgets);
    expect(find.text('Logarithmic'), findsNothing);
    expect(find.text('Linear'), findsNothing);
  });
}
