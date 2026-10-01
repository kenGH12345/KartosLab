import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/curve_fitting_strings.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/screens/curve_fitting_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('pump CurveFittingHome, reset, reopen creates fresh model',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CurveFittingHome()));
    await tester.pumpAndSettle();

    final state = tester.state<CurveFittingHomeState>(
      find.byType(CurveFittingHome),
    );
    expect(state.generation, 1);
    state.model.addPoint(DataPoint(x: 1, y: 2));
    expect(state.model.points.length, 1);

    state.model.reset();
    expect(state.model.points.length, 0);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(const MaterialApp(home: CurveFittingHome()));
    await tester.pumpAndSettle();

    final state2 = tester.state<CurveFittingHomeState>(
      find.byType(CurveFittingHome),
    );
    expect(identical(state, state2), isFalse);
    expect(state2.model.points.length, 0);
    expect(state2.generation, 1);

    state2.reinitializeForTest();
    await tester.pump();
    expect(state2.generation, 2);
    expect(state2.model.points.length, 0);
  });

  testWidgets('HomeScreen lists Curve Fitting card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text(CurveFittingStrings.title), findsOneWidget);
  });
}
