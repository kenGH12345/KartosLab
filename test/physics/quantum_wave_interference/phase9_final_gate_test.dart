import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/main.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/data/graph_data.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/probe.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/wave_display_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/models/single_particles_model.dart';
import 'package:kratos/physics/quantum_wave_interference/screens/quantum_wave_interference_home.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Phase 9 — final product gate (Home + sealed screens + lifecycle evidence).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> desktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openQwi(WidgetTester tester) async {
    final card = find.text(QuantumWaveInterferenceHome.title);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> back(WidgetTester tester) async {
    final b = find.byType(BackButton);
    expect(b, findsWidgets);
    await tester.tap(b.first);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  testWidgets('product entry: KratosApp Home exposes QWI, not debug gate', (tester) async {
    await desktop(tester);
    await tester.pumpWidget(const KratosApp());
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(QuantumWaveInterferenceHome.title), findsOneWidget);
    expect(find.textContaining('Android Gate'), findsNothing);
    expect(find.textContaining('QWI Android Gate'), findsNothing);
  });

  testWidgets('final user path Home↔QWI tabs×3 + peer Back', (tester) async {
    await desktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await openQwi(tester);
    expect(find.byType(ExperimentScreen), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.highIntensityTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HighIntensityScreen), findsOneWidget);

    await tester.tap(find.text(QuantumWaveInterferenceHome.singleParticlesTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SingleParticlesScreen), findsOneWidget);

    await back(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    final peer = find.text('波的干涉');
    await tester.ensureVisible(peer);
    await tester.tap(peer, warnIfMissed: false);
    await tester.pump();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 25));
      if (find.byType(BackButton).evaluate().isNotEmpty) {
        break;
      }
    }
    // Peer route on stack (Home remains underneath).
    expect(find.byType(BackButton), findsWidgets);
    await back(tester);
    expect(find.text(QuantumWaveInterferenceHome.title), findsOneWidget);
  });

  test('final snapshot max + Reset All across three models', () {
    final exp = ExperimentModel(random: SeededQwiRandom(1));
    exp.scene.detectionMode = DetectorMode.hits;
    exp.scene.setEmitting(true);
    for (var i = 0; i < 60; i++) {
      exp.step(1 / 60);
    }
    for (var s = 0; s < 4; s++) {
      expect(exp.scene.takeSnapshot(), isTrue);
    }
    expect(exp.scene.takeSnapshot(), isFalse);
    exp.scene.snapshots.deleteAt(0);
    expect(exp.scene.takeSnapshot(), isTrue);
    exp.reset();
    expect(exp.scene.snapshots.length, 0);
    expect(exp.scene.hits.length, 0);
    expect(exp.scene.wavelengthNm, 650);

    final hi = HighIntensityModel(random: SeededQwiRandom(1));
    hi.scene.setEmitting(true);
    hi.scene.setWaveDisplayMode(WaveDisplayMode.amplitude);
    hi.graphZoom.setLevel(6);
    hi.clock.setSpeed(TimeSpeed.fast);
    for (var i = 0; i < 40; i++) {
      hi.step(1 / 60);
    }
    for (var s = 0; s < 4; s++) {
      expect(hi.scene.takeSnapshot(), isTrue);
    }
    expect(hi.scene.takeSnapshot(), isFalse);
    hi.reset();
    expect(hi.scene.snapshots.length, 0);
    expect(hi.graphZoom.level, 3);
    expect(hi.clock.speed, TimeSpeed.normal);
    expect(hi.scene.waveDisplayMode, WaveDisplayMode.electricField);

    final sp = SingleParticlesModel(random: SeededQwiRandom(1));
    sp.scene.setAutoRepeat(true);
    sp.clock.setSpeed(TimeSpeed.fast);
    for (var i = 0; i < 2000 && sp.scene.hits.length < 5; i++) {
      sp.step(1 / 60);
    }
    for (var s = 0; s < 4; s++) {
      expect(sp.scene.takeSnapshot(), isTrue);
    }
    expect(sp.scene.takeSnapshot(), isFalse);
    sp.reset();
    expect(sp.scene.autoRepeat, isFalse);
    expect(sp.scene.isPacketActive, isFalse);
    expect(sp.scene.hits.length, 0);
    expect(sp.scene.snapshots.length, 0);
  });

  test('final which-path + statistics + determinism evidence', () {
    List<int> hist(SlitConfiguration cfg) {
      final m = SingleParticlesModel(random: SeededQwiRandom(42));
      m.scene.setSlitConfiguration(cfg);
      m.scene.setAutoRepeat(true);
      m.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 15000 && m.scene.hits.length < 50; i++) {
        m.step(1 / 60);
      }
      return HitsHistogramData.fromHits(m.scene.hits.hits).bins;
    }

    final both = hist(SlitConfiguration.bothOpen);
    final which = hist(SlitConfiguration.leftDetector);
    expect(both.reduce((a, b) => a + b), greaterThan(0));
    expect(which.reduce((a, b) => a + b), greaterThan(0));
    expect(both, isNot(equals(which)));

    List<double> seq(int seed) {
      final m = SingleParticlesModel(random: SeededQwiRandom(seed));
      m.scene.setAutoRepeat(true);
      m.clock.setSpeed(TimeSpeed.fast);
      for (var i = 0; i < 30000 && m.scene.hits.length < 100; i++) {
        m.step(1 / 60);
      }
      expect(m.scene.hits.length, 100);
      return m.scene.hits.hits.map((h) => h.x).toList();
    }

    expect(seq(9001), seq(9001));

    final exp = ExperimentModel(random: SeededQwiRandom(11));
    exp.scene.detectionMode = DetectorMode.hits;
    exp.scene.setEmitting(true);
    for (var i = 0; i < 20000 && exp.scene.hits.length < 1000; i++) {
      exp.step(1 / 60);
    }
    expect(exp.scene.hits.length, 1000);
    final bins = HitsHistogramData.fromHits(exp.scene.hits.hits).bins;
    expect(bins.where((c) => c > 0).length, greaterThan(3));
  });

  test('final probe success/failure + HI pause/step/speed', () {
    var success = false;
    for (var seed = 40; seed < 120 && !success; seed++) {
      final c = SingleParticlesController(
        model: SingleParticlesModel(random: SeededQwiRandom(seed)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
      c.setSlitConfiguration(SlitConfiguration.noBarrier);
      c.scene.timeSinceLastEmission = 1;
      c.fireOnce();
      for (var i = 0; i < 45; i++) {
        c.stepOnce();
      }
      if (!c.scene.isPacketActive) {
        continue;
      }
      c.scene.detectorProbe.radius = 0.4;
      c.scene.detectorProbe.normalizedX = 0.55;
      c.scene.detectorProbe.normalizedY = 0.5;
      c.scene.detectorProbe.reset();
      final before = c.scene.hits.length;
      c.performProbeDetect();
      if (c.scene.detectorProbe.state == ProbeState.detected) {
        expect(c.scene.hits.length, before);
        expect(c.scene.isPacketActive, isFalse);
        success = true;
      }
    }
    expect(success, isTrue);

    final fail = SingleParticlesModel(random: SeededQwiRandom(9));
    fail.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
    fail.scene.emitPacket();
    for (var i = 0; i < 40; i++) {
      fail.stepOnce();
    }
    fail.scene.detectorProbe.radius = 0.02;
    fail.scene.detectorProbe.normalizedX = 0.05;
    fail.scene.detectorProbe.normalizedY = 0.05;
    var failed = false;
    for (var a = 0; a < 40 && fail.scene.isPacketActive; a++) {
      fail.scene.detectorProbe.state = ProbeState.ready;
      fail.scene.performDetectorMeasurement();
      if (fail.scene.detectorProbe.state == ProbeState.notDetected) {
        failed = true;
        expect(fail.scene.solver.measurementProjections, isNotEmpty);
        expect(fail.scene.isPacketActive, isTrue);
        break;
      }
    }
    expect(failed, isTrue);

    final hi = HighIntensityModel(random: SeededQwiRandom(3));
    hi.scene.setEmitting(true);
    hi.clock.setSpeed(TimeSpeed.fast);
    hi.step(1 / 60);
    hi.clock.isPlaying = false;
    final t = hi.scene.solver.time;
    hi.step(1 / 60);
    expect(hi.scene.solver.time, t);
    for (var i = 0; i < 20; i++) {
      hi.stepOnce();
    }
    expect(hi.scene.solver.time, closeTo(t + 20 / 60, 1e-9));
  });

  testWidgets('lifecycle stress Enter/Exit ×20', (tester) async {
    await desktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    for (var cycle = 0; cycle < 20; cycle++) {
      await openQwi(tester);
      final tab = cycle % 3 == 0
          ? QuantumWaveInterferenceHome.experimentTabLabel
          : cycle % 3 == 1
              ? QuantumWaveInterferenceHome.highIntensityTabLabel
              : QuantumWaveInterferenceHome.singleParticlesTabLabel;
      await tester.tap(find.text(tab));
      await tester.pump(const Duration(milliseconds: 200));
      await back(tester);
      expect(find.byType(QuantumWaveInterferenceHome), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });
}
