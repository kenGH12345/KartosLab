import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/screens/bending_light_home.dart';
import 'package:kratos/bending_light/screens/bending_light_hub.dart';
import 'package:kratos/bending_light/view/intro_play_area.dart';
import 'package:kratos/bending_light/view/more_tools_play_area.dart';
import 'package:kratos/bending_light/view/prisms_play_area.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  Future<void> desktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> open(WidgetTester tester) async {
    final card = find.text(BendingLightHome.title);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Bending Light is listed under 物理 / 光学与波动', (tester) async {
    await desktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('物理'), findsOneWidget);
    expect(find.text('光学与波动'), findsOneWidget);
    final card = find.text(BendingLightHome.title);
    await tester.ensureVisible(card);
    expect(card, findsOneWidget);
    expect(find.text(BendingLightHome.subtitle), findsOneWidget);
    expect(find.byIcon(Icons.lens_outlined), findsWidgets);
  });

  testWidgets('Home opens the production screen, not the QA hub', (tester) async {
    await desktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await open(tester);

    expect(find.byType(BendingLightHome), findsOneWidget);
    expect(find.byType(BendingLightHub), findsNothing);
    expect(find.text('Bending Light — Intro'), findsNothing);
    expect(find.text('Intro'), findsWidgets);
    expect(find.byType(IntroPlayArea), findsOneWidget);
  });

  testWidgets('enter, back, and re-enter use a fresh default model', (tester) async {
    await desktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await open(tester);

    final first = tester.widget<IntroPlayArea>(find.byType(IntroPlayArea)).model;
    expect(first.laser.on, isFalse);
    expect(first.wavelength, BendingLightConstants.wavelengthRed);
    expect(identical(first.bottomMedium.substance, Substance.water), isTrue);
    first.setLaserOn(true);
    first.setWavelength(500e-9);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BendingLightHome), findsNothing);
    expect(find.byType(IntroPlayArea), findsNothing);
    expect(find.byType(PrismsPlayArea), findsNothing);
    expect(find.byType(MoreToolsPlayArea), findsNothing);

    await open(tester);
    final second = tester.widget<IntroPlayArea>(find.byType(IntroPlayArea)).model;
    expect(identical(first, second), isFalse);
    expect(second.laser.on, isFalse);
    expect(second.wavelength, BendingLightConstants.wavelengthRed);
    expect(find.byType(IntroPlayArea), findsOneWidget);
    expect(find.byType(PrismsPlayArea), findsOneWidget);
    expect(find.byType(MoreToolsPlayArea), findsOneWidget);
  });
}
