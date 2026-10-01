import 'dart:math' as math;
import 'dart:ui';

/// Layout constants from PhET Intro / Systems model+view source.
class EfacLayoutConstants {
  EfacLayoutConstants._();

  // —— Systems carousel selected positions (SystemsModel.ts) ——
  static const Offset sourceSelected = Offset(-0.15, 0);
  static const Offset converterSelected = Offset(-0.025, 0);
  static const Offset userSelected = Offset(0.09, 0);

  // —— Biker.ts / BikerNode.ts ——
  static const double rearWheelRadius = 0.021;
  static const Offset centerOfGearOffset = Offset(0.0058, -0.006);
  static const Offset centerOfBackWheelOffset = Offset(0.035, -0.01);
  static const double bikerImageScale = 0.490;
  static const double bicycleSystemRightOffset = 123;
  static const double bicycleSystemTopOffset = -249;

  // —— Generator.ts / GeneratorNode.ts ——
  static const double generatorWheelRadius = 0.039;
  static const Offset generatorWheelCenterOffset = Offset(0, 0.03);
  static const double spokesAndPaddlesCenterYOffset = -65;
  static const double generatorImageLeft = -107;
  static const double generatorImageTop = -165;
  static const double wireImageScale = 0.48;

  // —— BeakerHeaterNode.ts / BeakerHeater.ts ——
  static const double coilCenterXOffset = -4;
  static const double coilTopOffset = 15;
  static const double wireStraightLeft = -111;
  static const double wireStraightTop = 78;
  static const double elementBaseWidth = 72;
  static const double heaterElement2dHeight = 0.027; // model meters
  static const double beakerWidth = 0.075;
  static const double beakerHeight = beakerWidth * 1.1;
  static const Offset beakerOffset = Offset(0, 0.016);
  /// Thermometer tip relative to BeakerHeater model origin.
  static const Offset beakerThermometerOffset =
      Offset(beakerWidth * 0.45, beakerHeight * 0.6);

  // Intrinsic PNG sizes (assets/energy_forms_and_changes)
  static const Size wireStraightNative = Size(133, 50);
  static const Size wireBottomRightShortNative = Size(133, 235);
  static const Size wireBottomLeftNative = Size(133, 277);
  static const Size solarPanelNative = Size(389, 188);
  static const Size solarPanelPostNative = Size(62, 70);
  static const Size solarPanelGenNative = Size(142, 122);
  static const Size connectorNative = Size(46, 72);

  /// SolarPanel.ts PANEL_SIZE / PANEL_CONNECTOR_OFFSET (meters).
  static const Size solarPanelModelSize = Size(0.15, 0.07);
  static const Offset solarPanelConnectorOffset = Offset(0.015, 0);

  // —— Belt wheel centers (SystemsModel.ts:152-155) ——
  static Offset get beltWheel1Center =>
      sourceSelected + centerOfBackWheelOffset;
  static Offset get beltWheel2Center =>
      converterSelected + generatorWheelCenterOffset;

  // —— Intro / BurnerStand / HeaterCooler ——
  static const double edgeInset = 10;
  static const double gasPipeScale = 0.4;
  static const double gasPipeRightFromHeaterLeft = 15;
  static const double gasPipeBottomFromHeaterBottom = 6;
  static const double burnerStandPerspectiveAngle = math.pi / 4;
  static const double heaterWidthDivisor = 1.5;
  static const double heaterCoolerDefaultWidth = 120;
  static const double heaterCoolerOpeningHeightScale = 0.1;

  /// PhET `EFACQueryParameters.showSpeedControls` — flag, default off.
  /// When false, TimeControl shows Play/Pause + Step only (matches Original).
  static const bool showSpeedControls = false;
}
