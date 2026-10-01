import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/screens/bounce_screen.dart';

void main() {
  testWidgets('Bounce controls: gravity slider + line checkboxes present',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BounceScreen()));
    await tester.pump();
    expect(find.text('Gravity'), findsOneWidget);
    expect(find.text('Spring Strength 1'), findsOneWidget);
    expect(find.text('Spring Strength 2'), findsOneWidget);
    expect(find.byTooltip('Stop oscillation'), findsNWidgets(2));
    expect(find.text('Unstretched Length'), findsOneWidget);
    expect(find.text('Resting Position'), findsOneWidget);
    expect(find.text('Movable Line'), findsOneWidget);
    // Pause / Reset already in HUD
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byTooltip('Reset'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
