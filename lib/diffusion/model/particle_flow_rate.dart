import 'particle.dart';

/// ParticleFlowRate — gas-properties `ParticleFlowRate.ts` @ 7a52c48.
///
/// Flow rate = particles crossing the divider per ps (running average).
/// Not derived from mean velocity.
class ParticleFlowRate {
  ParticleFlowRate({
    required this.dividerX,
    required this.particles,
  });

  /// number of samples used to compute running average
  /// (gas-properties issues/51)
  static const int numberOfSamples = 300;

  final double dividerX;
  final List<DiffusionParticle> particles;

  /// particles/ps toward left (<--)
  double leftFlowRate = 0;

  /// particles/ps toward right (-->)
  double rightFlowRate = 0;

  final List<int> _leftCounts = [];
  final List<int> _rightCounts = [];
  final List<double> _dts = [];

  void reset() {
    leftFlowRate = 0;
    rightFlowRate = 0;
    _leftCounts.clear();
    _rightCounts.clear();
    _dts.clear();
  }

  /// [dtPs] model time delta in ps.
  void step(double dtPs) {
    assert(dtPs > 0);

    var leftCount = 0; // <--
    var rightCount = 0; // -->
    for (var i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      if (p.prevX >= dividerX && p.x < dividerX) {
        leftCount++;
      } else if (p.prevX <= dividerX && p.x > dividerX) {
        rightCount++;
      }
    }
    _leftCounts.add(leftCount);
    _rightCounts.add(rightCount);
    _dts.add(dtPs);

    if (_leftCounts.length > numberOfSamples) {
      _leftCounts.removeAt(0);
      _rightCounts.removeAt(0);
      _dts.removeAt(0);
    }

    final n = _leftCounts.length;
    assert(n == _rightCounts.length && n == _dts.length);

    final leftAverage = _sumInt(_leftCounts) / n;
    final rightAverage = _sumInt(_rightCounts) / n;
    final dtAverage = _sumDouble(_dts) / n;
    leftFlowRate = leftAverage / dtAverage;
    rightFlowRate = rightAverage / dtAverage;
  }

  static double _sumInt(List<int> xs) {
    var s = 0;
    for (final v in xs) {
      s += v;
    }
    return s.toDouble();
  }

  static double _sumDouble(List<double> xs) {
    var s = 0.0;
    for (final v in xs) {
      s += v;
    }
    return s;
  }
}
