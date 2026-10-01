import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_screen_scale.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/render_data/experiment/detector_render_data.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ExperimentController ctrl() => ExperimentController(
        model: ExperimentModel(random: SeededQwiRandom(7)),
        snapshotAudio: QwiSnapshotAudio(enabled: false),
      );

  testWidgets('detector ± zooms visible window and changes intensity samples', (tester) async {
    final c = ctrl()..setEmitting(true);
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

    expect(c.model.detectorScreenScaleIndex, 0);
    final before = DetectorRenderData.fromModel(c.model);
    final midBefore = before.fraunhofer.intensities[before.fraunhofer.intensities.length ~/ 2];

    await tester.tap(find.byKey(const Key('qwi_zoom_in')));
    await tester.pump();
    expect(c.model.detectorScreenScaleIndex, 1);
    final after = DetectorRenderData.fromModel(c.model);
    expect(after.fraunhofer.visibleHalfWidthM, lessThan(before.fraunhofer.visibleHalfWidthM));
    expect(after.fraunhofer.intensities[after.fraunhofer.intensities.length ~/ 2], isNot(midBefore));

    await tester.tap(find.byKey(const Key('qwi_zoom_in')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('qwi_zoom_in')));
    await tester.pump();
    expect(c.model.detectorScreenScaleIndex, 3);

    await tester.tap(find.byKey(const Key('qwi_zoom_out')));
    await tester.pump();
    expect(c.model.detectorScreenScaleIndex, 2);
  });

  testWidgets('detector ± shrinks overhead visible-region fraction', (tester) async {
    final c = ctrl()..setEmitting(true);
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

    double frac() {
      final z = c.model.detectorScreenScaleIndex;
      return DetectorScreenScale.visibleHalfWidthMeters(z) /
          DetectorScreenScale.fullDetectorScreenHalfWidthM;
    }

    expect(frac(), closeTo(1.0, 1e-9));
    await tester.tap(find.byKey(const Key('qwi_zoom_in')));
    await tester.pump();
    expect(frac(), lessThan(1.0));
    await tester.tap(find.byKey(const Key('qwi_zoom_in')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('qwi_zoom_in')));
    await tester.pump();
    expect(frac(), closeTo(0.25, 1e-9));
  });

  testWidgets('graph ± changes Y zoom only — not detector scale', (tester) async {
    final c = ctrl()
      ..setEmitting(true)
      ..setGraphExpanded(true);
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

    expect(c.model.detectorScreenScaleIndex, 0);
    final y0 = c.model.graphZoom.level;

    await tester.tap(find.byKey(const Key('qwi_graph_zoom_in')));
    await tester.pump();
    expect(c.model.detectorScreenScaleIndex, 0);
    expect(c.model.graphZoom.level, y0 + 1);

    await tester.tap(find.byKey(const Key('qwi_graph_zoom_out')));
    await tester.pump();
    expect(c.model.graphZoom.level, y0);
    expect(c.model.detectorScreenScaleIndex, 0);
  });
}
