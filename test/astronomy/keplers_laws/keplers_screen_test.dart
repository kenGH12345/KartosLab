import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/keplers_laws/keplers_laws_strings.dart';
import 'package:kratos/astronomy/keplers_laws/screens/keplers_laws_home.dart';
import 'package:kratos/astronomy/keplers_laws/screens/keplers_laws_screen.dart';
import 'package:kratos/astronomy/keplers_laws/model/law_mode.dart';
import 'package:kratos/astronomy/keplers_laws/widgets/keplers_law_thumbs.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  testWidgets('First Law screen pumps without overflow', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: KeplersLawsScreen(initialLaw: LawMode.first),
      ),
    );
    await tester.pump();
    expect(find.textContaining("Kepler's Laws"), findsWidgets);
    expect(find.textContaining('Eccentricity'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home has four law tabs', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: KeplersLawsHome()));
    await tester.pump();
    expect(find.text(KeplersLawsStrings.firstLaw), findsWidgets);
    expect(find.text(KeplersLawsStrings.secondLaw), findsWidgets);
    expect(find.text(KeplersLawsStrings.thirdLaw), findsWidgets);
    expect(find.text(KeplersLawsStrings.allLaws), findsWidgets);
  });

  testWidgets('Reset button is present', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: KeplersLawsScreen(initialLaw: LawMode.first),
      ),
    );
    await tester.pump();
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsWidgets);
  });

  testWidgets('Play is enabled on default stable orbit', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: KeplersLawsScreen(initialLaw: LawMode.first),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow).first);
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  testWidgets('All Laws shows law thumbnail radio', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: KeplersLawsScreen(
          initialLaw: LawMode.first,
          isAllLaws: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(KeplersLawsRadioRow), findsOneWidget);
    expect(find.text('I'), findsNothing);
    expect(find.text('II'), findsNothing);
    expect(find.text('III'), findsNothing);
  });

  testWidgets('play area fills NineGrid center (MVT canvas has height)',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: KeplersLawsScreen(initialLaw: LawMode.first),
      ),
    );
    await tester.pump();

    final box = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('keplers-play-area')),
    );
    // Must not collapse to 0 — that shifted the sun to the cell's lower half.
    expect(box.size.width, greaterThan(600));
    expect(box.size.height, greaterThan(400));
  });

  testWidgets('no overflow at required viewports', (tester) async {
    const sizes = <Size>[
      Size(1024, 768),
      Size(1280, 800),
      Size(1366, 1024),
      Size(840, 520),
    ];
    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: KeplersLawsScreen(initialLaw: LawMode.first),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$size');
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Reset restores default after play', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: KeplersLawsScreen(initialLaw: LawMode.first),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow).first);
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsOneWidget);
    await tester.tap(find.byType(KratosResetAllButton));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
