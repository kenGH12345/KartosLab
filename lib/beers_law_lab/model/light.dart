import 'dart:ui';

import 'beers_law_constants.dart';
import 'beers_law_solution.dart';
import 'light_mode.dart';

/// PhET `Light` — origin at lens center (cm).
class Light {
  Light({
    required BeersLawSolution initialSolution,
    this.position = BeersLawConstants.lightPosition,
    this.lensDiameter = BeersLawConstants.lightLensDiameter,
  })  : _isOn = false,
        _mode = LightMode.preset,
        _wavelength = initialSolution.lambdaMax,
        _initialWavelength = initialSolution.lambdaMax;

  final Offset position;
  final double lensDiameter;

  bool _isOn;
  double _wavelength;
  final double _initialWavelength;
  LightMode _mode;

  bool get isOn => _isOn;
  double get wavelength => _wavelength;
  LightMode get mode => _mode;

  double get minY => position.dy - lensDiameter / 2;
  double get maxY => position.dy + lensDiameter / 2;

  void setOn(bool value) => _isOn = value;

  /// Sets wavelength only when mode is [LightMode.variable], clamped to range.
  /// In PRESET, wavelength is forced to λ_max via [applySolution] / [setMode].
  void setWavelength(double nm) {
    if (_mode == LightMode.preset) return;
    _wavelength = nm.clamp(
      BeersLawConstants.minWavelength,
      BeersLawConstants.maxWavelength,
    );
  }

  /// Force wavelength (used internally for PRESET / solution change / reset).
  void forceWavelength(double nm) {
    _wavelength = nm.clamp(
      BeersLawConstants.minWavelength,
      BeersLawConstants.maxWavelength,
    );
  }

  void setMode(LightMode mode, BeersLawSolution currentSolution) {
    _mode = mode;
    if (mode == LightMode.preset) {
      forceWavelength(currentSolution.lambdaMax);
    }
  }

  /// Source: solutionProperty.link → wavelength = λ_max (always).
  void applySolution(BeersLawSolution solution) {
    forceWavelength(solution.lambdaMax);
  }

  void reset() {
    _isOn = false;
    _mode = LightMode.preset;
    _wavelength = _initialWavelength;
  }
}
