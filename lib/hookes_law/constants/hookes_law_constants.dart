/// Numeric constants from `js/common/HookesLawConstants.ts`.
///
/// Slider and arrow steps are applied by the control that writes the model
/// (PhET `NumberControl` / drag listener), not by every property write.
/// They live here so later phases do not invent new intervals.
class HookesLawConstants {
  const HookesLawConstants._();

  /// `toFixedNumber(appliedForce, 10)` in `Spring.ts`.
  static const int forceFromDisplacementDecimalPlaces = 10;

  static const int appliedForceDecimalPlaces = 1;
  static const int springForceDecimalPlaces = appliedForceDecimalPlaces;
  static const int seriesSpringForceComponentsDecimalPlaces =
      appliedForceDecimalPlaces;
  static const int parallelSpringForceComponentsDecimalPlaces =
      appliedForceDecimalPlaces + 1;
  static const int springConstantDecimalPlaces = 0;
  static const int displacementDecimalPlaces = 3;
  static const int energyDecimalPlaces = 2;

  /// Robotic-hand drag snap, metres. `ROBOTIC_ARM_DISPLACEMENT_INTERVAL`.
  static const double roboticArmDisplacementInterval = 0.01;

  // Applied-force NumberControl (`AppliedForceControl.ts`), newtons.
  static const double appliedForceSliderInterval = 5;
  static const double appliedForceArrowInterval = 1;
  static const double appliedForceKeyboardStep = 10;
  static const double appliedForceShiftKeyboardStep = appliedForceArrowInterval;
  static const double appliedForcePageKeyboardStep = 25;

  // Spring-constant NumberControl (`SpringConstantControl.ts`), N/m.
  static const double springConstantSliderInterval = 10;
  static const double springConstantArrowInterval = 1;
  static const double springConstantKeyboardStep = 20;
  static const double springConstantShiftKeyboardStep =
      springConstantArrowInterval;
  static const double springConstantPageKeyboardStep = 100;

  // Displacement NumberControl (`DisplacementControl.ts`), metres.
  static const double displacementSliderInterval = 0.05;
  static const double displacementArrowInterval = 0.01;
  static const double displacementKeyboardStep = 0.10;
  static const double displacementShiftKeyboardStep =
      displacementArrowInterval;
  static const double displacementPageKeyboardStep = 0.20;

  /// View length of 1 m. Not a [ModelViewTransform2]; the sim is 1-D.
  static const double unitDisplacementX = 225;

  /// View length of 1 N on the play-area force arrow.
  static const double unitForceX = 1.45;

  /// View length of 1 N on the Energy force plot (y).
  static const double unitForceY = 0.25;

  /// View length of 1 J.
  static const double unitEnergyY = 1.1;

  /// Energy screen play-area applied-force arrow, view length of 1 N.
  static const double energyUnitForceX = 0.4;

  static const double forceYAxisLength = 250;
  static const double energyYAxisLength = 250;

  /// joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` at SHA `bb6a94e0…`.
  /// IntroScreenView does not override it.
  static const double layoutBoundsWidth = 1024;
  static const double layoutBoundsHeight = 618;

  /// joist `HomeScreenView.LAYOUT_BOUNDS`. Not the Intro stage.
  static const double homeScreenLayoutWidth = 768;
  static const double homeScreenLayoutHeight = 504;

  /// joist `NavigationBar.NAVIGATION_BAR_SIZE.height`.
  /// Chrome sits outside the ScreenView. Not drawn in this phase.
  static const double navigationBarHeight = 40;

  static const double wallWidth = 25;
  static const double wallHeight = 170;
  static const double wallCornerRadius = 6;

  static const double vectorHeadWidth = 20;
  static const double vectorHeadHeight = 10;
  static const double forceTailWidth = 10;

  static const double sliderThumbWidth = 17;
  static const double sliderThumbHeight = 34;
  static const double sliderTrackWidth = 180;
  static const double sliderTrackHeight = 3;
  static const double sliderMajorTickLength = 20;

  static const int singleSpringLoops = 12;
  static const int springPointsPerLoop = 40;
  static const double springRadius = 10;
  static const double springAspectRatio = 4;
  static const double springLeftEndLength = 15;
  static const double springRightEndLength = 25;
  static const double springMinLineWidth = 3;
  static const double springDeltaLineWidth = 0.005;

