import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';

Future<void> _pumpGolden(
  WidgetTester tester,
  ExperimentController c,
  String name,
) async {
  await tester.binding.setSurfaceSize(const Size(768, 504));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox(
        width: 768,
        height: 504,
        child: ExperimentScreen(controller: c, autoStartClock: false),
      ),
    ),
  );
  await tester.pump();
  await expectLater(
    find.byType(ExperimentScreen),
    matchesGoldenFile('goldens/$name.png'),
  );
}

ExperimentController _ctrl() => ExperimentController(
      model: ExperimentModel(random: SeededQwiRandom(42)),
      snapshotAudio: QwiSnapshotAudio(enabled: false),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('experiment_default', (tester) async {
    final c = _ctrl();
    await _pumpGolden(tester, c, 'experiment_default');
  });

  testWidgets('experiment_photon_emitting', (tester) async {
    final c = _ctrl()..setEmitting(true);
    await _pumpGolden(tester, c, 'experiment_photon');
  });

  testWidgets('experiment_electron', (tester) async {
    final c = _ctrl()
      ..selectSource(SourceType.electrons)
      ..setEmitting(true);
    await _pumpGolden(tester, c, 'experiment_electron');
  });

  testWidgets('experiment_neutron', (tester) async {
    final c = _ctrl()
      ..selectSource(SourceType.neutrons)
      ..setEmitting(true);
    await _pumpGolden(tester, c, 'experiment_neutron');
  });

  testWidgets('experiment_helium', (tester) async {
    final c = _ctrl()
      ..selectSource(SourceType.heliumAtoms)
      ..setEmitting(true);
    await _pumpGolden(tester, c, 'experiment_helium');
  });

  testWidgets('experiment_single_slit', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setSlitConfiguration(SlitConfiguration.leftCovered);
    await _pumpGolden(tester, c, 'experiment_single_slit');
  });

  testWidgets('experiment_double_slit', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setSlitConfiguration(SlitConfiguration.bothOpen);
    await _pumpGolden(tester, c, 'experiment_double_slit');
  });

  testWidgets('experiment_detector_left', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setSlitConfiguration(SlitConfiguration.leftDetector);
    await _pumpGolden(tester, c, 'experiment_detector_left');
  });

  testWidgets('experiment_detector_right', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setSlitConfiguration(SlitConfiguration.rightDetector);
    await _pumpGolden(tester, c, 'experiment_detector_right');
  });

  testWidgets('experiment_both_detectors', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setSlitConfiguration(SlitConfiguration.bothDetectors);
    await _pumpGolden(tester, c, 'experiment_both_detectors');
  });

  testWidgets('experiment_intensity', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setDetectionMode(DetectorMode.intensity);
    await _pumpGolden(tester, c, 'experiment_intensity');
  });

  testWidgets('experiment_hits', (tester) async {
    final c = _ctrl()
      ..setDetectionMode(DetectorMode.hits)
      ..setEmitting(true);
    for (var i = 0; i < 120; i++) {
      c.stepWall(1 / 60);
    }
    await _pumpGolden(tester, c, 'experiment_hits');
  });

  testWidgets('experiment_graph', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setGraphExpanded(true);
    await _pumpGolden(tester, c, 'experiment_graph');
  });

  testWidgets('experiment_snapshot', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..takeSnapshot()
      ..setSnapshotPanelOpen(true);
    await _pumpGolden(tester, c, 'experiment_snapshot');
  });

  testWidgets('experiment_ruler', (tester) async {
    final c = _ctrl()
      ..setEmitting(true)
      ..setRulerVisible(true);
    await _pumpGolden(tester, c, 'experiment_ruler');
  });

  testWidgets('experiment_reset', (tester) async {
    final c = _ctrl()
      ..setWavelengthNm(400)
      ..setEmitting(true)
      ..reset();
    await _pumpGolden(tester, c, 'experiment_reset');
  });
}
