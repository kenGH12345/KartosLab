import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  testWidgets('Lab leave / re-enter rebinds ticker without crash',
      (tester) async {
    final c = BaBalanceLabController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaBalanceLabScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(c.clock.isRunning, isTrue);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaBalanceLabScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(c.clock.isRunning, isTrue);

    c.startBrickCreator(1, c.mvt.modelToView(const BaVector2(0.75, 0.9)));
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.75, 0.9)));
    c.endDrag();
    c.model.step(1 / 60);
    await tester.pump();
    c.dispose();
  });

  test('Lab controller dispose is clean', () {
    final c = BaBalanceLabController();
    c.dispose();
    expect(c.model.plank.tiltAngle, 0);
  });
}
