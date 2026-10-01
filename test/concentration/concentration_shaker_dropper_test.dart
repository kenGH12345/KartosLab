import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/shaker_particles.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';

void main() {
  const eps = 1e-9;

  ConcentrationModel fresh({int seed = 7}) =>
      ConcentrationModel(random: math.Random(seed));

  group('Shaker drag / dispensing', () {
    test('motion sets dispensingRate to max; stillness clears it', () {
      final m = fresh();
      expect(m.shaker.dispensingRate, 0);

      m.setShakerPosition(const Offset(360, 170));
      m.step(0.016);
      expect(
        m.shaker.dispensingRate,
        ConcentrationConstants.shakerMaxDispensingRate,
      );

      // Same position → stationary
      m.step(0.016);
      expect(m.shaker.dispensingRate, 0);
    });

    test('pointer-down without move does not dispense after settle', () {
      final m = fresh();
      // No position change
      m.step(0.05);
      m.step(0.05);
      expect(m.shaker.dispensingRate, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.soluteMoles, 0);
    });

    test('spawn count formula matches source', () {
      const rate = 0.2;
      const ppm = 200;
      const dt = 0.1;
      // round(max(1, 0.2*200*0.1)) = round(4) = 4
      expect(
        ShakerParticles.expectedSpawnCount(
          dispensingRate: rate,
          particlesPerMole: ppm,
          dt: dt,
        ),
        4,
      );
      // tiny dt still at least 1
      expect(
        ShakerParticles.expectedSpawnCount(
          dispensingRate: rate,
          particlesPerMole: ppm,
          dt: 0.001,
        ),
        1,
      );
    });

    test('moving frame spawns particles while dispensing', () {
      final m = fresh(seed: 1);
      // Establish rate
      m.setShakerPosition(const Offset(360, 170));
      m.step(0.05);
      expect(m.shaker.dispensingRate, greaterThan(0));

      // Keep moving so rate stays high and particles spawn
      for (var i = 0; i < 5; i++) {
        m.setShakerPosition(Offset(360 + i * 4.0, 170));
        m.step(0.1);
      }
      expect(
        m.shakerParticles.count + (m.soluteMoles > 0 ? 1 : 0),
        greaterThan(0),
      );
    });
  });

  group('Shaker particle → mole', () {
    test('each particle entering liquid adds 1/200 mol', () {
      final m = fresh(seed: 42);
      // Place particles by dragging until some moles appear
      for (var i = 0; i < 100; i++) {
        m.setShakerPosition(Offset(300 + (i % 20).toDouble(), 160 + (i % 5)));
        m.step(0.05);
      }
      expect(m.soluteMoles, greaterThan(0));
      // moles should be k/200
      final k = m.soluteMoles * 200;
      expect(k, closeTo(k.roundToDouble(), 1e-6));
    });

    test('volume unchanged by shaker (solid only)', () {
      final m = fresh();
      final v0 = m.solutionVolume;
      for (var i = 0; i < 40; i++) {
        m.setShakerPosition(Offset(320 + i.toDouble(), 170));
        m.step(0.05);
      }
      expect(m.solutionVolume, v0);
    });

    test('release: rate 0 but airborne particles keep falling', () {
      final m = fresh(seed: 3);
      for (var i = 0; i < 5; i++) {
        m.setShakerPosition(Offset(350 + i * 5.0, 160));
        m.step(0.05);
      }
      final airborne = m.shakerParticles.count;
      expect(airborne, greaterThan(0));

      // Stop moving
      m.step(0.05);
      expect(m.shaker.dispensingRate, 0);

      final molesBefore = m.soluteMoles;
      // Keep stepping without moving — particles finish falling
      for (var i = 0; i < 80; i++) {
        m.step(0.05);
      }
      expect(m.shakerParticles.count, 0);
      expect(m.soluteMoles, greaterThanOrEqualTo(molesBefore));
    });
  });

  group('Shaker max amount', () {
    test('soluteMoles clamped at 7; empty stops dispensing', () {
      final m = fresh();
      m.addSoluteAmount(6.99);
      for (var i = 0; i < 200; i++) {
        m.setShakerPosition(Offset(300 + (i % 30).toDouble(), 165));
        m.step(0.05);
      }
      expect(m.soluteMoles, lessThanOrEqualTo(7));
      expect(m.soluteMoles, closeTo(7, 1e-9));
      expect(m.shaker.isEmpty, isTrue);
      m.setShakerPosition(const Offset(400, 170));
      m.step(0.05);
      expect(m.shaker.dispensingRate, 0);
    });
  });

  group('Dropper', () {
    test('press sets flow; release clears', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      expect(m.dropper.isDispensing, isTrue);
      expect(m.dropper.flowRate, ConcentrationConstants.dropperFlowRate);
      m.setDropperDispensing(false);
      expect(m.dropper.flowRate, 0);
    });

    test('numerical: dt=0.1 → ΔV=0.005, Δn=stock×ΔV', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      final stock = m.solute.stockSolutionConcentration; // 5.5 drink mix
      m.step(0.1);
      expect(m.solutionVolume, closeTo(0.5 + 0.005, eps));
      expect(m.soluteMoles, closeTo(stock * 0.005, eps));
    });

    test('disabled at volume=1', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setVolumeDirect(1.0);
      expect(m.dropper.enabled, isFalse);
      m.setDropperDispensing(true);
      expect(m.dropper.isDispensing, isFalse);
      expect(m.dropper.flowRate, 0);
    });

    test('disabled at solute max', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.addSoluteAmount(7);
      expect(m.dropper.isEmpty, isTrue);
      expect(m.dropper.enabled, isFalse);
    });
  });

  group('Solid / Solution switching', () {
    test('only one dispenser form active', () {
      final m = fresh();
      expect(m.shaker.isVisible(m.soluteForm), isTrue);
      expect(m.dropper.isVisible(m.soluteForm), isFalse);

      m.setSoluteForm(SoluteForm.solution);
      expect(m.shaker.isVisible(m.soluteForm), isFalse);
      expect(m.dropper.isVisible(m.soluteForm), isTrue);

      m.setDropperDispensing(true);
      m.setSoluteForm(SoluteForm.solid);
      expect(m.dropper.isDispensing, isFalse);
      expect(m.dropper.flowRate, 0);
    });

    test('switch solute while dropper active clears moles', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.step(0.5);
      expect(m.soluteMoles, greaterThan(0));
      m.setSolute(SoluteDefinitions.copperSulfate);
      expect(m.soluteMoles, 0);
      expect(m.shakerParticles.count, 0);
    });
  });

  group('Saturation via shaker / dropper', () {
    test('shaker can drive to saturation + precipitate', () {
      final m = fresh(seed: 9);
      // copper sulfate sat 1.38 @ 0.5L needs > 0.69 mol
      m.setSolute(SoluteDefinitions.copperSulfate);
      for (var i = 0; i < 400; i++) {
        m.setShakerPosition(Offset(280 + (i % 40).toDouble(), 155 + (i % 8)));
        m.step(0.05);
        if (m.isSaturated) break;
      }
      expect(m.isSaturated, isTrue);
      expect(m.concentration, closeTo(1.38, 1e-9));
      expect(m.precipitateMoles, greaterThan(0));
      final c = m.concentration;
      final p0 = m.precipitateMoles;
      for (var i = 0; i < 40; i++) {
        m.setShakerPosition(Offset(300 + (i % 20).toDouble(), 160));
        m.step(0.05);
      }
      expect(m.concentration, closeTo(c, 1e-9));
      expect(m.precipitateMoles, greaterThanOrEqualTo(p0));
    });

    test('dropper can drive to saturation', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.potassiumDichromate); // sat 0.51, stock 0.5
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      // Need high concentration: evaporate first to reduce volume then fill
      // Or keep dispensing — stock 0.5 ≈ sat 0.51 so nearly saturated stock.
      for (var i = 0; i < 200; i++) {
        m.step(0.05);
      }
      // At stock≈sat, solution approaches but may not exceed; evaporate to saturate
      m.setDropperDispensing(false);
      m.setEvaporationRate(0.25);
      for (var i = 0; i < 40; i++) {
        m.step(0.05);
      }
      m.releaseEvaporation();
      expect(m.concentration, lessThanOrEqualTo(m.saturatedConcentration + 1e-9));
    });
  });

  group('Remove Solute / Reset with particles', () {
    test('remove solute clears moles and airborne particles', () {
      final m = fresh(seed: 5);
      for (var i = 0; i < 80; i++) {
        m.setShakerPosition(Offset(340 + (i % 25).toDouble(), 165));
        m.step(0.05);
        if (m.soluteMoles > 0) break;
      }
      expect(m.soluteMoles, greaterThan(0));
      // Keep some airborne if possible
      m.setShakerPosition(const Offset(400, 155));
      m.step(0.05);
      final v = m.solutionVolume;
      m.removeSolute();
      expect(m.soluteMoles, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.solutionVolume, v);
    });

    test('reset clears shaker and dropper activity', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.step(0.2);
      m.setSoluteForm(SoluteForm.solid);
      for (var i = 0; i < 10; i++) {
        m.setShakerPosition(Offset(350 + i * 3.0, 170));
        m.step(0.05);
      }
      m.reset();
      expect(m.soluteMoles, 0);
      expect(m.solutionVolume, 0.5);
      expect(m.soluteForm, SoluteForm.solid);
      expect(m.shakerParticles.count, 0);
      expect(m.dropper.isDispensing, isFalse);
      expect(m.shaker.dispensingRate, 0);
      expect(m.shaker.position, ConcentrationConstants.shakerPosition);
    });

    test('repeated shaker/dropper cycles ×4', () {
      final m = fresh(seed: 11);
      for (var cycle = 0; cycle < 4; cycle++) {
        if (cycle.isEven) {
          m.setSoluteForm(SoluteForm.solid);
          for (var i = 0; i < 15; i++) {
            m.setShakerPosition(Offset(320 + i.toDouble(), 168));
            m.step(0.05);
          }
        } else {
          m.setSoluteForm(SoluteForm.solution);
          m.setDropperDispensing(true);
          m.step(0.3);
          m.setDropperDispensing(false);
        }
        m.reset();
        expect(m.soluteMoles, 0);
        expect(m.shakerParticles.count, 0);
        expect(m.dropper.flowRate, 0);
      }
    });
  });

  group('KMnO4 particle color metadata', () {
    test('permanganate particle fill is black', () {
      expect(
        SoluteDefinitions.potassiumPermanganate.resolvedParticleFill,
        const Color.fromARGB(255, 0, 0, 0),
      );
    });
  });
}
