import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/projectile_motion/pm_strings.dart';
import 'package:kratos/projectile_motion/screens/projectile_motion_home.dart';

void main() {
  testWidgets('Projectile Motion home 打开四个 Tab', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectileMotionHome()));
    expect(find.text(PmStrings.title), findsOneWidget);
    expect(find.text(PmStrings.screenIntro), findsOneWidget);
    expect(find.text(PmStrings.screenVectors), findsOneWidget);
    expect(find.text(PmStrings.screenDrag), findsOneWidget);
    expect(find.text(PmStrings.screenLab), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('生命周期：打开 → dispose → 再打开不泄漏', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectileMotionHome()));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: ProjectileMotionHome()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(PmStrings.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tab 切换保留各屏独立入口', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectileMotionHome()));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text(PmStrings.screenLab));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(PmStrings.initialValues), findsWidgets);
    await tester.tap(find.text(PmStrings.screenIntro));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(PmStrings.title), findsOneWidget);
  });
}
