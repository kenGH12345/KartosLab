import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/under_pressure/model/fluid/fluid_color_model.dart';
import 'package:kratos/under_pressure/model/pool/chamber_pool_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_math.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';

/// Physics Oracle A–H + Chamber / Faucet / Geometry — source-faithful.
void main() {
  group('Oracle A — Basic absolute pressure', () {
    test('square fluid tip matches air(surface) + ρgh, not plain ρgh', () {
      final m = UnderPressureModel();
      const tipX = 4.0;
      const tipY = -2.0;
      final waterHeight = m.square.getWaterHeightAboveY(tipX, tipY);
      expect(waterHeight, closeTo(0.5, 1e-12));

      final expected = m.getAirPressure(waterHeight + tipY) +
          m.getWaterPressure(waterHeight);
      expect(m.getPressureAtCoords(tipX, tipY), closeTo(expected, 1e-9));
      expect(
        m.getPressureAtCoords(tipX, tipY)! > m.getWaterPressure(waterHeight),
        isTrue,
      );
    });

    test('standard air pressure endpoints and ground air', () {
      final m = UnderPressureModel();
      expect(
        UnderPressureModel.getStandardAirPressure(0),
        UnderPressureConstants.earthAirPressure,
      );
      expect(
        UnderPressureModel.getStandardAirPressure(150),
        UnderPressureConstants.earthAirPressureAt500Ft,
      );
      expect(
        m.getAirPressure(0),
        closeTo(UnderPressureConstants.earthAirPressure, 1e-9),
      );
    });
  });

  group('Oracle B — Density variation', () {
    test('fluid scales with density; air contribution unchanged', () {
      final m = UnderPressureModel();
      const tipX = 4.0;
      const tipY = -2.0;
      final h = m.square.getWaterHeightAboveY(tipX, tipY);
      final air = m.getAirPressure(h + tipY);

      m.fluidDensity = UnderPressureConstants.gasolineDensity;
      final pGas = m.getPressureAtCoords(tipX, tipY)!;
      m.fluidDensity = UnderPressureConstants.honeyDensity;
      final pHoney = m.getPressureAtCoords(tipX, tipY)!;

      expect(
        pHoney - air,
        closeTo(h * m.gravity * UnderPressureConstants.honeyDensity, 1e-6),
      );
      expect(
        pGas - air,
        closeTo(h * m.gravity * UnderPressureConstants.gasolineDensity, 1e-6),
      );
      expect(pHoney > pGas, isTrue);
      expect(m.getAirPressure(h + tipY), closeTo(air, 1e-12));
    });
  });

  group('Oracle C — Gravity variation', () {
    test('Mars / Earth / Jupiter scale fluid and air', () {
      final m = UnderPressureModel();
      const tipX = 4.0;
      const tipY = -2.0;
      final h = m.square.getWaterHeightAboveY(tipX, tipY);

      double pressureAt(double g) {
        m.gravity = g;
        return m.getPressureAtCoords(tipX, tipY)!;
      }

      final pMars = pressureAt(UnderPressureConstants.marsGravity);
      final pEarth = pressureAt(UnderPressureConstants.earthGravity);
      final pJupiter = pressureAt(UnderPressureConstants.jupiterGravity);

      expect(pMars < pEarth, isTrue);
      expect(pEarth < pJupiter, isTrue);

      m.gravity = UnderPressureConstants.marsGravity;
      expect(
        m.getAirPressure(h + tipY),
        closeTo(
          UnderPressureModel.getStandardAirPressure(h + tipY) *
              UnderPressureConstants.marsGravity /
              UnderPressureConstants.earthGravity,
          1e-6,
        ),
      );
    });
  });

  group('Oracle D — Depth / waterHeight', () {
    test('surface / shallow / deep follow getWaterHeightAboveY', () {
      final m = UnderPressureModel();
      expect(m.square.getWaterHeightAboveY(4, -1.5), closeTo(0, 1e-12));
      expect(
        m.getPressureAtCoords(4, -1.5),
        closeTo(m.getAirPressure(-1.5), 1e-9),
      );

      expect(m.square.getWaterHeightAboveY(4, -2.0), closeTo(0.5, 1e-12));
      // Bottom wall is y=-3 with exclusive bound (source: y > y2).
      expect(m.square.getWaterHeightAboveY(4, -2.9), closeTo(1.4, 1e-12));

      final pShallow = m.getPressureAtCoords(4, -2.0)!;
      final pDeep = m.getPressureAtCoords(4, -2.9)!;
      expect(pDeep > pShallow, isTrue);
      expect(m.getPressureAtCoords(4, -3.0), isNull); // on/outside bottom
    });
  });

  group('Oracle E — Atmosphere ON/OFF', () {
    test('OFF zeroes air; fluid contribution remains', () {
      final m = UnderPressureModel();
      const tipX = 4.0;
      const tipY = -2.0;
      final h = m.square.getWaterHeightAboveY(tipX, tipY);
      final pOn = m.getPressureAtCoords(tipX, tipY)!;
      final air = m.getAirPressure(h + tipY);

      m.isAtmosphere = false;
      final pOff = m.getPressureAtCoords(tipX, tipY)!;
      expect(m.getAirPressure(0), 0);
      expect(pOff, closeTo(m.getWaterPressure(h), 1e-9));
      expect(pOn - pOff, closeTo(air, 1e-6));
    });

    test('above ground reports air when ON, zero when OFF', () {
      final m = UnderPressureModel();
      expect(m.getPressureAtCoords(3, 1.0), closeTo(m.getAirPressure(1.0), 1e-9));
      m.isAtmosphere = false;
      expect(m.getPressureAtCoords(3, 1.0), 0);
    });
  });

  group('Oracle F — Units', () {
    test('same Pa → kPa / atm / psi with source constants', () {
      const pa = 101325.0;
      expect(UnderPressureUnits.pascalsToKPa(pa), closeTo(101.325, 1e-12));
      expect(
        UnderPressureUnits.pascalsToAtm(pa),
        closeTo(pa * UnderPressureUnits.atmospherePerPascal, 1e-15),
      );
      expect(
        UnderPressureUnits.pascalsToPsi(pa),
        closeTo(pa * UnderPressureUnits.psiPerPascal, 1e-15),
      );

      final metric =
          UnderPressureUnits.getPressureString(pa, MeasureUnits.metric);
      final atm =
          UnderPressureUnits.getPressureString(pa, MeasureUnits.atmosphere);
      final eng =
          UnderPressureUnits.getPressureString(pa, MeasureUnits.english);
      expect(metric, contains('kPa'));
      expect(atm, contains('atm'));
      expect(eng, contains('psi'));
      expect(metric, contains(UnderPressureMath.toFixed(101.325, 3)));
    });

    test('density / gravity display formatting', () {
      final m = UnderPressureModel();
      expect(m.getFluidDensityString(), contains('1000'));
      expect(m.getGravityString(), contains('9.8'));
      m.measureUnits = MeasureUnits.english;
      expect(m.getGravityString(), contains('ft/s'));
    });
  });

  group('Oracle G — Gauge / sensor positions', () {
    test('docked → null; air / fluid / outside', () {
      final m = UnderPressureModel();
      final s = m.barometers.first;
      expect(s.isDocked, isTrue);
      m.refreshSensorValues();
      expect(s.value, isNull);

      s.position = const Offset(3, 1.0);
      m.refreshSensorValues();
      expect(s.value, closeTo(m.getAirPressure(1.0), 1e-9));

      s.position = const Offset(4, -2.0);
      m.refreshSensorValues();
      expect(s.value, closeTo(m.getPressureAtCoords(4, -2)!, 1e-9));

      s.position = const Offset(0.5, -1.0);
      m.refreshSensorValues();
      expect(s.value, isNull);
      expect(m.getPressureAtCoords(0.5, -1.0), isNull);
    });

    test('four barometers exist', () {
      final m = UnderPressureModel();
      expect(m.barometers.length, UnderPressureConstants.numBarometers);
    });
  });

  group('Oracle H — Reset', () {
    test('complex state returns to defaults', () {
      final m = UnderPressureModel();
      m.fluidDensity = 800;
      m.gravity = 15;
      m.isAtmosphere = false;
      m.measureUnits = MeasureUnits.english;
      m.isRulerVisible = true;
      m.isGridVisible = true;
      m.rulerPosition = const Offset(10, 20);
      m.setScene(UnderPressureScene.trapezoid);
      m.square.inputFaucet.flowRate = 0.5;
      m.square.setVolume(2.5);
      m.barometers.first.position = const Offset(4, -2);
      m.setMysteryChoice('gravity');
      m.mystery.setCustomGravityIndex(2);

      m.reset();

      expect(m.fluidDensity, UnderPressureConstants.waterDensity);
      expect(m.gravity, UnderPressureConstants.earthGravity);
      expect(m.isAtmosphere, isTrue);
      expect(m.measureUnits, MeasureUnits.metric);
      expect(m.isRulerVisible, isFalse);
      expect(m.isGridVisible, isFalse);
      expect(m.currentScene, UnderPressureScene.square);
      expect(m.mysteryChoice, 'fluidDensity');
      expect(m.square.volume, 1.5);
      expect(m.barometers.first.isDocked, isTrue);
      expect(m.barometers.first.value, isNull);
      expect(
        m.fluidColorModel.color.toARGB32(),
        FluidColorModel.waterColor.toARGB32(),
      );
    });
  });

  group('Faucet Oracle', () {
    test('F1 closed: volume unchanged', () {
      final m = UnderPressureModel();
      final v0 = m.square.volume;
      m.square.inputFaucet.flowRate = 0;
      m.step(1.0);
      expect(m.square.volume, v0);
    });

    test('F2–F4 open / step / close', () {
      final m = UnderPressureModel();
      m.square.inputFaucet.flowRate = 0.5;
      m.step(1.0);
      expect(m.square.volume, closeTo(2.0, 1e-12));
      m.square.inputFaucet.flowRate = 0;
      m.step(1.0);
      expect(m.square.volume, closeTo(2.0, 1e-12));
      m.square.outputFaucet.flowRate = 0.25;
      m.step(2.0);
      expect(m.square.volume, closeTo(1.5, 1e-12));
    });

    test('F5 reset faucets and volume', () {
      final m = UnderPressureModel();
      m.square.inputFaucet.flowRate = 1;
      m.square.setVolume(2.9);
      m.square.reset();
      expect(m.square.volume, 1.5);
      expect(m.square.inputFaucet.flowRate, 0);
    });

    test('full tank disables input faucet', () {
      final m = UnderPressureModel();
      m.square.setVolume(m.square.maxVolume);
      expect(m.square.inputFaucet.enabled, isFalse);
      expect(m.square.inputFaucet.flowRate, 0);
    });
  });

  group('Chamber Oracle', () {
    test('C1–C2 stack placement updates stackMass', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.chamber);
      final mass = m.chamber.masses.first;
      mass.position = Offset(
        (m.chamber.leftOpening.x1 + m.chamber.leftOpening.x2) / 2,
        m.chamber.leftOpening.y2 + m.chamber.leftWaterHeight + 0.1,
      );
      mass.setDragging(true);
      mass.setDragging(false);
      expect(m.chamber.stack.contains(mass), isTrue);
      expect(m.chamber.stackMass, 500);
    });

    test('C3–C5 displacement affects waterHeight / pressure', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.chamber);
      final tipX =
          (m.chamber.rightOpening.x1 + m.chamber.rightOpening.x2) / 2;
      const tipY = -2.0;
      final h0 = m.chamber.getWaterHeightAboveY(tipX, tipY);
      final p0 = m.getPressureAtCoords(tipX, tipY)!;

      m.chamber.leftDisplacement = 0.2;
      final h1 = m.chamber.getWaterHeightAboveY(tipX, tipY);
      final p1 = m.getPressureAtCoords(tipX, tipY)!;
      expect(h1 > h0, isTrue);
      expect(p1 > p0, isTrue);
    });

    test('C6 chamber reset clears stack and displacement', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.chamber);
      m.chamber.leftDisplacement = 0.3;
      m.chamber.pushToStack(m.chamber.masses.first);
      m.chamber.reset();
      expect(m.chamber.stack, isEmpty);
      expect(m.chamber.leftDisplacement, 0);
      expect(m.chamber.stackMass, 0);
    });

    test('mass falling step settles on ground', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.chamber);
      final mass = m.chamber.masses[1];
      mass.isFalling = true;
      mass.velocity = -0.1;
      for (var i = 0; i < 120; i++) {
        m.step(1 / 60);
      }
      expect(
        mass.position.dy,
        greaterThanOrEqualTo(m.chamber.maxY + mass.height / 2 - 1e-9),
      );
    });
  });

  group('Geometry Oracle', () {
    test('Square inside / outside / air pocket', () {
      final m = UnderPressureModel();
      expect(m.square.isPointInsidePool(4, -1), isTrue);
      expect(m.square.isPointInsidePool(0, -1), isFalse);
      expect(
        m.getPressureAtCoords(4, -0.5),
        closeTo(m.getAirPressure(-0.5), 1e-9),
      );
    });

    test('Trapezoid geometry not a rectangle', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.trapezoid);
      expect(m.trapezoid.isPointInsidePool(3.2, -0.1), isTrue);
      expect(m.trapezoid.isPointInsidePool(1.0, -0.1), isFalse);
      expect(m.trapezoid.isPointInsidePool(5.0, -2.95), isTrue);
      // Left chamber column (not a simple rectangle bounding box).
      expect(m.getPressureAtCoords(3.2, -2.0), isNotNull);
      expect(m.getPressureAtCoords(5.0, -2.9), isNotNull); // bottom connector
    });

    test('Chamber regions', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.chamber);
      expect(m.chamber.isPointInsidePool(2.5, -2.5), isTrue);
      expect(m.chamber.isPointInsidePool(0.1, -1), isFalse);
      expect(m.getPressureAtCoords(2.5, -2.5), isNotNull);
    });

    test('Mystery uses square geometry + preset density', () {
      final m = UnderPressureModel();
      final gBefore = m.gravity;
      final dBefore = m.fluidDensity;
      m.setScene(UnderPressureScene.mystery);
      expect(m.mystery.isPointInsidePool(4, -2), isTrue);
      expect(m.fluidDensity, 1700);
      m.setScene(UnderPressureScene.square);
      expect(m.gravity, gBefore);
      expect(m.fluidDensity, dBefore);
    });

    test('Mystery planet presets', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.mystery);
      m.setMysteryChoice('gravity');
      m.mystery.setCustomGravityIndex(0);
      expect(m.gravity, 20);
      m.mystery.setCustomGravityIndex(2);
      expect(m.gravity, 6.5);
    });
  });

  group('FluidColor + step', () {
    test('color updates on density change after step', () {
      final m = UnderPressureModel();
      m.fluidDensity = UnderPressureConstants.gasolineDensity;
      m.step(0);
      expect(
        m.fluidColorModel.color.toARGB32(),
        isNot(FluidColorModel.waterColor.toARGB32()),
      );
    });
  });

  group('Air pressure linear map', () {
    test('midpoint between 0 and 150 m', () {
      final mid = UnderPressureModel.getStandardAirPressure(75);
      final expected = UnderPressureMath.linear(
        0,
        150,
        UnderPressureConstants.earthAirPressure,
        UnderPressureConstants.earthAirPressureAt500Ft,
        75,
      );
      expect(mid, closeTo(expected, 1e-9));
    });
  });

  group('Ruler / Grid state', () {
    test('defaults and reset', () {
      final m = UnderPressureModel();
      expect(m.isRulerVisible, isFalse);
      expect(m.isGridVisible, isFalse);
      m.isRulerVisible = true;
      m.isGridVisible = true;
      m.reset();
      expect(m.isRulerVisible, isFalse);
      expect(m.isGridVisible, isFalse);
      expect(
        m.rulerPosition,
        const Offset(
          UnderPressureConstants.rulerInitialX,
          UnderPressureConstants.rulerInitialY,
        ),
      );
    });
  });

  group('Scene / volume independence', () {
    test('square and trapezoid keep separate volumes', () {
      final m = UnderPressureModel();
      m.square.setVolume(2.2);
      m.trapezoid.setVolume(0.8);
      m.setScene(UnderPressureScene.trapezoid);
      expect(m.currentVolume, closeTo(0.8, 1e-12));
      m.setScene(UnderPressureScene.square);
      expect(m.currentVolume, closeTo(2.2, 1e-12));
      expect(m.square.volume, closeTo(2.2, 1e-12));
      expect(m.trapezoid.volume, closeTo(0.8, 1e-12));
    });

    test('density range endpoints match Constants', () {
      final m = UnderPressureModel();
      expect(m.fluidDensityMin, UnderPressureConstants.gasolineDensity);
      expect(m.fluidDensityMax, UnderPressureConstants.honeyDensity);
      expect(m.gravityMin, UnderPressureConstants.marsGravity);
      expect(m.gravityMax, UnderPressureConstants.jupiterGravity);
    });
  });

  group('Mystery fluid A/B/C', () {
    test('density choices 1700 / 840 / 1100', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.mystery);
      m.mystery.setCustomFluidDensityIndex(0);
      expect(m.fluidDensity, 1700);
      m.mystery.setCustomFluidDensityIndex(1);
      expect(m.fluidDensity, 840);
      m.mystery.setCustomFluidDensityIndex(2);
      expect(m.fluidDensity, 1100);
    });
  });

  group('Math helpers', () {
    test('toFixedNumber matches PhET rounding', () {
      expect(UnderPressureMath.toFixedNumber(9.86, 1), 9.9);
      expect(UnderPressureMath.toFixed(101.325, 3), '101.325');
    });
  });

  group('Chamber left-opening air pocket', () {
    test('above displaced water in left opening → waterHeight 0', () {
      final m = UnderPressureModel();
      m.setScene(UnderPressureScene.chamber);
      m.chamber.leftDisplacement = 0.1;
      final x = (m.chamber.leftOpening.x1 + m.chamber.leftOpening.x2) / 2;
      final yAbove = m.chamber.leftChamber.y2 +
          ChamberPoolModel.defaultHeight -
          m.chamber.leftDisplacement +
          0.05;
      expect(m.chamber.getWaterHeightAboveY(x, yAbove), 0);
    });
  });
}
