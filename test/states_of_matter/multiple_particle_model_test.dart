import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/engine/data/monatomic_liquid_states.dart';
import 'package:kratos/chemistry/states_of_matter/model/multiple_particle_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/phase_state.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/model/substance_type.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';

void main() {
  group('MultipleParticleModel', () {
    test('Neon solid init ? 100 molecules', () {
      final model = MultipleParticleModel(random: SomRandom(1));
      expect(model.substance, SubstanceType.neon);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 100);
      expect(model.scaledAtoms.length, 100);
      expect(model.temperatureSetPoint, SomConstants.solidTemperature);
    });

    test('step advances positions when playing', () {
      final model = MultipleParticleModel(random: SomRandom(2));
      final data = model.moleculeDataSet!;
      final before = [
        for (var i = 0; i < data.getNumberOfMolecules(); i++)
          data.moleculeCenterOfMassPositions[i]!.copy(),
      ];

      model.isPlaying = true;
      model.step(SomConstants.nominalTimeStep);

      var moved = 0;
      for (var i = 0; i < before.length; i++) {
        final p = data.moleculeCenterOfMassPositions[i]!;
        if ((p.x - before[i].x).abs() > 1e-12 ||
            (p.y - before[i].y).abs() > 1e-12) {
          moved++;
        }
      }
      expect(moved, greaterThan(0));
    });

    test('pause stops motion', () {
      final model = MultipleParticleModel(random: SomRandom(3));
      model.step(SomConstants.nominalTimeStep);

      final data = model.moleculeDataSet!;
      final before = [
        for (var i = 0; i < data.getNumberOfMolecules(); i++)
          data.moleculeCenterOfMassPositions[i]!.copy(),
      ];

      model.isPlaying = false;
      model.step(SomConstants.nominalTimeStep);

      for (var i = 0; i < before.length; i++) {
        final p = data.moleculeCenterOfMassPositions[i]!;
        expect(p.x, closeTo(before[i].x, 1e-12));
        expect(p.y, closeTo(before[i].y, 1e-12));
      }
    });

    test('setPhase liquid loads 100 neon positions from snapshot', () {
      final model = MultipleParticleModel(random: SomRandom(4));
      expect(MonatomicLiquidStates.neon['numberOfMolecules'], 100);

      model.setPhase(PhaseState.liquid);

      expect(model.moleculeDataSet!.getNumberOfMolecules(), 100);
      expect(model.temperatureSetPoint, SomConstants.liquidTemperature);

      final positions = model.moleculeDataSet!.moleculeCenterOfMassPositions;
      final xs = [
        for (var i = 0; i < 100; i++) positions[i]!.x,
      ]..sort();
      expect(xs.last - xs.first, greaterThan(5));
    });

    test('reset restores solid neon', () {
      final model = MultipleParticleModel(random: SomRandom(5));
      model.setPhase(PhaseState.gas);
      model.heatingCoolingAmount = 0.5;
      model.step(0.1);

      model.reset();

      expect(model.substance, SubstanceType.neon);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 100);
      expect(model.temperatureSetPoint, SomConstants.solidTemperature);
      expect(model.heatingCoolingAmount, 0);
      expect(model.isPlaying, isTrue);
      expect(model.isExploded, isFalse);
    });

    test('heatingCoolingAmount > 0 increases temperatureSetPoint', () {
      final model = MultipleParticleModel(random: SomRandom(6));
      final t0 = model.temperatureSetPoint;
      model.setHeatingCoolingAmount(1.0);
      for (var i = 0; i < 30; i++) {
        model.step(SomConstants.nominalTimeStep);
      }
      expect(model.temperatureSetPoint, greaterThan(t0));
    });
  });
}
