/// Mirrors `DisplayProperties.ts` for Buoyancy screens.
class BuoyancyDisplayProperties {
  BuoyancyDisplayProperties({
    this.canShowForces = true,
    this.supportsDepthLines = true,
    this.forcesInitiallyDisplayed = false,
    this.massValuesInitiallyDisplayed = true,
  })  : gravityForceVisible = forcesInitiallyDisplayed,
        buoyancyForceVisible = forcesInitiallyDisplayed,
        contactForceVisible = forcesInitiallyDisplayed,
        forceValuesVisible = forcesInitiallyDisplayed,
        massValuesVisible = massValuesInitiallyDisplayed,
        depthLinesVisible = false,
        vectorZoomLevel = 4;

  final bool canShowForces;
  final bool supportsDepthLines;
  final bool forcesInitiallyDisplayed;
  final bool massValuesInitiallyDisplayed;

  bool gravityForceVisible;
  bool buoyancyForceVisible;
  bool contactForceVisible;
  bool forceValuesVisible;
  bool massValuesVisible;
  bool depthLinesVisible;

  /// Integer 0..7 → `ForceVisualizationContract.zoomScales`.
  int vectorZoomLevel;

  void reset() {
    gravityForceVisible = forcesInitiallyDisplayed;
    buoyancyForceVisible = forcesInitiallyDisplayed;
    contactForceVisible = forcesInitiallyDisplayed;
    forceValuesVisible = forcesInitiallyDisplayed;
    massValuesVisible = massValuesInitiallyDisplayed;
    depthLinesVisible = false;
    vectorZoomLevel = 4;
  }
}
