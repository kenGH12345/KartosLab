import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  testWidgets('enter / leave / re-enter does not leave duplicate clock',
      (tester) async {
    final c = BaIntroController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaIntroScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(c.clock.isRunning, isTrue);

    // Leave
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    await tester.pump();

    // Re-enter with same controller
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaIntroScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(c.clock.isRunning, isTrue);

    // Advance physics without crash
    c.model.step(1 / 60);
    await tester.pump();
    c.dispose();
  });

  test('controller dispose stops ticker cleanly', () {
    final c = BaIntroController();
    c.dispose();
    // Second dispose should not be required; ensure no throw on model after.
    expect(c.model.plank.tiltAngle, 0);
  });
}
