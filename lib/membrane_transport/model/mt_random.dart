import 'dart:math' as math;

/// Injectable RNG for Membrane Transport core — mirrors PhET `dotRandom`.
///
/// Production may use [SystemMtRandom]; tests must use [SeededMtRandom].
abstract class MtRandom {
  double nextDouble();

  /// Inclusive [min], exclusive-ish continuous range like PhET `nextDoubleBetween`.
  double nextDoubleBetween(double min, double max) =>
      min + nextDouble() * (max - min);

  int nextInt(int max);

  List<T> shuffle<T>(List<T> list) {
    final copy = List<T>.from(list);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  T sample<T>(List<T> items) {
    assert(items.isNotEmpty);
    return items[nextInt(items.length)];
  }

  /// Box-Muller transform matching PhET `boxMullerTransform(mean, stdDev, random)`.
  double boxMuller(double mean, double stdDev) {
    double u1;
    do {
      u1 = nextDouble();
    } while (u1 <= 1e-12);
    final u2 = nextDouble();
    final mag = math.sqrt(-2.0 * math.log(u1));
    final z0 = mag * math.cos(2 * math.pi * u2);
    return mean + z0 * stdDev;
  }
}

class SeededMtRandom implements MtRandom {
  SeededMtRandom(int seed) : _rng = math.Random(seed);

  final math.Random _rng;

  @override
  double nextDouble() => _rng.nextDouble();

  @override
  double nextDoubleBetween(double min, double max) =>
      min + nextDouble() * (max - min);

  @override
  int nextInt(int max) => _rng.nextInt(max);

  @override
  List<T> shuffle<T>(List<T> list) {
    final copy = List<T>.from(list);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  @override
  T sample<T>(List<T> items) {
    assert(items.isNotEmpty);
    return items[nextInt(items.length)];
  }

  @override
  double boxMuller(double mean, double stdDev) {
    double u1;
    do {
      u1 = nextDouble();
    } while (u1 <= 1e-12);
    final u2 = nextDouble();
    final mag = math.sqrt(-2.0 * math.log(u1));
    final z0 = mag * math.cos(2 * math.pi * u2);
    return mean + z0 * stdDev;
  }
}

class SystemMtRandom implements MtRandom {
  SystemMtRandom() : _rng = math.Random();

  final math.Random _rng;

  @override
  double nextDouble() => _rng.nextDouble();

  @override
  double nextDoubleBetween(double min, double max) =>
      min + nextDouble() * (max - min);

  @override
  int nextInt(int max) => _rng.nextInt(max);

  @override
  List<T> shuffle<T>(List<T> list) {
    final copy = List<T>.from(list);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  @override
  T sample<T>(List<T> items) {
    assert(items.isNotEmpty);
    return items[nextInt(items.length)];
  }

  @override
  double boxMuller(double mean, double stdDev) {
    double u1;
    do {
      u1 = nextDouble();
    } while (u1 <= 1e-12);
    final u2 = nextDouble();
    final mag = math.sqrt(-2.0 * math.log(u1));
    final z0 = mag * math.cos(2 * math.pi * u2);
    return mean + z0 * stdDev;
  }
}
