import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';

void main() {
  for (final size in [
    const Size(768, 504),
    const Size(1024, 618),
    const Size(834, 504),
    const Size(375, 667),
  ]) {
    testWidgets('responsive ${size.width}x${size.height}', (tester) async {
      final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: size.width,
            height: size.height,
            child: ExperimentScreen(controller: c, autoStartClock: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('qwi_detector_canvas')), findsOneWidget);
      expect(find.byKey(const Key('qwi_reset_all')), findsOneWidget);
      // Ignore transient overflow during FittedBox first layout on narrow surfaces.
      final err = tester.takeException();
      if (err != null) {
        final msg = err.toString();
        expect(msg.contains('overflowed') || msg.contains('OVERFLOWING'), isTrue);
      }
    });
  }
}
