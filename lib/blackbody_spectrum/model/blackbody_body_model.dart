import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../blackbody_spectrum_constants.dart';

/// Physical model for a single blackbody at a given temperature.
///
/// Direct port of PhET `BlackbodyBodyModel.js`. All formulas and constants
/// are sourced from the original PhET source code.
///
/// [来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:27-234]
class BlackbodyBodyModel {
  BlackbodyBodyModel(this.temperature);

  /// Temperature in Kelvin; null means this body doesn't exist (saved slot unused).
  /// [来源: BlackbodyBodyModel.js:37-42]
  double? temperature;

  /// Planck's Law spectral power density.
  ///
  /// Returns MW/m²/µm for a given wavelength (nm).
  /// [来源: BlackbodyBodyModel.js:75-85]
  double getSpectralPowerDensityAt(double wavelength) {
    final t = temperature;
    if (t == null || wavelength == 0) return 0;

    final a = BlackbodySpectrumConstants.planckConstantA;
    final b = BlackbodySpectrumConstants.planckConstantB;
    final exponent = b / (wavelength * t);
    // Guard against overflow for very short wavelengths / low temperatures.
    if (exponent > 700) return 0;
    return a / (math.pow(wavelength, 5) * (math.exp(exponent) - 1));
  }

  /// Dimensionless normalized temperature for star sizing.
  /// [来源: BlackbodyBodyModel.js:94-103]
  double get renormalizedTemperature {
    final t = temperature;
    if (t == null) return 0;
    final draper = BlackbodySpectrumConstants.draperPoint;
    final relTemp = math.max(t, draper) - draper;
    return BlackbodySpectrumConstants.normalizationScaling *
        math.pow(relTemp, BlackbodySpectrumConstants.powerExponent);
  }

  /// Color intensity (0-255) for a given wavelength.
  /// [来源: BlackbodyBodyModel.js:113-121]
  int getRenormalizedColorIntensity(double wavelength) {
    final red = getSpectralPowerDensityAt(BlackbodySpectrumConstants.redWavelength);
    final green = getSpectralPowerDensityAt(BlackbodySpectrumConstants.greenWavelength);
    final blue = getSpectralPowerDensityAt(BlackbodySpectrumConstants.blueWavelength);
    final largest = math.max(red, math.max(green, blue));
    if (largest == 0) return 0;
    final current = getSpectralPowerDensityAt(wavelength);
    final bounded = math.min(renormalizedTemperature, 1.0);
    return (255 * bounded * current / largest).floor().clamp(0, 255);
  }

  /// Stefan-Boltzmann total intensity (W/m²).
  /// [来源: BlackbodyBodyModel.js:130-133]
  double get totalIntensity {
    final t = temperature;
    if (t == null) return 0;
    return BlackbodySpectrumConstants.stefanBoltzmannConstant *
        math.pow(t, 4);
  }

  /// Wien's displacement peak wavelength (nm).
  /// [来源: BlackbodyBodyModel.js:144-148]
  double get peakWavelength {
    final t = temperature;
    if (t == null || t <= 0) return 0;
    return 1e9 * BlackbodySpectrumConstants.wienConstant / t;
  }

  /// Red channel color.
  /// [来源: BlackbodyBodyModel.js:157-160]
  Color get redColor {
    final i = getRenormalizedColorIntensity(BlackbodySpectrumConstants.redWavelength);
    return Color.fromRGBO(i, 0, 0, 1);
  }

  /// Green channel color.
  /// [来源: BlackbodyBodyModel.js:181-184]
  Color get greenColor {
    final i = getRenormalizedColorIntensity(BlackbodySpectrumConstants.greenWavelength);
    return Color.fromRGBO(0, i, 0, 1);
  }

  /// Blue channel color.
  /// [来源: BlackbodyBodyModel.js:169-172]
  Color get blueColor {
    final i = getRenormalizedColorIntensity(BlackbodySpectrumConstants.blueWavelength);
    return Color.fromRGBO(0, 0, i, 1);
  }

  /// Combined star color.
  /// [来源: BlackbodyBodyModel.js:225-230]
  Color get starColor {
    final r = getRenormalizedColorIntensity(BlackbodySpectrumConstants.redWavelength);
    final g = getRenormalizedColorIntensity(BlackbodySpectrumConstants.greenWavelength);
    final b = getRenormalizedColorIntensity(BlackbodySpectrumConstants.blueWavelength);
    return Color.fromRGBO(r, g, b, 1);
  }

  /// Star halo radius (px).
  /// [来源: BlackbodyBodyModel.js:194-202]
  double get glowingStarHaloRadius {
    return _lerp(
      0, 2,
      BlackbodySpectrumConstants.glowingStarHaloMinimumRadius,
      BlackbodySpectrumConstants.glowingStarHaloMaximumRadius,
      renormalizedTemperature,
    );
  }

  /// Star halo color (star color with alpha).
  /// [来源: BlackbodyBodyModel.js:212-215]
  Color get glowingStarHaloColor {
    final alpha = _lerp(0, 1, 0, 0.3, renormalizedTemperature);
    return starColor.withValues(alpha: alpha);
  }

  static double _lerp(double a, double b, double c, double d, double v) {
    if (b == a) return c;
    final t = ((v - a) / (b - a)).clamp(0.0, 1.0);
    return c + t * (d - c);
  }
}
