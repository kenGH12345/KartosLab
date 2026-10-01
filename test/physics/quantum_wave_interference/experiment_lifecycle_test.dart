import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_screen.dart';

void main() {
  testWidgets('dispose owned controller without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 768,
          height: 504,
          child: ExperimentScreen(
            seed: 1,
            autoStartClock: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('external controller not disposed by screen', (tester) async {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 768,
          height: 504,
          child: ExperimentScreen(controller: c, autoStartClock: false),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // Still usable
    c.setWavelengthNm(600);
    expect(c.scene.wavelengthNm, 600);
    c.dispose();
  });
}
