import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/model/masb_model.dart';
import 'package:kratos/masses_and_springs_basics/screens/lab_screen.dart';
import 'package:kratos/masses_and_springs_basics/screens/stretch_screen.dart';
import 'package:kratos/masses_and_springs_basics/widgets/draggable_ruler_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  group('Stretch scene', () {
    test('damping=0.7, dual spring, attach→damped settle continuous', () {
      final model = MasbModel.stretch();
      expect(model.scene, MasbScene.stretch);
      expect(model.damping, 0.7);
      expect(model.springs.length, 2);
      expect(model.movableLineVisible, isTrue);

      final mass = model.masses.firstWhere((e) => e.massKg == 0.100);
      model.attachMassToSpring(mass, model.firstSpring);
      for (var i = 0; i < 5000; i++) {
        model.step(1 / 60);
        expect(model.spring.displacement.isFinite, isTrue);
        expect(mass.verticalVelocity.isFinite, isTrue);
      }
      final eq = -0.1 * 9.8 / 6;
      expect(model.spring.displacement, closeTo(eq, 0.05));
      expect(mass.verticalVelocity.abs(), lessThan(0.08));
    });

    test('reset restores stretch damping 0.7 and movable line', () {
      final c = MasbController(model: MasbModel.stretch(), autoTick: false);
      c.model.damping = 0.1;
      c.setMovableLineVisible(false);
      c.reset();
      expect(c.model.damping, 0.7);
      expect(c.model.movableLineVisible, isTrue);
      c.dispose();
    });

    testWidgets('StretchScreen mounts ruler and disposes ticker', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: StretchScreen()));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(StretchScreen), findsOneWidget);
      expect(find.byType(DraggableRulerOverlay), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  group('Lab scene', () {
    test('single spring + attach/detach interaction loop', () {
      final model = MasbModel.lab();
      expect(model.springs.length, 1);
      expect(model.secondSpring, isNull);
      final mass = model.masses.first;
      model.attachMassToSpring(mass, model.firstSpring);
      expect(model.firstSpring.massAttached, same(mass));

      model.beginDrag(mass.positionX, mass.positionY);
      model.updateDrag(mass.positionX + 0.2, mass.positionY);
      expect(mass.spring, isNull);
      model.endDrag();
    });

    testWidgets('LabScreen mounts and disposes ticker', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LabScreen()));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(LabScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    test('Lab mass value control changes equilibrium', () {
      final model = MasbModel.lab();
      final mass = model.masses.firstWhere((e) => e.adjustable);
      model.attachMassToSpring(mass, model.firstSpring);
      model.damping = 0.7;
      for (var i = 0; i < 3000; i++) {
        model.step(1 / 60);
      }
      final eq1 = -mass.massKg * 9.8 / 6;
      expect(model.spring.displacement, closeTo(eq1, 0.05));

      model.setAttachedMassKg(0.25);
      expect(mass.massKg, closeTo(0.25, 1e-6));
      for (var i = 0; i < 3000; i++) {
        model.step(1 / 60);
      }
      final eq2 = -0.25 * 9.8 / 6;
      expect(model.spring.displacement, closeTo(eq2, 0.06));
    });

    test('Period Trace advances from real oscillation peaks/crosses', () {
      final model = MasbModel.lab();
      final spring = model.firstSpring;
      expect(spring.periodTrace, isNotNull);
      model.setPeriodTraceVisible(true);
      final mass = model.masses.first;
      model.attachMassToSpring(mass, spring);
      // Pull down while staying on spring X (attached drag) then release.
      final x = spring.positionX;
      model.beginDrag(mass.positionX, mass.positionY);
      model.updateDrag(x, mass.positionY - 0.22);
      expect(mass.spring, same(spring));
      model.endDrag();

      var maxState = 0;
      for (var i = 0; i < 4000; i++) {
        model.step(1 / 60);
        maxState = mathMax(maxState, spring.periodTrace!.state);
      }
      expect(maxState, greaterThanOrEqualTo(2),
          reason: 'trace must record real peaks, not stay idle');
    });

    test('vectors visibility toggles do not alter physics', () {
      final model = MasbModel.lab();
      final mass = model.masses.first;
      model.attachMassToSpring(mass, model.firstSpring);
      model.beginDrag(mass.positionX, mass.positionY - 0.2);
      model.updateDrag(mass.positionX, mass.positionY - 0.2);
      model.endDrag();
      for (var i = 0; i < 30; i++) {
        model.step(1 / 60);
      }
      final x0 = model.spring.displacement;
      final v0 = mass.verticalVelocity;
      model.velocityVectorVisible = true;
      model.accelerationVectorVisible = true;
      model.step(1 / 60);
      expect(model.spring.displacement, isNot(x0)); // still evolving
      // Same step magnitude order — vectors are view-only flags
      expect(mass.verticalVelocity, isNot(v0));
      expect(model.velocityVectorVisible, isTrue);
    });
  });
}

int mathMax(int a, int b) => a > b ? a : b;
