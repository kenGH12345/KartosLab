/// Capacitor Lab: Basics — constants from PhET source.
///
/// Sources:
/// - `js/common/CLBConstants.js`
/// - `scenery-phet/js/capacitor/CapacitorConstants.js`
/// - `js/common/model/CLBModel.js` (CANVAS_RENDERING_SIZE)
/// - `scenery-phet/js/capacitor/YawPitchModelViewTransform3.js`
library;

class ClbConstants {
  ClbConstants._();

  // —— Model (CLBConstants.js) ——
  static const double epsilon0 = 8.854e-12; // F/m
  static const double worldDragMargin = 0.001; // m

  static const double batteryVoltageMin = -1.5; // V
  static const double batteryVoltageMax = 1.5;
  static const double batteryVoltageDefault = 0;
  static const double batteryVoltageSnapToZeroThreshold = 0.15;

  static const double capacitanceMin = 1e-13; // F
  static const double capacitanceMax = 3e-13;

  static const double lightBulbXSpacing = 0.023; // m
  static const double batteryX = 0.0065; // m
  static const double batteryY = 0.030; // m
  static const double batteryZ = 0;
  static const double lightBulbResistance = 5e12; // Ω

  static const double switchWireLength = 0.0064; // m
  static const double switchYSpacing = 0.0025; // m
  static const double epsilonVacuum = 1;
  static const double wireThickness = 0.0005; // m

  // —— Plate geometry (CapacitorConstants.js) ——
  static const double plateWidthMin = 0.01; // m
  static const double plateWidthMax = 0.02;
  /// Default width = √(200 mm²) = √(2e-4) m
  static const double plateWidthDefault = 0.01414213562373095; // sqrt(2e-4)
  static const double plateHeight = 0.0005; // m
  static const double plateSeparationMin = 0.002; // m
  static const double plateSeparationMax = 0.01;
  static const double plateSeparationDefault = 0.006;

  /// Capacitance screen capacitor offset from battery (CircuitConfig).
  static const double capacitanceCapacitorXSpacing = 0.024; // m
  static const double capacitanceCapacitorYSpacing = 0;

  /// Light-bulb screen offsets (CLBLightBulbModel).
  static const double lightBulbCapacitorXSpacing = 0.0180;
  static const double lightBulbCapacitorYSpacing = 0.0010;

  // —— View (CLBConstants.js) ——
  static const double dragHandleArrowLength = 45; // px
  static const double capacitanceMeterMaxValue = 2.7e-12;
  static const double plateChargeMeterMaxValue = 2.7e-12;
  static const double storedEnergyMeterMaxValue = 2.7e-12;
  static const double connectionPointRadius = 8; // px

  static const double electronCharge = 1.60218e-19; // C
  static const double minPlateCharge = 0.01e-12; // C = 1e-14

  static const int eFieldLinesMin = 1;
  static const int eFieldLinesMax = 900;

  static const int capacitanceControlExponent = -13;

  // —— Layout / MVT ——
  static const double canvasWidth = 1024;
  static const double canvasHeight = 618;
  static const double mvtScale = 12000;
  static const double mvtPitchRad = 30 * 3.141592653589793 / 180;
  static const double mvtYawRad = -45 * 3.141592653589793 / 180;

  /// Discharge / current cutoffs (LightBulbCircuit / Capacitor).
  static const double minVoltageForDischarge = 1e-3; // V

  /// Battery graphic view scale (BatteryNode.js).
  static const double batteryGraphicScale = 0.30;

  /// Battery body size (meters) — `Battery.js` BODY_SIZE
  static const double batteryBodyWidth = 0.0065;
  static const double batteryBodyHeight = 0.01425;

  /// Terminal Y offsets from battery origin — `Battery.js`
  static const double batteryPositiveTerminalYOffset =
      -(batteryBodyHeight / 2) - 0.00012;
  static const double batteryNegativeTerminalYOffset =
      -(batteryBodyHeight / 2) + 0.0006;
  static const double batteryBottomTerminalYOffset = batteryBodyHeight / 2;

