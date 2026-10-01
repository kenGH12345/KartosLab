import '../../ba_shared_constants.dart';
import '../ba_enums.dart';
import '../ba_mass.dart';
import '../ba_vector2.dart';

/// Challenge kinds in Balancing Act Game.
enum BaChallengeKind {
  balanceMasses,
  massDeduction,
  tiltPrediction,
}

/// Mass–distance pair used by challenges.
class MassDistancePair {
  const MassDistancePair({required this.mass, required this.distance});
  final BaMass mass;
  final double distance;
}

/// Source: `BalanceGameChallenge.ts` — semantic data only.
class BalanceGameChallenge {
  BalanceGameChallenge({
    required this.kind,
    required this.initialColumnState,
    this.maxAttemptsAllowed = BaGameConstants.defaultMaxAttemptsAllowed,
    List<MassDistancePair>? fixedMassDistancePairs,
    List<BaMass>? movableMasses,
    List<MassDistancePair>? balancedConfiguration,
  })  : fixedMassDistancePairs = fixedMassDistancePairs ?? [],
        movableMasses = movableMasses ?? [],
        balancedConfiguration = balancedConfiguration ?? [];

  final BaChallengeKind kind;
  final ColumnState initialColumnState;
  final int maxAttemptsAllowed;
  final List<MassDistancePair> fixedMassDistancePairs;
  final List<BaMass> movableMasses;
  final List<MassDistancePair> balancedConfiguration;

  bool get showMassEntryDialog => kind == BaChallengeKind.massDeduction;
  bool get showTiltPredictionSelector =>
      kind == BaChallengeKind.tiltPrediction;

  bool _containsEquivalentMass(BaMass mass, List<BaMass> massList) {
    for (final m in massList) {
      if (mass.massValue == m.massValue && mass.type == m.type) {
        return true;
      }
    }
    return false;
  }

  bool _containsEquivalentMasses(List<BaMass> a, List<BaMass> b) {
    if (a.length != b.length) return false;
    for (final m in a) {
      if (!_containsEquivalentMass(m, b)) return false;
    }
    return true;
  }

  List<BaMass> get _fixedMasses =>
      fixedMassDistancePairs.map((p) => p.mass).toList();

  bool usesSameFixedMasses(BalanceGameChallenge that) {
    if (identical(this, that)) return true;
    return _containsEquivalentMasses(_fixedMasses, that._fixedMasses);
  }

  bool usesSameMasses(BalanceGameChallenge that) {
    return usesSameFixedMasses(that) &&
        _containsEquivalentMasses(movableMasses, that.movableMasses);
  }

  bool usesSameFixedMassesAndDistances(BalanceGameChallenge that) {
    if (identical(this, that)) return true;
    if (fixedMassDistancePairs.length != that.fixedMassDistancePairs.length) {
      return false;
    }
    var matchCount = 0;
    for (final a in fixedMassDistancePairs) {
      for (final b in that.fixedMassDistancePairs) {
        if (a.mass.massValue == b.mass.massValue && a.distance == b.distance) {
          matchCount++;
        }
      }
    }
    return matchCount == fixedMassDistancePairs.length;
  }
}

/// Level composition schema from `BalanceGameChallengeFactory.generateChallengeSet`.
/// Difficulty tags only — random generation is vegas-boundary deferred.
abstract final class BaGameLevelDataset {
  static const int levelCount = BaGameConstants.maxLevels;
  static const int challengesPerLevel = BaGameConstants.challengesPerProblemSet;

