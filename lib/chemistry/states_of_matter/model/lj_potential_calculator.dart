import 'dart:math' as math;

import '../som_constants.dart';

/// Real (non-normalized) Lennard-Jones potential calculator — PhET LjPotentialCalculator.
class LjPotentialCalculator {
  LjPotentialCalculator(this._sigma, this._epsilon)
      : assert(_sigma > 0, 'sigma must be greater than 0'),
        _epsilonForCalcs = _epsilon * SomConstants.kBoltzmann;

  double _sigma;
  double _epsilon;
  double _epsilonForCalcs;

  double getSigma() => _sigma;

  void setSigma(double sigma) {
    _sigma = sigma;
  }

  double getEpsilon() => _epsilon;

  void setEpsilon(double epsilon) {
    _epsilon = epsilon;
    _epsilonForCalcs = _epsilon * SomConstants.kBoltzmann;
  }

  /// Potential in N·m for [distance] in picometers.
  double getLjPotential(double distance) {
    final distanceRatio = _sigma / distance;
    return 4 *
        _epsilonForCalcs *
        (math.pow(distanceRatio, 12) - math.pow(distanceRatio, 6));
  }

  /// Repulsive LJ force component in newtons.
  double getRepulsiveLjForce(double distance) {
    return 48 *
        _epsilonForCalcs *
        math.pow(_sigma, 12) /
        math.pow(distance, 13);
  }

  /// Attractive LJ force component in newtons.
  double getAttractiveLjForce(double distance) {
    return 24 *
        _epsilonForCalcs *
        math.pow(_sigma, 6) /
        math.pow(distance, 7);
  }

  /// Distance (pm) where attractive and repulsive forces balance.
  double getMinimumForceDistance() {
    return _sigma * math.pow(2, 1 / 6);
  }
}
