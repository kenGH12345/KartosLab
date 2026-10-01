import 'dart:math' as math;

import '../../ba_shared_constants.dart';
import '../ba_enums.dart';
import '../ba_mass.dart';
import '../ba_vector2.dart';
import 'balance_game_challenge.dart';

/// Source-faithful production factory.
/// Source: `js/game/model/BalanceGameChallengeFactory.ts`
class SourceFaithfulChallengeFactory {
  SourceFaithfulChallengeFactory({math.Random? random})
      : _random = random ?? math.Random();

  final math.Random _random;

  static const int maxGenAttempts = 50;
  static const int maxHalvingOfPastList = 3;
  static const int maxChallengeHistoryLength = 60;

  static final double maxDistanceFromCenter =
      BaGeometry.maxValidMassDistanceFromCenter;

  final List<BalanceGameChallenge> _usedBalance = [];
  final List<BalanceGameChallenge> _usedMassDeduction = [];
  final List<BalanceGameChallenge> _usedTilt = [];

  static final List<BaMass> balanceChallengeMasses = [
    BaMass.brickStack(1, const BaVector2(0, 0)),
    BaMass.brickStack(2, const BaVector2(0, 0)),
    BaMass.brickStack(3, const BaVector2(0, 0)),
    BaMass.brickStack(4, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.tinyRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.smallRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.mediumRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.bigRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.boy, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.girl, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.man, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.woman, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.barrel, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.cinderBlock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.puppy, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.sodaBottle, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.smallBucket, const BaVector2(0, 0)),
  ];

  /// Mystery masses used only in Game mass-deduction.
  static final List<BaMass> mysteryMasses = [
    BaMass.fromType(BaMassType.fireHydrant, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.television, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.largeTrashCan, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.smallRock, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.crate, const BaVector2(0, 0), isMystery: true),
    BaMass.fromType(BaMassType.flowerPot, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.mediumBucket, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.largeBucket, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.pottedPlant, const BaVector2(0, 0),
        isMystery: true),
    BaMass.fromType(BaMassType.tire, const BaVector2(0, 0), isMystery: true),
  ];

  static final List<BaMass> lowProfileMasses = [
    BaMass.fromType(BaMassType.tinyRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.smallRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.mediumRock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.cinderBlock, const BaVector2(0, 0)),
    BaMass.fromType(BaMassType.smallBucket, const BaVector2(0, 0)),
  ];

  int _randInt(int max) => max <= 0 ? 0 : _random.nextInt(max);

  double _nextDouble() => _random.nextDouble();

  /// Default production entry used by [BalanceGameModel].
  static List<BalanceGameChallenge> generateChallengeSet(int level) =>
      SourceFaithfulChallengeFactory().generateChallengeSetForLevel(level);

  List<BalanceGameChallenge> generateChallengeSetForLevel(int level) {
    switch (level) {
      case 0:
        return [
          _uniqueBalance(_generateSimpleBalance),
          _uniqueTilt(_generateSimpleTilt),
          _uniqueBalance(_generateEasyBalance),
          _uniqueMassDeduction(_generateSimpleMassDeduction),
          _uniqueTilt(_generateSimpleTilt),
          _uniqueMassDeduction(_generateEasyMassDeduction),
        ];
      case 1:
        return [
          _uniqueTilt(_generateEasyTilt),
          _uniqueBalance(_generateEasyBalance),
          _uniqueMassDeduction(_generateEasyMassDeduction),
          _uniqueTilt(_generateEasyTilt),
          _uniqueMassDeduction(_generateEasyMassDeduction),
          _uniqueBalance(_generateModerateBalance),
        ];
      case 2:
        return [
          _uniqueBalance(_generateModerateBalance),
          _uniqueMassDeduction(_generateEasyMassDeduction),
          _uniqueTilt(_generateModerateTilt),
          _uniqueBalance(_generateModerateBalance),
          _uniqueTilt(_generateModerateTilt),
          _uniqueMassDeduction(_generateModerateMassDeduction),
        ];
      case 3:
        return [
          _uniqueTilt(_generateAdvancedTilt),
          _uniqueBalance(_generateAdvancedBalance),
          _uniqueMassDeduction(_generateModerateMassDeduction),
          _uniqueTilt(_generateAdvancedTilt),
          _uniqueMassDeduction(_generateModerateMassDeduction),
          _uniqueBalance(_generateAdvancedBalance),
        ];
      default:
        throw ArgumentError('Invalid level: $level');
    }
  }

