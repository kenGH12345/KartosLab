import 'dart:math' as math;

/// Seedable RNG with Box-Muller Gaussian — for tests and thermostats.
class SomRandom {
  SomRandom([int? seed]) : _random = math.Random(seed);

  final math.Random _random;
  double? _spareGaussian;

  double nextDouble() => _random.nextDouble();

  /// Standard normal via Box-Muller.
  double nextGaussian() {
    if (_spareGaussian != null) {
      final g = _spareGaussian!;
      _spareGaussian = null;
      return g;
    }
    double u;
    double v;
    double s;
    do {
      u = nextDouble() * 2 - 1;
      v = nextDouble() * 2 - 1;
      s = u * u + v * v;
    } while (s >= 1 || s == 0);
    final mul = math.sqrt(-2 * math.log(s) / s);
    _spareGaussian = v * mul;
    return u * mul;
  }
}
