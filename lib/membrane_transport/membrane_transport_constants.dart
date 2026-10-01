import 'dart:math' as math;

import 'model/mt_vec2.dart';

/// Model / observation constants from PhET `MembraneTransportConstants.ts`.
class MembraneTransportConstants {
  MembraneTransportConstants._();

  static const double typicalSpeed = 30;

  static const double observationWindowWidth = 534;
  static const double observationWindowHeight = 400;

  static const double crossingCooldown = 10;

  static const double modelWidth = 200;
  static final double modelHeight =
      modelWidth * observationWindowHeight / observationWindowWidth;

  static const int ligandCount = 7;
  static const int maxSoluteCount = 200;
  static const double transportProteinWidth = 25;

  static const double screenViewXMargin = 8;
  static const double screenViewYMargin = 8;

  static const double overallArtworkScale = 0.1;

  static const double mvtScale = observationWindowWidth / modelWidth;

  static const double membraneMinY = -10;
  static const double membraneMaxY = 10;
  static const double membraneMinX = -modelWidth / 2;
  static const double membraneMaxX = modelWidth / 2;

  static const double captureRadius = (membraneMaxY - membraneMinY) / 2 * 4;

  static const double biasThreshold = 0.1;
  static const double gradientBiasStrength = 0.9;

  static const double gasNearEquilibriumCrossProbability = 0.90;

  static const int slotCount = 7;
  static const double slotMaxX = 84;

  static final List<double> slotPositions = _computeSlotPositions();

  static List<double> _computeSlotPositions() {
    const spacing = (slotMaxX * 2) / (slotCount - 1);
    return List.generate(slotCount, (i) => i * spacing - slotMaxX);
  }

  static double get insideMinY => -modelHeight / 2;
  static double get insideMaxY => membraneMinY;
  static double get outsideMinY => membraneMaxY;
  static double get outsideMaxY => modelHeight / 2;

  static double viewSizeToModel(double viewPx) =>
      (viewPx * overallArtworkScale) / mvtScale;

  static MtSize modelDimensionForViewBox(double viewW, double viewH) => MtSize(
        viewSizeToModel(viewW),
        viewSizeToModel(viewH),
      );

  static double clamp(double v, double lo, double hi) =>
      math.max(lo, math.min(hi, v));
}

/// Approximate particle model sizes from SVG viewBoxes × artwork scale × MVT.
class ParticleModelDimensions {
  ParticleModelDimensions._();

  static MtSize of(String type) {
    switch (type) {
      case 'oxygen':
        return MembraneTransportConstants.modelDimensionForViewBox(150, 98);
      case 'carbonDioxide':
        return MembraneTransportConstants.modelDimensionForViewBox(200, 110);
      case 'sodiumIon':
        return MembraneTransportConstants.modelDimensionForViewBox(130, 130);
      case 'potassiumIon':
        return MembraneTransportConstants.modelDimensionForViewBox(180, 180);
      case 'glucose':
        return MembraneTransportConstants.modelDimensionForViewBox(
          303.22,
          239.79,
        );
      case 'atp':
        return MembraneTransportConstants.modelDimensionForViewBox(
          387.62,
          1014.5,
        );
      case 'adp':
        return MembraneTransportConstants.modelDimensionForViewBox(
          387.62,
          854.49,
        );
      case 'phosphate':
        return MembraneTransportConstants.modelDimensionForViewBox(
          193.91,
          193.91,
        );
      case 'triangleLigand':
        return MembraneTransportConstants.modelDimensionForViewBox(
          206.35,
          143.52,
        );
      case 'starLigand':
        return MembraneTransportConstants.modelDimensionForViewBox(
          263.88,
          228.53,
        );
      default:
        return const MtSize(4, 4);
    }
  }
}