  /// Slightly lower bottom wire start so probes can't enter battery —
  /// `BatteryToSwitchWire.js` bottomOffset
  static const double batteryBottomWireProbeOffset = 0.00065;

  /// Horizontal gap before switch connection — `BatteryToSwitchWire.js`
  static const double batteryToSwitchSeparationOffsetX = -0.0006;

  /// Switch geometry — `CircuitSwitch.js`
  static const double switchAngleRad = 3.141592653589793 / 4; // π/4
  /// Switch tip shortens to 0.9 × length — `CircuitSwitch.js` angleProperty link
  static const double switchWireTipScale = 0.9;

  /// Voltmeter body / probe image scales — `VoltmeterBodyNode` / `VoltmeterProbeNode`.
  static const double voltmeterBodyScale = 0.336;
  static const double voltmeterProbeScale = 0.25;
  static const double voltmeterIconBodyScale = 0.17;
  static const double voltmeterIconProbeScale = 0.10;
  /// `ToolboxPanel.js` — `includeTimer ? 0.6 : 1`.
  static const double voltmeterToolboxIconScaleWithTimer = 0.6;
  static const double voltmeterToolboxIconScaleAlone = 1.0;

  /// Switch cue arrow — `SwitchNode.js`
  static const double switchCueArrowWidth = 25;
  static const double switchCueArrowOffsetX = -80;
  static const double switchCueArrowOffsetY = -250;

  /// Asset paths under `assets/simulations/capacitor_lab_basics/`
  static const String assetVoltmeterBody =
      'assets/simulations/capacitor_lab_basics/voltmeter_body.png';
  static const String assetProbeRed =
      'assets/simulations/capacitor_lab_basics/probe_red.png';
  static const String assetProbeBlack =
      'assets/simulations/capacitor_lab_basics/probe_black.png';
  static const String assetSwitchCueArrow =
      'assets/simulations/capacitor_lab_basics/switch_cue_arrow.png';
  static const String assetLightBulbBase =
      'assets/simulations/capacitor_lab_basics/light_bulb_base.png';
  static const String assetCapacitanceScreenIcon =
      'assets/simulations/capacitor_lab_basics/capacitance_screen_icon.png';

  /// BulbNode.js view constants
  static const double bulbViewHeight = 130;
  static const double bulbViewWidth = 65;
  static const double bulbBaseViewWidth = 42;
  static const int bulbFilamentZigZags = 8;
  static const double bulbFilamentZigZagSpan = 8;
  /// LightBulbCircuitNode: view center = position + (0.002, 0, 0)
  static const double bulbViewOffsetX = 0.0020;
  /// LightBulbToSwitchWire separationOffset.x
  static const double lightBulbToSwitchSeparationOffsetX = 0.0006;
  /// Halo brightness map: |I| 0…5e-13 → scale 0…225
  static const double bulbMaxCurrentForHalo = 5e-13;
  static const double bulbMaxHaloScale = 225;

  /// BatteryGraphicNode.js canvas constants (pre-scale).
  static const double batteryPerspectiveRatio = 0.304;
  static const double batteryMainHeight = 511;
  static const double batteryMainRadius = 158;
  static const double batteryPositiveTerminalRadius = 55;
  static const double batteryPositiveTerminalHeight = 26;
  static const double batteryPositiveSideHeight = 152;
  static const double batteryNegativeTerminalRadius = 81;
  static const double batteryGraphicLineWidth = 2;

  /// Manual step dt (CLBModel.manualStep).
  static const double manualStepDt = 0.2;
  static const double slowTimeScale = 0.125;

  /// CircuitConfig.WIRE_EXTENT — `CircuitConfig.js:22`
  static const double wireExtent = 0.016; // m

  /// Voltmeter initial probe positions — `Voltmeter.js:32-33`
  static const double positiveProbeX = 0.0669;
  static const double positiveProbeY = 0.0298;
  static const double negativeProbeX = 0.0707;
  static const double negativeProbeY = 0.0329;

  /// LightBulb BULB_BASE_SIZE — `LightBulb.js:17` (model geometry, not UI)
  static const double bulbBaseWidth = 0.0050;
  static const double bulbBaseHeight = 0.0035;
}