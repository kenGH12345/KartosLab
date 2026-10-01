import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/audio/qwi_snapshot_audio.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/models/single_particles_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_screen.dart';

Widget _wrap(SingleParticlesController c) {
  return MaterialApp(
    home: SizedBox(
      width: 768,
      height: 504,
      child: SingleParticlesScreen(controller: c, autoStartClock: false),
    ),
  );
}

SingleParticlesController _c(int seed) => SingleParticlesController(
      model: SingleParticlesModel(random: SeededQwiRandom(seed)),
      snapshotAudio: QwiSnapshotAudio(enabled: false),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SP screen builds key canvases and controls', (tester) async {
    final c = _c(1);
    await tester.pumpWidget(_wrap(c));
    await tester.pump();
    expect(find.byKey(const Key('sp_wave_canvas')), findsOneWidget);
    // Default is Screen mode (PhET isGraphVisible=false).
    expect(find.byKey(const Key('sp_detector_canvas')), findsOneWidget);
    expect(find.byKey(const Key('sp_graph_canvas')), findsNothing);
    await tester.tap(find.byKey(const Key('qwi_ab_switch')));
    await tester.pump();
    expect(find.byKey(const Key('sp_graph_canvas')), findsOneWidget);
    expect(find.byKey(const Key('sp_detector_canvas')), findsNothing);
    expect(find.byKey(const Key('sp_fire_button')), findsOneWidget);
    expect(find.byKey(const Key('sp_auto_repeat')), findsOneWidget);
    expect(find.byKey(const Key('sp_reset_all')), findsOneWidget);
    expect(find.byKey(const Key('sp_time_controls')), findsOneWidget);
  });

  testWidgets('fire button emits packet', (tester) async {
    final c = _c(2);
    await tester.pumpWidget(_wrap(c));
    await tester.tap(find.byKey(const Key('sp_fire_button')));
    await tester.pump();
    expect(c.scene.isPacketActive, isTrue);
  });

  testWidgets('probe appears for noBarrier', (tester) async {
    final c = _c(3);
    c.setSlitConfiguration(SlitConfiguration.noBarrier);
    c.setProbeVisible(true);
    await tester.pumpWidget(_wrap(c));
    await tester.pump();
    expect(find.byKey(const Key('sp_probe_checkbox')), findsOneWidget);
    expect(find.byKey(const Key('sp_probe_overlay')), findsOneWidget);
    expect(find.byKey(const Key('sp_probe_detect')), findsOneWidget);
  });

  testWidgets('snapshot 5th disabled', (tester) async {
    final c = _c(4);
    for (var i = 0; i < 4; i++) {
      c.takeSnapshot();
    }
    await tester.pumpWidget(_wrap(c));
    await tester.pump();
    expect(c.scene.snapshots.isFull, isTrue);
    expect(c.takeSnapshot(), isFalse);
    expect(c.scene.snapshots.length, 4);
  });

  testWidgets('responsive small/baseline/large no overflow', (tester) async {
    final c = _c(5);
    for (final size in const [Size(320, 240), Size(768, 504), Size(1920, 1080)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: size.width,
            height: size.height,
            child: SingleParticlesScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('reset all restores defaults', (tester) async {
    final c = _c(6);
    c.fireOnce();
    c.setAutoRepeat(true);
    await tester.pumpWidget(_wrap(c));
    await tester.tap(find.byKey(const Key('sp_reset_all')));
    await tester.pump();
    expect(c.scene.autoRepeat, isFalse);
    expect(c.scene.isPacketActive, isFalse);
    expect(c.scene.hits.length, 0);
  });
}
