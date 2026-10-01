import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/buoyancy/applications/view/buoyancy_applications_screen.dart';
import 'package:kratos/buoyancy/buoyancy_sim_host.dart';
import 'package:kratos/buoyancy/compare/view/buoyancy_compare_screen.dart';
import 'package:kratos/buoyancy/debug_buoyancy_main.dart';
import 'package:kratos/buoyancy/explore/view/buoyancy_explore_screen.dart';
import 'package:kratos/buoyancy/lab/view/buoyancy_lab_screen.dart';
import 'package:kratos/buoyancy/rendering/runtime/buoyancy_play_area.dart';
import 'package:kratos/buoyancy/shapes/view/buoyancy_shapes_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// PHASE 7 — Android device runtime gate (real emulator touch).
///
/// `flutter test integration_test/buoyancy_android_runtime_test.dart -d emulator-5554`
///
/// Live physics ticker: never `pumpAndSettle`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester, [int n = 12]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const BuoyancyAndroidRuntimeApp());
    await pumpFrames(tester, 30);
  }

  Future<void> goTab(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(Key('buoyancy_tab_$name')));
    await pumpFrames(tester, 20);
  }

  Future<void> dragOnPlayArea(WidgetTester tester) async {
    final area = find.byType(BuoyancyPlayArea);
    expect(area, findsOneWidget);
    final box = tester.getRect(area);
    final start = Offset(box.left + box.width * 0.35, box.top + box.height * 0.45);
    final end = Offset(box.left + box.width * 0.55, box.top + box.height * 0.55);
    final gesture = await tester.startGesture(start);
    await pumpFrames(tester, 4);
    await gesture.moveTo(end);
    await pumpFrames(tester, 8);
    await gesture.up();
    await pumpFrames(tester, 20);
  }

  testWidgets('A1 Launch + five screens first frame', (tester) async {
    await launch(tester);
    expect(find.byType(BuoyancySimHost), findsOneWidget);
    expect(find.byType(BuoyancyCompareScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await goTab(tester, 'explore');
    expect(find.byType(BuoyancyExploreScreen), findsOneWidget);

    await goTab(tester, 'lab');
    expect(find.byType(BuoyancyLabScreen), findsOneWidget);

    await goTab(tester, 'shapes');
    expect(find.byType(BuoyancyShapesScreen), findsOneWidget);

    await goTab(tester, 'applications');
    expect(find.byType(BuoyancyApplicationsScreen), findsOneWidget);

    await goTab(tester, 'compare');
    expect(find.byType(BuoyancyCompareScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A2 Compare drag + reset', (tester) async {
    await launch(tester);
    await goTab(tester, 'compare');
    expect(find.byType(BuoyancyPlayArea), findsOneWidget);
    await dragOnPlayArea(tester);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    await tester.tap(find.byType(KratosResetAllButton));
    await pumpFrames(tester, 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A3 Explore material + drag + reset', (tester) async {
    await launch(tester);
    await goTab(tester, 'explore');
    if (find.text('two').evaluate().isNotEmpty) {
      await tester.tap(find.text('two'));
      await pumpFrames(tester, 10);
    }
    await dragOnPlayArea(tester);
    await tester.tap(find.byType(KratosResetAllButton));
    await pumpFrames(tester, 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A4 Lab gravity + drag + reset', (tester) async {
    await launch(tester);
    await goTab(tester, 'lab');
    if (find.text('moon').evaluate().isNotEmpty) {
      await tester.tap(find.text('moon'));
      await pumpFrames(tester, 10);
    }
    await dragOnPlayArea(tester);
    await tester.tap(find.byType(KratosResetAllButton));
    await pumpFrames(tester, 20);
    expect(find.text('earth'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A5 Shapes catalog switch + drag + reset', (tester) async {
    await launch(tester);
    await goTab(tester, 'shapes');
    for (final shape in const [
      'ellipsoid',
      'verticalCylinder',
      'horizontalCylinder',
      'cone',
      'invertedCone',
      'duck',
      'block',
    ]) {
      final f = find.text(shape);
      if (f.evaluate().isEmpty) continue;
      await tester.ensureVisible(f.first);
      await tester.tap(f.first, warnIfMissed: false);
      await pumpFrames(tester, 8);
    }
    await dragOnPlayArea(tester);
    await tester.tap(find.byType(KratosResetAllButton));
    await pumpFrames(tester, 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A6 Applications bottle/boat + reset', (tester) async {
    await launch(tester);
    await goTab(tester, 'applications');
    expect(find.byType(BuoyancyApplicationsScreen), findsOneWidget);
    await dragOnPlayArea(tester);
    // Switch to boat if icon/button present
    final boatTab = find.textContaining('Cabin');
    if (boatTab.evaluate().isEmpty) {
      // Tap second mode control area — boat icon is Image.asset
      final images = find.byType(Image);
      if (images.evaluate().length >= 2) {
        await tester.tap(images.at(1), warnIfMissed: false);
        await pumpFrames(tester, 15);
      }
    }
    await dragOnPlayArea(tester);
    await tester.tap(find.byType(KratosResetAllButton));
    await pumpFrames(tester, 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A7 Full screen cycle no leakage / no exception', (tester) async {
    await launch(tester);
    for (final name in const [
      'compare',
      'explore',
      'lab',
      'shapes',
      'applications',
      'compare',
      'shapes',
      'lab',
      'explore',
      'compare',
    ]) {
      await goTab(tester, name);
      expect(find.byType(BuoyancyPlayArea), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('A8 Continuous physics frames after drag', (tester) async {
    await launch(tester);
    await goTab(tester, 'explore');
    await dragOnPlayArea(tester);
    // Physics continues — pump many frames without settle.
    await pumpFrames(tester, 60);
    expect(find.byType(BuoyancyPlayArea), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
