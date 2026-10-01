import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';

void main() {
  testWidgets('dispose owned controller', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 768,
          height: 504,
          child: HighIntensityScreen(seed: 1, autoStartClock: false),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('external controller survives leave', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
    c.setEmitting(true);
    for (var i = 0; i < 20; i++) {
      c.stepOnce();
    }
    final t = c.scene.solver.time;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 768,
          height: 504,
          child: HighIntensityScreen(controller: c, autoStartClock: false),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(c.scene.solver.time, t);
    c.dispose();
  });
}
