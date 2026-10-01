import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/wave_display_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';

Future<void> _golden(WidgetTester tester, HighIntensityController c, String name) async {
  c.resampleWave();
  await tester.binding.setSurfaceSize(const Size(768, 504));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox(
        width: 768,
        height: 504,
        child: HighIntensityScreen(controller: c, autoStartClock: false),
      ),
    ),
  );
  await tester.pump();
  await expectLater(find.byType(HighIntensityScreen), matchesGoldenFile('goldens/$name.png'));
}

HighIntensityController _c() => HighIntensityController(
      model: HighIntensityModel(random: SeededQwiRandom(42)),
      snapshotAudio: QwiSnapshotAudio(enabled: false),
    );

void _warm(HighIntensityController c, {int steps = 140}) {
  c.setEmitting(true);
  for (var i = 0; i < steps; i++) {
    c.stepOnce();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('high_default', (t) async {
    await _golden(t, _c(), 'high_default');
  });

  testWidgets('high_photon', (t) async {
    final c = _c();
    _warm(c);
    await _golden(t, c, 'high_photon');
  });

  testWidgets('high_electron', (t) async {
    final c = _c()..selectSource(SourceType.electrons);
    _warm(c);
    await _golden(t, c, 'high_electron');
  });

  testWidgets('high_neutron', (t) async {
    final c = _c()..selectSource(SourceType.neutrons);
    _warm(c);
    await _golden(t, c, 'high_neutron');
  });

  testWidgets('high_helium', (t) async {
    final c = _c()..selectSource(SourceType.heliumAtoms);
    _warm(c);
    await _golden(t, c, 'high_helium');
  });

  testWidgets('high_no_barrier', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.noBarrier);
    _warm(c);
    await _golden(t, c, 'high_no_barrier');
  });

  testWidgets('high_single_slit', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.leftCovered);
    _warm(c);
    await _golden(t, c, 'high_single_slit');
  });

  testWidgets('high_double_slit', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.bothOpen);
    _warm(c);
    await _golden(t, c, 'high_double_slit');
  });

  testWidgets('high_detector_left', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.leftDetector);
    _warm(c, steps: 80);
    await _golden(t, c, 'high_detector_left');
  });

  testWidgets('high_detector_right', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.rightDetector);
    _warm(c, steps: 80);
    await _golden(t, c, 'high_detector_right');
  });

  testWidgets('high_both_detectors', (t) async {
    final c = _c()..setSlitConfiguration(SlitConfiguration.bothDetectors);
    _warm(c, steps: 80);
    await _golden(t, c, 'high_both_detectors');
  });

  testWidgets('high_wave_electric', (t) async {
    final c = _c()..setWaveDisplayMode(WaveDisplayMode.electricField);
    _warm(c);
    await _golden(t, c, 'high_wave_electric');
  });

  testWidgets('high_wave_amplitude', (t) async {
    final c = _c()..setWaveDisplayMode(WaveDisplayMode.amplitude);
    _warm(c);
    await _golden(t, c, 'high_wave_amplitude');
  });

  testWidgets('high_wave_real_part', (t) async {
    final c = _c()
      ..selectSource(SourceType.electrons)
      ..setWaveDisplayMode(WaveDisplayMode.realPart);
    _warm(c);
    await _golden(t, c, 'high_wave_real_part');
  });

  testWidgets('high_hits', (t) async {
    final c = _c()..setDetectionMode(DetectorMode.hits);
    _warm(c, steps: 180);
    await _golden(t, c, 'high_hits');
  });

  testWidgets('high_intensity', (t) async {
    final c = _c()..setDetectionMode(DetectorMode.intensity);
    _warm(c, steps: 100);
    await _golden(t, c, 'high_intensity');
  });

  testWidgets('high_graph', (t) async {
    final c = _c();
    _warm(c, steps: 80);
    await _golden(t, c, 'high_graph');
  });

  testWidgets('high_zoom', (t) async {
    final c = _c()..setGraphZoom(6);
    _warm(c);
    await _golden(t, c, 'high_zoom');
  });

  testWidgets('high_snapshot', (t) async {
    final c = _c();
    _warm(c);
    c.takeSnapshot();
    c.setSnapshotPanelOpen(true);
    await _golden(t, c, 'high_snapshot');
  });

  testWidgets('high_ruler', (t) async {
    final c = _c()..setMeasuringTapeVisible(true);
    _warm(c);
    await _golden(t, c, 'high_ruler');
  });

  testWidgets('high_pause', (t) async {
    final c = _c()
      ..setEmitting(true)
      ..setPlaying(false);
    for (var i = 0; i < 40; i++) {
      c.stepOnce();
    }
    await _golden(t, c, 'high_pause');
  });

  testWidgets('high_reset', (t) async {
    final c = _c()
      ..setWavelengthNm(400)
      ..setEmitting(true)
      ..reset();
    await _golden(t, c, 'high_reset');
  });
}
