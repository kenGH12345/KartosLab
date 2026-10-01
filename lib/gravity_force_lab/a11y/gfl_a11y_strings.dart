/// Source-faithful a11y strings — Gravity Force Lab Full + ISLC.
///
/// SOURCE → Flutter:
/// - MassControl.accessibleName → [mass1]/[mass2]
/// - MassDescriber.getMassAndUnit → [massAndUnit]
/// - PositionDescriber objectLabelPositionPattern → [moveObject]
/// - ISLCRulerNode measureDistanceRuler → [measureDistanceRuler]
/// - ISLCForceValuesDisplayControl / Constant Size / Reset All
class GflA11yStrings {
  GflA11yStrings._();

  static const String screen = 'Gravity Force Lab';
  static const String simulationGroup = 'Simulation';
  static const String spherePositionsGroup = 'Sphere Positions';
  static const String massControlsGroup = 'Mass Controls';

  static const String mass1 = 'Mass 1';
  static const String mass2 = 'Mass 2';

  /// `objectLabelPositionPattern`: "Move {{label}}"
  static String moveObject(String label) => 'Move $label';

  /// `massAndUnitPattern`: "{{massValue}} kilograms"
  static String massAndUnit(double kg) => '${kg.round()} kilograms';

  static const String measureDistanceRuler = 'Measure Distance Ruler';
  static const String rulerGrabbed = 'Ruler grabbed';
  static const String rulerReleased = 'Ruler released';

  static const String forceValues = 'Force Values';
  static const String forceValuesHelp = 'Choose force value representation.';
  static const String decimalNotation = 'Decimal Notation';
  static const String scientificNotation = 'Scientific Notation';
  static const String hidden = 'Hidden';
  static const String forceValuesHidden = 'Force values hidden.';
  static const String forceValuesInNewtons = 'Force values in newtons.';
  static const String forceValuesScientific =
      'Force values in newtons with scientific notation.';

  static const String constantSize = 'Constant Size';
  static const String constantSizeHelp =
      'Keep both masses the same size while changing mass.';

  static const String resetAll = 'Reset All';

  static const String keyboardHelp = 'Keyboard Shortcuts';
  static const String keyboardHelpButton = 'Keyboard Shortcuts';

  // —— Keyboard Help (Full, not Basics) ——
  static const String moveSpheresHeading = 'Move Spheres';
  static const String moveSphereLabel = 'Move sphere';
  static const String moveInSmallerSteps = 'Move in smaller steps';
  static const String moveInLargerSteps = 'Move in larger steps';
  static const String jumpToLeft = 'Jump to left';
  static const String jumpToRight = 'Jump to right';

  static const String changeMassHeading = 'Change Mass';
  static const String changeMassLabel = 'Change mass';
  static const String changeMassInSmallerSteps = 'Change mass in smaller steps';
  static const String changeMassInLargerSteps = 'Change mass in larger steps';
  static const String jumpToMinimumMass = 'Jump to minimum mass';
  static const String jumpToMaximumMass = 'Jump to maximum mass';

  static const String grabReleaseRulerHeading = 'Grab or Release Ruler';
  static const String moveOrJumpGrabbedRuler = 'Jump or Move Grabbed Ruler';
  static const String moveGrabbedRuler = 'Move grabbed ruler';
  static const String jumpStartOfSphere =
      'Jump start of ruler to center of m1 sphere (J+C)';
  static const String jumpHome =
      'Jump and release ruler to home position (J+H)';

  static const String moveSphereDescription =
      'Move sphere left or right with arrow keys.';
  static const String changeMassPDOM =
      'Change mass with left or right arrow keys.';
}
