/// Shared constants — port of PhET `FrictionConstants.js` + model literals.
library;

import 'package:flutter/material.dart';

class FrictionConstants {
  FrictionConstants._();

  // Layout (friction-main.js) — do not change (PhET-iO / visual lock).
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;

  // Book colors (macro / magnified backgrounds / atoms)
  static const Color topBookColorMacro = Color.fromRGBO(125, 226, 249, 1);
  static const Color topBookColor = Color.fromRGBO(125, 226, 249, 1);
  static const Color topBookAtomsColor = Color.fromRGBO(0, 255, 255, 1);
  static const Color bottomBookColorMacro = Color.fromRGBO(183, 255, 181, 1);
  static const Color bottomBookColor = Color.fromRGBO(187, 255, 187, 1);
  static const Color bottomBookAtomsColor = Color.fromRGBO(0, 255, 0, 1);
  static const Color bookTextColor = Color(0xFF404040);

  static const double atomRadius = 7;
  static const double initialAtomSpacingX = 20;
  static const double initialAtomSpacingY = 20;

  static const double magnifierWindowWidth = 690;
  static const double magnifierWindowHeight = 300;
  static const double magnifierCornerRadius = 30;
  static const double magnifierScale = 0.05; // target rect relative to window

  // CoverNode geometry
  static const double bindingLength = 200;
  static const double bindingWidth = 30;
  static const double coverRound = 5;
  static const int coverPages = 8;
  static const double bookCoverWidth = 75;
  static const double coverAngle = 3.141592653589793 / 12; // Math.PI / 12
  static const double bookTitleFontSize = 22;

  // Book placements (FrictionScreenView).
  // PhET BookNode is at (x,y) AND CoverNode also applies the same (x,y) as a
  // child offset → screen position is 2×. Using the effective screen origins
  // so books sit below the magnifier (not hidden behind it).
  static const Offset bottomBookNodeOrigin = Offset(50, 225);
  static const Offset topBookNodeOrigin = Offset(65, 209);
  static const Offset bottomBookOrigin = Offset(100, 450); // 50+50, 225+225
  static const Offset topBookOrigin = Offset(130, 418); // 65+65, 209+209
  static const Offset magnifierOrigin = Offset(40, 25);
  // ThermometerNode (x,y) = bulb center (FrictionScreenView)
  static const Offset thermometerBulbCenter = Offset(690, 250);

  // MagnifierTargetNode target on book interface (MagnifierNode ctor args)
  static const double magnifierTargetX = 195;
  static const double magnifierTargetY = 425;

  // ThermometerNode options from FrictionScreenView
  static const double thermometerTubeHeight = 160;
  static const double thermometerTickSpacing = 9;
  static const double thermometerLineWidth = 1;
  static const double thermometerTubeWidth = 12;
  static const double thermometerBulbDiameter = 24;
  static const double thermometerGlassThickness = 3;
  static const double thermometerMajorTickLength = 4;
  static const Color thermometerFluidMain = Color.fromRGBO(237, 28, 36, 1);
  static const Color thermometerFluidHighlight = Color.fromRGBO(240, 150, 150, 1);

  // ResetAllButton
  static const double resetAllRadius = 22;

  // Model constants (FrictionModel.js)
  static const double atomSpacingY = 20;
  static const double initialAtomSpacingYBooks = 25; // INITIAL_ATOM_SPACING_Y in model
  static const double vibrationAmplitudeMin = 1;
  static const double amplitudeShearOff = 7;
  static const double vibrationAmplitudeMax = 12;
  static const double coolingRate = 0.2;
  static const double heatingMultiplier = 0.0075;
  static const double shearOffAmplitudeReduction = 0.01;
  static const double maxXDisplacement = 600;
  static const double minYPosition = -70;
  static const double defaultRowStartX = 50;
  static const double bookDraggingScaleFactor = 0.025;
  static const double shearOffSpeed = 400;
  static const double amplitudeSettledThreshold = vibrationAmplitudeMin + 0.4;

  // Thermometer mapping
  static const double thermometerMinTemp = vibrationAmplitudeMin - 1.05; // ~ -0.05
  static const double thermometerMaxTemp = amplitudeShearOff * 1.1; // ~7.7

  // Keyboard drag (FrictionKeyboardDragListener)
  static const double keyboardDragSpeed = 1000; // model units / s
  static const double keyboardShiftDragSpeed = 500;

  // Atom canvas rendering (AtomCanvasNode)
  static const double particleImageSizeForRendering = atomRadius * 2 * 1.2;
  static const double atomHighlightFactor = 0.7;
  static const double atomStrokeWidth = 2;

  // Pentatonic playback rates for break-off sound
  static const List<double> majorPentatonicPlaybackRates = [
    1.0,
    1.122462048309373, // 2^(2/12)
    1.2599210498948732, // 2^(4/12)
    1.4983070768766815, // 2^(7/12)
    1.681792830507429, // 2^(9/12)
  ];
}
