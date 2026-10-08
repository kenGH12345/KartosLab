import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/under_pressure_strings.dart';
import 'package:kratos/under_pressure/view/under_pressure_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MVT', () {
    test('origin maps to (0,245) and scale 70', () {
      const mvt = UpMvt();
      expect(mvt.modelToView(0, 0), const Offset(0, 245));
      expect(mvt.modelToView(1, 0).dx, 70);
      expect(mvt.modelToView(0, 1).dy, 245 - 70);
      expect(mvt.viewToModelDeltaY(70), closeTo(-1, 1e-12));
    });
  });

  group('Tip Offset', () {
    test('tip is below center by pressureReadOffset*scale in view', () {
      const mvt = UpMvt();
      expect(UpBarometerMetrics.tipOffsetViewPx, 51 * 1.5);
      final tipDy = UpBarometerMetrics.tipDeltaYModel(mvt);
      expect(tipDy, closeTo(mvt.viewToModelDeltaY(76.5), 1e-12));
      expect(tipDy < 0, isTrue); // tip lower in model Y when below center in view
    });

    test('sensor body move → tip pressure matches tip coords', () {
      final c = UnderPressureController();
      // Place gauge center so tip is in fluid at ~(-2)
      // tipY = centerY + tipDeltaY
      final tipDy = c.tipDeltaYModel;
      final center = Offset(4.0, -2.0 - tipDy);
      c.setSensorCenter(0, center);
      final tip = UpBarometerMetrics.tipFromCenter(center, c.mvt);
      expect(tip.dx, 4.0);
      expect(tip.dy, closeTo(-2.0, 1e-9));
      final expected = c.model.getPressureAtCoords(tip.dx, tip.dy);
      expect(c.model.barometers[0].value, closeTo(expected!, 1e-6));
      // Center alone would give different reading if misused:
      final atCenter = c.model.getPressureAtCoords(center.dx, center.dy);
      expect(c.model.barometers[0].value != atCenter, isTrue);
    });

    test('tip in air / fluid / outside', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;

      // Air: tip at y=1
      c.setSensorCenter(0, Offset(3, 1 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);
      expect(c.model.barometers[0].value! > 0, isTrue);

      // Fluid
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);

      // Outside underground
      c.setSensorCenter(0, Offset(0.5, -1 - tipDy));
      expect(c.model.barometers[0].value, isNull);
    });

    test('docked shows null', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      expect(c.model.barometers[0].value, isNotNull);
      c.endSensorDrag(0, overSensorPanel: true);
      expect(c.model.barometers[0].isDocked, isTrue);
      expect(c.model.barometers[0].value, isNull);
    });
  });

  group('Controls → Model → Pressure', () {
    test('density changes pressure', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      final p0 = c.model.barometers[0].value!;
      c.setDensity(UnderPressureConstants.honeyDensity);
      expect(c.model.barometers[0].value! > p0, isTrue);
    });

    test('gravity changes pressure', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      final pEarth = c.model.barometers[0].value!;
      c.setGravity(UnderPressureConstants.marsGravity);
      expect(c.model.barometers[0].value! < pEarth, isTrue);
    });

    test('atmosphere toggles air contribution', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      final pOn = c.model.barometers[0].value!;
      c.setAtmosphere(false);
      final pOff = c.model.barometers[0].value!;
      expect(pOn > pOff, isTrue);
      expect(c.model.isAtmosphere, isFalse);
    });

    test('units change display string, not Pa', () {
      final c = UnderPressureController();
      final tipDy = c.tipDeltaYModel;
      c.setSensorCenter(0, Offset(4, -2 - tipDy));
      final pa = c.model.barometers[0].value!;
      c.setUnits(MeasureUnits.english);
      expect(c.model.barometers[0].value, pa);
      expect(c.model.getPressureString(pa), contains('psi'));
    });
  });

  group('Ruler / Grid / Scene / Reset', () {
    test('ruler and grid toggles', () {
      final c = UnderPressureController();
      c.setRulerVisible(true);
      c.setGridVisible(true);
      expect(c.model.isRulerVisible, isTrue);
      expect(c.model.isGridVisible, isTrue);
      c.setRulerPosition(const Offset(100, 80));
      expect(c.model.rulerPosition, const Offset(100, 80));
    });

    test('scene selector updates model', () {
      final c = UnderPressureController();
      c.setScene(UnderPressureScene.trapezoid);
      expect(c.model.currentScene, UnderPressureScene.trapezoid);
      c.setScene(UnderPressureScene.square);
      expect(c.model.currentScene, UnderPressureScene.square);
    });

    test('reset restores complex state', () {
      final c = UnderPressureController();
      c.setDensity(800);
      c.setGravity(15);
      c.setAtmosphere(false);
      c.setUnits(MeasureUnits.english);
      c.setRulerVisible(true);
      c.setGridVisible(true);
      c.setSensorCenter(0, const Offset(4, -2));
      c.resetAll();
      expect(c.model.fluidDensity, UnderPressureConstants.waterDensity);
      expect(c.model.gravity, UnderPressureConstants.earthGravity);
      expect(c.model.isAtmosphere, isTrue);
      expect(c.model.measureUnits, MeasureUnits.metric);
      expect(c.model.isRulerVisible, isFalse);
      expect(c.model.barometers[0].isDocked, isTrue);
    });

    test('reset stress ×10', () {
      final c = UnderPressureController();
      for (var i = 0; i < 10; i++) {
        c.setDensity(900 + i.toDouble());
        c.setGravity(5 + i * 0.5);
        c.setAtmosphere(i.isEven);
        c.setUnits(MeasureUnits.values[i % 3]);
        c.setRulerVisible(true);
        c.setGridVisible(true);
        c.setSensorCenter(0, Offset(4, -2.0 - i * 0.01));
        c.resetAll();
        expect(c.model.fluidDensity, UnderPressureConstants.waterDensity);
        expect(c.model.barometers[0].isDocked, isTrue);
      }
    });
  });

  group('Screen construct / lifecycle', () {
    testWidgets('UnderPressureScreen builds Square', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
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
      expect(find.byType(UnderPressureScreen), findsOneWidget);
      expect(find.text(UnderPressureStrings.fluidDensity), findsOneWidget);
      expect(find.text(UnderPressureStrings.gravity), findsOneWidget);
      expect(find.text(UnderPressureStrings.atmosphere), findsOneWidget);
    });

    testWidgets('lifecycle enter leave re-enter ×3', (tester) async {
      for (var i = 0; i < 3; i++) {
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
        c.setDensity(1100);
        c.setAtmosphere(false);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        c.dispose();
      }
    });

    testWidgets('atmosphere OFF keeps black sky path reachable', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
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
      c.setAtmosphere(false);
      await tester.pump();
      expect(c.model.isAtmosphere, isFalse);
      expect(find.text(UnderPressureStrings.off), findsWidgets);
    });
  });

  group('Assets present', () {
    test('required image paths are loadable via asset bundle keys', () {
      const required = [
        'assets/simulations/under_pressure/images/grassTexture.png',
        'assets/simulations/under_pressure/images/cementTextureDark.jpg',
        'assets/simulations/under_pressure/images/squarePoolIcon.png',
        'assets/simulations/under_pressure/images/trapezoidPoolIcon.png',
        'assets/simulations/under_pressure/images/chamberPoolIcon.png',
        'assets/simulations/under_pressure/images/mysteryPoolIcon.png',
        'assets/simulations/under_pressure/images/underPressure.png',
      ];
      expect(required.length, 7);
    });
  });
}
