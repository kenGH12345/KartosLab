import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_screen.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_view.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 5 — Home screenshot goldens (H5-01 … H5-04).
///
/// Desktop 1280×900, DPR 1. Full Home canvas is large; goldens capture
/// navigable product states via the real Home → sim route.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openBalloons(WidgetTester tester) async {
    final card = find.text(BalloonsStaticElectricityScreen.title);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // Allow Image.asset decode.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> backToHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('H5 home screenshots', () {
    testWidgets('H5-01 home_electricity_category', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await tester.ensureVisible(find.text('电学与电路').first);
      await tester.pump();
      await tester.ensureVisible(
        find.text(BalloonsStaticElectricityScreen.title).first,
      );
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_electricity_category.png'),
      );
    });

    testWidgets('H5-02 balloons_home_card_visible', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await tester.ensureVisible(
        find.text(BalloonsStaticElectricityScreen.title).first,
      );
      await tester.pump();
      expect(find.text(BalloonsStaticElectricityScreen.title), findsOneWidget);
      expect(find.text(JohnTravoltageScreen.title), findsOneWidget);
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/balloons_home_card.png'),
      );
    });

    testWidgets('H5-03 open_balloons_from_home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openBalloons(tester);
      expect(find.byType(BalloonsStaticElectricityScreen), findsOneWidget);
      expect(find.byType(BalloonsStaticElectricityPlayArea), findsOneWidget);
      await expectLater(
        find.byType(BalloonsStaticElectricityScreen),
        matchesGoldenFile('goldens/open_balloons_from_home.png'),
      );
    });

    testWidgets('H5-04 back_to_home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openBalloons(tester);
      await backToHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(BalloonsStaticElectricityScreen), findsNothing);
      await tester.ensureVisible(
        find.text(BalloonsStaticElectricityScreen.title).first,
      );
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/back_to_home.png'),
      );
    });
  });
}
