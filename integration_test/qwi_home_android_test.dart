import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/main.dart';
import 'package:kratos/physics/quantum_wave_interference/assets/qwi_assets.dart';
import 'package:kratos/physics/quantum_wave_interference/screens/quantum_wave_interference_home.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';
import 'package:kratos/screens/home_screen.dart';
import 'package:flutter/services.dart';

/// PHASE 8 — Android Home → QWI formal navigation (not the Phase-7 debug gate).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(const KratosApp());
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> openQwi(WidgetTester tester) async {
    final card = find.text(QuantumWaveInterferenceHome.title);
    await tester.ensureVisible(card);
    await tester.tap(card, warnIfMissed: false);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 25));
      if (find.byType(QuantumWaveInterferenceHome).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byType(QuantumWaveInterferenceHome), findsOneWidget);
  }

  Future<void> backOnce(WidgetTester tester) async {
    final back = find.byType(BackButton);
    expect(back, findsWidgets);
    await tester.tap(back.first, warnIfMissed: false);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  testWidgets('Android Home → QWI → three tabs → Back → Home', (tester) async {
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await openQwi(tester);
    expect(find.byType(ExperimentScreen), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.highIntensityTabLabel), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HighIntensityScreen), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.singleParticlesTabLabel), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SingleParticlesScreen), findsOneWidget);

    await backOnce(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(QuantumWaveInterferenceHome), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android re-entry cycles + peer regression', (tester) async {
    await pumpApp(tester);

    for (var i = 0; i < 6; i++) {
      await openQwi(tester);
      if (i.isEven) {
        await tester.tap(
          find.text(QuantumWaveInterferenceHome.highIntensityTabLabel),
          warnIfMissed: false,
        );
      } else {
        await tester.tap(
          find.text(QuantumWaveInterferenceHome.singleParticlesTabLabel),
          warnIfMissed: false,
        );
      }
      await tester.pump(const Duration(milliseconds: 300));
      await backOnce(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    }

    final peer = find.text('波的干涉');
    await tester.ensureVisible(peer);
    await tester.tap(peer, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    await backOnce(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(QuantumWaveInterferenceHome.title), findsOneWidget);

    for (final path in [
      QwiAssets.experimentScreenIcon,
      QwiAssets.highIntensityScreenIcon,
      QwiAssets.singleParticlesScreenIcon,
    ]) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
    expect(tester.takeException(), isNull);
  });
}
