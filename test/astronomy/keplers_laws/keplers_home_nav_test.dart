import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/keplers_laws/screens/keplers_laws_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('Home lists Kepler\'s Laws card', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    expect(find.text("Kepler's Laws"), findsOneWidget);
    // Home list grows as sims are added; scroll into view before tap.
    await tester.ensureVisible(find.text("Kepler's Laws"));
    await tester.pump();
    await tester.tap(find.text("Kepler's Laws"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('First Law'), findsWidgets);
  });

  testWidgets('Home → Kepler → back, five times (dispose clock)', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();

    for (var i = 0; i < 5; i++) {
      await tester.ensureVisible(find.text("Kepler's Laws"));
      await tester.tap(find.text("Kepler's Laws"));
      // SimulationClock keeps a Ticker running; do not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('keplers-play-area')), findsWidgets);
      expect(tester.takeException(), isNull);

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(
        find.byKey(const ValueKey('keplers-play-area')),
        findsNothing,
        reason: 'iteration $i',
      );
      expect(find.text("Kepler's Laws"), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('KeplersLawsHome create/dispose five times', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(const MaterialApp(home: KeplersLawsHome()));
      await tester.pump();
      expect(find.byKey(const ValueKey('keplers-play-area')), findsWidgets);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
