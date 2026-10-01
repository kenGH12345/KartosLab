import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/wave_display_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/models/single_particles_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';

Future<void> _golden(WidgetTester tester, SingleParticlesController c, String name) async {
  c.resampleWave();
  await tester.binding.setSurfaceSize(const Size(768, 504));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox(
        width: 768,
        height: 504,
        child: SingleParticlesScreen(controller: c, autoStartClock: false),
      ),
    ),
  );
  await tester.pump();
  await expectLater(find.byType(SingleParticlesScreen), matchesGoldenFile('goldens/$name.png'));
}

SingleParticlesController _c() => SingleParticlesController(
      model: SingleParticlesModel(random: SeededQwiRandom(42)),
      snapshotAudio: QwiSnapshotAudio(enabled: false),
    );

void _fireWarm(SingleParticlesController c, {int steps = 90}) {
  c.fireOnce();
  for (var i = 0; i < steps; i++) {
    c.stepOnce();
  }
}

void _accumulateHits(SingleParticlesController c, {int target = 12, int maxSteps = 8000}) {
  c.setAutoRepeat(true);
  c.setTimeSpeed(TimeSpeed.fast);
  for (var i = 0; i < maxSteps && c.scene.hits.length < target; i++) {
    c.stepOnce();
  }
  c.setPlaying(false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sp_initial', (t) async {
    await _golden(t, _c(), 'sp_initial');
  });

  testWidgets('sp_no_barrier', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.noBarrier);
    _fireWarm(c);
    await _golden(t, c, 'sp_no_barrier');
  });

  testWidgets('sp_double_slit', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.bothOpen);
    _fireWarm(c);
    await _golden(t, c, 'sp_double_slit');
  });

  testWidgets('sp_single_slit', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.leftCovered);
    _fireWarm(c);
    await _golden(t, c, 'sp_single_slit');
  });

  testWidgets('sp_left_covered', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.leftCovered);
    _fireWarm(c, steps: 70);
    await _golden(t, c, 'sp_left_covered');
  });

  testWidgets('sp_right_covered', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.rightCovered);
    _fireWarm(c, steps: 70);
    await _golden(t, c, 'sp_right_covered');
  });

  testWidgets('sp_left_detector', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.leftDetector);
    _fireWarm(c, steps: 100);
    await _golden(t, c, 'sp_left_detector');
  });

  testWidgets('sp_right_detector', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.rightDetector);
    _fireWarm(c, steps: 100);
    await _golden(t, c, 'sp_right_detector');
  });

  testWidgets('sp_both_detectors', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.bothDetectors);
    _fireWarm(c, steps: 100);
    await _golden(t, c, 'sp_both_detectors');
  });

  testWidgets('sp_probe', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.noBarrier);
    c.setProbeVisible(true);
    _fireWarm(c, steps: 60);
    await _golden(t, c, 'sp_probe');
  });

  testWidgets('sp_hits_accumulated', (t) async {
    final c = _c();
    _accumulateHits(c, target: 15);
    await _golden(t, c, 'sp_hits_accumulated');
  });

  testWidgets('sp_graph', (t) async {
    final c = _c();
    _accumulateHits(c, target: 20);
    c.setGraphZoom(3);
    await _golden(t, c, 'sp_graph');
  });

  testWidgets('sp_snapshot', (t) async {
    final c = _c();
    _accumulateHits(c, target: 8);
    c.takeSnapshot();
    c.setSnapshotPanelOpen(true);
    await _golden(t, c, 'sp_snapshot');
  });

  testWidgets('sp_zoom', (t) async {
    final c = _c();
    _fireWarm(c);
    c.setGraphZoom(1);
    await _golden(t, c, 'sp_zoom');
  });

  testWidgets('sp_paused', (t) async {
    final c = _c();
    _fireWarm(c, steps: 50);
    c.setPlaying(false);
    await _golden(t, c, 'sp_paused');
  });

  testWidgets('sp_speed', (t) async {
    final c = _c();
    c.setTimeSpeed(TimeSpeed.fast);
    _fireWarm(c, steps: 40);
    await _golden(t, c, 'sp_speed');
  });

  testWidgets('sp_electron', (t) async {
    final c = _c()..selectSource(SourceType.electrons);
    _fireWarm(c);
    await _golden(t, c, 'sp_electron');
  });

  testWidgets('sp_amplitude_mode', (t) async {
    final c = _c()..setWaveDisplayMode(WaveDisplayMode.amplitude);
    _fireWarm(c);
    await _golden(t, c, 'sp_amplitude_mode');
  });

  testWidgets('sp_reset', (t) async {
    final c = _c();
    _accumulateHits(c, target: 5);
    c.reset();
    await _golden(t, c, 'sp_reset');
  });

  testWidgets('sp_helium', (t) async {
    final c = _c()..selectSource(SourceType.heliumAtoms);
    _fireWarm(c);
    await _golden(t, c, 'sp_helium');
  });
}
