import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/phase_changes_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/model/substance_type.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';

void main() {
  group('PhaseChangesModel', () {
    test('height shrinks toward target at capped rate', () {
      final model = PhaseChangesModel(random: SomRandom(10));
      expect(model.containerHeight, SomConstants.containerInitialHeight);

      model.setTargetContainerHeight(5000);
      // 0.5s * 1250/s = 625 max shrink
      model.stepInTime(0.5);

      expect(model.containerHeight, closeTo(10000 - 625, 1e-6));
      expect(model.normalizedLidVelocityY, lessThan(0));
    });

    test('height expands toward target at expand rate', () {
      final model = PhaseChangesModel(random: SomRandom(11));
      model.setTargetContainerHeight(5000);
      model.stepInTime(5); // reach near target
      expect(model.containerHeight, lessThan(6000));

      model.setTargetContainerHeight(10000);
      final before = model.containerHeight;
      model.stepInTime(0.5);
      // expand ≤ 1500/s → +750
      expect(model.containerHeight - before, closeTo(750, 1));
    });

    test('setEpsilon updates adjustable strength and scaled epsilon', () {
      final model = PhaseChangesModel(random: SomRandom(12));
      model.setSubstance(SubstanceType.adjustableAtom);

      final mid = (SomConstants.minAdjustableEpsilon +
              SomConstants.maxAdjustableEpsilon) /
          2;
      model.setEpsilon(mid);

      expect(model.adjustableAtomInteractionStrength, closeTo(mid, 1e-9));
      expect(model.getEpsilon(), closeTo(mid, 1e-9));
      final scaled = model.moleculeForceAndMotionCalculator!.getScaledEpsilon();
      expect(
        scaled,
        closeTo(PhaseChangesModel.convertEpsilonToScaledEpsilon(mid), 1e-9),
      );
    });

    test('returnLid clears exploded and restores container', () {
      final model = PhaseChangesModel(random: SomRandom(13));
      model.setContainerExploded(true);
      expect(model.isExploded, isTrue);
      expect(model.targetContainerHeight, SomConstants.containerInitialHeight);

      model.returnLid();
      expect(model.isExploded, isFalse);
      expect(model.containerHeight, SomConstants.containerInitialHeight);
    });

    test('injectMoleculesFromPump queues +3', () {
      final model = PhaseChangesModel(random: SomRandom(14));
      final beforeTarget = model.targetNumberOfMolecules;
      final beforeCount = model.moleculeDataSet!.getNumberOfMolecules();

      model.injectMoleculesFromPump(3);

      expect(model.numMoleculesQueuedForInjection, 3);
      expect(model.targetNumberOfMolecules, beforeTarget + 3);

      // Drain queue over steps (holdoff 0.25s between injections → need ≥0.5s)
      for (var i = 0; i < 80; i++) {
        model.stepInTime(SomConstants.nominalTimeStep);
      }

      expect(model.numMoleculesQueuedForInjection, 0);
      expect(
        model.moleculeDataSet!.getNumberOfMolecules(),
        beforeCount + 3,
      );
    });

    test('adjustableAtom is in validSubstances', () {
      final model = PhaseChangesModel(random: SomRandom(15));
      expect(model.validSubstances.contains(SubstanceType.adjustableAtom), isTrue);
      model.setSubstance(SubstanceType.adjustableAtom);
      expect(model.substance, SubstanceType.adjustableAtom);
    });
  });
}
