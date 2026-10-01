import 'dart:math' as math;

/// Injectable RNG — no global [math.Random] in numerical core.
abstract class QwiRandom {
  double nextDouble();

  int nextInt(int max);
}

class SeededQwiRandom implements QwiRandom {
  SeededQwiRandom(int seed) : _rng = math.Random(seed);

  final math.Random _rng;

  @override
  double nextDouble() => _rng.nextDouble();

  @override
  int nextInt(int max) => _rng.nextInt(max);
}

class SystemQwiRandom implements QwiRandom {
  SystemQwiRandom() : _rng = math.Random();

  final math.Random _rng;

  @override
  double nextDouble() => _rng.nextDouble();

  @override
  int nextInt(int max) => _rng.nextInt(max);
}
