import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/physics/quantum_wave_interference/assets/qwi_assets.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/debug/qwi_android_gate_app.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/wave_display_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/models/single_particles_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';

/// PHASE 7 — Real Android runtime gate for Quantum Wave Interference.
///
/// Harness is **not** Home Integration. Run:
/// `flutter test integration_test/qwi_android_gate_test.dart -d emulator-5554`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFew(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> pumpHub(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(const QwiAndroidGateApp());
    await pumpFew(tester, 8);
  }

  Future<void> openFromHub(WidgetTester tester, Key navKey) async {
    expect(find.byKey(QwiAndroidGateHub.hubKey), findsOneWidget);
    final nav = find.byKey(navKey);
    await tester.ensureVisible(nav);
    await tester.tap(nav, warnIfMissed: false);
    // Allow MaterialPageRoute transition to complete.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (find.byKey(const Key('qwi_gate_back')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(const Key('qwi_gate_back')), findsOneWidget);
  }

  Future<void> backToHub(WidgetTester tester) async {
    final back = find.byKey(const Key('qwi_gate_back'));
    expect(back, findsOneWidget);
    await tester.tap(back, warnIfMissed: false);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (find.byKey(QwiAndroidGateHub.hubKey).evaluate().isNotEmpty &&
          find.byKey(const Key('qwi_gate_back')).evaluate().isEmpty) {
        break;
      }
    }
    expect(find.byKey(QwiAndroidGateHub.hubKey), findsOneWidget);
  }

  group('Android launch + navigation', () {
    testWidgets('hub launches; open/back/re-enter each screen ×12', (tester) async {
      await pumpHub(tester);
      expect(find.byKey(QwiAndroidGateHub.hubKey), findsOneWidget);

      await openFromHub(tester, QwiAndroidGateHub.experimentNavKey);
      expect(find.byKey(const Key('qwi_detector_canvas')), findsOneWidget);
      expect(find.byKey(const Key('qwi_reset_all')), findsOneWidget);
      await backToHub(tester);

      await openFromHub(tester, QwiAndroidGateHub.hiNavKey);
      expect(find.byKey(const Key('hi_wave_canvas')), findsOneWidget);
      expect(find.byKey(const Key('hi_reset_all')), findsOneWidget);
      await backToHub(tester);

      await openFromHub(tester, QwiAndroidGateHub.spNavKey);
      expect(find.byKey(const Key('sp_wave_canvas')), findsOneWidget);
      expect(find.byKey(const Key('sp_reset_all')), findsOneWidget);
      await backToHub(tester);

      for (var i = 0; i < 12; i++) {
        final key = i % 3 == 0
            ? QwiAndroidGateHub.experimentNavKey
            : i % 3 == 1
                ? QwiAndroidGateHub.hiNavKey
                : QwiAndroidGateHub.spNavKey;
        await openFromHub(tester, key);
        await backToHub(tester);
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('Android Experiment smoke', () {
    testWidgets('controls / hits / snapshot / reset', (tester) async {
      final c = ExperimentController(
        model: ExperimentModel(random: SeededQwiRandom(21)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await pumpFew(tester);

      expect(find.byKey(const Key('qwi_detector_canvas')), findsOneWidget);
      expect(find.byKey(const Key('qwi_emitter')), findsOneWidget);

      c.setSlitConfiguration(SlitConfiguration.leftCovered);
      c.setWavelengthNm(500);
      c.setScreenDistanceM(0.7);
      c.setSlitConfiguration(SlitConfiguration.bothOpen);
      c.setDetectionMode(DetectorMode.hits);
      await tester.pump();

      await tester.tap(find.byKey(const Key('qwi_emitter')), warnIfMissed: false);
      await tester.pump();
      if (!c.scene.isEmitting) {
        c.setEmitting(true);
      }
      for (var i = 0; i < 90; i++) {
        c.stepWall(1 / 60);
      }
      await tester.pump();
      expect(c.scene.hits.length, greaterThan(0));

      final snap = find.byKey(const Key('qwi_take_snapshot'));
      if (snap.evaluate().isNotEmpty) {
        await tester.ensureVisible(snap);
        await tester.tap(snap, warnIfMissed: false);
        await tester.pump();
      }
      if (c.scene.snapshots.length == 0) {
        expect(c.takeSnapshot(), isTrue);
      }
      expect(c.scene.snapshots.length, greaterThan(0));

      final ruler = find.byKey(const Key('qwi_ruler_checkbox'));
      if (ruler.evaluate().isNotEmpty) {
        await tester.ensureVisible(ruler);
        await tester.tap(ruler, warnIfMissed: false);
        await tester.pump();
      }

      await tester.tap(find.byKey(const Key('qwi_reset_all')), warnIfMissed: false);
      await pumpFew(tester, 4);
      expect(c.scene.hits.length, 0);
      expect(c.scene.wavelengthNm, 650);
      expect(tester.takeException(), isNull);
    });
  });

  group('Android High Intensity smoke', () {
    testWidgets('modes / time / zoom / snapshot / reset', (tester) async {
      final c = HighIntensityController(
        model: HighIntensityModel(random: SeededQwiRandom(22)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Clock driven manually — avoids 120² resample every frame on emulator.
            body: HighIntensityScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await pumpFew(tester);
      expect(find.byKey(const Key('hi_wave_canvas')), findsOneWidget);

      for (final cfg in [
        SlitConfiguration.noBarrier,
        SlitConfiguration.leftCovered,
        SlitConfiguration.bothOpen,
        SlitConfiguration.leftDetector,
      ]) {
        c.setSlitConfiguration(cfg);
        await tester.pump();
        expect(c.scene.slitConfiguration, cfg);
      }

      final hitsBefore = c.scene.hits.length;
      c.setWaveDisplayMode(WaveDisplayMode.amplitude);
      await tester.pump();
      c.setWaveDisplayMode(WaveDisplayMode.electricField);
      await tester.pump();
      expect(c.scene.hits.length, hitsBefore);

      await tester.tap(find.byKey(const Key('hi_emit_toggle')), warnIfMissed: false);
      await tester.pump();
      if (!c.scene.isEmitting) {
        c.setEmitting(true);
      }
      for (var i = 0; i < 30; i++) {
        c.stepWall(1 / 60);
      }
      await tester.pump();

      c.setGraphZoom(6);
      await tester.pump();
      expect(c.model.graphZoom.level, 6);
      expect(c.scene.wavelengthNm, 650);

      c.setTimeSpeed(TimeSpeed.slow);
      c.stepWall(1 / 60);
      c.setTimeSpeed(TimeSpeed.normal);
      c.stepWall(1 / 60);
      c.setTimeSpeed(TimeSpeed.fast);
      c.stepWall(1 / 60);
      await tester.pump();

      c.setPlaying(false);
      final t0 = c.scene.solver.time;
      c.stepWall(1 / 60); // paused → no advance
      expect(c.scene.solver.time, t0);
      for (var i = 0; i < 20; i++) {
        c.stepOnce();
      }
      expect(c.scene.solver.time, closeTo(t0 + 20 / 60, 1e-9));

      expect(c.takeSnapshot(), isTrue);
      await tester.pump();
      expect(c.scene.snapshots.length, 1);

      await tester.tap(find.byKey(const Key('hi_reset_all')), warnIfMissed: false);
      await pumpFew(tester, 4);
      expect(c.scene.hits.length, 0);
      expect(c.scene.snapshots.length, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('Android Single Particles smoke', () {
    testWidgets('probe / auto fire / pause / step / reset', (tester) async {
      final c = SingleParticlesController(
        model: SingleParticlesModel(random: SeededQwiRandom(23)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleParticlesScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await pumpFew(tester);
      expect(find.byKey(const Key('sp_wave_canvas')), findsOneWidget);

      c.setSlitConfiguration(SlitConfiguration.noBarrier);
      c.setProbeVisible(true);
      await tester.pump();
      expect(find.byKey(const Key('sp_probe_overlay')), findsOneWidget);

      c.moveProbe(0.55, 0.5);
      c.scene.timeSinceLastEmission = 1;
      c.fireOnce();
      for (var i = 0; i < 20; i++) {
        c.stepOnce();
      }
      await tester.pump();
      expect(c.scene.isPacketActive, isTrue);
      c.performProbeDetect();
      await tester.pump();
      expect(tester.takeException(), isNull);

      c.setSlitConfiguration(SlitConfiguration.bothOpen);
      c.setAutoRepeat(true);
      c.setTimeSpeed(TimeSpeed.fast);
      c.setPlaying(true);
      for (var i = 0; i < 200; i++) {
        c.stepWall(1 / 60);
      }
      await tester.pump();

      c.setPlaying(false);
      final hitsPaused = c.scene.hits.length;
      final tPause = c.scene.solver.time;
      c.stepWall(1 / 60);
      expect(c.scene.hits.length, hitsPaused);
      expect(c.scene.solver.time, tPause);

      // Step is fixed 1/60 and independent of TimeSpeed; time may reset on
      // packet re-emit, so assert each step delta while a packet is active.
      c.setAutoRepeat(false);
      if (!c.scene.isPacketActive) {
        c.scene.timeSinceLastEmission = 1;
        c.fireOnce();
      }
      for (var i = 0; i < 20; i++) {
        final before = c.scene.solver.time;
        c.stepOnce();
        if (c.scene.isPacketActive) {
          expect(c.scene.solver.time - before, closeTo(1 / 60, 1e-9));
        }
      }

      c.setPlaying(true);
      c.setTimeSpeed(TimeSpeed.slow);
      c.setTimeSpeed(TimeSpeed.normal);
      c.setGraphZoom(1);
      c.setGraphZoom(6);
      expect(c.scene.wavelengthNm, 650);

      expect(c.takeSnapshot(), isTrue);
      expect(c.scene.snapshots.length, 1);

      await tester.tap(find.byKey(const Key('sp_reset_all')), warnIfMissed: false);
      await pumpFew(tester, 4);
      expect(c.scene.autoRepeat, isFalse);
      expect(c.scene.hits.length, 0);
      expect(c.scene.isPacketActive, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('Android asset packaging', () {
    testWidgets('bundled SVG / PNG / audio readable', (tester) async {
      await pumpHub(tester);
      for (final path in [
        QwiAssets.photon,
        QwiAssets.electron,
        QwiAssets.neutron,
        QwiAssets.heliumAtom,
        QwiAssets.singleParticleEmitter,
        QwiAssets.experimentScreenIcon,
        QwiAssets.highIntensityScreenIcon,
        QwiAssets.singleParticlesScreenIcon,
        QwiAssets.measuringTape,
        QwiAssets.snapshotCaptured,
      ]) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: path);
      }
    });
  });

  group('Android audio runtime', () {
    testWidgets('snapshotCaptured hook executes without crash', (tester) async {
      final audio = QwiSnapshotAudio(enabled: true);
      final c = ExperimentController(
        model: ExperimentModel(random: SeededQwiRandom(9)),
        snapshotAudio: audio,
      );
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperimentScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await pumpFew(tester);
      expect(c.takeSnapshot(), isTrue);
      await pumpFew(tester, 20);
      expect(audio.playCount, greaterThan(0));
      expect(tester.takeException(), isNull);
      await audio.dispose();
    });
  });
}
