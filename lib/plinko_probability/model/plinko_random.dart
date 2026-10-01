import 'dart:math' as math;

/// Seedable RNG matching PhET `dotRandom` usage in Plinko Probability.
class PlinkoRandom {
  PlinkoRandom([int? seed]) : _random = math.Random(seed);

  final math.Random _random;

  double nextDouble() => _random.nextDouble();

  bool nextBoolean() => _random.nextBool();
}
