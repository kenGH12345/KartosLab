import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/applications/view/buoyancy_applications_screen.dart';
import 'package:kratos/buoyancy/compare/view/buoyancy_compare_screen.dart';
import 'package:kratos/buoyancy/explore/view/buoyancy_explore_screen.dart';
import 'package:kratos/buoyancy/lab/view/buoyancy_lab_screen.dart';
import 'package:kratos/buoyancy/shapes/view/buoyancy_shapes_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1024, 768)),
        child: SizedBox(width: 1024, height: 768, child: child),
      ),
    );
  }

  testWidgets('Compare screen pumps and has Reset All', (tester) async {
    await tester.pumpWidget(wrap(const BuoyancyCompareScreen()));
    await tester.pump();
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.text('Forces'), findsOneWidget);
    expect(find.textContaining('Mass'), findsWidgets);
  });

  testWidgets('Explore screen pumps', (tester) async {
    await tester.pumpWidget(wrap(const BuoyancyExploreScreen()));
    await tester.pump();
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.text('Forces'), findsOneWidget);
    expect(find.text('Object Density'), findsOneWidget);
    expect(find.text('Fluid Density'), findsOneWidget);
  });

  testWidgets('Lab screen pumps gravity presets', (tester) async {
    await tester.pumpWidget(wrap(const BuoyancyLabScreen()));
    await tester.pump();
    expect(find.text('Gravity'), findsWidgets);
    expect(find.text('Earth'), findsOneWidget);
    expect(find.text('Fluid Displaced'), findsOneWidget);
    expect(find.text('Forces'), findsOneWidget);
  });

  testWidgets('Shapes screen lists seven shapes', (tester) async {
    await tester.pumpWidget(wrap(const BuoyancyShapesScreen()));
    await tester.pump();
    expect(find.text('block'), findsWidgets);
    expect(find.text('duck'), findsOneWidget);
    expect(find.text('Forces'), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
  });

  testWidgets('Applications screen pumps boat/bottle icons', (tester) async {
    await tester.pumpWidget(wrap(const BuoyancyApplicationsScreen()));
    await tester.pump();
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.text('Forces'), findsOneWidget);
    expect(find.text('Bottle'), findsOneWidget);
  });
}
