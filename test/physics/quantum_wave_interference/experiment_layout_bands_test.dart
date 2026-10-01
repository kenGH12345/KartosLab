import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/experiment_layout_spec.dart';
import 'package:kratos/physics/quantum_wave_interference/view/layout/qwi_layout_primitives.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Experiment clear-columns: no L/M/R overlap', (tester) async {
    final c = ExperimentController(
      model: ExperimentModel(random: SeededQwiRandom(1)),
      snapshotAudio: QwiSnapshotAudio(enabled: false),
    );
    final spec = ExperimentLayoutSpec.resolve();

    await tester.binding.setSurfaceSize(const Size(768, 504));
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 768,
          height: 504,
          child: ExperimentScreen(controller: c, autoStartClock: false),
        ),
      ),
    );
    await tester.pump();

    expect(spec.slitPanel.top, greaterThanOrEqualTo(spec.slitView.bottom));
    expect(spec.screenControls.top, greaterThanOrEqualTo(spec.detector.bottom));
    expect(spec.graph.top, greaterThanOrEqualTo(spec.screenControls.bottom));

    expect(spec.sourcePanel.right, lessThanOrEqualTo(spec.slitView.left - QwiSpacing.stack + 0.5));
    expect(spec.slitView.right, lessThanOrEqualTo(spec.detector.left - QwiSpacing.stack + 0.5));
    expect(spec.slitPanel.right, lessThanOrEqualTo(spec.detector.left - QwiSpacing.stack + 0.5));
    expect(spec.screenControls.left, greaterThanOrEqualTo(spec.slitPanel.right - 0.5));
  });
}
