import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/assets/qwi_assets.dart';
import 'package:kratos/physics/quantum_wave_interference/screens/quantum_wave_interference_home.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';
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

  Future<void> openQwi(WidgetTester tester) async {
    final card = find.text(QuantumWaveInterferenceHome.title);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
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

  testWidgets('Home card in 光学与波动 with original Experiment screen icon', (tester) async {
    await pumpHome(tester);
    expect(find.text('光学与波动'), findsOneWidget);
    expect(find.text(QuantumWaveInterferenceHome.title), findsOneWidget);
    expect(find.text(QuantumWaveInterferenceHome.subtitle), findsOneWidget);
    // Formal entry only — no debug/QA labels.
    expect(find.textContaining('Android Gate'), findsNothing);
    expect(find.textContaining('QA'), findsNothing);

    final semantics = tester.getSemantics(find.text(QuantumWaveInterferenceHome.title));
    expect(semantics.label, contains(QuantumWaveInterferenceHome.title));
  });

  testWidgets('Home → QWI → Back → Home', (tester) async {
    await pumpHome(tester);
    await openQwi(tester);
    expect(find.byType(QuantumWaveInterferenceHome), findsOneWidget);
    expect(find.byType(ExperimentScreen), findsOneWidget);
    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(QuantumWaveInterferenceHome), findsNothing);
  });

  testWidgets('Home → QWI tabs Experiment / HI / SP → Back', (tester) async {
    await pumpHome(tester);
    await openQwi(tester);

    expect(find.byKey(const Key('qwi_tab_experiment')), findsOneWidget);
    expect(find.text(QuantumWaveInterferenceHome.experimentTabLabel), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.highIntensityTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HighIntensityScreen), findsOneWidget);
    expect(find.byKey(const Key('hi_wave_canvas')), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.singleParticlesTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SingleParticlesScreen), findsOneWidget);
    expect(find.byKey(const Key('sp_wave_canvas')), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.experimentTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('qwi_detector_canvas')), findsOneWidget);

    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('re-entry ×10 recreates QWI (fresh route state)', (tester) async {
    await pumpHome(tester);
    for (var i = 0; i < 10; i++) {
      await openQwi(tester);
      expect(find.byType(QuantumWaveInterferenceHome), findsOneWidget);
      await backHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(QuantumWaveInterferenceHome), findsNothing);
    }
  });

  testWidgets('existing peer 波的干涉 still opens and returns', (tester) async {
    await pumpHome(tester);
    final peer = find.text('波的干涉');
    await tester.ensureVisible(peer);
    await tester.tap(peer);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // Home stays under the route stack; peer route must be on top.
    expect(find.byType(BackButton), findsOneWidget);
    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(QuantumWaveInterferenceHome.title), findsOneWidget);
    expect(find.byType(QuantumWaveInterferenceHome), findsNothing);
  });

  testWidgets('responsive Home card visible at small / baseline / large', (tester) async {
    for (final size in const [Size(375, 667), Size(1024, 768), Size(1920, 1080)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      final card = find.text(QuantumWaveInterferenceHome.title);
      await tester.ensureVisible(card);
      expect(card, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('screen icon assets are the original PhET SVGs', (tester) async {
    expect(QuantumWaveInterferenceHome.homeIconAsset, QwiAssets.experimentScreenIcon);
    expect(QwiAssets.experimentScreenIcon.endsWith('.svg'), isTrue);
    expect(QwiAssets.highIntensityScreenIcon.endsWith('.svg'), isTrue);
    expect(QwiAssets.singleParticlesScreenIcon.endsWith('.svg'), isTrue);
  });

  testWidgets('direct QWI home hosts three sealed screens', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: QuantumWaveInterferenceHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ExperimentScreen), findsOneWidget);
    await tester.tap(find.text(QuantumWaveInterferenceHome.highIntensityTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HighIntensityScreen), findsOneWidget);
    await tester.tap(find.text(QuantumWaveInterferenceHome.singleParticlesTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SingleParticlesScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
