/// Charges and Fields — constants from PhET ChargesAndFieldsConstants.ts
class CafConstants {
  CafConstants._();

  /// Prefactor: E = k·Q/r² with Q in nC, r in m, E in V/m.
  static const double kConstant = 9.0;

  static const double width = 8.0; // meters (dev layout)
  static const double height = 5.0; // meters

  static const double gridMajorSpacing = 0.5;
  static const int minorGridlinesPerMajor = 5;
  static double get gridMinorSpacing =>
      gridMajorSpacing / minorGridlinesPerMajor; // 0.1 m

  static const double electricFieldSensorSpacing = 0.5;
  static const double electricPotentialSensorSpacing = 0.1;

  static const double animationVelocity = 2.0; // m/s

  static const double chargeRadius = 12.0; // scenery / view px
  static const double electricFieldSensorCircleRadius = 7.0;
  static const double panelLineWidth = 2.0;

  static const double maxEFieldMagnitude = 1e6; // V/m
  static const double eFieldColorSatMagnitude = 5.0; // V/m

  static const double minDistanceScale = 1e-9;
  static const double equipotentialMinChargeDistance = 0.03;

  static const double maxElectricPotential = 40.0; // V saturation
  static const double minElectricPotential = -40.0;

  /// Joist ScreenView default layout bounds.
  static const double layoutWidth = 1024.0;
  static const double layoutHeight = 618.0;

  static const double resetAllRadius = 20.8;

  // Equipotential line search
  static const int maxEquipotentialSteps = 5000;
  static const int minEquipotentialSteps = 1000;
  static const double maxEpsilonDistance = 0.05;
  static const double minEpsilonDistance = 0.01;
  static const double pruneMaxOffset = 0.001;

  // Field arrow shape (ElectricFieldArrowShape)
  static const double fieldArrowLength = 40.0;
  static const double fieldArrowHoleRadius = 2.0;
  static const double fieldArrowHeadHeight = 10.0;
  static const double fieldArrowHeadWidth = 16.0;
  static const double fieldArrowTailWidth = 8.0;
  static const double fieldArrowCanvasScale = 1.3;
  static const double fieldArrowRatio = 2 / 5;
}
