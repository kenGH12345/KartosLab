import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_strings.dart';
import 'package:kratos/gravity_force_lab_basics/screens/gflb_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('pump GflbHome, reset, reopen creates fresh model', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GflbHome()));
    await tester.pumpAndSettle();

    final state = tester.state<GflbHomeState>(find.byType(GflbHome));
    expect(state.generation, 1);
    state.model.setMassValue(1, 5e9);
    expect(state.model.mass1.value, 5e9);

    state.model.reset();
    expect(state.model.mass1.value, 2e9);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(const MaterialApp(home: GflbHome()));
    await tester.pumpAndSettle();

    final state2 = tester.state<GflbHomeState>(find.byType(GflbHome));
    expect(identical(state, state2), isFalse);
    expect(state2.model.mass1.value, 2e9);
    expect(state2.generation, 1);

    state2.reinitializeForTest();
    await tester.pump();
    expect(state2.generation, 2);
  });

  testWidgets('HomeScreen lists Gravity Force Lab: Basics card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text(GflbStrings.title), findsOneWidget);
  });
}