  BalanceGameChallenge _uniqueBalance(BalanceGameChallenge Function() gen) =>
      _generateUnique(gen, _usesUniqueMasses, _usedBalance);

  BalanceGameChallenge _uniqueTilt(BalanceGameChallenge Function() gen) =>
      _generateUnique(gen, _usesUniqueFixedMassesAndDistances, _usedTilt);

  BalanceGameChallenge _uniqueMassDeduction(
          BalanceGameChallenge Function() gen) =>
      _generateUnique(gen, _usesUniqueFixedMasses, _usedMassDeduction);

  BalanceGameChallenge _generateUnique(
    BalanceGameChallenge Function() generator,
    bool Function(BalanceGameChallenge, List<BalanceGameChallenge>) uniqueTest,
    List<BalanceGameChallenge> history,
  ) {
    BalanceGameChallenge? challenge;
    var unique = false;
    for (var h = 0; h < maxHalvingOfPastList && !unique; h++) {
      for (var j = 0; j < maxGenAttempts && !unique; j++) {
        challenge = generator();
        if (uniqueTest(challenge, history)) {
          unique = true;
        }
      }
      if (!unique && history.isNotEmpty) {
        history.removeRange(0, (history.length / 2).round());
      }
    }
    final result = challenge!;
    history.add(result);
    if (history.length > maxChallengeHistoryLength) {
      history.removeAt(0);
    }
    return result;
  }

  bool _usesUniqueMasses(
      BalanceGameChallenge test, List<BalanceGameChallenge> used) {
    return !used.any((c) => c.usesSameMasses(test));
  }

  bool _usesUniqueFixedMasses(
      BalanceGameChallenge test, List<BalanceGameChallenge> used) {
    return !used.any((c) => c.usesSameFixedMasses(test));
  }

  bool _usesUniqueFixedMassesAndDistances(
      BalanceGameChallenge test, List<BalanceGameChallenge> used) {
    return !used.any((c) => c.usesSameFixedMassesAndDistances(test));
  }

  bool _isChallengeSolvable(
    double fixedMassValue,
    double movableMassValue,
    double distanceIncrement,
    double maxDistance,
  ) {
    if (fixedMassValue * distanceIncrement > movableMassValue * maxDistance ||
        fixedMassValue * maxDistance < movableMassValue * distanceIncrement) {
      return false;
    }
    final ratio = fixedMassValue / movableMassValue;
    final rem = ratio % distanceIncrement;
    return rem <= BaSharedConstants.comparisonTolerance ||
        (distanceIncrement - rem) <= BaSharedConstants.comparisonTolerance;
  }

  double _generateRandomValidPlankDistance() {
    const maxDistance = BaGeometry.plankLength / 2;
    const increment = BaGeometry.interSnapToMarkerDistance;
    final maxIncrements = (maxDistance / increment).round() - 1;
    return (_randInt(maxIncrements) + 1) * increment;
  }

  double _generateRandomValidPlankDistanceRange(
      double minDistance, double maxDistance) {
    final minIncrements =
        (minDistance / BaGeometry.interSnapToMarkerDistance).ceil();
    final maxIncrements =
        (maxDistance / BaGeometry.interSnapToMarkerDistance).floor();
    return (_randInt(maxIncrements - minIncrements + 1) + minIncrements) *
        BaGeometry.interSnapToMarkerDistance;
  }

  List<double> _getPossibleDistanceList(
      double massOfFixedItem, double massOfMovableItem) {
    final valid = <double>[];
    for (var testDistance = BaGeometry.interSnapToMarkerDistance;
        testDistance <= BaGeometry.maxValidMassDistanceFromCenter;
        testDistance += BaGeometry.interSnapToMarkerDistance) {
      final possible = testDistance * massOfMovableItem / massOfFixedItem;
      if (possible <= BaGeometry.maxValidMassDistanceFromCenter &&
          possible >=
              BaGeometry.interSnapToMarkerDistance -
                  BaSharedConstants.comparisonTolerance &&
          possible % BaGeometry.interSnapToMarkerDistance <
              BaSharedConstants.comparisonTolerance) {
        valid.add(possible);
      }
    }
    return valid;
  }

  double _chooseRandomValidFixedMassDistance(
      double fixedMassValue, double movableMassValue) {
    final distances =
        _getPossibleDistanceList(fixedMassValue, movableMassValue);
    return -distances[_randInt(distances.length)];
  }

