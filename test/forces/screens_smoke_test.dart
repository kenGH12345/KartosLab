import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/config/forces_strings.dart';
import 'package:kratos/forces/screens/forces_home.dart';
import 'package:kratos/forces/screens/net_force_screen.dart';
import 'package:kratos/forces/screens/motion_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ForcesHome shows four tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(const MaterialApp(home: ForcesHome()));
    await tester.pump();
    expect(find.text(ForcesStrings.screenNetForce), findsWidgets);
    expect(find.text(ForcesStrings.screenMotion), findsWidgets);
    expect(find.text(ForcesStrings.screenFriction), findsWidgets);
    expect(find.text(ForcesStrings.screenAcceleration), findsWidgets);
  });

  testWidgets('NetForceScreen builds without crash', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(const MaterialApp(home: NetForceScreen()));
    await tester.pump();
    expect(find.text(ForcesStrings.netForceGo), findsOneWidget);
    expect(find.text(ForcesStrings.netForceReturn), findsOneWidget);
    expect(find.text('合力'), findsOneWidget);
  });

  testWidgets('MotionScreenV2 motion builds', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: MotionScreenV2(style: MotionScreenStyleTab.motion),
      ),
    );
    await tester.pump();
    expect(find.text('外力'), findsOneWidget);
    expect(find.text(ForcesStrings.motionForce), findsOneWidget);
  });

  testWidgets('Friction screen shows friction slider label', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: MotionScreenV2(style: MotionScreenStyleTab.friction),
      ),
    );
    await tester.pump();
    expect(find.textContaining('摩擦'), findsWidgets);
    expect(find.textContaining('力'), findsWidgets);
  });

  testWidgets('Acceleration screen shows Acceleration checkbox', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: MotionScreenV2(style: MotionScreenStyleTab.acceleration),
      ),
    );
    await tester.pump();
    expect(find.text(ForcesStrings.screenAcceleration), findsOneWidget);
  });
}
