import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../blackbody_spectrum_constants.dart';
import '../model/blackbody_body_model.dart';

/// Immutable render data computed from the model, passed to painters.
/// Painters read this and never modify business state.
class BlackbodyRenderData {
  BlackbodyRenderData({
    required this.mainBody,
    required this.savedBodyOne,
    required this.savedBodyTwo,
    required this.graphValuesVisible,
    required this.intensityVisible,
    required this.labelsVisible,
    required this.wavelengthMax,
    required this.verticalZoom,
    required this.graphPointWavelength,
    required this.cueingArrowsVisible,
  });

  final BlackbodyBodyModel mainBody;
  final BlackbodyBodyModel savedBodyOne;
  final BlackbodyBodyModel savedBodyTwo;
  final bool graphValuesVisible;
  final bool intensityVisible;
  final bool labelsVisible;
  final double wavelengthMax;
  final double verticalZoom;
  final double graphPointWavelength;
  final bool cueingArrowsVisible;

  /// Spectral power density → view Y coordinate.
  /// [来源: ZoomableAxesView.js:353-356]
  double spectralPowerDensityToViewY(double spd) {
    return -BlackbodySpectrumConstants.spectralPowerDensityConversionFactor *
        _lerp(0, verticalZoom, 0, BlackbodySpectrumConstants.axesHeight, spd);
  }

  /// Wavelength → view X coordinate.
  /// [来源: ZoomableAxesView.js:333-335]
  double wavelengthToViewX(double wavelength) {
    return _lerp(0, wavelengthMax, 0, BlackbodySpectrumConstants.axesWidth, wavelength);
  }

  /// View X → wavelength.
  /// [来源: ZoomableAxesView.js:343-345]
  double viewXToWavelength(double viewX) {
    return _lerp(0, BlackbodySpectrumConstants.axesWidth, 0, wavelengthMax, viewX);
  }

  /// Sample curve points for a body (300 points + forced peak insertion).
  /// [来源: GraphDrawingNode.js:206-226]
  List<Offset> sampleCurvePoints(BlackbodyBodyModel body) {
    if (body.temperature == null) return [];

    final n = BlackbodySpectrumConstants.graphNumberPoints;
    final deltaWavelength = wavelengthMax / (n - 1);
    final xOffset = BlackbodySpectrumConstants.axesWidth / (n - 1);
    final yCutoff = BlackbodySpectrumConstants.axesHeight + 2;
    final peak = body.peakWavelength;
    final points = <Offset>[];

    bool peakInserted = false;
    for (var i = 0; i < n; i++) {
      final wl = deltaWavelength * i;

      // Insert peak wavelength point before the first sample past it.
      if (!peakInserted && peak > 0 && wl > peak && i > 0) {
        final yPeak = spectralPowerDensityToViewY(
          body.getSpectralPowerDensityAt(peak),
        );
        points.add(Offset(
          wavelengthToViewX(peak),
          yPeak.clamp(-yCutoff.toDouble(), 0.0),
        ));
        peakInserted = true;
      }

      final spd = body.getSpectralPowerDensityAt(wl);
      final y = spectralPowerDensityToViewY(spd);
      points.add(Offset(xOffset * i, y.clamp(-yCutoff.toDouble(), 0.0)));
    }

    return points;
  }

  /// Spectral power density at the graph point's current wavelength.
  double get graphPointSpd {
    return mainBody.getSpectralPowerDensityAt(graphPointWavelength);
  }

  /// Total intensity formatted as scientific notation string.
  /// [来源: BlackbodySpectrumControlPanel.js:140-157]
  String get intensityText {
    final value = mainBody.totalIntensity;
    if (value == 0) return '0 W/m²';
    return '${_formatScientific(value)} W/m²';
  }

  /// Graph point wavelength text (nm → µm, 3 decimals).
  /// [来源: GraphValuesPointNode.js:184-190]
  String get graphPointWavelengthText {
    return '${(graphPointWavelength / 1000).toStringAsFixed(3)} µm';
  }

  /// Graph point SPD text.
  /// [来源: GraphValuesPointNode.js:192-202]
  String get graphPointSpdText {
    final spd = graphPointSpd *
        BlackbodySpectrumConstants.spectralPowerDensityConversionFactor;
    if (spd < 0.01 && spd != 0) {
      return _formatScientific(spd);
    }
    return spd.toStringAsPrecision(4);
  }

  String _formatScientific(double value) {
    if (value == 0) return '0';
    final absValue = value.abs();
    final log10 = math.log(absValue) / math.ln10;
    final exponent = log10.floor();
    final mantissa = value / math.pow(10, exponent);
    final mStr = mantissa.toStringAsFixed(0);
    return '$mStr × 10^$exponent';
  }

  static double _lerp(double a, double b, double c, double d, double v) {
    if (b == a) return c;
    return c + ((v - a) / (b - a)) * (d - c);
  }
}
