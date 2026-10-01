import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/pool/mystery_pool_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/under_pressure_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Trapezoid scene', () {
    test('geometry is not a rectangle — sloped borders', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.trapezoid);
      final t = m.trapezoid;
      expect(t.x1top > t.x1bottom, isTrue); // left wall slopes inward at top? 
      // left chamber: wider at bottom
      expect(t.leftChamber.widthBottom > t.leftChamber.widthTop, isTrue);
      expect(t.rightChamber.widthTop > t.rightChamber.widthBottom, isTrue);
      expect(t.isPointInsidePool(3.2, -1.5), isTrue);
      expect(t.isPointInsidePool(0.5, -1.5), isFalse);
    });

    test('pressure query uses model — air / fluid / outside', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.trapezoid);
      final tipDy = c.tipDeltaYModel;

      c.setSensorCenter(0, Offset(3.2, 1 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);

      c.setSensorCenter(0, Offset(3.2, -1.5 - tipDy));
      final inFluid = c.model.barometers[0].value;
      expect(inFluid, isNotNull);
      expect(inFluid, closeTo(
        c.model.getPressureAtCoords(3.2, -1.5)!,
        1e-6,
      ));

      c.setSensorCenter(0, Offset(0.2, -1 - tipDy));
      expect(c.model.barometers[0].value, isNull);
    });

    test('faucet open → volume increases via clock step', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.trapezoid);
      final before = c.model.trapezoid.volume;
      c.setInputFlow(1.0);
      c.model.step(0.5);
      expect(c.model.trapezoid.volume, closeTo(before + 0.5, 1e-9));
      c.setInputFlow(0);
      c.setOutputFlow(1.0);
      final mid = c.model.trapezoid.volume;
      c.model.step(0.2);
      expect(c.model.trapezoid.volume, closeTo(mid - 0.2, 1e-9));
    });
  });

  group('Chamber mass / drop hit', () {
    test('valid drop over left opening adds to stack', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final chamber = c.model.chamber;
      final mass = chamber.masses[0];
      final lo = chamber.leftOpening;
      // Place center so massBounds overlaps drop area (source Bounds2 quirk).
      final dropY = lo.y2 + chamber.leftWaterHeight - chamber.leftDisplacement;
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset((lo.x1 + lo.x2) / 2, dropY + mass.height / 2),
      );
      expect(c.massWouldHitDropTarget(0), isTrue);
      c.endMassDrag(0);
      expect(chamber.stack.contains(mass), isTrue);
      expect(chamber.stackMass, closeTo(500, 1e-9));
    });

    test('invalid drop outside opening resets or falls', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final mass = c.model.chamber.masses[0];
      final initial = mass.position;
      c.beginMassDrag(0);
      // Far left underground-ish but above maxY fail → cannotFall may reset
      c.updateMassCenter(0, const Offset(0.2, 0.5));
      expect(c.massWouldHitDropTarget(0), isFalse);
      c.endMassDrag(0);
      // Not in stack
      expect(c.model.chamber.stack.contains(mass), isFalse);
      // Either reset to initial or falling on ground
      expect(
        mass.position == initial || mass.position.dy >= c.model.chamber.maxY,
        isTrue,
      );
    });

    test('edge hit — mass only partially over opening follows source Bounds2', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final chamber = c.model.chamber;
      final mass = chamber.masses[0];
      final lo = chamber.leftOpening;
      final dropY = lo.y2 + chamber.leftWaterHeight;
      c.beginMassDrag(0);
      // Center just left of opening so asymmetric maxX=x+width may still hit
      c.updateMassCenter(0, Offset(lo.x1 - mass.width * 0.2, dropY + mass.height / 2));
      final hit = c.massWouldHitDropTarget(0);
      // Document source behavior rather than inventing: recompute with model API
      expect(hit, mass.isInTargetDroppedArea());
      c.endMassDrag(0);
    });

    test('displacement raises right column / changes pressure', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final chamber = c.model.chamber;
      final tipDy = c.tipDeltaYModel;
      final ro = chamber.rightOpening;
      // Sensor in right opening fluid column
      c.setSensorCenter(0, Offset((ro.x1 + ro.x2) / 2, -1.0 - tipDy));
      final p0 = c.model.barometers[0].value!;

      final lo = chamber.leftOpening;
      final mass = chamber.masses[0];
      final dropY = lo.y2 + chamber.leftWaterHeight;
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset((lo.x1 + lo.x2) / 2, dropY + mass.height / 2),
      );
      c.endMassDrag(0);

      // Step until displacement settles upward
      for (var i = 0; i < 120; i++) {
        c.model.step(1 / 60);
      }
      c.refreshSensors();
      expect(chamber.leftDisplacement > 0, isTrue);
      final p1 = c.model.barometers[0].value!;
      expect(p1 > p0, isTrue);
    });

    test('remove mass → displacement returns toward 0', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final chamber = c.model.chamber;
      final lo = chamber.leftOpening;
      final mass = chamber.masses[0];
      final dropY = lo.y2 + chamber.leftWaterHeight;
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset((lo.x1 + lo.x2) / 2, dropY + mass.height / 2),
      );
      c.endMassDrag(0);
      for (var i = 0; i < 60; i++) {
        c.model.step(1 / 60);
      }
      expect(chamber.leftDisplacement > 0.01, isTrue);

      // Drag mass out of stack
      c.beginMassDrag(0);
      c.updateMassCenter(0, const Offset(1.35, 0.3));
      c.endMassDrag(0);
      for (var i = 0; i < 120; i++) {
        c.model.step(1 / 60);
      }
      expect(chamber.stack.isEmpty, isTrue);
      expect(chamber.leftDisplacement < 0.05, isTrue);
    });
  });

  group('Faucet / water', () {
    test('square input faucet dt volume delta', () {
      final c = UnderPressureController();
      final v0 = c.model.square.volume;
      c.setInputFlow(1.0);
      c.model.step(0.25);
      expect(c.model.square.volume, closeTo(v0 + 0.25, 1e-9));
    });

    test('mystery faucet uses mystery pool volume', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.mystery);
      final v0 = c.model.mystery.volume;
      c.setInputFlow(0.5);
      c.model.step(1.0);
      expect(c.model.mystery.volume, closeTo(v0 + 0.5, 1e-9));
      expect(c.model.square.volume, isNot(closeTo(c.model.mystery.volume, 1e-6)));
    });

    test('output drain stops at empty and disables', () {
      final c = UnderPressureController();
      c.model.square.setVolume(0.1);
      c.setOutputFlow(1.0);
      c.model.step(1.0);
      expect(c.model.square.volume, 0);
      expect(c.model.square.outputFaucet.enabled, isFalse);
    });
  });

  group('Mystery', () {
    test('dataset matches source choices', () {
      expect(MysteryPoolModel.fluidDensityChoices, [1700, 840, 1100]);
      expect(MysteryPoolModel.gravityChoices, [20, 14, 6.5]);
    });

    test('fluidDensity mystery applies density + color', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.mystery);
      c.setMysteryChoice('fluidDensity');
      c.setMysteryFluidIndex(1);
      expect(c.model.fluidDensity, 840);
      expect(
        c.model.fluidColorModel.color,
        MysteryPoolModel.fluidColors[1],
      );
    });

    test('gravity mystery applies gravityChoices', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.mystery);
      c.setMysteryChoice('gravity');
      c.setMysteryGravityIndex(2);
      expect(c.model.gravity, 6.5);
    });

    test('leaving mystery restores prior density/gravity', () {
      final c = UnderPressureController();
      c.setDensity(1200);
      c.setGravity(12);
      c.setScene(UnderPressureScene.mystery);
      expect(c.model.fluidDensity, isNot(1200)); // mystery overrides
      c.setScene(UnderPressureScene.square);
      expect(c.model.fluidDensity, closeTo(1200, 1e-9));
      expect(c.model.gravity, closeTo(12, 1e-9));
    });
  });

  group('Scene switching / isolation', () {
    test('rapid scene switching no crash + correct currentPool', () {
      final c = UnderPressureController();
      final order = [
        UnderPressureScene.square,
        UnderPressureScene.trapezoid,
        UnderPressureScene.chamber,
        UnderPressureScene.mystery,
        UnderPressureScene.square,
        UnderPressureScene.chamber,
        UnderPressureScene.trapezoid,
        UnderPressureScene.mystery,
      ];
      for (final s in order) {
        c.setScene(s);
        expect(c.model.currentScene, s);
        c.model.step(1 / 60);
        c.refreshSensors();
      }
    });

    test('sensor tip pressure across scenes uses current geometry', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      final center = Offset(3.2, -1.5 - tipDy);

      c.setScene(UnderPressureScene.square);
      c.setSensorCenter(0, center);
      final pSquare = c.model.barometers[0].value;

      c.setScene(UnderPressureScene.chamber);
      c.setSensorCenter(0, Offset(2.95, -1.0 - tipDy)); // left opening
      final pChamber = c.model.barometers[0].value;

      expect(pSquare, isNotNull);
      expect(pChamber, isNotNull);
      // Different geometry → different water-column contribution
      expect(pSquare == pChamber, isFalse);
    });

    testWidgets('all four scenes construct in screen', (tester) async {
      final c = UnderPressureController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 768,
              height: 504,
              child: UnderPressureScreen(controller: c),
            ),
          ),
        ),
      );
      await tester.pump();
      for (final s in UnderPressureScene.values) {
        c.setScene(s);
        await tester.pump();
        expect(find.byType(UnderPressureScreen), findsOneWidget);
      }
      c.dispose();
    });
  });

  group('Reset stress / lifecycle', () {
    test('reset clears faucet mass mystery after complex state', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.trapezoid);
      c.setInputFlow(0.8);
      c.model.step(0.5);
      c.setDensity(1300);
      c.setGravity(15);
      c.setAtmosphere(false);
      c.setGridVisible(true);
      c.setRulerVisible(true);

      c.setScene(UnderPressureScene.chamber);
      final lo = c.model.chamber.leftOpening;
      final mass = c.model.chamber.masses[0];
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset(
          (lo.x1 + lo.x2) / 2,
          lo.y2 + c.model.chamber.leftWaterHeight + mass.height / 2,
        ),
      );
      c.endMassDrag(0);

      c.setScene(UnderPressureScene.mystery);
      c.setMysteryFluidIndex(2);

      for (var i = 0; i < 10; i++) {
        c.resetAll();
        expect(c.model.currentScene, UnderPressureScene.square);
        expect(c.model.fluidDensity, 1000);
        expect(c.model.gravity, 9.8);
        expect(c.model.isAtmosphere, isTrue);
        expect(c.model.chamber.stack, isEmpty);
        expect(c.model.trapezoid.inputFaucet.flowRate, 0);
        expect(c.model.mystery.customFluidDensityIndex, 0);
      }
    });

    testWidgets('enter leave re-enter lifecycle ×3', (tester) async {
      for (var cycle = 0; cycle < 3; cycle++) {
        final c = UnderPressureController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 768,
                height: 504,
                child: UnderPressureScreen(controller: c),
              ),
            ),
          ),
        );
        await tester.pump();
        c.setScene(UnderPressureScene.chamber);
        c.setScene(UnderPressureScene.mystery);
        c.setInputFlow(0.3);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        c.dispose();
      }
    });
  });

  group('Phase 2 regression smoke', () {
    test('tip offset still applies on trapezoid', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.trapezoid);
      final tipDy = c.tipDeltaYModel;
      final center = Offset(3.2, -2.0 - tipDy);
      c.setSensorCenter(0, center);
      final tip = UpBarometerMetrics.tipFromCenter(center, c.mvt);
      expect(
        c.model.barometers[0].value,
        closeTo(c.model.getPressureAtCoords(tip.dx, tip.dy)!, 1e-6),
      );
    });
  });
}
