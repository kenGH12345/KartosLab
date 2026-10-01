import 'dart:math';

import '../data/game_equation_pool1.dart';
import '../data/game_equation_pool2.dart';
import '../data/game_equation_pool3.dart';
import '../model/bce_molecule.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';
import 'equation_pool.dart';

/// Show Why visualization mode (subset of ViewMode used by Game levels).
enum ShowWhyViewMode {
  balanceScales,
  barCharts,
}

/// PhET `GameLevel` base + Level1/2/3 factories.
class GameLevel {
  GameLevel({
    required this.levelNumber,
    required this.iconMolecule,
    required this.coefficientsRange,
    required EquationPool equationPool,
    required this.getViewMode,
  }) : _equationPool = equationPool;

  static const challengesPerGame = 5;
  static const pointsFirstAttempt = 2;
  static const pointsSecondAttempt = 1;

  final int levelNumber;
  final BceMolecule iconMolecule;
  final CoefficientRange coefficientsRange;
  final EquationPool _equationPool;
  final ShowWhyViewMode Function() getViewMode;

  int bestScore = 0;
  int bestTime = 0;

  void reset() {
    bestScore = 0;
    bestTime = 0;
  }

  Equation getEquation(int index) => _equationPool.getEquation(index);

  int getNumberOfChallenges() => challengesPerGame;

  int getPerfectScore() => getNumberOfChallenges() * pointsFirstAttempt;

  bool isPerfectScore(int points) => points == getPerfectScore();

  List<Equation> getChallenges() {
    _equationPool.reset();
    return _equationPool.getEquations(getNumberOfChallenges());
  }

  int get poolSize => _equationPool.poolSize;

  void disposePool() {
    for (var i = 0; i < _equationPool.poolSize; i++) {
      _equationPool.getEquation(i).dispose();
    }
  }

  static GameLevel level1({Random? random, int? initialCoefficient}) {
    final pool = GameEquationPool1.createAll(initialCoefficient: initialCoefficient);
    return GameLevel(
      levelNumber: 1,
      iconMolecule: BceMolecule.hCl,
      coefficientsRange: BceCoefficientRanges.game,
      equationPool: EquationPool(
        pool: pool,
        firstBigMolecule: GameEquationPool1.firstBigMolecule,
        random: random,
      ),
      getViewMode: () => ShowWhyViewMode.balanceScales,
    );
  }

  static GameLevel level2({Random? random, int? initialCoefficient}) {
    final rng = random ?? Random();
    final pool = GameEquationPool2.createAll(initialCoefficient: initialCoefficient);
    return GameLevel(
      levelNumber: 2,
      iconMolecule: BceMolecule.h2o,
      coefficientsRange: BceCoefficientRanges.game,
      equationPool: EquationPool(pool: pool, random: rng),
      getViewMode: () => rng.nextDouble() < 0.5
          ? ShowWhyViewMode.balanceScales
          : ShowWhyViewMode.barCharts,
    );
  }

  static GameLevel level3({Random? random, int? initialCoefficient}) {
    final pool = GameEquationPool3.createAll(initialCoefficient: initialCoefficient);
    final exclusions = <Equation, List<Equation>>{};
    for (final entry in GameEquationPool3.exclusionIndices.entries) {
      exclusions[pool[entry.key]] = [
        for (final i in entry.value) pool[i],
      ];
    }
    return GameLevel(
      levelNumber: 3,
      iconMolecule: BceMolecule.nh3,
      coefficientsRange: BceCoefficientRanges.game,
      equationPool: EquationPool(
        pool: pool,
        exclusionsMap: exclusions,
        random: random,
      ),
      getViewMode: () => ShowWhyViewMode.barCharts,
    );
  }
}
