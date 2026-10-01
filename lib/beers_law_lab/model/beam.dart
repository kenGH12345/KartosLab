import 'dart:ui';

import 'package:kratos/color_vision/model/visible_color.dart';

import 'beers_law_constants.dart';
import 'cuvette.dart';
import 'detector.dart';
import 'light.dart';
import 'solution_in_cuvette.dart';

/// Beam left/right color stops for LinearGradient (view will paint).
class BeamFill {
  const BeamFill({
    required this.baseColor,
    required this.leftAlpha,
    required this.rightAlpha,
    required this.cuvetteLeftX,
    required this.cuvetteWidthCm,
  });

  final Color baseColor;
  final double leftAlpha;
  final double rightAlpha;

  /// Model X of cuvette left (cm) — gradient spans cuvette width only.
  final double cuvetteLeftX;
  final double cuvetteWidthCm;
}

/// PhET `Beam` — reactive; no step(). Properties in model units (cm).
class Beam {
  Beam({
    required Light light,
    required Cuvette cuvette,
    required Detector detector,
    required SolutionInCuvette solutionInCuvette,
  })  : _light = light,
        _cuvette = cuvette,
        _detector = detector,
        _solutionInCuvette = solutionInCuvette;

  final Light _light;
  final Cuvette _cuvette;
  final Detector _detector;
  final SolutionInCuvette _solutionInCuvette;

  bool get isVisible => _light.isOn;

  /// Beam length in cm: to probe if in beam, else [BeersLawConstants.maxLightWidth].
  double get lengthCm {
    if (!_light.isOn) return 0;
    if (_detector.isProbeInBeam(_light)) {
      return _detector.probePosition.dx - _light.position.dx;
    }
    return BeersLawConstants.maxLightWidth;
  }

  double get heightCm => _light.lensDiameter;

  Offset get origin => Offset(
        _light.position.dx,
        _light.position.dy - _light.lensDiameter / 2,
      );

  /// Wavelength → Color via PhET-compatible [VisibleColor].
  Color get wavelengthColor =>
      VisibleColor.wavelengthToColor(_light.wavelength);

  BeamFill? get fill {
    if (!_light.isOn) return null;
    final t = _solutionInCuvette.transmittance;
    // linear(0, 1, MIN_ALPHA, MAX_ALPHA, transmittance)
    final rightAlpha = BeersLawConstants.minLightAlpha +
        (BeersLawConstants.maxLightAlpha - BeersLawConstants.minLightAlpha) * t;
    return BeamFill(
      baseColor: wavelengthColor,
      leftAlpha: BeersLawConstants.maxLightAlpha,
      rightAlpha: rightAlpha,
      cuvetteLeftX: _cuvette.position.dx,
      cuvetteWidthCm: _cuvette.width,
    );
  }
}