  BaMass? _createMassByRatio(double massValue, List<double> ratios) {
    final indexOffset = _randInt(balanceChallengeMasses.length);
    for (var i = 0; i < balanceChallengeMasses.length; i++) {
      final candidate =
          balanceChallengeMasses[(i + indexOffset) % balanceChallengeMasses.length];
      for (final ratio in ratios) {
        if ((candidate.massValue * ratio - massValue).abs() < 1e-9) {
          return candidate.createCopy();
        }
      }
    }
    return null;
  }

  BalanceGameChallenge _create1Fixed1Movable(
    BaMass fixedMass,
    double fixedDistance,
    BaMass movableMass,
  ) {
    final solutionDistance =
        -(fixedMass.massValue * fixedDistance / movableMass.massValue);
    return BalanceGameChallenge(
      kind: BaChallengeKind.balanceMasses,
      initialColumnState: ColumnState.singleColumn,
      fixedMassDistancePairs: [
        MassDistancePair(mass: fixedMass, distance: fixedDistance),
      ],
      movableMasses: [movableMass],
      balancedConfiguration: [
        MassDistancePair(mass: movableMass, distance: solutionDistance),
      ],
    );
  }

  BalanceGameChallenge _create2Fixed1Movable(
    BaMass fixed1,
    double d1,
    BaMass fixed2,
    double d2,
    BaMass movable,
  ) {
    final fixedPairs = [
      MassDistancePair(mass: fixed1, distance: -d1),
      MassDistancePair(mass: fixed2, distance: -d2),
    ];
    final fixedTorque = fixedPairs[0].mass.massValue * fixedPairs[0].distance +
        fixedPairs[1].mass.massValue * fixedPairs[1].distance;
    final solutionDistance = -fixedTorque / movable.massValue;
    return BalanceGameChallenge(
      kind: BaChallengeKind.balanceMasses,
      initialColumnState: ColumnState.singleColumn,
      fixedMassDistancePairs: fixedPairs,
      movableMasses: [movable],
      balancedConfiguration: [
        MassDistancePair(mass: movable, distance: solutionDistance),
      ],
    );
  }

  BalanceGameChallenge _generateSimpleBalance() {
    final numBricks = _randInt(4) + 1;
    final distance = -_generateRandomValidPlankDistance();
    return _create1Fixed1Movable(
      BaMass.brickStack(numBricks, const BaVector2(0, 0)),
      distance,
      BaMass.brickStack(numBricks, const BaVector2(0, 0)),
    );
  }

  BalanceGameChallenge _generateEasyBalance() {
    var numFixed = 1;
    var numMovable = 1;
    var valid = <double>[];
    while (valid.isEmpty) {
      numFixed = math.pow(2, _randInt(3)).toInt();
      if (numFixed == 1 || _nextDouble() > 0.5) {
        numMovable = 2 * numFixed;
      } else {
        numMovable = numFixed ~/ 2;
      }
      valid = _getPossibleDistanceList(
        numFixed * BaMassCatalog.brickMass,
        numMovable * BaMassCatalog.brickMass,
      );
    }
    final fixedDist = -valid[_randInt(valid.length)];
    return _create1Fixed1Movable(
      BaMass.brickStack(numFixed, const BaVector2(0, 0)),
      fixedDist,
      BaMass.brickStack(numMovable, const BaVector2(0, 0)),
    );
  }

  BalanceGameChallenge _generateModerateBalance() {
    late BaMass fixedProto;
    BaMass? movable;
    do {
      fixedProto =
          balanceChallengeMasses[_randInt(balanceChallengeMasses.length)];
      movable = _createMassByRatio(
        fixedProto.massValue,
        const [3.0, 1.0 / 3.0, 3.0 / 2.0, 2.0 / 3.0, 4.0, 1.0 / 4.0],
      );
    } while (movable == null ||
        !_isChallengeSolvable(
          fixedProto.massValue,
          movable.massValue,
          BaGeometry.interSnapToMarkerDistance,
          maxDistanceFromCenter,
        ));
    final fixedDist = _chooseRandomValidFixedMassDistance(
      fixedProto.massValue,
      movable.massValue,
    );
    return _create1Fixed1Movable(
      fixedProto.createCopy(),
      fixedDist,
      movable,
    );
  }

