/// Injectable RNG for Quantum Measurement core models.
/// Mirrors PhET `dotRandom` / `dot.Random` usage for measurement sampling.
///
/// Production: [SystemQmRandom]. Tests: [SeededQmRandom].
library;

import 'dart:math' as math;

abstract class QmRandom {
  double nextDouble();

  int nextInt(int maxExclusive);

  /// Returns value in `[0, 1)` never exactly `0` — matches CoinSet seed generation
  /// which rejects `0` because seed `0`/`1` are reserved for all-same outcomes.
  double nextNonZeroDouble() {
    double v;
    do {
      v = nextDouble();
    } while (v == 0.0);
    return v;
  }
}

/// Deterministic RNG for tests. Same seed ⇒ same sequence.
class SeededQmRandom extends QmRandom {
  SeededQmRandom(int seed) : _rng = math.Random(seed);

  /// Builds from a continuous seed in (0, 1] as used by CoinSet.seedProperty.
  /// Maps to an int seed via floor(seed * 1e9) for Dart Random compatibility.
  /// Note: not bit-identical to PhET `dot.Random({seed})` algorithm; deterministic
  /// within Flutter test suite only. See RNG_SPEC.md.
  factory SeededQmRandom.fromUnitInterval(double unitSeed) {
    assert(unitSeed > 0 && unitSeed <= 1);
    final intSeed = (unitSeed * 1e9).floor().clamp(1, 0x7fffffff);
    return SeededQmRandom(intSeed);
  }

  final math.Random _rng;

  @override
  double nextDouble() => _rng.nextDouble();

  @override
  int nextInt(int maxExclusive) => _rng.nextInt(maxExclusive);
}

class SystemQmRandom extends QmRandom {
  SystemQmRandom() : _rng = math.Random();

  final math.Random _rng;

  @override
  double nextDouble() => _rng.nextDouble();

  @override
  int nextInt(int maxExclusive) => _rng.nextInt(maxExclusive);
}
