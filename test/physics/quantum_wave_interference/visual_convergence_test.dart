import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/assets/qwi_assets.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/probe.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/models/single_particles_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_colors.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_layout.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_probe_node.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5 visual assets', () {
    test('original SVG / PNG / MP3 assets resolve', () async {
      for (final path in [
        QwiAssets.photon,
        QwiAssets.electron,
        QwiAssets.neutron,
        QwiAssets.heliumAtom,
        QwiAssets.measuringTape,
        QwiAssets.snapshotCaptured,
        QwiAssets.singleParticleEmitter,
      ]) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(100), reason: path);
      }
    });

    test('probe state colors match QuantumWaveInterferenceColors', () {
      expect(QwiColors.probeReadyFill.a, closeTo(0.3, 0.02));
      expect(QwiColors.probeNotDetectedFill.a, closeTo(0.5, 0.02));
      expect(QwiColors.probeDetectedFill.a, closeTo(0.65, 0.05));
      expect(QwiColors.panelFill, const Color(0xFFF4F4F4));
      expect(QwiColors.screenBackground, Colors.white);
    });

    test('snapshot audio hook increments without throwing when disabled', () async {
      final audio = QwiSnapshotAudio(enabled: false);
      await audio.playSnapshotCaptured();
      expect(audio.playCount, 1);
      await audio.dispose();
    });

    test('layout remains 768×504', () {
      expect(QwiLayout.designWidth, 768);
      expect(QwiLayout.designHeight, 504);
    });
  });

  group('Probe / Measuring Tape widgets', () {
    testWidgets('probe node shows Detect and size slider', (tester) async {
      final probe = DetectorProbe();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 460,
              child: QwiProbeNode(
                probe: probe,
                waveSize: const Size(420, 385),
                panelAnchor: const Offset(210, 420),
                onMove: (a, b) {},
                onRadiusChanged: (r) => probe.radius = r,
                onDetectOrReset: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('sp_probe_overlay')), findsOneWidget);
      expect(find.byKey(const Key('sp_probe_detect')), findsOneWidget);
      expect(find.byKey(const Key('sp_probe_size_slider')), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('measuring tape uses original PNG and shows unit', (tester) async {
      final c = SingleParticlesController(
        model: SingleParticlesModel(random: SeededQwiRandom(1)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      c.setMeasuringTapeVisible(true);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 768,
            height: 504,
            child: SingleParticlesScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('qwi_measuring_tape')), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(find.textContaining('μm'), findsOneWidget);
    });

    testWidgets('probe chrome on noBarrier SP screen', (tester) async {
      final c = SingleParticlesController(
        model: SingleParticlesModel(random: SeededQwiRandom(2)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      c.setSlitConfiguration(SlitConfiguration.noBarrier);
      c.setProbeVisible(true);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 768,
            height: 504,
            child: SingleParticlesScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('sp_probe_overlay')), findsOneWidget);
      expect(find.byKey(const Key('sp_probe_detect')), findsOneWidget);
    });

    testWidgets('particle SVG icons appear for each source type', (tester) async {
      final c = SingleParticlesController(
        model: SingleParticlesModel(random: SeededQwiRandom(3)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 768,
            height: 504,
            child: SingleParticlesScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();
      for (final t in SourceType.values) {
        expect(find.byKey(ValueKey('sp_source_$t')), findsOneWidget);
      }
    });
  });
}
