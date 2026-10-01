import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/multiple_particle_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/phase_state.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/model/substance_type.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';

void main() {
  group('Diatomic oxygen + Water engines', () {
    MultipleParticleModel modelWith(SubstanceType substance, {int seed = 1}) {
      return MultipleParticleModel(
        random: SomRandom(seed),
        initialSubstance: substance,
        validSubstances: const {
          SubstanceType.neon,
          SubstanceType.argon,
          SubstanceType.diatomicOxygen,
          SubstanceType.water,
        },
      );
    }

    test('O2 solid init molecule count formula → 50 molecules / 100 atoms', () {
      final model = modelWith(SubstanceType.diatomicOxygen, seed: 11);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 50);
      expect(model.scaledAtoms.length, 100);
      expect(model.moleculeDataSet!.atomsPerMolecule, 2);
      expect(model.temperatureSetPoint, SomConstants.solidTemperature);
    });

    test('Water solid init molecule count → 76 molecules / 228 atoms', () {
      final model = modelWith(SubstanceType.water, seed: 12);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 76);
      expect(model.scaledAtoms.length, 228);
      expect(model.moleculeDataSet!.atomsPerMolecule, 3);
      expect(model.temperatureSetPoint, SomConstants.solidTemperature);
    });

    test('setPhase solid/liquid/gas for oxygen does not throw', () {
      final model = modelWith(SubstanceType.diatomicOxygen, seed: 13);
      expect(() => model.setPhase(PhaseState.solid), returnsNormally);
      expect(() => model.setPhase(PhaseState.liquid), returnsNormally);
      expect(() => model.setPhase(PhaseState.gas), returnsNormally);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 50);
    });

    test('setPhase solid/liquid/gas for water does not throw', () {
      final model = modelWith(SubstanceType.water, seed: 14);
      expect(() => model.setPhase(PhaseState.solid), returnsNormally);
      expect(() => model.setPhase(PhaseState.liquid), returnsNormally);
      expect(() => model.setPhase(PhaseState.gas), returnsNormally);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 76);
    });

    test('step advances for oxygen and water', () {
      for (final substance in [
        SubstanceType.diatomicOxygen,
        SubstanceType.water,
      ]) {
        final model = modelWith(substance, seed: 20);
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
        expect(moved, greaterThan(0), reason: '$substance should move');
      }
    });

    test('reset works after oxygen/water use', () {
      final model = modelWith(SubstanceType.diatomicOxygen, seed: 30);
      model.setSubstance(SubstanceType.water);
      model.setPhase(PhaseState.gas);
      model.heatingCoolingAmount = 0.4;
      model.step(0.05);

      model.reset();

      expect(model.substance, SubstanceType.neon);
      expect(model.moleculeDataSet!.getNumberOfMolecules(), 100);
      expect(model.temperatureSetPoint, SomConstants.solidTemperature);
      expect(model.heatingCoolingAmount, 0);
      expect(model.isPlaying, isTrue);
    });
  });
}
