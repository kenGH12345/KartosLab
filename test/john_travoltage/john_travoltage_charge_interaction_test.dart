import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/model/leg.dart';
import 'package:kratos/john_travoltage/view/electron_layer_node.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';
import 'package:kratos/john_travoltage/view/jt_view_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JohnTravoltage Phase 3 — Charge Interaction', () {
    JohnTravoltageModel seeded([int seed = 42]) =>
        JohnTravoltageModel(random: math.Random(seed));

    test('1. setLegAngle changes angle via pivot convention', () {
      final m = seeded();
      final start = m.leg.angle;
      m.setLegAngle(1.8);
      expect(m.leg.angle, closeTo(1.8, 1e-12));
      expect(m.leg.angle, isNot(start));
      expect(m.lastLegAngleDelta, closeTo((1.8 - start).abs(), 1e-12));
    });

    test('2. angle respects [0, π] + limitRotation', () {
      final m = seeded();
      m.setLegAngle(-0.5, applyLimitRotation: true);
      expect(m.leg.angle, 0);
      m.setLegAngle(-2.0, applyLimitRotation: true);
      expect(m.leg.angle, math.pi);
      m.setLegAngle(Leg.limitRotation(1.5));
      expect(m.leg.angle, inInclusiveRange(0, math.pi));
    });

    test('3. carpet state matches exclusive (1, 2.4)', () {
      final m = seeded();
      m.setLegAngle(1.0);
      expect(m.shoeOnCarpet, isFalse);
      m.setLegAngle(1.5);
      expect(m.shoeOnCarpet, isTrue);
      m.setLegAngle(2.4);
      expect(m.shoeOnCarpet, isFalse);
    });

    test('4–5. small increments accumulate across π/16', () {
      final m = seeded();
      final start = m.leg.angle;
      final step = JohnTravoltageConstants.accumulatedAngleThreshold / 5;
      var angle = start;
      // Source uses while (accumulated > threshold) — need strictly more than π/16.
      for (var i = 0; i < 5; i++) {
        angle += step;
        m.setLegAngle(angle);
        expect(m.electronCount, 0, reason: 'step $i still at/under threshold');
      }
      // One more tiny nudge to cross the exclusive threshold.
      angle += 1e-6;
      m.setLegAngle(angle);
      expect(m.electronCount, 1);
    });

    test('6. multiple threshold in one gesture-sized jump', () {
      final m = seeded();
      final start = m.leg.angle;
      m.setLegAngle(
        start + JohnTravoltageConstants.accumulatedAngleThreshold * 4.2,
      );
      expect(m.electronCount, 4);
    });

    test('7. MAX_ELECTRONS stays at 100', () {
      final m = seeded();
      var i = 0;
      while (m.electronCount < 100 && i < 800) {
        m.setLegAngle(1.1 + (i.isEven ? 0 : 1.2));
        i++;
      }
      expect(m.electronCount, 100);
      m.setLegAngle(1.1);
      m.setLegAngle(2.3);
      m.setLegAngle(1.1);
      expect(m.electronCount, 100);
    });

    test('8. reverse rubbing still accumulates |Δangle|', () {
      final m = seeded();
      m.setLegAngle(1.2);
      m.setLegAngle(2.0);
      final mid = m.electronCount;
      expect(mid, greaterThan(0));
      // Reverse direction — |Δangle| still creates charge
      m.setLegAngle(1.2);
      expect(m.electronCount, greaterThan(mid));
    });

    test('9. electron creation uses spawn segment', () {
      final m = seeded(7);
      m.setLegAngle(1.2);
      m.setLegAngle(2.0);
      expect(m.electronCount, greaterThan(0));
      final e = m.electrons.first;
      // Spawn segment is near foot (y ~445–452)
      expect(e.position.y, greaterThan(400));
      expect(e.position.x, inInclusiveRange(420, 440));
    });

    test('10. electron view samples 1:1 with model ids', () {
      final m = seeded();
      m.setLegAngle(1.2);
      m.setLegAngle(2.2);
      m.setLegAngle(1.3);
      final samples = syncElectronViewSamples(m);
      expect(samples.length, m.electronCount);
      final ids = samples.map((s) => s.id).toSet();
      expect(ids.length, m.electronCount);
      for (final e in m.electrons) {
        expect(ids.contains(e.id), isTrue);
      }
    });

    test('11. electron positions update across step', () {
      final m = seeded(3);
      m.setLegAngle(1.2);
      m.setLegAngle(2.2);
      expect(m.electronCount, greaterThan(1));
      final before = m.electrons.map((e) => e.position).toList();
      for (var i = 0; i < 30; i++) {
        m.step(1 / 60);
      }
      var moved = 0;
      for (var i = 0; i < m.electrons.length; i++) {
        if (m.electrons[i].position.distance(before[i]) > 0.01) moved++;
      }
      expect(moved, greaterThan(0));
    });

    test('12. reset during charge clears all', () {
      final m = seeded();
      m.setLegAngle(1.2);
      m.setLegAngle(2.2);
      expect(m.electronCount, greaterThan(0));
      m.reset();
      expect(m.electronCount, 0);
      expect(m.accumulatedAngle, 0);
      expect(m.lastLegAngleDelta, 0);
      expect(m.leg.angle, JohnTravoltageConstants.legInitialAngle);
      expect(m.sparkVisible, isFalse);
      expect(m.leg.dragging, isFalse);
    });

    test('13. repeated charge/reset cycles', () {
      final m = seeded(9);
      for (var c = 0; c < 3; c++) {
        m.setLegAngle(1.15);
        m.setLegAngle(2.25);
        m.setLegAngle(1.2);
        expect(m.electronCount, greaterThan(0), reason: 'cycle $c');
        m.reset();
        expect(m.electronCount, 0, reason: 'cycle $c reset');
      }
    });

    test('14. high-charge stability at 100 + steps', () {
      final m = seeded(5);
      var i = 0;
      while (m.electronCount < 100 && i < 800) {
        m.setLegAngle(1.05 + (i.isEven ? 0 : 1.3));
        i++;
      }
      expect(m.electronCount, 100);
      for (var s = 0; s < 120; s++) {
        m.step(1 / 60);
      }
      expect(m.electronCount, 100);
      for (final e in m.electrons) {
        expect(e.position.x.isFinite, isTrue);
        expect(e.position.y.isFinite, isTrue);
        expect(e.velocity.x.isFinite, isTrue);
        expect(e.velocity.y.isFinite, isTrue);
      }
    });

    test('release: no charge growth without angle change', () {
      final m = seeded();
      m.setLegAngle(1.2);
      m.setLegAngle(2.0);
      final n = m.electronCount;
      m.leg.dragging = false;
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
      }
      expect(m.electronCount, n);
    });

    testWidgets('play area: model↔view electron count stays 1:1', (tester) async {
      final model = seeded(11);
      await tester.pumpWidget(
        MaterialApp(
          home: JohnTravoltagePlayArea(
            model: model,
            autoStartClock: false,
            enableAudio: false,
          ),
        ),
      );
      await tester.pump();

      final state = tester.state<JohnTravoltagePlayAreaState>(
        find.byType(JohnTravoltagePlayArea),
      );
      expect(state.electronSamples.length, 0);

      model.setLegAngle(1.2);
      model.setLegAngle(2.2);
      await tester.pump();

      expect(state.electronSamples.length, model.electronCount);
      expect(find.byType(ElectronLayerNode), findsOneWidget);

      // Drive motion via manual steps while clock off
      for (var i = 0; i < 20; i++) {
        model.step(1 / 60);
      }
      await tester.pump();
      expect(state.electronSamples.length, model.electronCount);

      model.reset();
      await tester.pump();
      expect(state.electronSamples.length, 0);
      expect(model.electronCount, 0);
    });

    testWidgets('leg drag gesture increases charge', (tester) async {
      final model = seeded(13);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: JohnTravoltagePlayArea(
              model: model,
              autoStartClock: false,
              enableAudio: false,
            ),
          ),
        ),
      );
      await tester.pump();

      final pivot = Offset(
        JohnTravoltageConstants.legPivot.x,
        JohnTravoltageConstants.legPivot.y,
      );
      // Drag around pivot through carpet angles
      final start = Offset(
        pivot.dx + 80 * math.cos(1.2),
        pivot.dy + 80 * math.sin(1.2),
      );
      final end = Offset(
        pivot.dx + 80 * math.cos(2.2),
        pivot.dy + 80 * math.sin(2.2),
      );

      final gesture = await tester.startGesture(start);
      await tester.pump();
      const steps = 12;
      for (var i = 1; i <= steps; i++) {
        final t = i / steps;
        await gesture.moveTo(Offset.lerp(start, end, t)!);
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();

      expect(model.electronCount, greaterThan(0));
      expect(model.leg.borderVisible, isFalse);
      expect(model.leg.angle, inInclusiveRange(0, math.pi));
    });

    test('layout still 768×504 (no MediaQuery in model)', () {
      expect(JtViewLayout.layoutWidth, JohnTravoltageConstants.layoutWidth);
      expect(JtViewLayout.layoutHeight, JohnTravoltageConstants.layoutHeight);
    });
  });
}
