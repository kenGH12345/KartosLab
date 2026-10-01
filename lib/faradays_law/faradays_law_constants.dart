import 'dart:ui' show Offset, Rect, Size;

/// Constants from PhET `FaradaysLawConstants.js` + Coil / Voltmeter / FieldLines.
abstract final class FaradaysLawConstants {
  /// `LAYOUT_BOUNDS` — 834 × 504
  static final Size layoutSize = const Size(834, 504);
  static final Rect layoutBounds = Rect.fromLTWH(0, 0, 834, 504);

  static const Offset bulbPosition = Offset(190, 200);
  static final Offset voltmeterPosition = bulbPosition - const Offset(0, 120);

  static const double magnetHeight = 30;
  static const double magnetWidth = 140;
  static const Offset defaultMagnetPosition = Offset(647, 200);

  static const Offset topCoilPosition = Offset(422, 110);
  static const Offset bottomCoilPosition = Offset(448, 310);

  /// `Coil.js` — transition from B=constant to power law (pixels).
  static const double nearFieldRadius = 50;

  static const int bottomCoilSpirals = 4;
  static const int topCoilSpirals = 2;

  /// Joist `Screen` option on `FaradaysLawScreen`.
  static const double maxDt = 0.1;

  /// `Voltmeter.js`
  static const double emfToSignalScale = 0.2;
  static const double needleResponsiveness = 50;
  static const double needleFriction = 10;
  static const double activityThreshold = 1e-3;

  /// `VoltmeterGauge.js` needle clamp.
  static const double needleMinAngle = -1.5707963267948966; // -π/2
  static const double needleMaxAngle = 1.5707963267948966; // π/2

  /// `BulbNode.js` — halo scale = 20 * |voltage|; hidden if scale < 0.1
  static const double bulbHaloScaleFactor = 20;
  static const double bulbHaloVisibilityThreshold = 0.1;

  /// Coil restricted zones (`FaradaysLawModel.js`).
  static const double coilRestrictedAreaHeight = 12;
  static const double topCoilRestrictedAreaWidth = 25;
  static const double bottomCoilRestrictedAreaWidth = 55;

  /// Background `rgb(151, 208, 255)`.
  static const int backgroundColorValue = 0xFF97D0FF;

  /// ResetAllButton scale in ControlPanelNode.
  static const double resetAllButtonScale = 0.75;

  // —— View / CoilNode.js ——
  static const double coilImageScale = 1 / 3;
  static const double coilXOffset = 8;
  static const double coilTwoOffset = 8;

  static const Offset fourCoilTopEnd = Offset(0, -10);
  static const Offset fourCoilBottomEnd = Offset(70, 6);
  static const Offset twoCoilTopEnd = Offset(30, -10);
  static const Offset twoCoilBottomEnd = Offset(60, 6);

  /// `BulbNode.js`
  static const double bulbXDisplacement = -45;
  static const double bulbBaseWidth = 36;
  static const double bulbBodyHeight = 80; // 125 - 45
  static const double bulbWidth = 65;

  /// `CoilsWiresNode.js`
  static const int wireColorValue = 0xFF7F3521;
  static const double wireWidth = 3;
  static const double wireArcRadius = 7;

  /// `VoltmeterWiresNode.js`
  static const int voltmeterWireColorValue = 0xFF353A89;

  /// Magnet 3D appearance (`MagnetNode.js`)
  static const double magnetOffsetDxRatio = 1 / 35;
  static const double magnetOffsetDyRatio = 1 / 15;
  static const double magnet3dShadowAmount = 0.4;
  static const int magnetNorthColorValue = 0xFFDB1E21;
  static const int magnetSouthColorValue = 0xFF354D9A;

  /// Drag hint arrows (`MagnetMovementArrowsNode.js`)
  static const int magnetArrowFillValue = 0xFFB2FCB7;
  static const double magnetArrowDistance = 12;

  /// Field line stroke (`MagnetFieldLines.js`)
  static const int fieldLineStrokeValue = 0xFFFFFFFF;
  static const double fieldLineStrokeWidth = 3;
  static const double fieldLineArrowWidth = 16;
  static const double fieldLineArrowHeight = 18;
}
