import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/screens/bounce_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('BounceScreen ticks then disposes without leftover ticker',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BounceScreen()));
    await tester.pump();
    // Advance real time so Ticker fires.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BounceScreen), findsOneWidget);

    // Leave screen — dispose must stop ticker.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
  });

  test('MasbController reset clears springs and shelf seats', () {
    final c = MasbController(autoTick: false);
    final mass = c.model.masses.firstWhere((e) => e.massKg == 0.100);
    c.model.attachMassToSpring(mass, c.model.firstSpring);
    for (var i = 0; i < 60; i++) {
      c.model.step(1 / 60);
    }
    expect(c.model.spring.displacement.abs(), greaterThan(0.01));
    c.reset();
    expect(c.model.spring.massAttached, isNull);
    expect(c.model.spring.displacement.abs(), lessThan(0.05));
    expect(c.model.masses.every((e) => e.onShelf), isTrue);
    c.dispose();
  });
}
