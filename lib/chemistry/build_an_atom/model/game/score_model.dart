/// Score / star progress data — vegas `ScoreDisplayStars` proportion math.
library;

import '../../constants/baa_constants.dart';

/// Star fill state derived from score / perfectScore.
class StarProgress {
  const StarProgress({
    required this.score,
    this.numberOfStars = BAAConstants.challengesPerLevel,
    this.perfectScore = BAAConstants.maxPointsPerGameLevel,
  });

  final int score;
  final int numberOfStars;
  final int perfectScore;

  double get proportion =>
      perfectScore == 0 ? 0 : score / perfectScore;

  int get filledStars {
    final p = proportion * numberOfStars;
    return p.floor().clamp(0, numberOfStars);
  }

  /// Fractional remainder after filled stars (0..1), used for half-star.
  double get remainder {
    final p = proportion * numberOfStars;
    final r = p - filledStars;
    return r > 1e-6 ? r : 0;
  }

  bool get hasHalfStar => remainder > 1e-6;

  int get emptyStars {
    final used = filledStars + (hasHalfStar ? 1 : 0);
    return (numberOfStars - used).clamp(0, numberOfStars);
  }

  /// Accessible star count rounded to 1 decimal (vegas `toFixedNumber(..., 1)`).
  double get accessibleStarCount {
    final v = filledStars + remainder;
    return (v * 10).roundToDouble() / 10;
  }
}

/// Points awarded for a correct answer given attempt count (1-based).
int pointsForAttempt(int attempts) {
  if (attempts <= 1) return BAAConstants.pointsFirstAttempt;
  return BAAConstants.pointsSecondAttempt;
}
