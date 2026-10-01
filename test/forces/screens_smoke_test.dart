import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/screens/forces_home.dart';
import 'package:kratos/forces/screens/net_force_screen.dart';
import 'package:kratos/forces/screens/motion_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ForcesHome shows four tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    expect(find.text('Net Force'), findsWidgets);
    expect(find.text('Motion'), findsWidgets);
    expect(find.text('Friction'), findsWidgets);
    expect(find.text('Acceleration'), findsWidgets);
  });

  testWidgets('NetForceScreen builds without crash', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(const MaterialApp(home: NetForceScreen()));
    await tester.pump();
    expect(find.text('Go!'), findsOneWidget);
    expect(find.text('Return'), findsOneWidget);
    expect(find.text('Sum of Forces'), findsOneWidget);
  });

  testWidgets('MotionScreenV2 motion builds', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: MotionScreenV2(style: MotionScreenStyleTab.motion),
      ),
    );
    await tester.pump();
    expect(find.text('Applied Force'), findsOneWidget);
    expect(find.text('Force'), findsOneWidget);
  });

  testWidgets('Friction screen shows friction slider label', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: MotionScreenV2(style: MotionScreenStyleTab.friction),
      ),
    );
    await tester.pump();
    expect(find.text('Friction'), findsWidgets);
    expect(find.text('Forces'), findsOneWidget);
  });

  testWidgets('Acceleration screen shows Acceleration checkbox', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: MotionScreenV2(style: MotionScreenStyleTab.acceleration),
      ),
    );
    await tester.pump();
    expect(find.text('Acceleration'), findsOneWidget);
  });
}
