import 'dart:ui';

/// Constants from PhET `BLLConstants` + Beer's Law screen defaults.
abstract final class BeersLawConstants {
  static const Size layoutBounds = Size(1100, 700);

  /// Model→view: 1 cm = 125 px (`BeersLawScreen.ts`).
  static const double modelViewScale = 125;

  static const double minWavelength = 380; // nm
  static const double maxWavelength = 780; // nm
  static const int numberOfVisibleWavelengths = 401; // 780 − 380 + 1

  static const double wavelengthStep = 1; // nm

  /// Cuvette width range (cm) — `BLLConstants.CUVETTE_WIDTH_RANGE`.
  static const double cuvetteWidthMin = 0.5;
  static const double cuvetteWidthMax = 2.0;
  static const double cuvetteWidthDefault = 1.0;
  static const double cuvetteHeight = 3.0; // cm

  /// Default snap interval (cm) — `BLLQueryParameters.cuvetteSnapInterval`.
  static const double cuvetteSnapIntervalDefault = 0.1;
  static const double cuvetteSnapIntervalMin = 0;
  static const double cuvetteSnapIntervalMax = 0.5;

  static const double lightLensDiameter = 0.45; // cm

  /// Detector probe sensor diameter (cm).
  static const double detectorSensorDiameter = 0.57;

  /// Ruler size (cm).
  static const double rulerLength = 2.1;
  static const double rulerHeight = 0.35;

  /// Beam visualization alphas (`Beam.ts`).
  static const double maxLightAlpha = 0.78;
  static const double minLightAlpha = 0.078;
  static const double maxLightWidth = 50; // cm

  /// Display decimal places (`BLLConstants`).
  static const int decimalPlacesAbsorbance = 2;
  static const int decimalPlacesTransmittance = 2;
  static const int decimalPlacesWavelength = 0;
  static const int decimalPlacesConcentrationMolar = 0;
  static const int decimalPlacesCuvetteWidth = 2;

  /// Water color — `BLLColors.WATER`.
  static const Color waterColor = Color.fromARGB(255, 224, 255, 255);

  // --- Default positions (cm), relative to cuvette top-left (3.3, 0.5) ---

  static const Offset cuvettePosition = Offset(3.3, 0.5);

  /// Light at cuvette.x−1.5, cuvette.y+height/2 → (1.8, 2.0).
  static const Offset lightPosition = Offset(1.8, 2.0);

  /// Detector body: cuvette.x+3, cuvette.y−0.3 → (6.3, 0.2).
  static const Offset detectorBodyPosition = Offset(6.3, 0.2);

  /// Detector probe: cuvette.x+3, light.y → (6.3, 2.0).
  static const Offset detectorProbePosition = Offset(6.3, 2.0);

  static const Rect detectorProbeDragBounds = Rect.fromLTRB(0, 0, 7.9, 5.25);

  /// Ruler: cuvette.x−2.6, cuvette.y+4 → (0.7, 4.5).
  static const Offset rulerPosition = Offset(0.7, 4.5);
  static const Rect rulerDragBounds = Rect.fromLTRB(0, 0, 6, 5);

  /// Probe Y-snap threshold on drag end: 0.5 × lensDiameter (`DetectorProbeNode`).
  static const double probeBeamSnapThreshold =
      lightLensDiameter / 2; // 0.225 cm
}