  /// Ordered challenge kinds per zero-based level (source switch cases).
  static List<BaChallengeKind> challengeKindsForLevel(int level) {
    switch (level) {
      case 0:
        return const [
          BaChallengeKind.balanceMasses, // simple
          BaChallengeKind.tiltPrediction, // simple
          BaChallengeKind.balanceMasses, // easy
          BaChallengeKind.massDeduction, // simple
          BaChallengeKind.tiltPrediction, // simple
          BaChallengeKind.massDeduction, // easy
        ];
      case 1:
        return const [
          BaChallengeKind.tiltPrediction,
          BaChallengeKind.balanceMasses,
          BaChallengeKind.massDeduction,
          BaChallengeKind.tiltPrediction,
          BaChallengeKind.massDeduction,
          BaChallengeKind.balanceMasses,
        ];
      case 2:
        return const [
          BaChallengeKind.balanceMasses,
          BaChallengeKind.massDeduction,
          BaChallengeKind.tiltPrediction,
          BaChallengeKind.balanceMasses,
          BaChallengeKind.tiltPrediction,
          BaChallengeKind.massDeduction,
        ];
      case 3:
        return const [
          BaChallengeKind.tiltPrediction,
          BaChallengeKind.balanceMasses,
          BaChallengeKind.massDeduction,
          BaChallengeKind.tiltPrediction,
          BaChallengeKind.massDeduction,
          BaChallengeKind.balanceMasses,
        ];
      default:
        throw ArgumentError('Invalid level: $level');
    }
  }
}

/// Deterministic challenge factory for Phase 1 tests / oracle.
/// Full random PhET factory remains behind Vegas boundary (P1).
class DeterministicChallengeFactory {
  /// Balance Me: fixed 20 kg at +1.0 m; movable 10 kg; solution at −2.0 m.
  static BalanceGameChallenge balanceMassesSample() {
    final fixed = BaMass.generic(20, const BaVector2(0, 0));
    final movable = BaMass.generic(10, const BaVector2(3, 0));
    return BalanceGameChallenge(
      kind: BaChallengeKind.balanceMasses,
      initialColumnState: ColumnState.singleColumn,
      fixedMassDistancePairs: [
        MassDistancePair(mass: fixed, distance: 1.0),
      ],
      movableMasses: [movable],
      balancedConfiguration: [
        MassDistancePair(mass: movable, distance: -2.0),
      ],
    );
  }

  /// Mass deduction: fixed mystery total 15 kg (e.g. 10+5).
  static BalanceGameChallenge massDeductionSample({double fixedTotal = 15}) {
    final a = BaMass.generic(10, const BaVector2(0, 0), height: 0.3);
    final b = BaMass.generic(5, const BaVector2(0, 0), height: 0.3);
    // Scale so sum == fixedTotal if needed
    assert((a.massValue + b.massValue - fixedTotal).abs() < 1e-9);
    return BalanceGameChallenge(
      kind: BaChallengeKind.massDeduction,
      initialColumnState: ColumnState.doubleColumns,
      fixedMassDistancePairs: [
        MassDistancePair(mass: a, distance: -1.0),
        MassDistancePair(mass: b, distance: -0.5),
      ],
      movableMasses: [],
      balancedConfiguration: [],
    );
  }

  /// Tilt prediction: fixed masses with net torque ≠ 0 (tips right when free).
  static BalanceGameChallenge tiltPredictionSample() {
    final heavy = BaMass.generic(30, const BaVector2(0, 0));
    final light = BaMass.generic(10, const BaVector2(0, 0));
    return BalanceGameChallenge(
      kind: BaChallengeKind.tiltPrediction,
      initialColumnState: ColumnState.doubleColumns,
      fixedMassDistancePairs: [
        MassDistancePair(mass: heavy, distance: 1.0),
        MassDistancePair(mass: light, distance: -1.0),
      ],
      movableMasses: [],
      balancedConfiguration: [],
    );
  }

  /// Builds a 6-challenge set matching kind schema; uses deterministic samples.
  static List<BalanceGameChallenge> generateChallengeSet(int level) {
    final kinds = BaGameLevelDataset.challengeKindsForLevel(level);
    return kinds.map((kind) {
      if (kind == BaChallengeKind.balanceMasses) {
        return balanceMassesSample();
      }
      if (kind == BaChallengeKind.massDeduction) {
        return massDeductionSample();
      }
      return tiltPredictionSample();
    }).toList();
  }
}
