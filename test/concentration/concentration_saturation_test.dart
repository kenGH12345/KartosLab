import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/view/concentration_controls.dart';

void main() {
  const eps = 1e-12;

  ConcentrationModel fresh() => ConcentrationModel();
  ConcentrationModel seeded(int seed) =>
      ConcentrationModel(random: math.Random(seed));

  group('Saturation states', () {
    test('unsaturated: concentration < sat, no precipitate', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.5);
      expect(m.concentration, closeTo(1.0, eps));
      expect(m.concentration, lessThan(m.saturatedConcentration));
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateParticles.count, 0);
    });

    test('approach then cross saturation → cap + precipitate', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.68);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateMoles, 0);

      m.addSoluteAmount(0.02);
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.isSaturated, isTrue);
      expect(m.precipitateMoles, closeTo(0.7 - 0.5 * 1.38, eps));
      expect(m.precipitateParticles.count, greaterThan(0));
    });

    test('concentration never exceeds sat for three solutes', () {
      for (final solute in [
        SoluteDefinitions.potassiumDichromate,
        SoluteDefinitions.copperSulfate,
        SoluteDefinitions.drinkMix,
      ]) {
        final m = fresh();
        m.setSolute(solute);
        m.addSoluteAmount(3.0);
        expect(m.concentration, closeTo(solute.saturatedConcentration, eps));
        expect(
          m.concentration,
          lessThanOrEqualTo(solute.saturatedConcentration),
        );
        expect(m.precipitateMoles, greaterThan(0));
        expect(m.isSaturated, isTrue);
      }
    });
  });

  group('Precipitate count', () {
    test('count = round(200 × precipitateMoles)', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.0);
      final expectedMoles = 1.0 - 0.5 * 1.38;
      expect(m.precipitateMoles, closeTo(expectedMoles, eps));
      final expectedCount = (200 * expectedMoles).round();
      expect(m.solution.numberOfPrecipitateParticles, expectedCount);
      expect(m.precipitateParticles.count, expectedCount);
    });

    test('tiny precipitate → at least 1 particle', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.69001);
      expect(m.precipitateMoles, greaterThan(0));
      expect(m.precipitateMoles, lessThan(0.01));
      expect(m.solution.numberOfPrecipitateParticles, greaterThanOrEqualTo(1));
      expect(m.precipitateParticles.count, greaterThanOrEqualTo(1));
    });

    test('stable identity: shrink keeps prefix particles', () {
      final m = seeded(42);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(2.0);
      final before = List.of(m.precipitateParticles.particles);
      expect(before.length, greaterThan(10));
      final keepIds = before.take(5).map((p) => p.id).toList();
      final keepPos = before.take(5).map((p) => p.position).toList();

      m.setSolventFlowRate(0.25);
      m.step(1.0);
      m.setSolventFlowRate(0);
      final after = m.precipitateParticles.particles;
      expect(after.length, lessThan(before.length));
      expect(after.length, greaterThan(0));
      for (var i = 0; i < 5 && i < after.length; i++) {
        expect(after[i].id, keepIds[i]);
        expect(after[i].position, keepPos[i]);
      }
    });
  });

  group('Saturation reversibility', () {
    test('saturated → add water → unsaturated', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.8);
      expect(m.isSaturated, isTrue);
      final precipBefore = m.precipitateMoles;

      m.setSolventFlowRate(0.25);
      m.step(1.2);
      m.setSolventFlowRate(0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateMoles, 0);
      expect(m.precipitateMoles, lessThan(precipBefore));
      expect(m.precipitateParticles.count, 0);
      expect(m.concentration, closeTo(1.0, eps));
    });

    test('unsaturated → evaporation → saturated', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.6);
      expect(m.isSaturated, isFalse);
      m.setEvaporationRate(0.25);
      m.step(0.4);
      m.releaseEvaporation();
      expect(m.isSaturated, isTrue);
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.precipitateMoles, greaterThan(0));
    });

    test('saturated ↔ unsaturated cycle ×3', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      for (var i = 0; i < 3; i++) {
        while (!m.isSaturated && m.soluteMoles < 6) {
          m.addSoluteAmount(0.15);
        }
        expect(m.isSaturated, isTrue);
        expect(m.precipitateParticles.count, greaterThan(0));

        m.setSolventFlowRate(0.25);
        while (m.isSaturated && m.solutionVolume < 0.99) {
          m.step(0.2);
        }
        m.setSolventFlowRate(0);
        expect(m.isSaturated, isFalse);
        expect(m.precipitateParticles.count, 0);
      }
    });

    test('drain saturated keeps concentration', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.0);
      final c = m.concentration;
      expect(c, closeTo(1.38, eps));
      final precipBefore = m.precipitateMoles;
      m.setDrainFlowRate(0.25);
      m.step(0.4);
      m.setDrainFlowRate(0);
      expect(m.solutionVolume, closeTo(0.4, eps));
      expect(m.concentration, closeTo(c, 1e-12));
      expect(m.precipitateMoles, closeTo(precipBefore, 1e-9));
    });
  });

  group('Shaker + saturation', () {
    test('shaker into saturated raises moles / precipitate', () {
      final m = seeded(7);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.8);
      expect(m.isSaturated, isTrue);
      final n0 = m.soluteMoles;
      final p0 = m.precipitateMoles;

      for (var i = 0; i < 20; i++) {
        m.setShakerPosition(Offset(340 + i * 2.0, 160));
        m.step(0.05);
      }
      for (var i = 0; i < 40; i++) {
        m.step(0.05);
      }
      expect(m.soluteMoles, greaterThan(n0));
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.precipitateMoles, greaterThan(p0));
    });

    test('liquid surface Y follows volume', () {
      final m = seeded(3);
      m.setVolumeDirect(0.2);
      final surfaceLow = m.beaker.position.dy -
          (0.2 / m.beaker.volume) * m.beaker.size.height -
          m.solute.particleSize;
      m.setVolumeDirect(0.8);
      final surfaceHigh = m.beaker.position.dy -
          (0.8 / m.beaker.volume) * m.beaker.size.height -
          m.solute.particleSize;
      expect(surfaceHigh, lessThan(surfaceLow));
    });

    test('remove solute clears precipitate and shaker particles', () {
      final m = seeded(9);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.5);
      for (var i = 0; i < 8; i++) {
        m.setShakerPosition(Offset(340 + i * 3.0, 160));
        m.step(0.05);
      }
      expect(m.precipitateParticles.count, greaterThan(0));
      final vol = m.solutionVolume;
      m.removeSolute();
      expect(m.soluteMoles, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateParticles.count, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.solutionVolume, vol);
    });
  });

  group('Solute switch / color / reset', () {
    test('switch solute clears precipitate and saturation', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.5);
      expect(m.isSaturated, isTrue);
      expect(m.precipitateParticles.count, greaterThan(0));
      m.setSolute(SoluteDefinitions.drinkMix);
      expect(m.soluteMoles, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateParticles.count, 0);
    });

    test('liquid color changes with concentration', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.drinkMix);
      final c0 = m.solution.color;
      m.addSoluteAmount(0.5);
      final c1 = m.solution.color;
      m.addSoluteAmount(1.5);
      final c2 = m.solution.color;
      expect(c1, isNot(equals(c0)));
      expect(c2, isNot(equals(c1)));
    });

    test('KMnO4 particle fill is black', () {
      expect(
        SoluteDefinitions.potassiumPermanganate.resolvedParticleFill,
        const Color.fromARGB(255, 0, 0, 0),
      );
    });

    test('reset clears saturated / precipitate / shaker', () {
      final m = seeded(11);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(2.0);
      for (var i = 0; i < 5; i++) {
        m.setShakerPosition(Offset(350 + i.toDouble(), 160));
        m.step(0.05);
      }
      m.reset();
      expect(m.isSaturated, isFalse);
      expect(m.precipitateMoles, 0);
      expect(m.precipitateParticles.count, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.soluteMoles, 0);
      expect(m.solutionVolume, 0.5);
    });
  });

  group('Saturated indicator', () {
    test('label constant matches source', () {
      expect(SaturatedIndicator.label, 'Saturated!');
    });

    test('isSaturated drives visibility semantics', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      expect(m.isSaturated, isFalse);
      m.addSoluteAmount(0.8);
      expect(m.isSaturated, isTrue);
      m.setSolventFlowRate(0.25);
      m.step(2.0);
      m.setSolventFlowRate(0);
      expect(m.isSaturated, isFalse);
    });
  });

  group('Performance smoke', () {
    test('high precipitate stays finite; sync does not reshuffle', () {
      final m = seeded(1);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(7.0);
      final count = m.precipitateParticles.count;
      expect(count, greaterThan(100));
      expect(count, m.solution.numberOfPrecipitateParticles);
      final ids = m.precipitateParticles.particles.map((p) => p.id).toList();
      m.step(0);
      expect(m.precipitateParticles.particles.map((p) => p.id).toList(), ids);
    });
  });
}