  List<BalanceGameChallenge> _generateSolvableChallenges(
    BaMass fixed1,
    BaMass fixed2,
    BaMass movable,
    double distanceIncrement,
    double maxDistance,
  ) {
    final solvable = <BalanceGameChallenge>[];
    for (var d1 = distanceIncrement; d1 <= maxDistance; d1 += distanceIncrement) {
      for (var d2 = distanceIncrement;
          d2 <= maxDistance;
          d2 += distanceIncrement) {
        if (d1 == d2 || (d1 - d2).abs() < 1.1 * distanceIncrement) continue;
        final fixedTorque = fixed1.massValue * d1 + fixed2.massValue * d2;
        final movableDist = fixedTorque / movable.massValue;
        if (movableDist >= distanceIncrement &&
            movableDist <= maxDistance &&
            movableDist % distanceIncrement == 0) {
          solvable.add(_create2Fixed1Movable(
            fixed1.createCopy(),
            d1,
            fixed2.createCopy(),
            d2,
            movable.createCopy(),
          ));
        }
      }
    }
    return solvable;
  }

  BalanceGameChallenge _generateAdvancedBalance() {
    late List<BalanceGameChallenge> solvable;
    do {
      final f1 =
          balanceChallengeMasses[_randInt(balanceChallengeMasses.length)];
      final f2 =
          balanceChallengeMasses[_randInt(balanceChallengeMasses.length)];
      final m =
          balanceChallengeMasses[_randInt(balanceChallengeMasses.length)];
      solvable = _generateSolvableChallenges(
        f1,
        f2,
        m,
        BaGeometry.interSnapToMarkerDistance,
        BaGeometry.plankLength / 2 - BaGeometry.interSnapToMarkerDistance,
      );
    } while (solvable.isEmpty);
    return solvable[_randInt(solvable.length)];
  }

  BalanceGameChallenge _generateSimpleTilt() {
    final left = 1 + _randInt(4);
    var right = left;
    while (right == left) {
      right = 1 + _randInt(4);
    }
    final dist = _generateRandomValidPlankDistance();
    return BalanceGameChallenge(
      kind: BaChallengeKind.tiltPrediction,
      initialColumnState: ColumnState.doubleColumns,
      fixedMassDistancePairs: [
        MassDistancePair(
          mass: BaMass.brickStack(left, const BaVector2(0, 0)),
          distance: dist,
        ),
        MassDistancePair(
          mass: BaMass.brickStack(right, const BaVector2(0, 0)),
          distance: -dist,
        ),
      ],
    );
  }

  BalanceGameChallenge _generateEasyTilt() {
    final bricks = 1 + _randInt(4);
    final leftDist = _generateRandomValidPlankDistanceRange(
      2 * BaGeometry.interSnapToMarkerDistance,
      BaGeometry.plankLength / 2 - BaGeometry.interSnapToMarkerDistance * 2,
    );
    var rightDist = -leftDist;
    if (_nextDouble() > 0.2) {
      rightDist = -_generateRandomValidPlankDistanceRange(
        2 * BaGeometry.interSnapToMarkerDistance,
        BaGeometry.plankLength / 2 - BaGeometry.interSnapToMarkerDistance * 2,
      );
    }
    return BalanceGameChallenge(
      kind: BaChallengeKind.tiltPrediction,
      initialColumnState: ColumnState.doubleColumns,
      fixedMassDistancePairs: [
        MassDistancePair(
          mass: BaMass.brickStack(bricks, const BaVector2(0, 0)),
          distance: leftDist,
        ),
        MassDistancePair(
          mass: BaMass.brickStack(bricks, const BaVector2(0, 0)),
          distance: rightDist,
        ),
      ],
    );
  }

  List<MassDistancePair> _positionMassesCloseToBalancing(List<BaMass> masses) {
    var bestNetTorque = double.infinity;
    const minAcceptableTorque = 1.0;
    var bestDistanceList = <double>[];
    for (var i = 0; i < maxGenAttempts; i++) {
      final distanceList = <double>[];
      for (var j = 0;
          distanceList.length < masses.length && j < maxGenAttempts;
          j++) {
        var candidate = _generateRandomValidPlankDistance();
        if (j == 0) {
          candidate = _nextDouble() >= 0.5 ? -candidate : candidate;
        } else {
          candidate =
              distanceList.last > 0 ? -candidate.abs() : candidate.abs();
        }
        if (!distanceList.contains(candidate)) {
          distanceList.add(candidate);
        }
      }
      if (distanceList.length != masses.length) {
        distanceList.clear();
        for (var k = 0; k < masses.length; k++) {
          distanceList.add(BaGeometry.interSnapToMarkerDistance +
              BaGeometry.interSnapToMarkerDistance * k);
        }
      }
      var netTorque = 0.0;
      for (var m = 0; m < masses.length; m++) {
        netTorque += masses[m].massValue * distanceList[m];
      }
      netTorque = netTorque.abs();
      if (netTorque < bestNetTorque && netTorque > minAcceptableTorque) {
        bestNetTorque = netTorque;
        bestDistanceList = List<double>.from(distanceList);
      }
    }
    final result = <MassDistancePair>[];
    for (var i = 0; i < masses.length; i++) {
      result.add(MassDistancePair(
        mass: masses[i],
        distance: bestDistanceList[i],
      ));
    }
    return result;
  }

