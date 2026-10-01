import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/resistance_in_a_wire/model/resistance_in_a_wire_model.dart';
import 'package:kratos/resistance_in_a_wire/resistance_in_a_wire_view_constants.dart';
import 'package:kratos/resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';
import 'package:kratos/resistance_in_a_wire/view/riaw_play_area.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 5 — Home screenshot goldens (H01 … H05).
///
/// Peer: `test/ohms_law/home/ohms_law_home_screenshot_test.dart`
///
/// H01/H02/H04: Home chrome at 1280×900.
/// H03/H05: Home open/reopen asserted in-file; pixel golden reuses Phase 4
/// G01 pump (1024×618 + seed `0x52494157`) so production `dotRandom` stays
/// unseeded while Home cold-start visuals stay regression-locked.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const goldenDotSeed = 0x52494157;

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

  Future<void> openRiaw(WidgetTester tester) async {
    final card = find.text(ResistanceInAWireScreen.title);
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

  Future<void> pumpPhase4ColdStart(WidgetTester tester) async {
    final model = ResistanceInAWireModel();
    addTearDown(model.dispose);
    await tester.binding.setSurfaceSize(
      ResistanceInAWireViewConstants.layoutSize,
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ResistanceInAWireScreen(
          model: model,
          showAppBar: false,
          dotRandom: math.Random(goldenDotSeed),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('H5 home screenshots', () {
    testWidgets('H01 home_electricity_category', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await tester.ensureVisible(find.text('电学与电路').first);
      await tester.pump();
      await tester.ensureVisible(
        find.text(ResistanceInAWireScreen.title).first,
      );
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/h01_home_electricity_category.png'),
      );
    });

    testWidgets('H02 riaw_home_card_visible', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await tester.ensureVisible(
        find.text(ResistanceInAWireScreen.title).first,
      );
      await tester.pump();
      expect(find.text(ResistanceInAWireScreen.title), findsOneWidget);
      expect(find.text(ResistanceInAWireScreen.subtitle), findsOneWidget);
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/h02_riaw_home_card.png'),
      );
    });

    testWidgets('H03 open_riaw_from_home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);
      expect(find.byType(ResistanceInAWireScreen), findsOneWidget);
      expect(find.byType(ResistanceInAWirePlayArea), findsOneWidget);
    });

    testWidgets('H03b cold-start play area golden (Phase 4 seed)',
        (tester) async {
      // Isolated from Home chrome so physicalSize/surface match Phase 4 G01.
      tester.view.physicalSize = ResistanceInAWireViewConstants.layoutSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpPhase4ColdStart(tester);
      await expectLater(
        find.byType(ResistanceInAWirePlayArea),
        matchesGoldenFile('../visual/goldens/g01_initial.png'),
      );
    });

    testWidgets('H04 back_to_home', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);
      await backToHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(ResistanceInAWireScreen), findsNothing);
      await tester.ensureVisible(
        find.text(ResistanceInAWireScreen.title).first,
      );
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/h04_back_to_home.png'),
      );
    });

    testWidgets('H05 reopen_riaw', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openRiaw(tester);
      await backToHome(tester);
      await openRiaw(tester);
      expect(find.byType(ResistanceInAWireScreen), findsOneWidget);
      expect(find.byType(ResistanceInAWirePlayArea), findsOneWidget);
    });

    testWidgets('H05b reopen cold-start golden (Phase 4 seed)', (tester) async {
      tester.view.physicalSize = ResistanceInAWireViewConstants.layoutSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpPhase4ColdStart(tester);
      await expectLater(
        find.byType(ResistanceInAWirePlayArea),
        matchesGoldenFile('../visual/goldens/g01_initial.png'),
      );
    });
  });
}
