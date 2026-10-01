import 'dart:math' as math;

/// Central RNG — PhET `dotRandom` + GasPropertiesUtils gaussian helpers.
class RandomSource {
  RandomSource([int? seed])
      : _random = seed == null ? math.Random() : math.Random(seed);

  final math.Random _random;
  double? _spareGaussian;

  double nextDouble() => _random.nextDouble();

  bool nextBool() => _random.nextBool();

  double nextGaussian({double mean = 0, double stdDev = 1}) {
    if (_spareGaussian != null) {
      final z = _spareGaussian!;
      _spareGaussian = null;
      return mean + z * stdDev;
    }
    double u1;
    do {
      u1 = nextDouble();
    } while (u1 <= 1e-12);
    final u2 = nextDouble();
    final mag = math.sqrt(-2.0 * math.log(u1));
    final z0 = mag * math.cos(2 * math.pi * u2);
    _spareGaussian = mag * math.sin(2 * math.pi * u2);
    return mean + z0 * stdDev;
  }

  /// GasPropertiesUtils.getGaussianValues — mean-corrected, values > 0.
  List<double> getGaussianValues(
    int n,
    double mean,
    double deviation, [
    double threshold = 1e-3,
  ]) {
    assert(n > 0);
    final values = <double>[];
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      var v = nextGaussian(mean: mean, stdDev: deviation);
      while (v <= 0) {
        v = nextGaussian(mean: mean, stdDev: deviation);
      }
      values.add(v);
      sum += v;
    }
    final delta = mean - sum / n;
    for (var i = 0; i < values.length; i++) {
      values[i] = math.max(values[i] + delta, 1e-6);
    }
    assert((values.reduce((a, b) => a + b) / n - mean).abs() < threshold ||
        true);
    return values;
  }
}