  BalanceGameChallenge _generateModerateTilt() {
    var left = lowProfileMasses[_randInt(lowProfileMasses.length)].createCopy();
    var right = BaMass.brickStack(_randInt(4) + 1, const BaVector2(0, 0));
    if (_nextDouble() >= 0.5) {
      final tmp = left;
      left = right;
      right = tmp;
    }
    return BalanceGameChallenge(
      kind: BaChallengeKind.tiltPrediction,
      initialColumnState: ColumnState.doubleColumns,
      fixedMassDistancePairs:
          _positionMassesCloseToBalancing([left, right]),
    );
  }

  BalanceGameChallenge _generateAdvancedTilt() {
    final m1 = lowProfileMasses[_randInt(lowProfileMasses.length)].createCopy();
    final m2 = lowProfileMasses[_randInt(lowProfileMasses.length)].createCopy();
    final m3 = BaMass.brickStack(_randInt(4) + 1, const BaVector2(0, 0));
    return BalanceGameChallenge(
      kind: BaChallengeKind.tiltPrediction,
      initialColumnState: ColumnState.doubleColumns,
      fixedMassDistancePairs:
          _positionMassesCloseToBalancing([m1, m2, m3]),
    );
  }

  BalanceGameChallenge _createMassDeduction(
    BaMass mystery,
    double mysteryDist,
    BaMass known,
  ) {
    final solutionDist =
        -mystery.massValue * mysteryDist / known.massValue;
    return BalanceGameChallenge(
      kind: BaChallengeKind.massDeduction,
      initialColumnState: ColumnState.noColumns,
      fixedMassDistancePairs: [
        MassDistancePair(mass: mystery, distance: mysteryDist),
      ],
      movableMasses: [known],
      balancedConfiguration: [
        MassDistancePair(mass: known, distance: solutionDist),
      ],
    );
  }

  BalanceGameChallenge _generateSimpleMassDeduction() {
    final indexOffset = 1 + _randInt(balanceChallengeMasses.length);
    BaMass? known;
    BaMass? mysteryProto;
    for (var i = 0; i < mysteryMasses.length && known == null; i++) {
      mysteryProto = mysteryMasses[(i + indexOffset) % mysteryMasses.length];
      known = _createMassByRatio(mysteryProto.massValue, const [1]);
    }
    final mysteryDist = -_generateRandomValidPlankDistance();
    return _createMassDeduction(
      mysteryProto!.createCopy(),
      mysteryDist,
      known!,
    );
  }

  BalanceGameChallenge _generateEasyMassDeduction() {
    final indexOffset = _randInt(balanceChallengeMasses.length);
    BaMass? known;
    BaMass? mysteryProto;
    for (var i = 0; i < mysteryMasses.length && known == null; i++) {
      mysteryProto = mysteryMasses[(i + indexOffset) % mysteryMasses.length];
      known = _createMassByRatio(mysteryProto.massValue, const [2, 0.5]);
    }
    final possible =
        _getPossibleDistanceList(mysteryProto!.massValue, known!.massValue);
    final mysteryDist = -possible[_randInt(possible.length)];
    return _createMassDeduction(
      mysteryProto.createCopy(),
      mysteryDist,
      known,
    );
  }

  BalanceGameChallenge _generateModerateMassDeduction() {
    final indexOffset = _randInt(balanceChallengeMasses.length);
    BaMass? known;
    BaMass? mysteryProto;
    for (var i = 0; i < mysteryMasses.length && known == null; i++) {
      mysteryProto = mysteryMasses[(i + indexOffset) % mysteryMasses.length];
      known = _createMassByRatio(
        mysteryProto.massValue,
        const [1.5, 3, 1.0 / 3.0, 2.0 / 3.0, 4, 1.0 / 4.0],
      );
    }
    final possible =
        _getPossibleDistanceList(mysteryProto!.massValue, known!.massValue);
    final mysteryDist = -possible[_randInt(possible.length)];
    return _createMassDeduction(
      mysteryProto.createCopy(),
      mysteryDist,
      known,
    );
  }
}
