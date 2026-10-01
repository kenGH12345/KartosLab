import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/cck_ac_virtual_lab/cck_strings.dart';
import 'package:kratos/cck_ac_virtual_lab/screens/cck_ac_virtual_lab_screen.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Home 出现 AC 虚拟实验室卡片', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('AC 虚拟实验室'), findsOneWidget);
    expect(find.text('交流 · 电容 · 电感'), findsOneWidget);
  });

  testWidgets('Home → CCK AC Lab → Back 可重复进入', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    Future<void> open() async {
      final card = find.text('AC 虚拟实验室');
      await tester.ensureVisible(card.first);
      await tester.pump();
      await tester.tap(card.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CckAcVirtualLabScreen), findsOneWidget);
      expect(find.text(CckStrings.title), findsOneWidget);
    }

    await open();
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(CckAcVirtualLabScreen), findsNothing);

    await open();
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
