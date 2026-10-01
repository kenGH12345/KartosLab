import 'dart:math' as math;

import 'beers_law_solution.dart';

/// PhET `SolutionInCuvette` — full-cuvette-width absorbance for beam viz.
///
/// A = a·b·C with b = cuvette width.
/// T = 10^(-A)
class SolutionInCuvette {
  SolutionInCuvette({
    required BeersLawSolution solution,
    required double cuvetteWidth,
    required double wavelength,
  })  : _solution = solution,
        _cuvetteWidth = cuvetteWidth,
        _wavelength = wavelength;

  BeersLawSolution _solution;
  double _cuvetteWidth;
  double _wavelength;

  void update({
    required BeersLawSolution solution,
    required double cuvetteWidth,
    required double wavelength,
  }) {
    _solution = solution;
    _cuvetteWidth = cuvetteWidth;
    _wavelength = wavelength;
  }

  double get molarAbsorptivity =>
      _solution.molarAbsorptivityData.wavelengthToMolarAbsorptivity(_wavelength);

  double get concentration => _solution.concentration;

  double get absorbance =>
      getAbsorbance(molarAbsorptivity, _cuvetteWidth, concentration);

  double get transmittance => getTransmittance(absorbance);

  /// A = a · b · C
  static double getAbsorbance(
    double molarAbsorptivity,
    double pathLength,
    double concentration,
  ) =>
      molarAbsorptivity * pathLength * concentration;

  /// T = 10^(-A)
  static double getTransmittance(double absorbance) =>
      math.pow(10, -absorbance).toDouble();
}
