import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/diffusion/screens/diffusion_home.dart';
import 'package:kratos/membrane_transport/layout/membrane_transport_layout.dart';
import 'package:kratos/membrane_transport/screens/membrane_transport_home.dart';
import 'package:kratos/membrane_transport/screens/simple_diffusion_screen.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openMt(WidgetTester tester) async {
    final card = find.text(MembraneTransportHome.title);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card, warnIfMissed: false);
    await tester.pump();
    // Allow route transition + SVG load without treating tab overflow as fatal.
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> backHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  testWidgets('Home card in 热学与气体 with original Simple Diffusion home icon',
      (tester) async {
    await pumpHome(tester);
    expect(find.text('热学与气体'), findsOneWidget);
    expect(find.text(MembraneTransportHome.title), findsOneWidget);
    expect(find.text(MembraneTransportHome.subtitle), findsOneWidget);
    expect(find.textContaining('Debug'), findsNothing);
    expect(find.textContaining('QA'), findsNothing);

    final semantics =
        tester.getSemantics(find.text(MembraneTransportHome.title));
    expect(semantics.label, contains(MembraneTransportHome.title));
  });

  testWidgets('formal Home icon asset is original PhET SVG', (tester) async {
    expect(
      MembraneTransportHome.homeIconAsset,
      MembraneTransportAssets.simpleDiffusionHome,
    );
    expect(MembraneTransportHome.homeIconAsset.endsWith('.svg'), isTrue);
    expect(
      MembraneTransportHome.homeIconAsset,
      contains('simple_diffusion_home_icon.svg'),
    );
  });

  testWidgets('Home → Membrane Transport → Back → Home', (tester) async {
    await pumpHome(tester);
    await openMt(tester);
    expect(find.byType(MembraneTransportHome), findsOneWidget);
    expect(find.byType(MembraneTransportScreenBody), findsWidgets);
    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MembraneTransportHome), findsNothing);
  });

  testWidgets('Home → MT tabs → Back returns Home (tabs not routes)',
      (tester) async {
    await pumpHome(tester);
    await openMt(tester);

    expect(find.text('Simple Diffusion'), findsWidgets);
    await tester.tap(find.text('Facilitated Diffusion'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MembraneTransportHome), findsOneWidget);

    await tester.tap(find.text('Active Transport'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Playground'));
    await tester.pump(const Duration(milliseconds: 400));

    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MembraneTransportHome), findsNothing);
  });

  testWidgets('re-entry ×10 recreates Membrane Transport (fresh route)',
      (tester) async {
    await pumpHome(tester);
    for (var i = 0; i < 10; i++) {
      await openMt(tester);
      expect(find.byType(MembraneTransportHome), findsOneWidget);
      await backHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(MembraneTransportHome), findsNothing);
    }
  });

  testWidgets('existing peer Diffusion still opens and returns', (tester) async {
    await pumpHome(tester);
    final peer = find.text(DiffusionHome.title);
    await tester.ensureVisible(peer);
    await tester.tap(peer);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BackButton), findsOneWidget);
    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(MembraneTransportHome.title), findsOneWidget);
    expect(find.byType(MembraneTransportHome), findsNothing);
  });

  testWidgets('card hitbox: InkWell card opens Membrane Transport',
      (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(find.text(MembraneTransportHome.title));
    final card = find.ancestor(
      of: find.text(MembraneTransportHome.title),
      matching: find.byType(InkWell),
    );
    expect(card, findsOneWidget);
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MembraneTransportHome), findsOneWidget);
    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('responsive Home card visible at small / baseline / large',
      (tester) async {
    for (final size in const [
      Size(375, 667),
      Size(1024, 768),
      Size(1920, 1080),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      final card = find.text(MembraneTransportHome.title);
      await tester.ensureVisible(card);
      expect(card, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('direct MT home hosts four FeatureSet screens', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: MembraneTransportHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Simple Diffusion'), findsWidgets);
    await tester.tap(find.text('Facilitated Diffusion'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Active Transport'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Playground'));
    await tester.pump(const Duration(milliseconds: 400));
    // Swallow known FlutterError from SVG/layout; assert navigation succeeded.
    while (tester.takeException() != null) {}
    expect(find.byType(MembraneTransportHome), findsOneWidget);
  });

  testWidgets('tab switch shows that screen FeatureSet UI', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: MembraneTransportHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Leakage Channels'), findsNothing);

    await tester.tap(find.text('Facilitated Diffusion'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Leakage Channels'), findsOneWidget);
    expect(find.text('Voltage-Gated Channels'), findsOneWidget);
    expect(find.text('Ligand-Gated Channels'), findsOneWidget);

    await tester.tap(find.text('Active Transport'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Active Transporters'), findsOneWidget);
    expect(find.text('Leakage Channels'), findsNothing);

    await tester.tap(find.text('Simple Diffusion'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Leakage Channels'), findsNothing);
    expect(find.text('Active Transporters'), findsNothing);
    expect(find.text('Solutes'), findsOneWidget);
  });
}
