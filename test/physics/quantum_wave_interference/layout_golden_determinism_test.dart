import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/experiment_layout_spec.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/high_intensity_layout_spec.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/single_particles_layout_spec.dart';

/// Final Layout Regression — golden / Spec determinism (same seed ×3).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Experiment Spec resolve is deterministic ×3', () {
    final a = ExperimentLayoutSpec.resolve();
    final b = ExperimentLayoutSpec.resolve();
    final c = ExperimentLayoutSpec.resolve();
    expect(a.detector.left, b.detector.left);
    expect(b.detector.left, c.detector.left);
    expect(a.middleCenterX, c.middleCenterX);
    expect(a.graph.top, c.graph.top);
  });

  test('HI Spec resolve is deterministic ×3', () {
    final a = HighIntensityLayoutSpec.resolve();
    final b = HighIntensityLayoutSpec.resolve();
    final c = HighIntensityLayoutSpec.resolve();
    expect(a.waveRegion.left, b.waveRegion.left);
    expect(b.waveRegion.left, c.waveRegion.left);
    expect(a.waveRegion.top, c.waveRegion.top);
    expect(a.detector.left, c.detector.left);
    expect(a.graph.left, c.graph.left);
  });

  test('SP Spec resolve is deterministic ×3', () {
    final a = SingleParticlesLayoutSpec.resolve();
    final b = SingleParticlesLayoutSpec.resolve();
    final c = SingleParticlesLayoutSpec.resolve();
    expect(a.waveRegion.left, b.waveRegion.left);
    expect(b.waveRegion.left, c.waveRegion.left);
    expect(a.probeLayer.height, c.probeLayer.height);
    expect(a.sourcePanelTop, c.sourcePanelTop);
    expect(a.sourcePanelTop, isNot(HighIntensityLayoutConstants.sourceControlPanelTop));
  });

  testWidgets('HI golden render deterministic ×3 (same seed)', (tester) async {
    Future<void> pumpOnce() async {
      final c = HighIntensityController(
        model: HighIntensityModel(random: SeededQwiRandom(42)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );
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
    }

    // Same setup as high_default golden — compare ×3 for determinism.
    await pumpOnce();
    await expectLater(
      find.byType(HighIntensityScreen),
      matchesGoldenFile('goldens/high_default.png'),
    );
    await pumpOnce();
    await expectLater(
      find.byType(HighIntensityScreen),
      matchesGoldenFile('goldens/high_default.png'),
    );
    await pumpOnce();
    await expectLater(
      find.byType(HighIntensityScreen),
      matchesGoldenFile('goldens/high_default.png'),
    );
  });
}
