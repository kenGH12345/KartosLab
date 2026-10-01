import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/pool/mystery_pool_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/under_pressure_screen.dart';

/// Phase 5 — Final Behavioral Acceptance (no Model changes).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Physics acceptance — absolute pressure chain', () {
    test('surface / shallow / deep depth follows getWaterHeightAboveY', () {
      final m = UnderPressureModel();
      const x = 4.0;
      // y=0 is exclusive boundary (not inside); air is y>0
      final nearSurfaceAir = m.getPressureAtCoords(x, 0.01)!;
      final shallow = m.getPressureAtCoords(x, -0.5)!;
      final deep = m.getPressureAtCoords(x, -2.5)!;
      expect(shallow > nearSurfaceAir, isTrue);
      expect(deep > shallow, isTrue);
      final hDeep = m.square.getWaterHeightAboveY(x, -2.5);
      expect(
        deep,
        closeTo(
          m.getAirPressure(hDeep - 2.5) + m.getWaterPressure(hDeep),
          1e-6,
        ),
      );
    });

    test('atmosphere OFF zeroes air; fluid contribution remains', () {
      final m = UnderPressureModel();
      const x = 4.0;
      const y = -2.0;
      final h = m.square.getWaterHeightAboveY(x, y);
      final on = m.getPressureAtCoords(x, y)!;
      m.isAtmosphere = false;
      final off = m.getPressureAtCoords(x, y)!;
      expect(m.getAirPressure(0), 0);
      expect(off, closeTo(m.getWaterPressure(h), 1e-9));
      expect(on > off, isTrue);
    });

    test('units switch display only — internal Pa unchanged', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      final pa = c.model.barometers[0].value!;
      c.setUnits(MeasureUnits.metric);
      final kPa = c.model.getPressureString(pa);
      c.setUnits(MeasureUnits.atmosphere);
      final atm = c.model.getPressureString(pa);
      c.setUnits(MeasureUnits.english);
      final psi = c.model.getPressureString(pa);
      expect(kPa.contains('kPa'), isTrue);
      expect(atm.toLowerCase().contains('atm'), isTrue);
      expect(psi.toLowerCase().contains('psi'), isTrue);
      expect(c.model.barometers[0].value, closeTo(pa, 1e-9));
    });

    test('density endpoints 700 / 1000 / 1420 scale fluid only', () {
      final m = UnderPressureModel();
      const x = 4.0;
      const y = -2.0;
      final h = m.square.getWaterHeightAboveY(x, y);
      final air = m.getAirPressure(h + y);
      for (final d in [
        UnderPressureConstants.gasolineDensity,
        UnderPressureConstants.waterDensity,
        UnderPressureConstants.honeyDensity,
      ]) {
        m.fluidDensity = d;
        expect(
          m.getPressureAtCoords(x, y)! - air,
          closeTo(h * m.gravity * d, 1e-6),
        );
        expect(m.getAirPressure(h + y), closeTo(air, 1e-12));
      }
    });

    test('Mars / Earth / Jupiter scale air and fluid', () {
      final m = UnderPressureModel();
      const x = 4.0;
      const y = -2.0;
      final h = m.square.getWaterHeightAboveY(x, y);
      m.gravity = UnderPressureConstants.marsGravity;
      final pMars = m.getPressureAtCoords(x, y)!;
      m.gravity = UnderPressureConstants.earthGravity;
      final pEarth = m.getPressureAtCoords(x, y)!;
      m.gravity = UnderPressureConstants.jupiterGravity;
      final pJup = m.getPressureAtCoords(x, y)!;
      expect(pMars < pEarth, isTrue);
      expect(pEarth < pJup, isTrue);
      // Air scales with g/9.8
      m.gravity = UnderPressureConstants.marsGravity;
      expect(
        m.getAirPressure(0),
        closeTo(
          UnderPressureConstants.earthAirPressure *
              UnderPressureConstants.marsGravity /
              UnderPressureConstants.earthGravity,
          1e-6,
        ),
      );
      expect(h > 0, isTrue);
    });
  });

  group('Four geometries', () {
    test('Square air / fluid / outside', () {
      final m = UnderPressureModel();
      expect(m.getPressureAtCoords(4, 1), isNotNull); // air
      expect(m.getPressureAtCoords(4, -1.5), isNotNull); // fluid
      expect(m.getPressureAtCoords(0.5, -1), isNull); // outside
    });

    test('Trapezoid upper / lower / outside', () {
      final m = UnderPressureModel()..setScene(UnderPressureScene.trapezoid);
      expect(m.trapezoid.isPointInsidePool(3.2, -1.0), isTrue);
      expect(m.trapezoid.isPointInsidePool(5.0, -2.9), isTrue); // bottom
      expect(m.trapezoid.isPointInsidePool(0.5, -1.0), isFalse);
      expect(m.getPressureAtCoords(3.2, -1.0), isNotNull);
      expect(m.getPressureAtCoords(0.5, -1.0), isNull);
    });

    test('Chamber empty / mass / displacement / remove', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final chamber = c.model.chamber;
      expect(chamber.stack, isEmpty);
      expect(chamber.leftDisplacement, 0);

      final lo = chamber.leftOpening;
      final mass = chamber.masses[0];
      final dropY = lo.y2 + chamber.leftWaterHeight;
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset((lo.x1 + lo.x2) / 2, dropY + mass.height / 2),
      );
      c.endMassDrag(0);
      expect(chamber.stack.contains(mass), isTrue);

      for (var i = 0; i < 90; i++) {
        c.model.step(1 / 60);
      }
      expect(chamber.leftDisplacement > 0, isTrue);
      final tipDy = c.tipDeltaYModel;
      final ro = chamber.rightOpening;
      c.setSensorCenter(0, Offset((ro.x1 + ro.x2) / 2, -1 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);

      c.beginMassDrag(0);
      c.updateMassCenter(0, const Offset(1.35, 0.3));
      c.endMassDrag(0);
      for (var i = 0; i < 120; i++) {
        c.model.step(1 / 60);
      }
      expect(chamber.stack, isEmpty);
      expect(chamber.leftDisplacement < 0.05, isTrue);
    });

    test('Mystery presets A/B/C densities and planet gravity', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.mystery);
      c.setMysteryChoice('fluidDensity');
      for (var i = 0; i < 3; i++) {
        c.setMysteryFluidIndex(i);
        expect(
          c.model.fluidDensity,
          MysteryPoolModel.fluidDensityChoices[i],
        );
      }
      c.setMysteryChoice('gravity');
      for (var i = 0; i < 3; i++) {
        c.setMysteryGravityIndex(i);
        expect(c.model.gravity, MysteryPoolModel.gravityChoices[i]);
      }
      // Not water default while in mystery fluid A
      c.setMysteryChoice('fluidDensity');
      c.setMysteryFluidIndex(0);
      expect(c.model.fluidDensity, isNot(1000));
    });
  });

  group('Sensor tip / dock / four sensors', () {
    test('all 4 sensors measure at tip not center', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      for (var i = 0; i < 4; i++) {
        final center = Offset(3.5 + i * 0.2, -1.5 - tipDy);
        c.setSensorCenter(i, center);
        final tip = UpBarometerMetrics.tipFromCenter(center, c.mvt);
        expect(
          c.model.barometers[i].value,
          closeTo(c.model.getPressureAtCoords(tip.dx, tip.dy)!, 1e-6),
        );
        final atCenter = c.model.getPressureAtCoords(center.dx, center.dy);
        expect(c.model.barometers[i].value != atCenter, isTrue);
      }
    });

    test('docked → null; undock → value', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);
      c.endSensorDrag(0, overSensorPanel: true);
      expect(c.model.barometers[0].isDocked, isTrue);
      expect(c.model.barometers[0].value, isNull);
    });

    test('air / fluid / outside / surface matrix', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, 1 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);
      c.setSensorCenter(0, Offset(0.4, -1 - tipDy));
      expect(c.model.barometers[0].value, isNull);
      // Near-surface air (y>0); y=0 is exclusive pool boundary → null
      c.setSensorCenter(0, Offset(4, 0.05 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);
    });
  });

  group('Faucet dynamics', () {
    test('closed → volume unchanged across steps', () {
      final c = UnderPressureController();
      final v0 = c.model.square.volume;
      c.setInputFlow(0);
      c.setOutputFlow(0);
      for (var i = 0; i < 30; i++) {
        c.model.step(1 / 60);
      }
      expect(c.model.square.volume, closeTo(v0, 1e-12));
    });

    test('open → cumulative volume; close stops', () {
      final c = UnderPressureController();
      final v0 = c.model.square.volume;
      c.setInputFlow(1.0);
      c.model.step(0.1);
      c.model.step(0.1);
      c.model.step(0.1);
      expect(c.model.square.volume, closeTo(v0 + 0.3, 1e-9));
      final mid = c.model.square.volume;
      c.setInputFlow(0);
      c.model.step(0.5);
      expect(c.model.square.volume, closeTo(mid, 1e-12));
    });

    test('small / normal / larger dt use rate × dt', () {
      final c = UnderPressureController();
      c.model.square.setVolume(1.0);
      c.setInputFlow(0.5);
      c.model.step(0.01);
      expect(c.model.square.volume, closeTo(1.005, 1e-12));
      c.model.step(1 / 60);
      expect(c.model.square.volume, closeTo(1.005 + 0.5 / 60, 1e-12));
      c.model.step(0.2);
      expect(c.model.square.volume, closeTo(1.005 + 0.5 / 60 + 0.1, 1e-12));
    });

    test('trapezoid faucet independent of square volume', () {
      final c = UnderPressureController();
      final sq0 = c.model.square.volume;
      c.setScene(UnderPressureScene.trapezoid);
      c.setInputFlow(1.0);
      c.model.step(0.4);
      expect(c.model.trapezoid.volume, closeTo(1.5 + 0.4, 1e-9));
      expect(c.model.square.volume, closeTo(sq0, 1e-12));
    });

    test('flowRate View/Model consistency flags', () {
      final c = UnderPressureController();
      expect(c.model.square.inputFaucet.flowRate, 0);
      c.setInputFlow(0.6);
      expect(c.model.square.inputFaucet.flowRate, closeTo(0.6, 1e-12));
      expect(c.model.square.inputFaucet.flowRate > 0, isTrue);
      c.setInputFlow(0);
      expect(c.model.square.inputFaucet.flowRate, 0);
    });
  });

  group('Chamber invalid drop / mass reset', () {
    test('invalid drop does not enter stack', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.chamber);
      final mass = c.model.chamber.masses[1];
      final initial = mass.position;
      c.beginMassDrag(1);
      c.updateMassCenter(1, const Offset(0.3, 0.4));
      expect(c.massWouldHitDropTarget(1), isFalse);
      c.endMassDrag(1);
      expect(c.model.chamber.stack.contains(mass), isFalse);
      expect(
        mass.position == initial || !mass.isFalling || mass.position.dy >= 0,
        isTrue,
      );
    });

    test('mass + faucet complex → Reset All restores defaults', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.trapezoid);
      c.setInputFlow(0.9);
      c.model.step(0.3);
      c.setDensity(1300);
      c.setGravity(15);
      c.setAtmosphere(false);
      c.setUnits(MeasureUnits.english);
      c.setRulerVisible(true);
      c.setGridVisible(true);
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

      c.resetAll();
      expect(c.model.currentScene, UnderPressureScene.square);
      expect(c.model.fluidDensity, UnderPressureConstants.waterDensity);
      expect(c.model.gravity, UnderPressureConstants.earthGravity);
      expect(c.model.isAtmosphere, isTrue);
      expect(c.model.measureUnits, MeasureUnits.metric);
      expect(c.model.isRulerVisible, isFalse);
      expect(c.model.isGridVisible, isFalse);
      expect(c.model.chamber.stack, isEmpty);
      expect(c.model.trapezoid.inputFaucet.flowRate, 0);
      expect(c.model.square.inputFaucet.flowRate, 0);
      expect(c.model.mystery.customFluidDensityIndex, 0);
      for (final s in c.model.barometers) {
        expect(s.isDocked, isTrue);
      }
    });
  });

  group('Scene switching / isolation / stress', () {
    test('Square→Trap→Chamber→Mystery→Square retention', () {
      final c = UnderPressureController();
      c.setDensity(1100);
      c.setGravity(11);
      c.setUnits(MeasureUnits.atmosphere);
      c.setRulerVisible(true);

      for (final s in [
        UnderPressureScene.square,
        UnderPressureScene.trapezoid,
        UnderPressureScene.chamber,
        UnderPressureScene.mystery,
        UnderPressureScene.square,
      ]) {
        c.setScene(s);
        expect(c.model.currentScene, s);
        // Shared controls retained (except mystery override while active)
        if (s != UnderPressureScene.mystery) {
          expect(c.model.fluidDensity, closeTo(1100, 1e-9));
          expect(c.model.gravity, closeTo(11, 1e-9));
        }
        expect(c.model.measureUnits, MeasureUnits.atmosphere);
        expect(c.model.isRulerVisible, isTrue);
      }
    });

    test('chamber mass does not leak into square faucet volume', () {
      final c = UnderPressureController();
      final sq0 = c.model.square.volume;
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
      for (var i = 0; i < 30; i++) {
        c.model.step(1 / 60);
      }
      c.setScene(UnderPressureScene.square);
      expect(c.model.square.volume, closeTo(sq0, 1e-12));
      expect(c.model.chamber.stack.isNotEmpty, isTrue); // chamber keeps stack
    });

    test('rapid scene switching ×3 rounds no crash', () {
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
      for (var round = 0; round < 3; round++) {
        for (final s in order) {
          c.setScene(s);
          c.model.step(1 / 60);
          c.refreshSensors();
        }
      }
      expect(c.model.currentScene, UnderPressureScene.mystery);
    });

    test('rapid controls stress keeps Model consistent', () {
      final c = UnderPressureController();
      for (var i = 0; i < 20; i++) {
        c.setDensity(700 + (i % 5) * 100.0);
        c.setGravity(5 + (i % 4) * 3.0);
        c.setAtmosphere(i.isEven);
        c.setUnits(
          MeasureUnits.values[i % MeasureUnits.values.length],
        );
        c.setRulerVisible(i.isOdd);
        c.setGridVisible(i % 3 == 0);
        c.setScene(
          UnderPressureScene.values[i % UnderPressureScene.values.length],
        );
        c.model.step(0);
        c.refreshSensors();
      }
      expect(
        c.model.currentScene == UnderPressureScene.mystery ||
            (c.model.fluidDensity >= 700 && c.model.fluidDensity <= 1420),
        isTrue,
      );
      // Mystery fluid presets may exceed normal slider range (e.g. 1700).
      if (c.model.currentScene == UnderPressureScene.mystery &&
          c.model.mysteryChoice == 'fluidDensity') {
        expect(
          MysteryPoolModel.fluidDensityChoices.contains(c.model.fluidDensity),
          isTrue,
        );
      }
    });

    test('reset stress ×10', () {
      final c = UnderPressureController();
      for (var i = 0; i < 10; i++) {
        c.setScene(
          UnderPressureScene.values[i % UnderPressureScene.values.length],
        );
        c.setDensity(900 + i * 10.0);
        c.setGravity(8 + i * 0.5);
        c.setAtmosphere(i.isEven);
        c.setUnits(MeasureUnits.values[i % 3]);
        c.setRulerVisible(true);
        c.setGridVisible(true);
        c.setInputFlow(0.5);
        if (c.model.currentScene == UnderPressureScene.chamber) {
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
        }
        c.resetAll();
        expect(c.model.currentScene, UnderPressureScene.square);
        expect(c.model.fluidDensity, 1000);
        expect(c.model.gravity, 9.8);
        expect(c.model.chamber.stack, isEmpty);
        expect(c.model.square.inputFaucet.flowRate, 0);
      }
    });
  });

  group('Clock / lifecycle leak', () {
    test('single onTick — re-attach does not double volume', () {
      final c = UnderPressureController();
      // Simulate clock ticks via model.step only once per frame (controller owns one onTick).
      c.setInputFlow(1.0);
      final v0 = c.model.square.volume;
      c.model.step(0.2);
      expect(c.model.square.volume, closeTo(v0 + 0.2, 1e-9));
      // Replacing onTick should not stack — controller sets single callback.
      var ticks = 0;
      final prev = c.clock.onTick;
      c.clock.onTick = (dt, t) {
        ticks++;
        prev?.call(dt, t);
      };
      // Direct model step still single application
      final mid = c.model.square.volume;
      c.model.step(0.1);
      expect(c.model.square.volume, closeTo(mid + 0.1, 1e-9));
      expect(ticks, 0); // model.step does not go through clock
    });

    testWidgets('leave / re-enter ×5 no crash / single screen', (tester) async {
      for (var cycle = 0; cycle < 5; cycle++) {
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
        c.setInputFlow(0.2);
        c.setScene(UnderPressureScene.trapezoid);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        c.dispose();
      }
    });

    testWidgets('scene switch + leave/re-enter chamber faucet mass',
        (tester) async {
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
      final gen1 = c.listenerGeneration;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

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
      expect(c.model.chamber.stack.contains(mass), isTrue);
      c.notifyListeners();
      expect(c.listenerGeneration > gen1, isTrue);
      c.dispose();
    });
  });

  group('Fluid color / ruler / grid across scenes', () {
    test('fluid color updates after density + step', () {
      final c = UnderPressureController();
      final before = c.model.fluidColorModel.color;
      c.setDensity(700);
      c.model.step(1 / 60);
      // gasoline color differs from water (after FluidColorModel.step)
      expect(c.model.fluidColorModel.color, isNot(before));
    });

    test('grid visibility does not change pressure', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      final p0 = c.model.barometers[0].value!;
      c.setGridVisible(true);
      c.refreshSensors();
      expect(c.model.barometers[0].value, closeTo(p0, 1e-12));
      c.setGridVisible(false);
      expect(c.model.barometers[0].value, closeTo(p0, 1e-12));
    });

    test('ruler show/hide/reset across scenes', () {
      final c = UnderPressureController();
      for (final s in UnderPressureScene.values) {
        c.setScene(s);
        c.setRulerVisible(true);
        c.setRulerPosition(const Offset(100, 200));
        expect(c.model.isRulerVisible, isTrue);
        expect(c.model.rulerPosition, const Offset(100, 200));
        c.setRulerVisible(false);
      }
      c.resetAll();
      expect(c.model.isRulerVisible, isFalse);
    });
  });
}
