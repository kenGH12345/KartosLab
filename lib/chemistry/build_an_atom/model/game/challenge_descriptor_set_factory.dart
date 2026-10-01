/// Challenge set generation — PhET `ChallengeDescriptorSetFactory`.
library;

import 'dart:math';

import '../../constants/baa_constants.dart';
import 'atom_value_pool.dart';
import 'challenge_descriptor.dart';
import 'challenge_type.dart';

/// Valid challenge types per 0-based level index.
const List<List<ChallengeType>> kLevelChallengeTypes = [
  // Level 1
  [ChallengeType.schematicToElement, ChallengeType.countsToElement],
  // Level 2
  [
    ChallengeType.schematicToCharge,
    ChallengeType.schematicToMassNumber,
    ChallengeType.countsToCharge,
    ChallengeType.countsToMassNumber,
  ],
  // Level 3
  [
    ChallengeType.schematicToSymbolCharge,
    ChallengeType.schematicToSymbolMassNumber,
    ChallengeType.schematicToSymbolProtonCount,
    ChallengeType.countsToSymbolCharge,
    ChallengeType.countsToSymbolMassNumber,
  ],
  // Level 4
  [
    ChallengeType.schematicToSymbolAll,
    ChallengeType.symbolToSchematic,
    ChallengeType.symbolToCounts,
    ChallengeType.countsToSymbolAll,
  ],
];

/// Builds a list of challenge descriptors for one level.
class ChallengeDescriptorSetFactory {
  ChallengeDescriptorSetFactory._();

  static List<ChallengeDescriptor> createSet({
    required int levelIndex,
    required Random random,
    int challengesPerLevel = BAAConstants.challengesPerLevel,
  }) {
    final valid = kLevelChallengeTypes[levelIndex];
    final pool = AtomValuePool(levelIndex);
    final descriptors = <ChallengeDescriptor>[];
    ChallengeType? previous;

    for (var i = 0; i < challengesPerLevel; i++) {
      final d = _getRandomAvailable(
        random: random,
        validChallengeTypes: valid,
        pool: pool,
        previousChallengeType: previous,
      );
      descriptors.add(d);
      previous = d.type;
    }

    assert(
      descriptors.length == challengesPerLevel,
      'expected $challengesPerLevel challenges, got ${descriptors.length}',
    );
    return descriptors;
  }

  static ChallengeDescriptor _getRandomAvailable({
    required Random random,
    required List<ChallengeType> validChallengeTypes,
    required AtomValuePool pool,
    required ChallengeType? previousChallengeType,
  }) {
    var index = random.nextInt(validChallengeTypes.length);
    var challengeType = validChallengeTypes[index];
    if (previousChallengeType != null &&
        challengeType == previousChallengeType) {
      index = (index + 1) % validChallengeTypes.length;
      challengeType = validChallengeTypes[index];
    }

    var minProtonCount = 0;
    var maxProtonCount = double.infinity;
    var isChargedRequired = false;

    if (challengeType.isSchematicRelated) {
      maxProtonCount =
          BAAConstants.maxProtonNumberForSchematicChallenges.toDouble();
    } else {
      minProtonCount =
          BAAConstants.maxProtonNumberForSchematicChallenges + 1;
    }

    if (challengeType.isChargeRelated) {
      isChargedRequired = random.nextBool();
    }

    final atomValue = pool.getRandomAtomValue(
      random,
      minProtonCount: minProtonCount,
      maxProtonCount: maxProtonCount,
      isChargedRequired: isChargedRequired,
    );
    pool.markAtomAsUsed(atomValue);

    return ChallengeDescriptor(type: challengeType, atomValue: atomValue);
  }
}
