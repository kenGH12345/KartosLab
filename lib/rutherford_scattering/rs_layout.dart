import 'dart:ui';

/// Layout geometry derived from PhET `RSBaseScreenView.ts` + `RSConstants.ts`
/// for ScreenView layoutBounds 1024×618.
///
/// Source formulas (do not invent offsets):
/// - gun: left = layout.left+75, top = layout.centerY+50
/// - LaserPointer body 75×68 + nozzle 20×60, rotated −π/2 → ~68×95
/// - beam: 40×110, centerX=gun.centerX, bottom=gun.top
/// - foil: TargetMaterialNode 120×30, centerX=beam.centerX, bottom=beam.top
/// - space: x = foil.right + TARGET_SPACE_MARGIN − SPACE_BUFFER,
///          y = PANEL_TOP_MARGIN − SPACE_BUFFER, size 510²
/// - panels: left = space.right + PANEL_SPACE_MARGIN, top = space.top
/// - scene radio: left = foil.left, top = space.top, vertical spacing 15
class RsLayout {
  RsLayout._();

  static const double layoutW = 1024;
  static const double layoutH = 618;

  // --- LaserPointer after −π/2 (pointing up) ---
  // Unrotated: length 95 (75+20), height 68 → rotated: width 68, height 95
  static const double gunW = 68;
  static const double gunH = 95;
  static const double gunLeft = 75;
  static const double gunTop = 309 + 50; // centerY(309)+50
  static const double gunCenterX = gunLeft + gunW / 2; // 109

  // --- Beam ---
  static const double beamW = 40;
  static const double beamH = 110;
  static const double beamLeft = gunCenterX - beamW / 2; // 89
  static const double beamBottom = gunTop; // 359
  static const double beamTop = beamBottom - beamH; // 249

  // --- Foil (TargetMaterialNode path height = BACK_DEPTH 30, width 120) ---
  static const double foilW = 120;
  static const double foilH = 30;
  static const double foilLeft = gunCenterX - foilW / 2; // 49
  static const double foilBottom = beamTop; // 249
  static const double foilTop = foilBottom - foilH; // 219
  static const double foilCenterX = gunCenterX;
  static const double foilCenterY = foilTop + foilH / 2; // 234
  static const double foilRight = foilLeft + foilW; // 169

  // --- Observation space ---
  static const double spaceSize = 510;
  static const double spaceBuffer = 10;
  static const double targetSpaceMargin = 50;
  static const double panelTopMargin = 15;
  static const double spaceLeft =
      foilRight + targetSpaceMargin - spaceBuffer; // 209
  static const double spaceTop = panelTopMargin - spaceBuffer; // 5
  static const double spaceRight = spaceLeft + spaceSize; // 719
  static const double spaceBottom = spaceTop + spaceSize; // 515
  static const double spaceCenterX = spaceLeft + spaceSize / 2; // 464

  // --- Control panels ---
  static const double panelSpaceMargin = 35;
  static const double panelLeft = spaceRight + panelSpaceMargin; // 754
  static const double panelTop = spaceTop; // 5
  static const double panelWidth = 240;

  // --- Scene radio (left of foil / above space) ---
  static const double sceneLeft = foilLeft; // 49
  static const double sceneTop = spaceTop; // 5
  static const double sceneSpacing = 15;
  static const double sceneButtonSize = 56;

  // --- Scale label / time / reset ---
  static const double scaleLabelTop = spaceBottom + 10; // 525
  static const double timeCenterX = spaceCenterX - 5; // 459
  static const double timeBottom = scaleLabelTop + 20 + 60; // ~605
  static const double resetRight = layoutW - 48; // 976
  static const double resetBottom = layoutH - 20; // 598

  // --- Slider geometry (RSConstants.PANEL_SLIDER_THUMB_DIMENSION) ---
  static const Size sliderThumb = Size(15, 30);
  static const double sliderTrackHeight = 1;
  static const double sliderTrackWidthFactor = 0.75; // of panel minWidth 230

  /// Energy thumb — PhET sun HSlider default blue.
  static const Color energyThumb = Color(0xFF3291B8);
  static const Color energyThumbHighlight = Color(0xFF64B4D4);

  /// Protons thumb — AtomPropertiesPanel `rgb(220, 58, 10)`.
  static const Color protonsThumb = Color(0xFFDC3A0A);
  static const Color protonsThumbHighlight = Color(0xFFFF6C3C);

  /// Neutrons thumb — `rgb(130, 130, 130)`.
  static const Color neutronsThumb = Color(0xFF828282);
  static const Color neutronsThumbHighlight = Color(0xFFB4B4B4);

  static Rect get spaceRect =>
      const Rect.fromLTWH(spaceLeft, spaceTop, spaceSize, spaceSize);
}
