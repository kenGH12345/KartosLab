import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/ohms_law/view/ohms_law_play_area.dart';
import 'package:kratos/ohms_law/view/ohms_law_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 5 — Home screenshot goldens (H01 … H05).
///
/// Peer: `test/balloons_and_static_electricity/home/base_home_screenshot_test.dart`
/// Desktop 1280×900, DPR 1. Implementation-regression goldens (Home chrome).
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

  Future<void> openOhmsLaw(WidgetTester tester) async {
    final card = find.text(OhmsLawScreen.title);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
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
    testWidgets('H01 home_electricity_category', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await tester.ensureVisible(find.text('电学与电路').first);
      await tester.pump();
      await tester.ensureVisible(find.text(OhmsLawScreen.title).first);
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/h01_home_electricity_category.png'),
      );
    });

    testWidgets('H02 ohms_law_home_card_visible', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await tester.ensureVisible(find.text(OhmsLawScreen.title).first);
      await tester.pump();
      expect(find.text(OhmsLawScreen.title), findsOneWidget);
      expect(find.text(OhmsLawScreen.subtitle), findsOneWidget);
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/h02_ohms_law_home_card.png'),
      );
    });

    testWidgets('H03 open_ohms_law_from_home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);
      expect(find.byType(OhmsLawScreen), findsOneWidget);
      expect(find.byType(OhmsLawPlayArea), findsOneWidget);
      await expectLater(
        find.byType(OhmsLawScreen),
        matchesGoldenFile('goldens/h03_open_ohms_law_from_home.png'),
      );
    });

    testWidgets('H04 back_to_home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);
      await backToHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OhmsLawScreen), findsNothing);
      await tester.ensureVisible(find.text(OhmsLawScreen.title).first);
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/h04_back_to_home.png'),
      );
    });

    testWidgets('H05 reopen_ohms_law', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openOhmsLaw(tester);
      await backToHome(tester);
      await openOhmsLaw(tester);
      expect(find.byType(OhmsLawScreen), findsOneWidget);
      expect(find.byType(OhmsLawPlayArea), findsOneWidget);
      await expectLater(
        find.byType(OhmsLawScreen),
        matchesGoldenFile('goldens/h05_reopen_ohms_law.png'),
      );
    });
  });
}
