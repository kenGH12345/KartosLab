/// Runtime config façade over [MySolarSystemConstants].
///
/// When `solar-system-common` lands, replace values here without changing
/// Controller / Painter / Widget call sites.
library;

import '../my_solar_system_constants.dart';

class SimulationConfig {
  const SimulationConfig();

  static const SimulationConfig instance = SimulationConfig();

  double get G => MySolarSystemConstants.G;
  double get engineTimeScale => MySolarSystemConstants.engineTimeScale;
  double get modelToViewTime => MySolarSystemConstants.modelToViewTime;
  int get maxPathPoints => MySolarSystemConstants.maxPathPoints;
  double get pathStrokeWidth => MySolarSystemConstants.pathStrokeWidth;

  double get massUiMin => MySolarSystemConstants.massUiMin;
  double get massUiMax => MySolarSystemConstants.massUiMax;
  double get massSliderStep => MySolarSystemConstants.massSliderStep;

  double get gridSpacing => MySolarSystemConstants.gridSpacing;
  int get gridHalfCount => MySolarSystemConstants.gridHalfCount;

  double get velocityToViewMultiplier =>
      MySolarSystemConstants.velocityToViewMultiplier;
  double get velocityMinMagnitude => MySolarSystemConstants.velocityMinMagnitude;

  double get bodyViewRadiusMin => MySolarSystemConstants.bodyViewRadiusMin;
  double get bodyViewRadiusMax => MySolarSystemConstants.bodyViewRadiusMax;
  double get bodyHitDilation => MySolarSystemConstants.bodyHitDilation;

  double get followComPositionMax => MySolarSystemConstants.followComPositionMax;
  double get followComSpeedMax => MySolarSystemConstants.followComSpeedMax;

  double zoomScaleForLevel(int level) =>
      MySolarSystemConstants.zoomScaleForLevel(level);

  double gravityArrowScale(double power) =>
      MySolarSystemConstants.gravityArrowScale(power);

  double overlayMaxWidth(double screenWidth) =>
      MySolarSystemConstants.overlayMaxWidth(screenWidth);

  double overlayBottomMaxHeight(double screenHeight, double screenWidth) =>
      MySolarSystemConstants.overlayBottomMaxHeight(screenHeight, screenWidth);

  double clampMassUi(double mass) => MySolarSystemConstants.clampMassUi(mass);
}
