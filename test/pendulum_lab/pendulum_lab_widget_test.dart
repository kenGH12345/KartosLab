import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/pendulum_lab/screens/pendulum_lab_home.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';

void main() {
  testWidgets('Pendulum Lab home opens three tabs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PendulumLabHome()));
    expect(find.text(PlStrings.title), findsOneWidget);
    expect(find.text(PlStrings.screenIntro), findsOneWidget);
    expect(find.text(PlStrings.screenEnergy), findsOneWidget);
    expect(find.text(PlStrings.screenLab), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