  static const double nibWidth = 10;
  static const double nibHeight = 8;
  static const double nibCornerRadius = 2;

  static const double introSystemLeft = 15;
  static const double introControlsRightMargin = 10;
  static const double introControlsTopMargin = 10;
  static const double introControlsSpacing = 10;
  static const double introResetMargin = 15;
  static const double resetAllButtonRadius = 20.5;

  /// `IntroSystemNode`: controls sit this far below the wall.
  static const double introControlsGapBelowWall = 10;

  /// Force-vector node bottom is this far above the spring origin.
  static const double introForceVectorGap = 50;

  /// Displacement-vector node top is this far below the spring origin.
  static const double introDisplacementVectorGap = 50;

  /// Play column (wall) plus the control row. Must stay ≤ layout height / 2
  /// (`IntroScreenView` asserts `systemNode.height <= layoutBounds.height / 2`).
  static const double introPlayHeight = wallHeight;
  static const double introControlsBlockHeight = 118;
  static const double introSystemHeight =
      introPlayHeight + introControlsGapBelowWall + introControlsBlockHeight;

  /// Width of one system column. Wall left is the column's x = 0.
  /// Attachment (spring left) is [wallWidth] into the column.
  static const double introSystemWidth = 750;

  static const double introAnimationSeconds = 0.5;

  static const double checkboxBoxWidth = 18;
  static const double checkboxSpacing = 8;
  static const double visibilityPanelSpacing = 20;
  static const double visibilityPanelMargin = 15;
  static const double springPanelXMargin = 20;
  static const double springPanelYMargin = 5;

  static const double controlFontSize = 18;
  static const double majorTickFontSize = 14;

  static const double gripperRadius = 35;
  static const double gripperLineWidth = 6;
  static const double gripperOverlap = 2;

  static const double armHeight = 14;
  static const double armRedBoxWidth = 7;
  static const double armRedBoxHeight = 30;
  static const double armGradientBoxWidth = 20;
  static const double armGradientBoxHeight = 60;
  static const double armOverlap = 10;

  /// Systems screen. Same 1024×618 stage as Intro. `SystemsScreenView.ts`.
  static const double systemsSystemLeft = 30;
  static const double systemsControlsGapBelowWall = 25;
  static const double parallelWallHeight = 300;
  static const double systemsSpringConstantTrackWidth = 120;
  static const int seriesSpringLoops = 8;
  static const int parallelSpringLoops = 8;
  static const double parallelTopSpringFraction = 0.25;
  static const double parallelForceAboveTopSpring = 80;
  static const double seriesForceAboveAxis = 65;
  static const double seriesComponentStackGap = 10;
  static const double trussLineWidth = 4;
  static const double trussOverlap = 10;

  /// spring1 / spring2 from `HookesLawColors.ts`. Parallel top and series left
  /// are spring1 (purple). Parallel bottom and series right are spring2 (yellow).
  static const int spring1FrontR = 221;
  static const int spring1FrontG = 191;
  static const int spring1FrontB = 255;
  static const int spring1MiddleR = 146;
  static const int spring1MiddleG = 64;
  static const int spring1MiddleB = 255;
  static const int spring1BackR = 124;
  static const int spring1BackG = 54;
  static const int spring1BackB = 217;
  static const int spring2FrontR = 255;
  static const int spring2FrontG = 223;
  static const int spring2FrontB = 127;
  static const int spring2MiddleR = 255;
  static const int spring2MiddleG = 191;
  static const int spring2MiddleB = 0;
  static const int spring2BackR = 217;
  static const int spring2BackG = 163;
  static const int spring2BackB = 0;

  /// Energy screen. Same 1024×618 stage. `EnergyScreenView.ts`.
  /// The system node's left bound is 35; its local origin is the wall's
  /// right-center, so the attachment sits 25 px to the right of that bound.
  static const double energySystemLeft = 35;
  static const double energySystemBottomMargin = 10;
  static const double energyControlsGapBelowWall = 10;
  static const double energyBarGapAboveSystem = 35;
  static const double energyBarWidth = 20;
  static const double energyBarAxisLengthFactor = 1.65;
  static const double energyPlotDomainFactor = 1.1;
  static const double energyBarWhenPlotLeft = 15;
  static const double energyPlotLineWidth = 3;
  static const double energyPointRadius = 5;
  static const double energySceneForceAboveAxis = 50;
}
